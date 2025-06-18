CLASS zcl_acb_unit_updater DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES: BEGIN OF unit_mapping_line,
             old_unit TYPE zacb_ingredient_unit,
             new_unit TYPE zacb_ingredient_unit,
           END OF unit_mapping_line.
    TYPES unit_mapping_tab TYPE SORTED TABLE OF unit_mapping_line WITH UNIQUE KEY old_unit.
    TYPES unit_range       TYPE RANGE OF zacb_ingredient_unit.

    DATA out TYPE REF TO if_oo_adt_classrun_out.

    METHODS update_units_db.
    METHODS update_units_eml.
    METHODS output_change_documents.

    METHODS get_old_unit_rnge_from_mapping IMPORTING unit_mapping  TYPE unit_mapping_tab
                                           RETURNING VALUE(result) TYPE unit_range.
ENDCLASS.


CLASS zcl_acb_unit_updater IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    me->out = out.

    out->write( |🍽️ Massenänderung von Mengeneinheiten| ).

    update_units_db( ).
    update_units_eml( ).
    output_change_documents( ).
  ENDMETHOD.

  METHOD update_units_db.
    DATA(mapping) = VALUE unit_mapping_tab( ( old_unit = 'G' new_unit = 'GR' ) ).
    DATA(unit_filter) = get_old_unit_rnge_from_mapping( mapping ).

    SELECT FROM zacb_ingredient
      FIELDS DISTINCT recipe_id
      WHERE unit IN @unit_filter
      ORDER BY recipe_id
      INTO TABLE @DATA(recipes_to_update).

    out->write( |Es wurden { lines( recipes_to_update ) NUMBER = USER }| &&
      | zu aktualisierende Rezepte gefunden (DB)| ).

    LOOP AT recipes_to_update ASSIGNING FIELD-SYMBOL(<recipe>).
      TRY.
          out->write( |Bearbeite Rezept { <recipe>-recipe_id }| ).

          SELECT SINGLE FROM zacb_recipe
            FIELDS *
            WHERE recipe_id  = @<recipe>-recipe_id
            INTO @DATA(recipe_old).
          SELECT FROM zacb_ingredient
            FIELDS *
            WHERE recipe_id  = @<recipe>-recipe_id
              AND unit      IN @unit_filter
            ORDER BY PRIMARY KEY
            INTO TABLE @DATA(ingredients_old).
          IF recipe_old IS INITIAL OR ingredients_old IS INITIAL.
            cl_message_helper=>set_msg_vars_for_clike( |Überspringe Rezept, parallele Änderungen| ).
            RAISE EXCEPTION TYPE lcx_error USING MESSAGE.
          ENDIF.

          DATA(recipe_new) = VALUE #( BASE recipe_old
                                      last_changed_by = cl_abap_context_info=>get_user_technical_name( )
                                      last_changed_at = cl_abap_tstmp=>utclong2tstmp( utclong_current( ) ) ).

          DATA(ingredients_new) = ingredients_old.
          LOOP AT ingredients_new ASSIGNING FIELD-SYMBOL(<ingredient>).
            <ingredient>-unit                  = mapping[ old_unit = <ingredient>-unit ]-new_unit.
            <ingredient>-last_changed_by       = cl_abap_context_info=>get_user_technical_name( ).
            <ingredient>-last_changed_at       = cl_abap_tstmp=>utclong2tstmp( utclong_current( ) ).
            <ingredient>-local_last_changed_by = <ingredient>-last_changed_by.
            <ingredient>-local_last_changed_at = <ingredient>-last_changed_at.
          ENDLOOP.

          UPDATE zacb_recipe FROM @recipe_new.
          IF sy-subrc <> 0.
            cl_message_helper=>set_msg_vars_for_clike(
              |Fehler bei Update auf ZACB_RECIPE: { sy-subrc }| ).
            RAISE EXCEPTION TYPE lcx_error USING MESSAGE.
          ENDIF.

          UPDATE zacb_ingredient FROM TABLE @ingredients_new.
          IF sy-subrc <> 0.
            cl_message_helper=>set_msg_vars_for_clike(
              |Fehler bei Update auf ZACB_INGREDIENT: { sy-subrc }| ).
            RAISE EXCEPTION TYPE lcx_error USING MESSAGE.
          ENDIF.

          DATA(object_id) = EXACT if_chdo_object_tools_rel=>ty_cdobjectv(
            sy-mandt && <recipe>-recipe_id ).

          zcl_zacb_recipe_chdo=>write(
            objectid            = object_id
            utime               = cl_abap_context_info=>get_system_time( )
            udate               = cl_abap_context_info=>get_system_date( )
            username            = EXACT #( cl_abap_context_info=>get_user_technical_name( ) )
            o_zacb_recipe       = recipe_old
            n_zacb_recipe       = recipe_new
            upd_zacb_recipe     = 'U'
            xzacb_ingredient    = CORRESPONDING #( ingredients_new )
            yzacb_ingredient    = CORRESPONDING #( ingredients_old )
            upd_zacb_ingredient = 'U' ).

          COMMIT WORK.

        CATCH cx_chdo_write_error
              lcx_error INTO DATA(error).
          ROLLBACK WORK.
          out->write( error->get_text( ) ).
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD update_units_eml.
    DATA unit_updates TYPE TABLE FOR UPDATE ZACB_R_Ingredient.

    DATA(mapping) = VALUE unit_mapping_tab( ( old_unit = 'GR' new_unit = 'G' ) ).
    DATA(unit_filter) = get_old_unit_rnge_from_mapping( mapping ).

    SELECT FROM ZACB_R_Ingredient
      FIELDS DISTINCT RecipeId
      WHERE Unit IN @unit_filter
      ORDER BY RecipeId
      INTO TABLE @DATA(recipes_to_update).

    out->write( |Es wurden { lines( recipes_to_update ) NUMBER = USER }| &&
      | zu aktualisierende Rezepte gefunden (EML)| ).

    IF recipes_to_update IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF ZACB_R_Recipe
      ENTITY Recipe BY \_Ingredient
      FIELDS ( Unit )
      WITH CORRESPONDING #( recipes_to_update )
      RESULT DATA(ingredients).

    unit_updates = CORRESPONDING #( ingredients ).
    LOOP AT unit_updates ASSIGNING FIELD-SYMBOL(<update>) WHERE Unit IN unit_filter.
      <update>-Unit = mapping[ old_unit = <update>-Unit ]-new_unit.
    ENDLOOP.

    MODIFY ENTITIES OF ZACB_R_Recipe
      ENTITY Ingredient
      UPDATE FIELDS ( Unit )
      WITH unit_updates
      REPORTED DATA(reported)
      FAILED DATA(failed).

    LOOP AT reported-recipe ASSIGNING FIELD-SYMBOL(<reported>).
      out->write( <reported>-%msg->if_message~get_text( ) ).
    ENDLOOP.

    IF failed IS NOT INITIAL.
      ROLLBACK ENTITIES.
    ELSE.
      COMMIT ENTITIES RESPONSE OF ZACB_R_Recipe
        REPORTED DATA(reported_late)
        FAILED DATA(failed_late).
      LOOP AT reported_late-recipe ASSIGNING FIELD-SYMBOL(<reported_late>).
        out->write( |{ <reported_late>-%key-RecipeId }:| &&
          <reported_late>-%msg->if_message~get_text( ) ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD output_change_documents.
    TRY.
        cl_chdo_read_tools=>changedocument_read(
          EXPORTING
            i_objectclass    = zcl_zacb_recipe_chdo=>objectclass
            i_date_of_change = cl_abap_context_info=>get_system_date( )
          IMPORTING
            et_cdredadd_tab  = DATA(change_document_lines) ).
        out->write( change_document_lines ).
      CATCH cx_chdo_read_error INTO DATA(error).
        out->write( error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_old_unit_rnge_from_mapping.
    RETURN VALUE #( FOR u IN unit_mapping
                    ( sign   = cl_abap_range=>sign-including
                      option = cl_abap_range=>option-equal
                      low    = u-old_unit ) ).
  ENDMETHOD.
ENDCLASS.
