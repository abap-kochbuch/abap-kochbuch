CLASS zcl_acb_add_user DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.



CLASS zcl_acb_add_user IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA(myself) = EXACT zacb_user_name( cl_abap_context_info=>get_user_technical_name( ) ).
    DATA(details) = zcl_acb_demo_generator=>determine_user_details( EXACT #( myself ) ).

    INSERT zacb_user FROM @( VALUE #(
        username   = myself
        last_name  = details-last_name
        first_name = details-first_name
        author     = abap_true
        admin      = abap_true
    ) ).
    IF sy-subrc = 0.
      out->write( |🧑‍🍳 { myself } was added| ).
    ELSE.
      out->write( |🧑‍🍳 { myself } already has a user master record| ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
