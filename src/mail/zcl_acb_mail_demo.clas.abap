CLASS zcl_acb_mail_demo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .

    METHODS send_text_mail
      IMPORTING
        !out TYPE REF TO if_oo_adt_classrun_out .
    METHODS send_format_mail
      IMPORTING
        !out TYPE REF TO if_oo_adt_classrun_out .
    METHODS send_mail_with_attachment
      IMPORTING
        !out TYPE REF TO if_oo_adt_classrun_out .
    METHODS validate_mail
      IMPORTING
        !out TYPE REF TO if_oo_adt_classrun_out .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA address TYPE  cl_bcs_mail_message=>ty_address VALUE 'test@example.com'. "Bitte Mailadresse anpasssen"

ENDCLASS.



CLASS zcl_acb_mail_demo IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    send_text_mail( out ).
    send_format_mail( out ).
    send_mail_with_attachment( out ).
    validate_mail( out ).
  ENDMETHOD.


  METHOD send_format_mail.
    DATA content TYPE  string.
    TRY.
        DATA(mail) = cl_bcs_mail_message=>create_instance( ).

        mail->set_sender( address ).

        mail->add_recipient(
          iv_address = address
          iv_copy    = cl_bcs_mail_message=>to ).
        mail->add_recipient(
          iv_address = address
          iv_copy    = cl_bcs_mail_message=>cc ).

        mail->set_subject( 'Test new API - sample formatting' ).

        content = '<h1>Hello,</h1><p>I have been formatted.</p><p><strong>Have a nice day</strong></p>'.
        mail->set_main( cl_bcs_mail_textpart=>create_text_html( iv_content = content ) ).

        mail->send( IMPORTING et_status      = DATA(status)
                              ev_mail_status = DATA(mail_status) ).

        out->write( 'Test: Send formatting' ).
        out->write( status ).
        out->write( |Status of the mails: { mail_status }| ).

      CATCH cx_bcs_mail INTO DATA(exception).
        out->write( exception->get_text( ) ).
    ENDTRY.
  ENDMETHOD.


  METHOD send_text_mail.
    DATA content TYPE  string.
    TRY.
        DATA(mail) = cl_bcs_mail_message=>create_instance( ).

        mail->set_sender( address  ).

        mail->add_recipient( iv_address = address
                             iv_copy    = cl_bcs_mail_message=>to ).
        mail->add_recipient( iv_address = address
                             iv_copy    = cl_bcs_mail_message=>cc ).

        mail->set_subject( 'Test new API - sample text' ).

        content = 'This is a normal text'.
        mail->set_main( cl_bcs_mail_textpart=>create_instance( iv_content      = content
                                                               iv_content_type = 'text/plain' ) ).

        mail->send( IMPORTING et_status      = DATA(status)
                              ev_mail_status = DATA(mail_status) ).

        out->write( 'Test: Send normal method' ).
        out->write( status ).
        out->write( |Status of the mails: { mail_status }| ).

      CATCH cx_bcs_mail INTO DATA(exception).
        out->write( exception->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD send_mail_with_attachment.
    DATA content TYPE string.

    TRY.
        DATA(mail) = cl_bcs_mail_message=>create_instance( ).

        mail->set_sender( address ).

        mail->add_recipient( iv_address = address
                             iv_copy    = cl_bcs_mail_message=>to ).
        mail->add_recipient( iv_address = address
                             iv_copy    = cl_bcs_mail_message=>cc ).

        mail->set_subject( 'Testing new API - Example email with attachment' ).

        content = 'Mail with attachment'.
        mail->set_main( cl_bcs_mail_textpart=>create_text_plain( iv_content = content ) ).

        mail->add_attachment( cl_bcs_mail_textpart=>create_text_plain( iv_content  = 'Text attachment'
                                                                       iv_filename = 'TestAttachmentText.txt' ) ).

        mail->add_attachment(
            cl_bcs_mail_textpart=>create_instance(
                iv_content      = '<mail><to>Recipient</to><from>Sender</from><content>My XML!</content></mail>'
                iv_content_type = 'text/xml'
                iv_filename     = 'TestAttachmentXml.xml' ) ).

        mail->send( IMPORTING et_status      = DATA(status)
                              ev_mail_status = DATA(mail_status) ).

        out->write( 'Test: Send Mail with Attachment' ).
        out->write( status ).
        out->write( |Status of the mails: { mail_status }| ).

      CATCH cx_bcs_mail INTO DATA(exception).
        out->write( exception->get_text( ) ).
    ENDTRY.
  ENDMETHOD.


  METHOD validate_mail.
    TRY.
        DATA mail_address TYPE cl_mail_address=>ty_address_string.
        mail_address = address.
        DATA(mail_check) = cl_mail_address=>create_instance(
          iv_address_string = mail_address ).
        DATA(address_valid) = mail_check->validate( ).
        out->write( |mail address { mail_address
          } is valid: { address_valid }| ).

        mail_address = 'test-example.com'.
        mail_check = cl_mail_address=>create_instance(
          iv_address_string = mail_address ).
        address_valid = mail_check->validate( ).
        out->write( |mail address{ mail_address
          } is valid: { address_valid }| ).
      CATCH cx_bcs_mail INTO DATA(exception).
        out->write( exception->get_text( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
