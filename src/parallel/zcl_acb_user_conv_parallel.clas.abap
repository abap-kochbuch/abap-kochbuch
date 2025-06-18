CLASS zcl_acb_user_conv_parallel DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_acb_user_converter.
ENDCLASS.


CLASS zcl_acb_user_conv_parallel IMPLEMENTATION.
  METHOD zif_acb_user_converter~convert_csv_to_users.
    DATA groups TYPE string_table.
    FIELD-SYMBOLS <group> TYPE string.

    DATA(text) = csv.

    REPLACE ALL OCCURRENCES OF
      cl_abap_char_utilities=>cr_lf(1)
            IN text WITH ''.
    SPLIT text AT |\n| INTO TABLE DATA(lines).

    LOOP AT lines ASSIGNING FIELD-SYMBOL(<line>).
      IF sy-tabix = 1 OR sy-tabix MOD 10 = 0.
        INSERT <line> INTO TABLE groups ASSIGNING <group>.
      ELSE.
        <group> &&= |\n{ <line> }|.
      ENDIF.
    ENDLOOP.

    DATA(tasks) = VALUE cl_abap_parallel=>t_in_inst_tab( FOR g IN groups
                                                         ( NEW
                                                           zcl_acb_user_conversion_task( csv       = g
                                                                                         delimiter = delimiter ) ) ).

    NEW cl_abap_parallel( p_num_tasks = 3 )->run_inst( EXPORTING p_in_tab  = tasks
                                                       IMPORTING p_out_tab = DATA(processing_results) ).
    LOOP AT processing_results ASSIGNING FIELD-SYMBOL(<task>).
      IF <task>-inst IS NOT BOUND.
        IF <task>-message IS NOT INITIAL.
          cl_message_helper=>set_msg_vars_for_clike( <task>-message ).
          RAISE EXCEPTION TYPE zcx_acb_user_conversion_error USING MESSAGE.
        ELSE.
          RAISE EXCEPTION NEW zcx_acb_user_conversion_error( ).
        ENDIF.
      ENDIF.
      DATA(task) = CAST zcl_acb_user_conversion_task( <task>-inst ).
      INSERT LINES OF task->get_result( ) INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
