CLASS LHC_RAP_TDAT_CTS DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      GET
        RETURNING
          VALUE(RESULT) TYPE REF TO IF_MBC_CP_RAP_TDAT_CTS.

ENDCLASS.

CLASS LHC_RAP_TDAT_CTS IMPLEMENTATION.
  METHOD GET.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = 'ZACB_LABEL'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'Label' table = 'ZACB_LABEL' )
                                         ( entity = 'LabelText' table = 'ZACB_LABELT' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS LHC_ZACB_I_LABEL_S DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR LabelAll
        RESULT result,
      SELECTCUSTOMIZINGTRANSPTREQ FOR MODIFY
        IMPORTING
          KEYS FOR ACTION LabelAll~SelectCustomizingTransptReq
        RESULT result,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR LabelAll
        RESULT result.
ENDCLASS.

CLASS LHC_ZACB_I_LABEL_S IMPLEMENTATION.
  METHOD GET_INSTANCE_FEATURES.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF ZACB_I_Label_S IN LOCAL MODE
    ENTITY LabelAll
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%IS_DRAFT = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %TKY = all[ 1 ]-%TKY
               %ACTION-edit = edit_flag
               %ASSOC-_Label = edit_flag
               %ACTION-SelectCustomizingTransptReq = selecttransport_flag ) ).
  ENDMETHOD.
  METHOD SELECTCUSTOMIZINGTRANSPTREQ.
    MODIFY ENTITIES OF ZACB_I_Label_S IN LOCAL MODE
      ENTITY LabelAll
        UPDATE FIELDS ( TransportRequestID HideTransport )
        WITH VALUE #( FOR key IN keys
                        ( %TKY               = key-%TKY
                          TransportRequestID = key-%PARAM-transportrequestid
                          HideTransport      = abap_false ) ).

    READ ENTITIES OF ZACB_I_Label_S IN LOCAL MODE
      ENTITY LabelAll
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %TKY   = entity-%TKY
                          %PARAM = entity ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD 'ZACB_I_LABEL' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%UPDATE      = is_authorized.
    result-%ACTION-Edit = is_authorized.
    result-%ACTION-SelectCustomizingTransptReq = is_authorized.
  ENDMETHOD.
ENDCLASS.
CLASS LSC_ZACB_I_LABEL_S DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_SAVER.
  PROTECTED SECTION.
    METHODS:
      SAVE_MODIFIED REDEFINITION,
      CLEANUP_FINALIZE REDEFINITION.
ENDCLASS.

