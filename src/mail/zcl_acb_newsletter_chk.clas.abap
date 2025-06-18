CLASS zcl_acb_newsletter_chk DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_jt_check_20 .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS: initial TYPE zacb_days VALUE 00.

ENDCLASS.



CLASS zcl_acb_newsletter_chk IMPLEMENTATION.

  METHOD if_apj_jt_check_20~adjust_hidden.
  ENDMETHOD.


  METHOD if_apj_jt_check_20~adjust_read_only.
  ENDMETHOD.

  METHOD if_apj_jt_check_20~check_and_adjust.
    DATA det_days TYPE zacb_days.

    TRY.
        det_days = ct_value[ KEY param
                             parameter_name = zcl_acb_newsletter=>para_lastdays ]-low.

        IF det_days <> initial.
          ev_successful = abap_true.
        ELSE.
          INSERT VALUE #( id         = 'ZACB_NEWSLETTER'
                          type       = 'E'
                          number     = '001'
                          message_v1 = det_days ) INTO TABLE et_msg.
        ENDIF.

      CATCH cx_sy_itab_line_not_found INTO DATA(error).
        INSERT VALUE #( id         = 'ZACB_NEWSLETTER'
                        type       = 'E'
                        number     = '001'
                        message_v1 = det_days ) INTO TABLE et_msg.
    ENDTRY.
  ENDMETHOD.


  METHOD if_apj_jt_check_20~check_and_adjust_parameter.

  ENDMETHOD.


  METHOD if_apj_jt_check_20~check_authorizations.
    SELECT SINGLE FROM zacb_user
    FIELDS *
    WHERE username = @iv_username AND admin = @abap_true
    INTO @DATA(user).

    IF user IS INITIAL.
      INSERT VALUE #( id = 'zacb_job' type = 'e' number = '002' message_v1 = iv_username ) INTO TABLE et_msg.
    ELSE.
      ev_successful = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD if_apj_jt_check_20~check_start_condition.
    ev_incorrect = abap_false.
  ENDMETHOD.


  METHOD if_apj_jt_check_20~get_dynamic_properties.
    IF it_value[ KEY param parameter_name = zcl_acb_newsletter=>para_lastfourweeks ]-low = abap_true.
      INSERT VALUE #( job_parameter_name = zcl_acb_newsletter=>para_lastdays read_only_ind = abap_true ) INTO TABLE rts_dynamic_property.
    ELSE.
      INSERT VALUE #( job_parameter_name = zcl_acb_newsletter=>para_lastdays read_only_ind = abap_false ) INTO TABLE rts_dynamic_property.
    ENDIF.
  ENDMETHOD.


  METHOD if_apj_jt_check_20~initialize.
    TRY.
        ct_value[ KEY param parameter_name = zcl_acb_newsletter=>para_lastdays ]-low = '28'.
      CATCH cx_sy_itab_line_not_found.
        INSERT VALUE #( parameter_name = zcl_acb_newsletter=>para_lastdays sign = 'I' option = 'EQ' low = '28' ) INTO TABLE ct_value.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
