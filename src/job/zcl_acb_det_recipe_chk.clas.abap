CLASS zcl_acb_det_recipe_chk DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_jt_check_20 .
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_acb_det_recipe_chk IMPLEMENTATION.


  METHOD if_apj_jt_check_20~adjust_hidden.
  ENDMETHOD.


  METHOD if_apj_jt_check_20~adjust_read_only.
  ENDMETHOD.


  METHOD if_apj_jt_check_20~check_and_adjust.
    DATA det_days TYPE zacb_days.
    TRY.
        det_days = ct_value[ KEY param parameter_name = zcl_acb_det_recipe=>para_lastdays ]-low.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    IF det_days IS NOT INITIAL.
      ev_successful = abap_true.
    ELSE.
      INSERT VALUE #( id = 'ZACB_JOB' type = 'E' number = '001' message_v1 = det_days ) INTO TABLE et_msg.
    ENDIF.

  ENDMETHOD.


  METHOD if_apj_jt_check_20~check_and_adjust_parameter.

  ENDMETHOD.


  METHOD if_apj_jt_check_20~check_authorizations.
    " Fix for installation of SAJC and SAJT via abapGit with not yet filled user table
    SELECT FROM zacb_user
      FIELDS COUNT(*).
    IF sy-dbcnt = 0.
      ev_successful = abap_true.
      RETURN.
    ENDIF.

    SELECT SINGLE FROM zacb_user
    FIELDS *
    WHERE username = @iv_username AND admin = @abap_true
    INTO @DATA(user).

    IF user IS INITIAL.
      INSERT VALUE #( id = 'ZACB_JOB' type = 'E' number = '000' message_v1 = iv_username ) INTO TABLE et_msg.
    ELSE.
      ev_successful = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD if_apj_jt_check_20~check_start_condition.
    IF is_schedule_info-periodic_granularity IS INITIAL.
      INSERT VALUE #( id = 'ZACB_JOB' type = 'E' number = '002' ) INTO TABLE et_msg.
      ev_incorrect = abap_true.
    ELSE.
      ev_incorrect = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD if_apj_jt_check_20~get_dynamic_properties.
    IF it_value[ KEY param parameter_name = zcl_acb_det_recipe=>para_lastfourweeks ]-low = abap_true.
      INSERT VALUE #( job_parameter_name = zcl_acb_det_recipe=>para_lastdays read_only_ind = abap_true ) INTO TABLE rts_dynamic_property.
    ELSE.
      INSERT VALUE #( job_parameter_name = zcl_acb_det_recipe=>para_lastdays read_only_ind = abap_false ) INTO TABLE rts_dynamic_property.
    ENDIF.
  ENDMETHOD.


  METHOD if_apj_jt_check_20~initialize.
    TRY.
        ct_value[ KEY param parameter_name = zcl_acb_det_recipe=>para_lastdays ]-low = '28'.
      CATCH cx_sy_itab_line_not_found.
        INSERT VALUE #( parameter_name = zcl_acb_det_recipe=>para_lastdays sign = 'I' option = 'EQ' low = '28' ) INTO TABLE ct_value.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
