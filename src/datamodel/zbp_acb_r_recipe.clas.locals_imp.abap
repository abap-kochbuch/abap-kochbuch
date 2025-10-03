CLASS lhc_review DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS:
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE Review,
      precheck_delete FOR PRECHECK
        IMPORTING keys FOR DELETE Review.

ENDCLASS.

CLASS lhc_review IMPLEMENTATION.

  METHOD precheck_delete.
    DATA(myself) = cl_abap_context_info=>get_user_technical_name( ).
    LOOP AT keys INTO DATA(entity).

      SELECT FROM zacb_user FIELDS COUNT( * )
      WHERE username = @myself AND admin = @abap_true.

      IF sy-dbcnt = 0.
        APPEND VALUE #(  %tky =  entity-%tky ) TO failed-review.

        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = 'Nur Admin dürfen Reviews löschen...'
                        ) ) TO reported-review.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

    METHOD precheck_update.
    DATA(myself) = cl_abap_context_info=>get_user_technical_name( ).
    LOOP AT entities INTO DATA(entity).


      SELECT SINGLE FROM zacb_review
      FIELDS created_by
      WHERE review_id = @entity-ReviewId
      INTO @DATA(created_by).

      IF created_by IS NOT INITIAL AND created_by <> myself.
          APPEND VALUE #(  %tky =  entity-%tky ) TO failed-review.

          APPEND VALUE #( %tky = entity-%tky
                          %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Keine Berechtigung zum Ändern von anderen Reviews'
                          ) ) TO reported-review.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ingredient DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS:
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE Ingredient,
      precheck_delete FOR PRECHECK
        IMPORTING keys FOR DELETE Ingredient.

ENDCLASS.

