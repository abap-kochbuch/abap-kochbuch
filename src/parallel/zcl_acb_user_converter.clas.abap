CLASS zcl_acb_user_converter DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_acb_user_converter.
ENDCLASS.


CLASS zcl_acb_user_converter IMPLEMENTATION.
  METHOD zif_acb_user_converter~convert_csv_to_users.
    IF delimiter IS INITIAL.
      RAISE EXCEPTION NEW zcx_acb_user_conversion_error(
                              textid = zcx_acb_user_conversion_error=>delimiter_not_specified ).
    ENDIF.

    DATA(text) = csv.

    REPLACE ALL OCCURRENCES OF
      cl_abap_char_utilities=>cr_lf(1)
            IN text WITH ''.

    SPLIT text AT |\n| INTO TABLE DATA(lines).

    LOOP AT lines ASSIGNING FIELD-SYMBOL(<line>).
      TRY.
          SPLIT <line> AT delimiter INTO TABLE DATA(fields).

          INSERT VALUE #( username   = EXACT #( fields[ 1 ] )
                          first_name = EXACT #( VALUE #( fields[ 2 ] OPTIONAL ) )
                          last_name  = EXACT #( VALUE #( fields[ 3 ] OPTIONAL ) )
                          mail       = EXACT #( VALUE #( fields[ 4 ] OPTIONAL ) )
                          author     = EXACT #( to_upper( VALUE #( fields[ 5 ] DEFAULT abap_false ) ) )
                          admin      = EXACT #( to_upper( VALUE #( fields[ 6 ] DEFAULT abap_false ) ) ) )
                 INTO TABLE result.

        CATCH cx_sy_itab_line_not_found
              cx_sy_conversion_error INTO DATA(format_error).
          RAISE EXCEPTION TYPE zcx_acb_user_conversion_error
                MESSAGE e004(zacb_user)
                EXPORTING previous = format_error.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