CLASS LSC_ZACB_I_LABEL_S IMPLEMENTATION.
  METHOD SAVE_MODIFIED.
    READ TABLE update-LabelAll INDEX 1 INTO DATA(all).
    IF all-TransportRequestID IS NOT INITIAL.
      lhc_rap_tdat_cts=>get( )->record_changes(
                                  transport_request = all-TransportRequestID
                                  create            = REF #( create )
                                  update            = REF #( update )
                                  delete            = REF #( delete ) ).
    ENDIF.
  ENDMETHOD.
  METHOD CLEANUP_FINALIZE ##NEEDED.
  ENDMETHOD.
ENDCLASS.
CLASS LHC_ZACB_I_LABEL DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      VALIDATETRANSPORTREQUEST FOR VALIDATE ON SAVE
        IMPORTING
          KEYS FOR Label~ValidateTransportRequest,
      VALIDATEDATACONSISTENCY FOR VALIDATE ON SAVE
        IMPORTING
          KEYS FOR Label~ValidateDataConsistency,
      GET_GLOBAL_FEATURES FOR GLOBAL FEATURES
        IMPORTING
          REQUEST REQUESTED_FEATURES FOR Label
        RESULT result,
      DEPRECATE FOR MODIFY
        IMPORTING
          KEYS FOR ACTION Label~Deprecate
        RESULT result,
      INVALIDATE FOR MODIFY
        IMPORTING
          KEYS FOR ACTION Label~Invalidate
        RESULT result,
      COPYLABEL FOR MODIFY
        IMPORTING
          KEYS FOR ACTION Label~CopyLabel,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR Label
        RESULT result,
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR Label
        RESULT result.
ENDCLASS.

CLASS LHC_ZACB_I_LABEL IMPLEMENTATION.
  METHOD VALIDATETRANSPORTREQUEST.
    DATA change TYPE REQUEST FOR CHANGE ZACB_I_Label_S.
    SELECT SINGLE TransportRequestID
      FROM ZACB_LABEL_D_S
      WHERE SingletonID = 1
      INTO @DATA(TransportRequestID).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = TransportRequestID
                                table             = 'ZACB_LABEL'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-Label ) ).
  ENDMETHOD.
  METHOD VALIDATEDATACONSISTENCY.
    READ ENTITIES OF ZACB_I_Label_S IN LOCAL MODE
      ENTITY Label
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(Label).
    DATA(table) = xco_cp_abap_repository=>object->tabl->database_table->for( 'ZACB_LABEL' ).
    DATA: BEGIN OF element_check,
            element  TYPE string,
            check    TYPE ref to if_xco_dp_check,
          END OF element_check,
          element_checks LIKE TABLE OF element_check WITH EMPTY KEY.
    LOOP AT Label ASSIGNING FIELD-SYMBOL(<Label>).
      element_checks = VALUE #(
        ( element = 'LabelColor' check = table->field( 'LABEL_COLOR' )->get_value_check( ia_value = <Label>-LabelColor  ) )
        ( element = 'ConfigDeprecationCode' check = table->field( 'CONFIGDEPRECATIONCODE' )->get_value_check( ia_value = <Label>-ConfigDeprecationCode  ) )
      ).
      LOOP AT element_checks INTO element_check.
        INSERT VALUE #( %TKY        = <Label>-%TKY
                        %STATE_AREA = |Label_{ element_check-element }| ) INTO TABLE reported-Label.
        element_check-check->execute( ).
        CHECK element_check-check->passed = xco_cp=>boolean->false.
        INSERT VALUE #( %TKY        = <Label>-%TKY ) INTO TABLE failed-Label.
        LOOP AT element_check-check->messages ASSIGNING FIELD-SYMBOL(<msg>).
          INSERT VALUE #( %TKY = <Label>-%TKY
                          %STATE_AREA = 'Label_Input_Check'
                          %PATH-LabelAll-SingletonID = 1
                          %PATH-LabelAll-%IS_DRAFT = <Label>-%IS_DRAFT
                          %msg = new_message(
                                   id       = <msg>->value-msgid
                                   number   = <msg>->value-msgno
                                   severity = if_abap_behv_message=>severity-error
                                   v1       = <msg>->value-msgv1
                                   v2       = <msg>->value-msgv2
                                   v3       = <msg>->value-msgv3
                                   v4       = <msg>->value-msgv4 ) ) INTO TABLE reported-Label ASSIGNING FIELD-SYMBOL(<rep>).
          ASSIGN COMPONENT element_check-element OF STRUCTURE <rep>-%ELEMENT TO FIELD-SYMBOL(<comp>).
          <comp> = if_abap_behv=>mk-on.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
  METHOD GET_GLOBAL_FEATURES.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%UPDATE = edit_flag.
    result-%ASSOC-_LabelText = edit_flag.
  ENDMETHOD.
  METHOD DEPRECATE.
    MODIFY ENTITIES OF ZACB_I_Label_S IN LOCAL MODE
      ENTITY Label
      UPDATE
        FIELDS ( ConfigDeprecationCode ConfigDeprecationCode_Critlty )
        WITH VALUE #( FOR key IN keys
                       ( %TKY            = key-%TKY
                         ConfigDeprecationCode            = 'W'
                         ConfigDeprecationCode_Critlty = 2 ) ).
    READ ENTITIES OF ZACB_I_Label_S IN LOCAL MODE
      ENTITY Label
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(Label).
    result = VALUE #( FOR row IN Label
                        ( %TKY   = row-%TKY
                          %PARAM  = row ) ).
    reported-Label = VALUE #( FOR key IN keys ( %CID = key-%CID_REF
                                                   %TKY = key-%TKY
                                                   %ACTION-Deprecate = if_abap_behv=>mk-on
                                                   %ELEMENT-ConfigDeprecationCode = if_abap_behv=>mk-on
                                                   %msg = mbc_cp_api=>message( )->get_item_deprecated( )
                                                   %PATH-LabelAll-%IS_DRAFT = key-%IS_DRAFT
                                                   %PATH-LabelAll-SingletonID = 1 ) ).
  ENDMETHOD.
  METHOD INVALIDATE.
    MODIFY ENTITIES OF ZACB_I_Label_S IN LOCAL MODE
      ENTITY Label
      UPDATE
        FIELDS ( ConfigDeprecationCode ConfigDeprecationCode_Critlty )
        WITH VALUE #( FOR key IN keys
                       ( %TKY            = key-%TKY
                         ConfigDeprecationCode            = 'E'
                         ConfigDeprecationCode_Critlty = 1 ) ).
    READ ENTITIES OF ZACB_I_Label_S IN LOCAL MODE
      ENTITY Label
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(Label).
    result = VALUE #( FOR row IN Label
                        ( %TKY   = row-%TKY
                          %PARAM  = row ) ).
    reported-Label = VALUE #( FOR key IN keys ( %CID = key-%CID_REF
                                                   %TKY = key-%TKY
                                                   %ACTION-Invalidate = if_abap_behv=>mk-on
                                                   %ELEMENT-ConfigDeprecationCode = if_abap_behv=>mk-on
                                                   %msg = mbc_cp_api=>message( )->get_item_invalidated( )
                                                   %PATH-LabelAll-%IS_DRAFT = key-%IS_DRAFT
                                                   %PATH-LabelAll-SingletonID = 1 ) ).
  ENDMETHOD.
  METHOD COPYLABEL.
    DATA new_Label TYPE TABLE FOR CREATE ZACB_I_Label_S\_Label.
    DATA new_LabelText TYPE TABLE FOR CREATE ZACB_I_Label_S\\Label\_LabelText.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-Label = VALUE #( FOR fkey IN keys ( %TKY = fkey-%TKY ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF ZACB_I_Label_S IN LOCAL MODE
      ENTITY Label
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_Label)
      FAILED DATA(read_failed).
    READ ENTITIES OF ZACB_I_Label_S IN LOCAL MODE
      ENTITY Label BY \_LabelText
      ALL FIELDS WITH CORRESPONDING #( ref_Label )
      RESULT DATA(ref_LabelText).

    LOOP AT ref_Label ASSIGNING FIELD-SYMBOL(<ref_Label>).
      DATA(key) = keys[ KEY draft %TKY = <ref_Label>-%TKY ].
      DATA(key_cid) = key-%CID.
      APPEND VALUE #(
        %TKY-SingletonID = 1
        %IS_DRAFT = <ref_Label>-%IS_DRAFT
        %TARGET = VALUE #( (
          %CID = key_cid
          %IS_DRAFT = <ref_Label>-%IS_DRAFT
          %DATA = CORRESPONDING #( <ref_Label> EXCEPT
            ConfigDeprecationCode
            LabelId
            LastChangedAt
            LocalLastChangedAt
            SingletonID
        ) ) )
      ) TO new_Label ASSIGNING FIELD-SYMBOL(<new_Label>).
      <new_Label>-%TARGET[ 1 ]-LabelId = key-%PARAM-LabelId.
      FIELD-SYMBOLS <new_LabelText> LIKE LINE OF new_LabelText.
      UNASSIGN <new_LabelText>.
      LOOP AT ref_LabelText ASSIGNING FIELD-SYMBOL(<ref_LabelText>) USING KEY draft WHERE %TKY-%IS_DRAFT = key-%TKY-%IS_DRAFT
              AND %TKY-LabelId = key-%TKY-LabelId.
        IF <new_LabelText> IS NOT ASSIGNED.
          INSERT VALUE #( %CID_REF  = key_cid
                          %IS_DRAFT = key-%IS_DRAFT ) INTO TABLE new_LabelText ASSIGNING <new_LabelText>.
        ENDIF.
        INSERT VALUE #( %CID = key_cid && <ref_LabelText>-Language
                        %IS_DRAFT = key-%IS_DRAFT
                        %DATA = CORRESPONDING #( <ref_LabelText> EXCEPT
                                                 LabelId
                                                 LocalLastChangedAt
                                                 SingletonID
        ) ) INTO TABLE <new_LabelText>-%TARGET ASSIGNING FIELD-SYMBOL(<target>).
        <target>-%KEY-LabelId = key-%PARAM-LabelId.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF ZACB_I_Label_S IN LOCAL MODE
      ENTITY LabelAll CREATE BY \_Label
      FIELDS (
               LabelId
               LabelColor
             ) WITH new_Label
      ENTITY Label CREATE BY \_LabelText
      FIELDS (
               Language
               LabelId
               LabelText
             ) WITH new_LabelText
      MAPPED DATA(mapped_create)
      FAILED failed
      REPORTED reported.

    mapped-Label = mapped_create-Label.
    INSERT LINES OF read_failed-Label INTO TABLE failed-Label.

    IF failed-Label IS INITIAL.
      reported-Label = VALUE #( FOR created IN mapped-Label (
                                                 %CID = created-%CID
                                                 %ACTION-CopyLabel = if_abap_behv=>mk-on
                                                 %MSG = mbc_cp_api=>message( )->get_item_copied( )
                                                 %PATH-LabelAll-%IS_DRAFT = created-%IS_DRAFT
                                                 %PATH-LabelAll-SingletonID = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD 'ZACB_I_LABEL' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%ACTION-Deprecate = is_authorized.
    result-%ACTION-Invalidate = is_authorized.
    result-%ACTION-CopyLabel = is_authorized.
  ENDMETHOD.
  METHOD GET_INSTANCE_FEATURES.
    READ ENTITIES OF ZACB_I_Label_S IN LOCAL MODE
      ENTITY Label
      FIELDS ( ConfigDeprecationCode ) WITH CORRESPONDING #( keys )
      RESULT DATA(Label).

    result =
      VALUE #(
        FOR row IN Label
        LET Deprecate = COND #( WHEN row-ConfigDeprecationCode = '' AND row-%IS_DRAFT = if_abap_behv=>mk-on
                                THEN if_abap_behv=>fc-o-enabled
                                ELSE if_abap_behv=>fc-o-disabled  )
            Invalidate = COND #( WHEN ( row-ConfigDeprecationCode = '' OR row-ConfigDeprecationCode = 'W' ) AND row-%IS_DRAFT = if_abap_behv=>mk-on
                                THEN if_abap_behv=>fc-o-enabled
                                ELSE if_abap_behv=>fc-o-disabled  )
        IN ( %TKY              = row-%TKY
             %ACTION-Deprecate = Deprecate
             %ACTION-Invalidate = Invalidate
                                        %ACTION-CopyLabel = COND #( WHEN row-%IS_DRAFT = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
   ) ).
  ENDMETHOD.
ENDCLASS.
CLASS LHC_ZACB_I_LABELTEXT DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      VALIDATETRANSPORTREQUEST FOR VALIDATE ON SAVE
        IMPORTING
          KEYS FOR LabelText~ValidateTransportRequest,
      GET_GLOBAL_FEATURES FOR GLOBAL FEATURES
        IMPORTING
          REQUEST REQUESTED_FEATURES FOR LabelText
        RESULT result.
ENDCLASS.

CLASS LHC_ZACB_I_LABELTEXT IMPLEMENTATION.
  METHOD VALIDATETRANSPORTREQUEST.
    DATA change TYPE REQUEST FOR CHANGE ZACB_I_Label_S.
    SELECT SINGLE TransportRequestID
      FROM ZACB_LABEL_D_S
      WHERE SingletonID = 1
      INTO @DATA(TransportRequestID).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = TransportRequestID
                                table             = 'ZACB_LABELT'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-LabelText ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_FEATURES.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%UPDATE = edit_flag.
    result-%DELETE = edit_flag.
  ENDMETHOD.
ENDCLASS.