CLASS lhc_ingredient IMPLEMENTATION.

  METHOD precheck_update.
    DATA(myself) = cl_abap_context_info=>get_user_technical_name( ).
    LOOP AT entities INTO DATA(entity).

      SELECT SINGLE FROM zacb_ingredient
      FIELDS created_by
      WHERE ingredient_id = @entity-IngredientId
      INTO @DATA(created_by).

      IF created_by IS NOT INITIAL AND created_by <> myself.
        IF sy-dbcnt = 0.
          APPEND VALUE #(  %tky =  entity-%tky ) TO failed-ingredient.

          APPEND VALUE #( %tky = entity-%tky
                          %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Sie dürfen hier keine Zutaten hinzufügen...'
                          ) ) TO reported-ingredient.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_delete.
    DATA(myself) = cl_abap_context_info=>get_user_technical_name( ).
    LOOP AT keys INTO DATA(entity).

      READ ENTITIES OF zacb_r_recipe IN LOCAL MODE
      ENTITY Recipe
      FIELDS ( CreatedBy ) WITH VALUE #( ( %key = entity-%key ) )
      RESULT DATA(recipes).

      LOOP AT recipes INTO DATA(recipe).

        IF myself <> recipe-CreatedBy.
          APPEND VALUE #(  %tky =  entity-%tky ) TO failed-ingredient.

          APPEND VALUE #( %tky = entity-%tky
                          %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Sie dürfen hier keine Zutaten löschen...'
                          ) ) TO reported-ingredient.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zacb_r_recipe DEFINITION INHERITING FROM cl_abap_behavior_saver_failed.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_zacb_r_recipe IMPLEMENTATION.
  METHOD save_modified.
    TYPES ingredient_tab TYPE SORTED TABLE OF zacb_ingredient WITH UNIQUE KEY recipe_id ingredient_id.
    TYPES: BEGIN OF recipe_change_line,
             recipe_id        TYPE zacb_recipe_id,
             change_indicator TYPE if_chdo_object_tools_rel=>ty_cdchngindh,
             recipe_old       TYPE zacb_recipe,
             recipe_new       TYPE zacb_recipe,
             ingredients_old  TYPE ingredient_tab,
             ingredients_new  TYPE ingredient_tab,
           END OF recipe_change_line.
    DATA changes TYPE SORTED TABLE OF recipe_change_line WITH UNIQUE KEY recipe_id.
    FIELD-SYMBOLS <change> LIKE LINE OF changes.

    LOOP AT create-recipe ASSIGNING FIELD-SYMBOL(<create_recipe>).
      INSERT VALUE #(
        recipe_id        = <create_recipe>-RecipeId
        change_indicator = 'I'
        recipe_new       = CORRESPONDING #( <create_recipe> MAPPING FROM ENTITY USING CONTROL )
      ) INTO TABLE changes.
      ASSERT sy-subrc = 0.
    ENDLOOP.

    LOOP AT update-recipe ASSIGNING FIELD-SYMBOL(<update_recipe>).
      ASSERT NOT line_exists( changes[ recipe_id = <update_recipe>-RecipeId ] ).

      INSERT VALUE #(
        recipe_id        = <update_recipe>-RecipeId
        change_indicator = 'U'
      ) INTO TABLE changes ASSIGNING <change>.
      ASSERT sy-subrc = 0.

      SELECT SINGLE FROM zacb_recipe
        FIELDS *
        WHERE recipe_id = @<update_recipe>-RecipeId
        INTO @<change>-recipe_old.
      ASSERT sy-subrc = 0.

      <change>-recipe_new = CORRESPONDING #(
        BASE ( <change>-recipe_old )
        <update_recipe> MAPPING FROM ENTITY USING CONTROL ).
    ENDLOOP.

    LOOP AT delete-recipe ASSIGNING FIELD-SYMBOL(<delete_recipe>).
      ASSERT NOT line_exists( changes[ recipe_id = <delete_recipe>-RecipeId ] ).

      INSERT VALUE #(
        recipe_id        = <delete_recipe>-RecipeId
        change_indicator = 'D'
      ) INTO TABLE changes ASSIGNING <change>.
      ASSERT sy-subrc = 0.

      SELECT SINGLE FROM zacb_recipe
        FIELDS *
        WHERE recipe_id = @<delete_recipe>-RecipeId
        INTO @<change>-recipe_old.
      ASSERT sy-subrc = 0.
    ENDLOOP.

    LOOP AT create-ingredient ASSIGNING FIELD-SYMBOL(<create_ingredient>).
      ASSIGN changes[ recipe_id = <create_ingredient>-RecipeId ]
        TO <change> ELSE UNASSIGN.
      IF <change> IS NOT ASSIGNED.
        INSERT VALUE #(
          recipe_id        = <create_ingredient>-RecipeId
          change_indicator = 'U'
        ) INTO TABLE changes ASSIGNING <change>.
        ASSERT sy-subrc = 0.
      ENDIF.

      INSERT CORRESPONDING #( <create_ingredient> MAPPING FROM ENTITY USING CONTROL )
        INTO TABLE <change>-ingredients_new.
      ASSERT sy-subrc = 0.
    ENDLOOP.

    LOOP AT update-ingredient ASSIGNING FIELD-SYMBOL(<update_ingredient>).
      ASSIGN changes[ recipe_id = <update_ingredient>-RecipeId ]
        TO <change> ELSE UNASSIGN.
      IF <change> IS NOT ASSIGNED.
        INSERT VALUE #(
          recipe_id        = <update_ingredient>-RecipeId
          change_indicator = 'U'
        ) INTO TABLE changes ASSIGNING <change>.
        ASSERT sy-subrc = 0.
      ENDIF.

      SELECT SINGLE FROM zacb_ingredient
        FIELDS *
        WHERE recipe_id = @<update_ingredient>-RecipeId
          AND ingredient_id = @<update_ingredient>-IngredientId
        INTO @DATA(ingredient_old).
      ASSERT sy-subrc = 0.

      INSERT ingredient_old INTO TABLE <change>-ingredients_old.
      ASSERT sy-subrc = 0.

      INSERT CORRESPONDING #(
        BASE ( ingredient_old ) <update_ingredient> MAPPING FROM ENTITY USING CONTROL
      ) INTO TABLE <change>-ingredients_new.
      ASSERT sy-subrc = 0.
    ENDLOOP.

    LOOP AT delete-ingredient ASSIGNING FIELD-SYMBOL(<delete_ingredient>).
      ASSIGN changes[ recipe_id = <delete_ingredient>-RecipeId ]
        TO <change> ELSE UNASSIGN.
      IF <change> IS NOT ASSIGNED.
        INSERT VALUE #(
          recipe_id        = <delete_ingredient>-RecipeId
          change_indicator = 'U'
        ) INTO TABLE changes ASSIGNING <change>.
        ASSERT sy-subrc = 0.
      ENDIF.

      SELECT SINGLE FROM zacb_ingredient
        FIELDS *
        WHERE recipe_id = @<delete_ingredient>-RecipeId
          AND ingredient_id = @<delete_ingredient>-IngredientId
        INTO @ingredient_old.
      ASSERT sy-subrc = 0.

      INSERT ingredient_old INTO TABLE <change>-ingredients_old.
      ASSERT sy-subrc = 0.
    ENDLOOP.

    LOOP AT changes ASSIGNING <change>.
      TRY.
          DATA(object_id) = EXACT if_chdo_object_tools_rel=>ty_cdobjectv( sy-mandt && <change>-recipe_id ).
          zcl_zacb_recipe_chdo=>write(
            objectid                = object_id
            utime                   = cl_abap_context_info=>get_system_time( )
            udate                   = cl_abap_context_info=>get_system_date( )
            username                = EXACT #( cl_abap_context_info=>get_user_technical_name( ) )
            object_change_indicator = <change>-change_indicator
            o_zacb_recipe           = <change>-recipe_old
            n_zacb_recipe           = <change>-recipe_new
            upd_zacb_recipe         = 'U'
            xzacb_ingredient        = CORRESPONDING #( <change>-ingredients_new )
            yzacb_ingredient        = CORRESPONDING #( <change>-ingredients_old )
            upd_zacb_ingredient     = 'U' ).
        CATCH cx_chdo_write_error INTO DATA(error).
          cl_message_helper=>set_msg_vars_for_any( error ).
          DATA(message) = xco_cp=>sy->message( ).
          INSERT VALUE #(
            %msg = new_message(
            id       = message->value-msgid
            number   = message->value-msgno
            severity = if_abap_behv_message=>severity-error
            v1       = message->value-msgv1
            v2       = message->value-msgv2
            v3       = message->value-msgv3
            v4       = message->value-msgv4 )
            %key = <change>-recipe_id
          ) INTO TABLE reported-recipe.
          INSERT VALUE #(
            %key        = <change>-recipe_id
            %fail-cause = if_abap_behv=>cause-unspecific
          ) INTO TABLE failed-recipe.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_zacb_r_recipe DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS:

      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Recipe
        RESULT result,
      lock FOR LOCK
        IMPORTING keys FOR LOCK Recipe,
      earlynumbering_create FOR NUMBERING
        IMPORTING entities FOR CREATE Recipe,
      get_instance_authorizations FOR INSTANCE AUTHORIZATION
        IMPORTING keys REQUEST requested_authorizations FOR Recipe RESULT result,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE Recipe.

