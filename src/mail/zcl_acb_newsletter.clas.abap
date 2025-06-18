CLASS zcl_acb_newsletter DEFINITION
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



CLASS zcl_acb_newsletter IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE #(
        changeable_ind = abap_true
        (
        datatype      = 'C'
        selname       = para_lastdays
        kind          = if_apj_dt_exec_object=>parameter
        param_text    = 'Ermittlungstage'
        length        = 2
        mandatory_ind = abap_true )
        (
        datatype      = 'C'
        selname       = para_lastfourweeks
        kind          = if_apj_dt_exec_object=>parameter
        param_text    = 'Letzte 4 Wochen'
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

        DATA(header) = cl_bali_header_setter=>create( object      = 'ZACB_JOB_NEWSLETTER'
                                                      subobject   = 'NEWSLETTER'
                                                      external_id = cl_system_uuid=>create_uuid_c32_static( ) ).
        log->set_header( header ).

        log_message( severity     = if_bali_constants=>c_severity_information
                     message_text = 'Newsletter Versand Start' ).

        DATA(newsletter) = NEW zcl_acb_mail_newsletter( days ).
        newsletter->send( ).

        log_message( severity     = if_bali_constants=>c_severity_information
                     message_text = 'Newsletter Versand erfolgreich' ).

        cl_bali_log_db=>get_instance( )->save_log( log                        = log
                                                   assign_to_current_appl_job = abap_true ).
      CATCH cx_bali_runtime cx_uuid_error cx_bcs_mail zcx_acb_newsletter_error INTO DATA(error).
        " Fix für Installationsbug hinsichtlich Reihenfolge (https://github.com/abapGit/abapGit/issues/7240)
        DATA(message_class) = 'ZACB_NEWSLETTER'.
        RAISE EXCEPTION TYPE cx_apj_rt_content MESSAGE ID message_class NUMBER 003 WITH error->get_text(  ).
    ENDTRY.
  ENDMETHOD.


  METHOD log_message.
    DATA free_text TYPE REF TO if_bali_free_text_setter.
    free_text = cl_bali_free_text_setter=>create( severity = severity
                                                  text     = message_text ).
    log->add_item( free_text ).
  ENDMETHOD.
ENDCLASS.
