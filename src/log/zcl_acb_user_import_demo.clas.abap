CLASS zcl_acb_user_import_demo DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_acb_user_import_demo IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " In this method a call to the HTTP Service
    " ZACB_USER_IMPORT is 'simulated' using fixed
    " values.
    " This enables you to analyze the code in the
    " debugger without needing to call the service
    " yourself and request authorizations for it.

    DATA(csv) = concat_lines_of(
      table = VALUE string_table( ( |{ cl_abap_context_info=>get_user_technical_name( ) };Manfred;Mustermann;;X;X| )
                                  ( `DOEJ;John;Doe;X;;;` )
                                  ( `SMITHJ;Jane;Smith;;;` ) )
      sep   = |\n| ).

    DATA(handler) = NEW zcl_acb_user_import_handler( ).

    DATA(request) = CAST if_web_http_request( NEW lcl_request( 'POST' ) ).
    request->set_text( csv ).
    request->set_content_type( 'application/csv' ).
    request->set_form_field(
      i_name  = 'delimiter'
      i_value = ';' ).
    request->set_form_field(
      i_name  = 'drop-users'
      i_value = 'true' ).

    DATA(response) = CAST if_web_http_response(
      NEW lcl_response( ) ).

    handler->if_http_service_extension~handle_request(
      request  = request
      response = response ).

    out->write( response->get_status( ) ).
    out->write( response->get_text( ) ).
  ENDMETHOD.
ENDCLASS.
