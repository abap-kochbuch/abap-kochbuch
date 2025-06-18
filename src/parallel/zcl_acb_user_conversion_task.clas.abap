CLASS zcl_acb_user_conversion_task DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_abap_parallel.

    METHODS constructor IMPORTING csv       TYPE string
                                  delimiter TYPE string.

    METHODS get_result RETURNING VALUE(result) TYPE zif_acb_user_converter=>users
                       RAISING   zcx_acb_user_conversion_error.
  PRIVATE SECTION.
    DATA csv               TYPE string.
    DATA delimiter         TYPE string.
    DATA conversion_result TYPE zif_acb_user_converter=>users.
    DATA conversion_error  TYPE REF TO zcx_acb_user_conversion_error.
ENDCLASS.


CLASS zcl_acb_user_conversion_task IMPLEMENTATION.
  METHOD constructor.
    me->csv       = csv.
    me->delimiter = delimiter.
  ENDMETHOD.

  METHOD get_result.
    IF conversion_error IS BOUND.
      RAISE EXCEPTION conversion_error.
    ENDIF.
    RETURN conversion_result.
  ENDMETHOD.

  METHOD if_abap_parallel~do.
    TRY.
        conversion_result = NEW zcl_acb_user_converter( )->zif_acb_user_converter~convert_csv_to_users(
                                    csv       = csv
                                    delimiter = delimiter ).
      CATCH zcx_acb_user_conversion_error INTO conversion_error ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
