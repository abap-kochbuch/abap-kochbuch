CLASS lcx_processing_error DEFINITION INHERITING FROM cx_static_check.
  PUBLIC SECTION.
    INTERFACES if_t100_dyn_msg.
ENDCLASS.


CLASS lhc_masschange DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING
      REQUEST requested_authorizations FOR MassChange
      RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR MassChange RESULT result.

    METHODS generateTemplate FOR MODIFY
      IMPORTING keys FOR ACTION MassChange~generateTemplate RESULT result.
    METHODS processFile FOR MODIFY
      IMPORTING keys FOR ACTION MassChange~processFile RESULT result.
    METHODS setProcessingStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MassChange~setProcessingStatus.

    METHODS add_table_to_worksheet IMPORTING !table TYPE STANDARD TABLE
                                             sheet  TYPE REF TO if_xco_xlsx_wa_worksheet.

    METHODS process_single_file
      IMPORTING file_content TYPE xstring
      RAISING   lcx_processing_error.

    METHODS create_table_for_sheet IMPORTING view_entity   TYPE csequence
                                             sheet         TYPE REF TO if_xco_xlsx_ra_worksheet
                                   RETURNING VALUE(result) TYPE REF TO data
                                   RAISING   lcx_processing_error.
ENDCLASS.