ENDCLASS.

CLASS lhc_zacb_r_recipe IMPLEMENTATION.

  METHOD get_global_authorizations.
    DATA(myself) = cl_abap_context_info=>get_user_technical_name( ).

    SELECT FROM zacb_user
    FIELDS COUNT( * )
    WHERE username = @myself.

    IF sy-dbcnt <> 0.
      result-%create = if_abap_behv=>auth-allowed.
      result-%update = if_abap_behv=>auth-allowed.
      result-%action-Edit = if_abap_behv=>auth-allowed.
      result-%delete = if_abap_behv=>auth-allowed.
    ELSE.
      result-%create = if_abap_behv=>auth-unauthorized.
      result-%update = if_abap_behv=>auth-unauthorized.
      result-%action-Edit = if_abap_behv=>auth-unauthorized.
      result-%delete = if_abap_behv=>auth-unauthorized.
    ENDIF.
  ENDMETHOD.
  METHOD lock.
    TRY.
        DATA(lock) = cl_abap_lock_object_factory=>get_instance( iv_name = 'EZACB_RECIPE' ).

        LOOP AT keys ASSIGNING FIELD-SYMBOL(<recipe>).
          TRY.
              lock->enqueue(
                it_parameter = VALUE #( ( name = 'RECIPE_ID' value = REF #( <recipe>-recipeid ) ) )
              ).
            CATCH cx_abap_foreign_lock INTO DATA(foreign_lock).
              APPEND VALUE #( recipeid = <recipe>-recipeid ) TO failed-recipe.
              APPEND VALUE #( recipeid = <recipe>-recipeid
                              %msg     = new_message( id       = 'ZACB_COMMON'
                                                      number   = '000'
                                                      v1       = <recipe>-recipeid
                                                      v2       = foreign_lock->user_name
                                                      severity = CONV #( 'E' ) )
              ) TO reported-recipe.
          ENDTRY.
        ENDLOOP.

      CATCH cx_abap_lock_failure INTO DATA(exception).
        RAISE SHORTDUMP exception.
    ENDTRY.
  ENDMETHOD.
  METHOD earlynumbering_create.
    DATA recipe_id_max TYPE zacb_recipe_id.
    DATA entity        TYPE STRUCTURE FOR CREATE zacb_r_recipe.

    TRY.
        LOOP AT entities INTO entity WHERE recipeid IS NOT INITIAL.
          APPEND CORRESPONDING #( entity ) TO mapped-recipe.
        ENDLOOP.

        DATA(entities_wo_recipeid) = entities.
        DELETE entities_wo_recipeid WHERE recipeid IS NOT INITIAL.

        IF entities_wo_recipeid IS NOT INITIAL.
          cl_numberrange_runtime=>number_get( EXPORTING nr_range_nr       = '01'
                                                        object            = 'ZACB_RECIP'
                                                        quantity          = CONV #( lines( entities_wo_recipeid ) )
                                              IMPORTING number            = DATA(number_range_key)
                                                        returncode        = DATA(number_range_return_code)
                                                        returned_quantity = DATA(number_range_returned_quantity) ).
        ENDIF.
        recipe_id_max = number_range_key - number_range_returned_quantity.
        LOOP AT entities INTO entity.
          recipe_id_max += 1.
          entity-recipeid = recipe_id_max.

          APPEND VALUE #( %cid      = entity-%cid
                          %key      = entity-%key
                          %is_draft = entity-%is_draft )
                 TO mapped-recipe.
        ENDLOOP.
      CATCH cx_number_ranges INTO DATA(error).
        LOOP AT entities INTO entity.
          APPEND VALUE #( %cid      = entity-%cid
                          %key      = entity-%key
                          %is_draft = entity-%is_draft
                          %msg      = error )
                 TO reported-recipe.
          APPEND VALUE #( %cid      = entity-%cid
                          %key      = entity-%key
                          %is_draft = entity-%is_draft )
                 TO failed-recipe.
        ENDLOOP.
    ENDTRY.

  ENDMETHOD.


  METHOD get_instance_authorizations.
    READ ENTITIES OF zacb_r_recipe IN LOCAL MODE
         ENTITY recipe
         FIELDS ( RecipeId CreatedBy )
         WITH CORRESPONDING #( keys )
         RESULT DATA(recipes)
         FAILED failed.

    DATA(myself) = cl_abap_context_info=>get_user_technical_name( ).

    LOOP AT recipes INTO DATA(recipe).
      IF myself <> recipe-CreatedBy.
        APPEND VALUE #( %tky    = recipe-%tky
                        %delete = if_abap_behv=>auth-unauthorized
                      ) TO result.
      ELSE.
        APPEND VALUE #( %tky    = recipe-%tky
                        %delete = if_abap_behv=>auth-allowed
                      ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(myself) = cl_abap_context_info=>get_user_technical_name( ).
    LOOP AT entities INTO DATA(entity).

      SELECT SINGLE FROM zacb_recipe FIELDS created_by
      WHERE recipe_id = @entity-RecipeId
      INTO @DATA(created_by).

      IF created_by IS NOT INITIAL AND created_by <> myself.
        APPEND VALUE #(  %tky =  entity-%tky ) TO failed-recipe.

        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = 'Sie dürfen dieses Rezept nicht ändern...'
                        ) ) TO reported-recipe.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
