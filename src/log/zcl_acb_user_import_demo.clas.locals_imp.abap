*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lcl_request DEFINITION.
  PUBLIC SECTION.
    INTERFACES if_web_http_request.

    METHODS constructor IMPORTING !method TYPE csequence.

  PRIVATE SECTION.
    DATA text          TYPE string.
    DATA form_fields TYPE if_web_http_request=>name_value_pairs.
    DATA content_type  TYPE string.
    DATA method        TYPE string.
ENDCLASS.


CLASS lcl_request IMPLEMENTATION.
  METHOD constructor.
    me->method = method.
  ENDMETHOD.

  METHOD if_web_http_request~add_multipart.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~append_binary.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~append_text.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~delete_header_field.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~from_xstring.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~get_binary.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~get_content_type.
    RETURN me->content_type.
  ENDMETHOD.

  METHOD if_web_http_request~get_cookie.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~get_cookies.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~get_data_length.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~get_form_field.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~get_form_fields.
    IF i_formfield_encoding IS NOT INITIAL.
      RAISE EXCEPTION NEW cx_web_message_error( ).
    ENDIF.
    RETURN form_fields.
  ENDMETHOD.

  METHOD if_web_http_request~get_form_fields_cs.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~get_form_field_cs.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~get_header_field.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~get_header_fields.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~get_last_error.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~get_method.
    RETURN method.
  ENDMETHOD.

  METHOD if_web_http_request~get_multipart.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~get_text.
    RETURN text.
  ENDMETHOD.

  METHOD if_web_http_request~num_multiparts.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~set_authorization_basic.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~set_authorization_bearer.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~set_binary.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~set_content_type.
    me->content_type = content_type.
  ENDMETHOD.

  METHOD if_web_http_request~set_cookie.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~set_formfield_encoding.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~set_form_field.
    r_value = me.

    TRY.
        DATA(field) = REF #( form_fields[ name = i_name ] ).
        field->value = i_value.
      CATCH cx_sy_itab_line_not_found.
        INSERT VALUE #( name  = i_name
                        value = i_value ) INTO TABLE form_fields.
    ENDTRY.
  ENDMETHOD.

  METHOD if_web_http_request~set_form_fields.
    r_value = me.

    IF i_multivalue IS NOT INITIAL.
      RAISE EXCEPTION NEW cx_web_message_error( ).
    ENDIF.

    me->form_fields = i_fields.
  ENDMETHOD.

  METHOD if_web_http_request~set_header_field.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~set_header_fields.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~set_query.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~set_text.
    r_value = me.

    IF i_offset IS NOT INITIAL OR i_length <> -1.
      RAISE EXCEPTION NEW cx_web_message_error( ).
    ENDIF.

    me->text = i_text.
  ENDMETHOD.

  METHOD if_web_http_request~set_uri_path.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~set_version.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_request~to_xstring.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.
ENDCLASS.


CLASS lcl_response DEFINITION.
  PUBLIC SECTION.
    INTERFACES if_web_http_response.

  PRIVATE SECTION.
    DATA text         TYPE string.
    DATA content_type TYPE string.
    DATA status       TYPE if_web_http_response=>http_status.
ENDCLASS.


CLASS lcl_response IMPLEMENTATION.
  METHOD if_web_http_response~add_multipart.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~delete_cookie_at_client.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~delete_header_field.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~from_xstring.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~get_binary.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~get_content_type.
    content_type = me->content_type.
  ENDMETHOD.

  METHOD if_web_http_response~get_cookie.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~get_cookies.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~get_data_length.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~get_header_field.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~get_header_fields.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~get_last_error.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~get_multipart.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~get_status.
    RETURN status.
  ENDMETHOD.

  METHOD if_web_http_response~get_text.
    r_value = text.
  ENDMETHOD.

  METHOD if_web_http_response~num_multiparts.
    RAISE cx_web_message_error. " Amazing
  ENDMETHOD.

  METHOD if_web_http_response~server_cache_expire_rel.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~set_binary.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~set_compression.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~set_content_type.
    me->content_type = content_type.
  ENDMETHOD.

  METHOD if_web_http_response~set_cookie.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~set_formfield_encoding.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~set_header_field.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~set_header_fields.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~set_status.
    r_value = me.
    status = VALUE #( code   = i_code
                      reason = i_reason ).
  ENDMETHOD.

  METHOD if_web_http_response~set_text.
    r_value = me.
    IF i_offset IS NOT INITIAL OR i_length <> -1.
      RAISE EXCEPTION NEW cx_web_message_error( ).
    ENDIF.
    me->text = i_text.
  ENDMETHOD.

  METHOD if_web_http_response~suppress_content_type.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.

  METHOD if_web_http_response~to_xstring.
    RAISE EXCEPTION NEW cx_web_message_error( ).
  ENDMETHOD.
ENDCLASS.
