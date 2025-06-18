CLASS zcl_acb_newsletter_notif DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_rt_job_notif_exit .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_acb_newsletter_notif IMPLEMENTATION.
  METHOD if_apj_rt_job_notif_exit~notify_jt_end.
    DATA(mail) = cl_bcs_mail_message=>create_instance( ).

    mail->set_sender( 'error@example.com' ).
    mail->add_recipient( 'test@example.com' ).

    mail->set_subject( CONV #( | Jobfehler | ) ).

    mail->set_main( cl_bcs_mail_textpart=>create_text_plain( iv_content = | Der Job { is_job_info-job_name
                                                                          } hat einen Fehler. Bitte prüfen | ) ).

    mail->send( ).
  ENDMETHOD.


  METHOD if_apj_rt_job_notif_exit~notify_jt_start.
  ENDMETHOD.
ENDCLASS.
