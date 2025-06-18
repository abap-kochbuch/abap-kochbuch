CLASS zcl_acb_numberrange DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS delete_numberrange_object.
    METHODS read_numberrange_object.
    METHODS update_interval IMPORTING nrlevel TYPE int1.
    METHODS create_interval.
    METHODS delete_interval.
    METHODS read_number.
    METHODS exists_interval RETURNING VALUE(result_exist) TYPE abap_bool.
    METHODS get_number RETURNING VALUE(result_number) TYPE zacb_recipe_id.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS zcl_acb_numberrange IMPLEMENTATION.


  METHOD exists_interval.
    TRY.
        cl_numberrange_objects=>read(
          EXPORTING
            language        = cl_abap_context_info=>get_user_language_abap_format( )
            object          = 'ZACB_RECIP'
          IMPORTING
            attributes      = DATA(attributes)
            interval_exists = DATA(interval_exists)
            obj_text        = DATA(obj_text)
        ).
        result_exist = interval_exists.
      CATCH cx_nr_object_not_found cx_number_ranges  cx_abap_context_info_error INTO DATA(exception).
        RAISE SHORTDUMP exception.
    ENDTRY.
  ENDMETHOD.
  METHOD delete_numberrange_object.
    TRY.
        cl_numberrange_objects=>delete(
          EXPORTING
            object = 'ZACB_RECIP' ).
      CATCH cx_nr_object_not_found cx_number_ranges  INTO DATA(exception).
        RAISE SHORTDUMP exception.
    ENDTRY.
  ENDMETHOD.

  METHOD read_numberrange_object.
    TRY.
        cl_numberrange_objects=>read(
          EXPORTING
            language        = cl_abap_context_info=>get_user_language_abap_format( )
            object          = 'ZACB_RECIP'
          IMPORTING
            attributes      = DATA(attributes)
            interval_exists = DATA(interval_exists)
            obj_text        = DATA(obj_text)
        ).
      CATCH cx_nr_object_not_found cx_number_ranges  cx_abap_context_info_error INTO DATA(exception).
        RAISE SHORTDUMP exception.
    ENDTRY.
  ENDMETHOD.

  METHOD create_interval.
    TRY.
        cl_numberrange_intervals=>create(
          EXPORTING
            interval  = VALUE #( (
                                 nrrangenr  = '01'
                                 externind  = ''
                                 fromnumber = '00001'
                                 tonumber   = '20000'
                                 procind    = 'I' ) )
            object    = 'ZACB_RECIP'
          IMPORTING
            error     = DATA(error)
            error_inf = DATA(error_inf)
            error_iv  = DATA(error_iv)
            warning   = DATA(warning) ).

      CATCH cx_nr_object_not_found cx_number_ranges INTO DATA(exception).
        RAISE SHORTDUMP exception.
    ENDTRY.
  ENDMETHOD.

  METHOD update_interval.
    TRY.
        cl_numberrange_intervals=>update(
          EXPORTING
            interval  = VALUE #( (
                                 nrrangenr  = '01'
                                 fromnumber = '00001'
                                 tonumber   = '20000'
                                 externind  = ''
                                 nrlevel    = CONV #( nrlevel )
                                 procind    = 'U' ) )
            object    = 'ZACB_RECIP'
          IMPORTING
            error     = DATA(error)
            error_inf = DATA(error_inf)
            error_iv  = DATA(error_iv)
            warning   = DATA(warning) ).
      CATCH cx_nr_object_not_found cx_number_ranges INTO DATA(exception).
        RAISE SHORTDUMP exception.
    ENDTRY.
  ENDMETHOD.


  METHOD delete_interval.
    TRY.
        cl_numberrange_intervals=>delete(
          EXPORTING
            interval  = VALUE #( (
                                 nrrangenr  = '01'
                                 fromnumber = '00001'
                                 tonumber   = '20000'
                                 externind  = ''
                                 procind    = 'D' ) )
            object    = 'ZACB_RECIP'
          IMPORTING
            error     = DATA(error)
            error_inf = DATA(error_inf)
            error_iv  = DATA(error_iv)
            warning   = DATA(warning) ).
      CATCH cx_nr_object_not_found cx_number_ranges INTO DATA(exception).
        RAISE SHORTDUMP exception.
    ENDTRY.
  ENDMETHOD.


  METHOD read_number.
    TRY.
        cl_numberrange_intervals=>read(
          EXPORTING
            object       = 'ZACB_RECIP'
            nr_range_nr1 = ' '
            nr_range_nr2 = ' '
            subobject    = ' '
          IMPORTING
            interval     = DATA(interval) ).
      CATCH cx_nr_object_not_found cx_number_ranges INTO DATA(exception).
        RAISE SHORTDUMP exception.
    ENDTRY.
  ENDMETHOD.



  METHOD get_number.
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = 'ZACB_RECIP'
            quantity          = 1
          IMPORTING
            number            = DATA(number)
            returned_quantity = DATA(returned_quantity)
            returncode        = DATA(rcode) ).
        result_number = number.
      CATCH cx_nr_object_not_found cx_number_ranges INTO DATA(exception).
        RAISE SHORTDUMP exception.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