CLASS lhc_masschange IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF ZACB_R_MassChange IN LOCAL MODE
         ENTITY MassChange
         FIELDS ( TemplateFilename ProcessingFilename ProcessingStatus )
         WITH CORRESPONDING #( keys )
         RESULT DATA(mass_changes)
         FAILED failed
         REPORTED reported.
    LOOP AT mass_changes ASSIGNING FIELD-SYMBOL(<mass_change>).
      INSERT VALUE #( %tky                         = <mass_change>-%tky
                      " Templateerzeugung nur, wenn noch kein Template angehängt ist
                      %action-generateTemplate     = COND #(
                            WHEN <mass_change>-TemplateFilename IS INITIAL
                            THEN if_abap_behv=>fc-o-enabled
                            ELSE if_abap_behv=>fc-o-disabled )
                      " Verarbeitung nur, wenn Verarbeitungsdatei angehängt ist und
                      " Instanz aktiv gespeichert wurde und noch nicht verarbeitet
                      %action-processFile          = COND #(
                               WHEN <mass_change>-ProcessingFilename IS NOT INITIAL
                                AND <mass_change>-%is_draft           = if_abap_behv=>mk-off
                                AND <mass_change>-ProcessingStatus    = '2'
                               THEN if_abap_behv=>fc-o-enabled
                               ELSE if_abap_behv=>fc-o-disabled )
                      " Verarbeitungsdatei anhängen nur, wenn noch nicht verarbeitet und
                      " Template vorhanden
                      %field-ProcessingFileContent = COND #(
                          WHEN <mass_change>-TemplateFilename IS NOT INITIAL
                           AND (    <mass_change>-ProcessingStatus = '1'
                                 OR <mass_change>-ProcessingStatus = '2' )
                          THEN if_abap_behv=>fc-f-unrestricted
                          ELSE if_abap_behv=>fc-f-read_only ) )
             INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.

  METHOD generateTemplate.
    DATA(document) = xco_cp_xlsx=>document->empty( )->write_access( ).

    DATA(sheet) = document->get_workbook( )->worksheet->at_position( 1 ).
    sheet->set_name( 'Rezepte' ).

    SELECT FROM ZACB_R_Recipe
      FIELDS RecipeId, RecipeName, RecipeText
      ORDER BY PRIMARY KEY
      INTO TABLE @DATA(recipes).

    add_table_to_worksheet( table = recipes
                            sheet = sheet ).

    sheet = document->get_workbook( )->add_new_sheet( 'Zutaten' ).

    SELECT FROM ZACB_R_Ingredient
      FIELDS RecipeId,
             IngredientId,
             Name,
             CAST( Quantity AS INT4 ) AS Quantity,
             Unit
      ORDER BY PRIMARY KEY
      INTO TABLE @DATA(ingredients).

    add_table_to_worksheet( table = ingredients
                            sheet = sheet ).

    DATA(content) = document->get_file_content( ).

    MODIFY ENTITIES OF ZACB_R_MassChange IN LOCAL MODE
           ENTITY MassChange
           UPDATE FIELDS ( TemplateFileContent TemplateFileMimetype TemplateFilename ProcessingStatus ) WITH VALUE #(
               FOR k IN keys
               ( %tky                 = k-%tky
                 TemplateFileContent  = content
                 TemplateFileMimetype = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                 TemplateFilename     = 'template.xlsx'
                 ProcessingStatus     = '1' ) )
           REPORTED reported
           FAILED failed
           MAPPED mapped.

    READ ENTITIES OF ZACB_R_MassChange IN LOCAL MODE
         ENTITY MassChange
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(mass_changes).
    result = VALUE #( FOR mass_change IN mass_changes
                      ( %tky   = mass_change-%tky
                        %param = mass_change ) ).
  ENDMETHOD.

  METHOD processFile.
    READ ENTITIES OF ZACB_R_MassChange IN LOCAL MODE
         ENTITY MassChange
         FIELDS ( ProcessingFileContent )
         WITH CORRESPONDING #( keys )
         RESULT DATA(mass_changes).

    LOOP AT mass_changes ASSIGNING FIELD-SYMBOL(<mass_change>).
      TRY.
          process_single_file( <mass_change>-ProcessingFileContent ).
          INSERT VALUE #( %tky = <mass_change>-%tky
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                        text     = |Massenänderung wurde erfolgreich durchgeführt| ) )
                 INTO TABLE reported-masschange.
          MODIFY ENTITIES OF ZACB_R_MassChange IN LOCAL MODE
                 ENTITY MassChange
                 UPDATE FIELDS ( ProcessingStatus )
                 WITH VALUE #( ( %tky = <mass_change>-%tky ProcessingStatus = '3' ) ).
        CATCH lcx_processing_error INTO DATA(error).
          INSERT VALUE #( %tky = <mass_change>-%tky
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text     = error->get_text( ) ) )
                 INTO TABLE reported-MassChange.
          INSERT VALUE #( %tky        = <mass_change>-%tky
                          %fail-cause = if_abap_behv=>cause-unspecific ) INTO TABLE failed-MassChange.
      ENDTRY.
    ENDLOOP.

    READ ENTITIES OF ZACB_R_MassChange IN LOCAL MODE
         ENTITY MassChange
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT mass_changes.
    result = VALUE #( FOR mass_change IN mass_changes
                      ( %tky   = mass_change-%tky
                        %param = mass_change ) ).
  ENDMETHOD.

  METHOD setProcessingStatus.
    READ ENTITIES OF ZACB_R_MassChange IN LOCAL MODE
         ENTITY MassChange
         FIELDS ( ProcessingStatus ProcessingFileContent )
         WITH CORRESPONDING #( keys )
         RESULT DATA(mass_changes).

    MODIFY ENTITIES OF ZACB_R_MassChange IN LOCAL MODE
           ENTITY MassChange
           UPDATE FIELDS ( ProcessingStatus )
           WITH VALUE #(
               FOR change IN mass_changes
               ( %tky             = change-%tky
                 ProcessingStatus = COND #( WHEN change-ProcessingStatus IS INITIAL THEN
                                              '0'
                                            WHEN change-ProcessingStatus = '1' AND change-ProcessingFileContent IS NOT INITIAL THEN
                                              '2'
                                            ELSE
                                              change-ProcessingStatus ) ) ).
  ENDMETHOD.

  METHOD add_table_to_worksheet.
    DATA(from_second_row) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
      )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 2 )
      )->get_pattern( ).

    DATA(stream) = sheet->select( from_second_row )->row_stream( ).

    stream->operation->write_from( REF #( table ) )->execute( ).

    DATA(cursor) = sheet->cursor( io_column = xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
                                  io_row    = xco_cp_xlsx=>coordinate->for_numeric_value( 1 ) ).

    DATA(descriptor) = CAST cl_abap_structdescr(
      CAST cl_abap_tabledescr(
        cl_abap_typedescr=>describe_by_data( table )
      )->get_table_line_type( ) ).

    LOOP AT descriptor->get_components( ) ASSIGNING FIELD-SYMBOL(<component>).
      cursor->get_cell( )->value->write_from( <component>-name ).
      cursor->move_right( ).
    ENDLOOP.
  ENDMETHOD.

  METHOD process_single_file.
    DATA(document) = xco_cp_xlsx=>document->for_file_content( file_content )->read_access( ).
    DATA(sheet) = document->get_workbook( )->worksheet->for_name( 'Rezepte' ).
    IF NOT sheet->exists( ).
      cl_message_helper=>set_msg_vars_for_clike( |Arbeitsblatt Rezepte existiert nicht| ).
      RAISE EXCEPTION TYPE lcx_processing_error USING MESSAGE.
    ENDIF.

    DATA(recipes) = create_table_for_sheet( view_entity = 'ZACB_R_Recipe'
                                            sheet       = sheet ).
    IF recipes IS NOT BOUND.
      cl_message_helper=>set_msg_vars_for_clike( |Format invalide| ).
      RAISE EXCEPTION TYPE lcx_processing_error USING MESSAGE.
    ENDIF.

    DATA(from_second_row) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
      )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 2 )
      )->get_pattern( ).
    sheet->select( from_second_row )->row_stream( )->operation->write_to( recipes )->execute( ).

    sheet = document->get_workbook( )->worksheet->for_name( 'Zutaten' ).
    IF NOT sheet->exists( ).
      cl_message_helper=>set_msg_vars_for_clike( |Arbeitsblatt Zutaten existiert nicht| ).
      RAISE EXCEPTION TYPE lcx_processing_error USING MESSAGE.
    ENDIF.

    DATA(ingredients) = create_table_for_sheet( view_entity = 'ZACB_R_Ingredient'
                                                sheet       = sheet ).

    sheet->select( from_second_row )->row_stream( )->operation->write_to( ingredients )->execute( ).

    MODIFY ENTITIES OF ZACB_R_Recipe
           ENTITY Recipe
           UPDATE FIELDS ( RecipeName RecipeText )
           WITH CORRESPONDING #( recipes->* )
           ENTITY Ingredient
           UPDATE FIELDS ( Name Quantity Unit )
           WITH CORRESPONDING #( ingredients->* )
           FAILED DATA(failed).
    IF failed IS NOT INITIAL.
      cl_message_helper=>set_msg_vars_for_clike( |Fehler bei Massenänderung| ).
      RAISE EXCEPTION TYPE lcx_processing_error USING MESSAGE.
    ENDIF.
  ENDMETHOD.

  METHOD create_table_for_sheet.
    DATA components    TYPE cl_abap_structdescr=>component_table.
    DATA column_header TYPE string.

    DATA(cursor) = sheet->cursor( io_column = xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
                                  io_row    = xco_cp_xlsx=>coordinate->for_numeric_value( 1 ) ).
    WHILE cursor->has_cell( ) AND cursor->get_cell( )->has_value( ).
      cursor->get_cell( )->get_value( )->write_to( REF #( column_header ) ).
      IF column_header IS INITIAL.
        EXIT.
      ENDIF.

      cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = |{ view_entity }-{ column_header }|
                                           RECEIVING  p_descr_ref    = DATA(column_descriptor)
                                           EXCEPTIONS type_not_found = 1
                                                      OTHERS         = 2 ).
      IF sy-subrc <> 0.
        cl_message_helper=>set_msg_vars_for_clike( |Feld { view_entity }-{ column_header } unbekannt| ).
        RAISE EXCEPTION TYPE lcx_processing_error USING MESSAGE.
      ENDIF.

      APPEND VALUE #( name = column_header
                      type = CAST #( column_descriptor ) )
             TO components.

      cursor->move_right( ).
    ENDWHILE.

    DATA(table_descriptor) = cl_abap_tabledescr=>get( cl_abap_structdescr=>get( components ) ).
    CREATE DATA result TYPE HANDLE table_descriptor.
  ENDMETHOD.
ENDCLASS.
