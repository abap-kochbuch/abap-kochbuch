CLASS zcl_acb_det_recipe DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS: para_lastdays      TYPE string VALUE 'DAYS',
               para_lastfourweeks TYPE string VALUE 'WEEKS'.
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS log_message
      IMPORTING severity     TYPE cl_bali_free_text_setter=>ty_severity
                message_text TYPE cl_bali_free_text_setter=>ty_text
      RAISING
                cx_bali_runtime.
    DATA: log TYPE REF TO  if_bali_log.
    CONSTANTS: fourweeks TYPE zacb_days VALUE 28.
ENDCLASS.

CLASS zcl_acb_det_recipe IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE #(
        changeable_ind = abap_true
        (
        datatype      = 'C'
        selname       = para_lastdays
        kind          = if_apj_dt_exec_object=>parameter
        param_text    = 'Determination days'
        length        = 2
        mandatory_ind = abap_true )
        (
        datatype      = 'C'
        selname       = para_lastfourweeks
        kind          = if_apj_dt_exec_object=>parameter
        param_text    = 'Last 4 weeks'
        length        = 1
        checkbox_ind  = abap_true ) ).

    et_parameter_val = VALUE #(
                        sign   = 'I'
                        option = 'EQ' (
                        selname = para_lastfourweeks
                        low     = abap_true ) (
                        selname = para_lastdays
                        low     = 1 ) ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    DATA days TYPE zacb_days.
    DATA test TYPE abap_bool.

    LOOP AT it_parameters INTO DATA(parameter).
      CASE parameter-selname.
        WHEN para_lastfourweeks.
          days = fourweeks.
        WHEN para_lastdays.
          days = parameter-low.
      ENDCASE.
    ENDLOOP.

    TRY.
        log = cl_bali_log=>create( ).

        DATA(header) = cl_bali_header_setter=>create( object      = 'ZACB_JOB'
                                                      subobject   = 'JOB'
                                                      external_id = cl_system_uuid=>create_uuid_c32_static( ) ).
        log->set_header( header ).
        log_message( severity     = if_bali_constants=>c_severity_status
                     message_text = 'Start' ).
        log_message( severity     = if_bali_constants=>c_severity_information
                     message_text = 'Ermittlungstage' ).
        log_message( severity     = if_bali_constants=>c_severity_information
                     message_text = CONV #( days ) ).
        DATA(det_date) = EXACT timestamp( xco_cp=>sy->moment( xco_cp_time=>time_zone->utc
                                              )->subtract( iv_day = CONV #( days )
                                              )->as( xco_cp_time=>format->abap
                                              )->value ).

        SELECT FROM zacb_recipe
          FIELDS *
          WHERE created_at > @det_date
          INTO TABLE @DATA(recipes).

        IF sy-subrc <> 0.
          log_message( severity     = if_bali_constants=>c_severity_error
                       message_text = 'No data found' ).
        ENDIF.

        LOOP AT recipes INTO DATA(recipe).
          log_message( severity     = if_bali_constants=>c_severity_information
                       message_text = CONV #( recipe-recipe_id ) ).
          log_message( severity     = if_bali_constants=>c_severity_information
                       message_text = CONV #( recipe-recipe_name ) ).
        ENDLOOP.
        log_message( severity     = if_bali_constants=>c_severity_status
                     message_text = 'End' ).

        cl_bali_log_db=>get_instance( )->save_log( log                        = log
                                                   assign_to_current_appl_job = abap_true ).
      CATCH cx_bali_runtime cx_uuid_error INTO DATA(error).
        RAISE SHORTDUMP error.
    ENDTRY.
  ENDMETHOD.


  METHOD log_message.
    DATA free_text TYPE REF TO if_bali_free_text_setter.
    free_text = cl_bali_free_text_setter=>create( severity = severity
                                                  text     = message_text ).
    log->add_item( free_text ).
  ENDMETHOD.
ENDCLASS.
