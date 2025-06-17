CLASS zcl_acb_user_import_handler DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.

  PRIVATE SECTION.
    TYPES users TYPE SORTED TABLE OF zacb_user WITH UNIQUE KEY username.

    DATA log TYPE REF TO if_bali_log.

    METHODS convert_csv_to_users
      IMPORTING csv           TYPE string
                delimiter     TYPE string
      RETURNING VALUE(result) TYPE users
      RAISING   zcx_acb_user_conversion_error.
ENDCLASS.


CLASS zcl_acb_user_import_handler IMPLEMENTATION.
  METHOD if_http_service_extension~handle_request.
    TRY.
        log = cl_bali_log=>create_with_header( cl_bali_header_setter=>create( object    = 'ZACB_USER'
                                                                              subobject = 'IMPORT' ) ).
        log->add_item( cl_bali_free_text_setter=>create(
          'Starte Benutzerdatenimport' ) ).

        DATA(parameters) = request->get_form_fields( ).
        DATA(delimiter) = VALUE #( parameters[ name = 'delimiter' ]-value OPTIONAL ).
        DATA(drop_users) = VALUE #( parameters[ name = 'drop-users' ]-value OPTIONAL ).
        response->set_content_type( 'text/plain; charset=utf-8' ).

        IF request->get_method( ) <> 'POST'.
          response->set_status( if_web_http_status=>bad_request ).
          log->add_item( cl_bali_free_text_setter=>create( severity = if_bali_constants=>c_severity_error
                                                           text     = |Nicht unterstützte HTTP-Methode | &&
                                                                      |{ request->get_method( ) } erkannt| ) ).
        ENDIF.

        TRY.
            CASE request->get_content_type( ).
              WHEN 'application/csv'.
                IF delimiter IS INITIAL.
                  response->set_status( if_web_http_status=>bad_request ).
                  response->set_text( |Parameter DELIMITER (Trennzeichen) wurde nicht übergeben| ).
                  RETURN.
                ENDIF.

                DATA(users) = convert_csv_to_users( csv       = request->get_text( )
                                                    delimiter = delimiter ).

                IF users IS INITIAL.
                  response->set_status( if_web_http_status=>bad_request ).
                  response->set_text( |Benutzerdaten konnten nicht konvertiert werden| ).
                  RETURN.
                ENDIF.

                IF to_lower( drop_users ) = 'true'.
                  DELETE FROM zacb_user.
                ENDIF.

                MODIFY zacb_user FROM TABLE @users.
                IF sy-subrc <> 0.
                  ROLLBACK WORK.
                  response->set_status( if_web_http_status=>internal_server_error ).
                  RETURN.
                ENDIF.

                DATA(modified_entries) = sy-dbcnt.
                response->set_status( if_web_http_status=>created ).

                MESSAGE s001(zacb_user) WITH modified_entries INTO DATA(success_message).
                log->add_item( cl_bali_message_setter=>create_from_sy( ) ).

                response->set_text( success_message ).

                COMMIT WORK.

              WHEN OTHERS.
                response->set_status( if_web_http_status=>bad_request ).
                response->set_text( |Content Type nicht unterstützt| ).
                RETURN.
            ENDCASE.
          CATCH zcx_acb_user_conversion_error INTO DATA(conversion_error).
            ROLLBACK WORK.
            log->add_item( cl_bali_exception_setter=>create(
               severity  = if_bali_constants=>c_severity_error
               exception = conversion_error ) ).
            response->set_status( if_web_http_status=>bad_request ).
            response->set_text( conversion_error->get_text( ) ).
        ENDTRY.

        MESSAGE s000(zacb_user) INTO DATA(dummy) ##NEEDED.
        log->add_item( cl_bali_message_setter=>create_from_sy( ) ).

        cl_bali_log_db=>get_instance( )->save_log( log ).
        COMMIT WORK.

      CATCH cx_bali_runtime INTO DATA(bali_error).
        RAISE SHORTDUMP bali_error.
    ENDTRY.
  ENDMETHOD.

  METHOD convert_csv_to_users.
    IF delimiter IS INITIAL.
      RAISE EXCEPTION NEW zcx_acb_user_conversion_error( textid = zcx_acb_user_conversion_error=>delimiter_not_specified ).
    ENDIF.

    DATA(text) = csv.

    REPLACE ALL OCCURRENCES OF
      cl_abap_char_utilities=>cr_lf(1)
            IN text WITH ''.

    SPLIT text AT |\n| INTO TABLE DATA(lines).

    LOOP AT lines ASSIGNING FIELD-SYMBOL(<line>).
      TRY.
          SPLIT <line> AT delimiter INTO TABLE DATA(fields).

          INSERT VALUE #( username   = EXACT #( fields[ 1 ] )
                          first_name = EXACT #( VALUE #( fields[ 2 ] OPTIONAL ) )
                          last_name  = EXACT #( VALUE #( fields[ 3 ] OPTIONAL ) )
                          mail       = EXACT #( VALUE #( fields[ 4 ] OPTIONAL ) )
                          author     = EXACT #( to_upper( VALUE #( fields[ 5 ] DEFAULT abap_false ) ) )
                          admin      = EXACT #( to_upper( VALUE #( fields[ 6 ] DEFAULT abap_false ) ) ) )
                 INTO TABLE result.

        CATCH cx_sy_itab_line_not_found
              cx_sy_conversion_error INTO DATA(format_error).
          RAISE EXCEPTION TYPE zcx_acb_user_conversion_error
                MESSAGE e004(zacb_user)
                EXPORTING previous = format_error.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
