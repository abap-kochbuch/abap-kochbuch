CLASS zcl_acb_mail_newsletter DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS send RAISING cx_bcs_mail.
    METHODS constructor IMPORTING det_days TYPE zacb_days RAISING zcx_acb_newsletter_error.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS add_mail_header RAISING cx_bcs_mail.
    METHODS add_recipe_infos RAISING cx_bcs_mail.
    METHODS add_mail_footer RAISING cx_bcs_mail.
    METHODS add_recipients RAISING cx_bcs_mail.
    METHODS add_sender RAISING cx_bcs_mail.
    METHODS add_content RAISING cx_bcs_mail.
    METHODS add_attachment RAISING cx_bcs_mail.
    METHODS det_recipes RAISING zcx_acb_newsletter_error.
    DATA: mail TYPE REF TO cl_bcs_mail_message.
    DATA: content TYPE string.
    DATA: recipes TYPE TABLE OF zacb_recipe.
    DATA: days TYPE zacb_days.
    CONSTANTS: sender_address TYPE cl_bcs_mail_message=>ty_address VALUE 'newsletter@example.com'.

ENDCLASS.

CLASS zcl_acb_mail_newsletter IMPLEMENTATION.

  METHOD constructor.
    days = det_days.
    det_recipes( ).
  ENDMETHOD.

  METHOD det_recipes.
    DATA(det_date) = EXACT timestamp( xco_cp=>sy->moment( xco_cp_time=>time_zone->utc
                                        )->subtract( iv_day = CONV #( days )
                                        )->as( xco_cp_time=>format->abap
                                        )->value ).

    SELECT FROM zacb_recipe
      FIELDS *
      WHERE created_at > @det_date
      INTO TABLE @recipes.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_acb_newsletter_error( ).
    ENDIF.
  ENDMETHOD.

  METHOD add_mail_header.
    content &&= |<h1><strong>Newsletter Recipe Portal</strong></h1>|.
    content &&= |<p>Welcome to our monthly newsletter.</p>|.
    content &&= |<p>Thanks to your loyalty, you'll receive a voucher today.</p>|.
    content &&= |<p>Today you'll find out what you missed last month.</p>|.
  ENDMETHOD.

  METHOD add_recipe_infos.
    content &&= |<table style="border-collapse: collapse; width: 100%; height: 36px;" border="1"> |.
    content &&= |<tbody> |.
    content &&= |<tr style="height: 18px;"> |.
    content &&= |<td style="width: 20%; height: 18px;">Recipe ID</td>|.
    content &&= |<td style="width: 60%; height: 18px;">Recipe name</td>|.
    content &&= |<td style="width: 20%; height: 18px;">Recipe text</td>|.
    content &&= |</tr> |.

    LOOP AT recipes INTO DATA(recipe).
      content &&= |<tr style="height: 18px;">|.
      content &&= |<td style="width: 20%; height: 18px;">{ recipe-recipe_id }</td>|.
      content &&= |<td style="width: 60%; height: 18px;">{ recipe-recipe_name }</td>|.
      content &&= |<td style="width: 20%; height: 18px;">{ recipe-recipe_text }</td>|.
      content &&= |</tr>|.
    ENDLOOP.

    content &&= |</tbody>|.
    content &&= |</table>|.
  ENDMETHOD.

  METHOD add_mail_footer.
    content &&= |<p>Until then.</p>|.
    content &&= |<p>Your favorite recipe portal</p>|.
    content &&= |<p>Visit us again on our social media platforms</p>|.
  ENDMETHOD.

  METHOD add_recipients.
    SELECT FROM zacb_user
    FIELDS mail
    ORDER BY username
    INTO TABLE @DATA(mails).

    LOOP AT mails INTO DATA(mail_user).
      DATA(mail_check) = cl_mail_address=>create_instance(
        iv_address_string = CONV #( mail_user-mail ) ).
      IF mail_check->validate( ).
        mail->add_recipient(
          iv_address = CONV #( mail_user-mail )
          iv_copy    = cl_bcs_mail_message=>bcc ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD send.
    mail = cl_bcs_mail_message=>create_instance( ).
    add_sender( ).
    add_recipients(  ).
    add_content( ).
    add_attachment( ).
    mail->send( ).
  ENDMETHOD.

  METHOD add_sender.
    mail->set_sender( sender_address ).
  ENDMETHOD.


  METHOD add_content.
    add_mail_header( ).
    add_recipe_infos(  ).
    add_mail_footer( ).
  ENDMETHOD.
  METHOD add_attachment.
    mail->add_attachment( cl_bcs_mail_textpart=>create_text_plain(
               iv_content      = 'Gutschein ABCD-EFGH-HIJK'
               iv_filename     = 'Gutscheincode.txt' ) ).

  ENDMETHOD.

ENDCLASS.
