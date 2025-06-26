CLASS zcl_acb_debug_info DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    DATA out TYPE REF TO if_oo_adt_classrun_out.

    METHODS display_debug_info.

    METHODS output_table_entry_count.
    METHODS output_system_fields.
    METHODS output_time_info.
    METHODS output_user_info.
    METHODS output_technical_run_time_info.
    METHODS output_messages.
    METHODS output_system_info.

    METHODS check_tables_not_empty EXCEPTIONS data_not_generated.
    METHODS output_abap_cloud_system_flds.
    METHODS output_standard_system_fields.
    METHODS output_internal_system_fields.
    METHODS output_obsolete_system_fields.
ENDCLASS.


CLASS zcl_acb_debug_info IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    me->out = out.
    display_debug_info( ).
  ENDMETHOD.

  METHOD display_debug_info.
    out->write( |🧑‍💻 Debug-Informationen für ABAP Kochbuch 👨‍🍳| ).

    output_table_entry_count( ).
    output_system_fields( ).
    output_time_info( ).
    output_user_info( ).
    output_technical_run_time_info( ).
    output_messages( ).
    output_system_info( ).
  ENDMETHOD.

  METHOD output_table_entry_count.
    out->write( |🧮 Füllstand der Datenbanktabellen| ).

    SELECT FROM zacb_recipe FIELDS COUNT(*).
    out->write( |Anzahl Rezepte: { sy-dbcnt NUMBER = USER }| ).

    SELECT FROM zacb_ingredient FIELDS COUNT(*).
    out->write( |Anzahl Zutaten: { sy-dbcnt NUMBER = USER }| ).

    SELECT FROM zacb_review FIELDS COUNT(*).
    out->write( |Anzahl Reviews: { sy-dbcnt NUMBER = USER }| ).

    SELECT FROM zacb_user FIELDS COUNT(*).
    out->write( |Anzahl Benutzer: { sy-dbcnt NUMBER = USER }| ).

*    SELECT FROM zacb_label FIELDS COUNT(*).
*    out->write( |Anzahl Labeles: { sy-dbcnt NUMBER = USER }| ).

  ENDMETHOD.

  METHOD output_system_fields.
    out->write( |👀 Systemfelder| ).
    output_abap_cloud_system_flds( ).
    output_standard_system_fields( ).
    output_internal_system_fields( ).
    output_obsolete_system_fields( ).
  ENDMETHOD.

  METHOD output_time_info.
    out->write( |🕰️ Zeitinformationen| ).

    out->write( |Datum in Systemzeit laut sy-datum: { sy-datum DATE = USER }| ).
    out->write( |Uhrzeit in Systemzeit laut sy-uzeit: { sy-uzeit TIME = USER }| ).

    " Zeitreise, gestern war schöner
*    sy-datum = sy-datum - 1. " Syntaxfehler

    out->write( |Datum in UTC laut cl_abap_context_info: | &&
      |{ cl_abap_context_info=>get_system_date( ) DATE = USER }| ).
    out->write( |Uhrzeit in UTC laut cl_abap_context_info: | &&
      |{ cl_abap_context_info=>get_system_time( ) TIME = USER }| ).

    DATA now TYPE timestampl.
    GET TIME STAMP FIELD now.
    out->write( |Zeitstempel in DEC(21,7) laut GET TIME STAMP: | &&
      |{ now TIMESTAMP = USER TIMEZONE = 'UTC' }| ).

    DATA(now_utclong) = utclong_current( ).
    out->write( |Zeitstempel in utclong laut utclong_current: | &&
      |{ now TIMESTAMP = USER TIMEZONE = 'UTC' }| ).

    DATA(now_one_line) = cl_abap_tstmp=>utclong2tstmp( utclong_current( ) ).
    out->write( |Zeitstempel in DEC(21,7) laut utclong_current: | &&
      |{ now_one_line TIMESTAMP = USER TIMEZONE = 'UTC' }| ).

    DATA(system_date) = xco_cp=>sy->date( xco_cp_time=>time_zone->utc ).
    out->write( |Datum in UTC laut XCO (string): | &&
      system_date->as( xco_cp_time=>format->abap )->value ).
    DATA(system_date_d) = EXACT d( system_date->as( xco_cp_time=>format->abap )->value ).
    out->write( |Datum in UTC laut XCO (d): | &&
      |{ system_date_d DATE = USER }| ).

    DATA(tomorrow) = system_date->add( iv_day = 1 ).
    out->write( |Morgen in UTC laut XCO in...| ).
    out->write( |  string: | &&
      tomorrow->as( xco_cp_time=>format->abap )->value ).
    out->write( |  ISO 8601: | &&
      tomorrow->as( xco_cp_time=>format->iso_8601_basic )->value ).
    out->write( |  ISO 8601 erweitert: | &&
      tomorrow->as( xco_cp_time=>format->iso_8601_extended )->value ).

    DATA(system_time) = xco_cp=>sy->time( xco_cp_time=>time_zone->utc ).
    out->write( |Uhrzeit in UTC laut XCO (string): | &&
      system_time->as( xco_cp_time=>format->abap )->value ).
    DATA(system_time_t) = EXACT t(
      system_time->as( xco_cp_time=>format->abap )->value ).
    out->write( |Uhrzeit in UTC laut XCO (t): | &&
      |{ system_time_t TIME = USER }| ).
    out->write( |Uhrzeit in UTC laut XCO (ISO 8601): | &&
      system_time->as( xco_cp_time=>format->iso_8601_basic )->value ).
    out->write( |Uhrzeit in UTC laut XCO (ISO 8601 erweitert): | &&
      system_time->as( xco_cp_time=>format->iso_8601_extended )->value ).

    DATA(moment) = xco_cp=>sy->moment( xco_cp_time=>time_zone->utc ).
    out->write( |Zeitstempel in UTC laut XCO (string): | &&
      moment->as( xco_cp_time=>format->abap )->value ).

    DATA(now_xco) = EXACT timestamp(
      moment->as( xco_cp_time=>format->abap )->value ).
    out->write( |Zeitstempel in UTC laut XCO (timestamp): | &&
      |{ now_xco TIMESTAMP = USER TIMEZONE = 'UTC' }| ).
    out->write( |Zeitstempel in UTC laut XCO (ISO 8601): | &&
      moment->as( xco_cp_time=>format->iso_8601_basic )->value ).
    out->write( |Zeitstempel in UTC laut XCO (ISO 8601 erweitert): | &&
      moment->as( xco_cp_time=>format->iso_8601_extended )->value ).

    DATA(tomorrow_3pm) = tomorrow->get_moment(
      iv_hour   = '15'
      iv_minute = '00'
      iv_second = '00' ).
    DATA(in_24_hours) = moment->add( iv_hour = '24' ).
    DATA(interval) = moment->interval_to( tomorrow_3pm ).
    IF interval->contains( in_24_hours ).
      out->write( |Bis morgen 15 Uhr sind es mehr als 24h| ).
    ELSE.
      out->write( |Bis morgen 15 Uhr sind es weniger als 24h| ).
    ENDIF.
  ENDMETHOD.

  METHOD output_user_info.
    DATA business_partner TYPE string.

    out->write( |🧑 Benutzerinformationen| ).

    out->write( |Angemeldeter Benutzer laut sy-uname: { sy-uname }| ).

    out->write( |Angemeldeter Benutzer laut cl_abap_context_info: | &&
      cl_abap_context_info=>get_user_technical_name( ) ).

    out->write( |Weitere Benutzerinformationen von cl_abap_context_info:| ).
    out->write( |  Alias: | &&
      cl_abap_context_info=>get_user_alias( ) ).

    TRY.
        business_partner = cl_abap_context_info=>get_user_business_partner_id( ).
      CATCH cx_abap_context_info_error INTO DATA(bp_error).
        business_partner = bp_error->get_text( ).
    ENDTRY.
    out->write( |  Geschäftspartner: { business_partner }| ).

    TRY.
        out->write( |  Beschreibung: | &&
          cl_abap_context_info=>get_user_description( ) ).
        out->write( |  Formatierter Name: | &&
          cl_abap_context_info=>get_user_formatted_name( ) ).
        out->write( |  Zeitzone: | &&
          cl_abap_context_info=>get_user_time_zone( ) ).
        out->write( |  Sprache: | &&
          cl_abap_context_info=>get_user_language_abap_format( ) ).

        out->write( |Spezifische Sprache von { sy-uname }: | &&
          cl_abap_context_info=>get_user_language_abap_format( sy-uname ) ).
      CATCH cx_abap_context_info_error INTO DATA(context_error).
        out->write( context_error ).
    ENDTRY.

    out->write( |Angemeldeter Benutzer laut XCO: | &&
      xco_cp=>sy->user( )->name ).

    out->write( |Benutzerkennung spezifischer User XCO: | &&
      xco_cp_system=>user( sy-uname )->name ).
  ENDMETHOD.

  METHOD output_technical_run_time_info.
    out->write( |💻 Technische Laufzeitinformationen| ).

    out->write( |System: { sy-sysid }| ).
    out->write( |Mandant: { sy-mandt }| ).
    out->write( |Program: { sy-repid }| ).

    out->write( |Sprache: { sy-langu }| ).

    DATA(language) = xco_cp=>sy->language( ).
    out->write( |Sprache (XCO): { language->get_name( ) } | &&
      |({ language->value }/| &&
      |{ language->as( xco_cp_language=>format->iso_639 ) })| ).

    out->write( |Callstack:| ).
    DATA(callstack) = xco_cp=>current->call_stack->full( ).
    callstack = callstack->to->last_occurrence_of(
      xco_cp_call_stack=>line_pattern->method(
        )->where_class_name_matches( 'Z(CL|IF|BP)_ACB_.*' ) ).
    out->write(
      callstack->as_text( xco_cp_call_stack=>format->adt( )
        )->get_lines( )->join( |\n| )->value ).
  ENDMETHOD.

  METHOD output_messages.
    out->write( |📰 Meldungen | ).

    check_tables_not_empty(
      EXCEPTIONS
        data_not_generated = 1
        OTHERS             = 2 ).
    IF sy-subrc <> 0.
      DATA(message) = xco_cp=>sy->message( ).
      out->write(
        |{ message->get_type( )->value }: | &&
        message->get_text( ) ).
    ENDIF.
  ENDMETHOD.

  METHOD check_tables_not_empty.
    SELECT SINGLE FROM zacb_recipe
      FIELDS @abap_true
      INTO @DATA(not_empty).
    IF not_empty = abap_false OR 1 = 1. " Für Demozwecke immer auslösen
      MESSAGE e001(zacb_common)
         WITH 'ZACB_RECIPE' 'ZCL_ACB_DEMO_GENERATOR'
         RAISING data_not_generated.
    ENDIF.
  ENDMETHOD.

  METHOD output_system_info.
    out->write( |ℹ️ System Informationen| ).

    out->write( |Tenant Informationen 🌤️| ).
    DATA(tenant) = xco_cp=>current->tenant( ).
    IF tenant IS BOUND.
      DATA(ui_url) = tenant->get_url( xco_cp_tenant=>url_type->ui ).
      IF ui_url IS BOUND.
        out->write( |  UI URL: | &&
          |{ ui_url->get_protocol( ) }://| &&
          |{ ui_url->get_host( ) }:| &&
          |{ ui_url->get_port( ) }| ).
      ELSE.
        out->write( |  UI URL: nicht verfügbar| ).
      ENDIF.
      out->write( |  ID: | &&
        tenant->get_id( ) ).
      out->write( |  Subaccount ID: | &&
        COND #( LET sa_id = tenant->get_subaccount_id( ) IN
                WHEN sa_id IS BOUND
                THEN sa_id->as_string( ) ) ).
      out->write( |  Global Account ID: | &&
        COND #( LET ga_id = tenant->get_global_account_id( ) IN
                WHEN ga_id IS BOUND
                THEN ga_id->as_string( ) ) ).
      out->write( |  GUID: | &&
        COND #( LET guid = tenant->get_guid( ) IN
                WHEN guid IS BOUND
                THEN guid->as( xco_cp_uuid=>format->c36 )->value ) ).
    ELSE.
      out->write( |  System ohne Tenant| ).
    ENDIF.

    DATA home_component TYPE REF TO if_xco_software_component.

    DATA(candidates) = VALUE if_xco_software_component=>list(
      ( xco_cp_system=>software_component->for_name( 'HOME' ) )
      ( xco_cp_system=>software_component->for_name( 'ZLOCAL' ) ) ).

    LOOP AT candidates INTO DATA(candidate).
      IF home_component IS BOUND AND
         candidate->is_home_component( ).
        FREE home_component.
        EXIT.
      ELSEIF candidate->is_home_component( ).
        home_component = candidate.
      ENDIF.
    ENDLOOP.

    DATA(component_text) = COND #(
      WHEN home_component IS BOUND
      THEN home_component->name
      ELSE |konnte nicht eindeutig ermittelt werden| ).

    out->write( |HOME Softwarekomponente im System: { component_text }| ).

    DATA(basis) = xco_cp_system=>software_component->for_name( 'SAP_BASIS' ).
    IF basis->get_extendability( ) = xco_cp_software_component=>extendability->extendable.
      out->write( |Softwarekomponente { basis->name } ist erweiterbar| ).
    ELSE.
      out->write( |Softwarekomponente { basis->name } ist nicht erweiterbar| ).
    ENDIF.

    out->write( |Installierte Sprachen 🗣️| ).

    out->write( |  Mit XCO:| ).
    LOOP AT xco_cp_system=>languages->installed->get( ) INTO DATA(language).
      out->write( |  { language->as( xco_cp_language=>format->iso_639 ) }: | &&
        language->get_long_text_description( ) ).
    ENDLOOP.

    out->write( |  Mit CDS:| ).
    SELECT FROM I_Language
      FIELDS LanguageISOCode,
             \_Text[ ONE TO ONE WHERE Language = @sy-langu ]-LanguageName
      ORDER BY LanguageISOCode
      INTO TABLE @DATA(languages).
    LOOP AT languages ASSIGNING FIELD-SYMBOL(<language>).
      out->write( |  { <language>-LanguageISOCode }: { <language>-LanguageName }| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD output_abap_cloud_system_flds.
    out->write( |Freigegebene Systemfelder in ABAP Cloud:| ).
    out->write( |  sy-batch: { sy-batch }| ).
    out->write( |  sy-dbcnt: { sy-dbcnt }| ).
    out->write( |  sy-fdpos: { sy-fdpos }| ).
    out->write( |  sy-index: { sy-index }| ).
    out->write( |  sy-langu: { sy-langu }| ).
    out->write( |  sy-mandt: { sy-mandt }| ).
    out->write( |  sy-msgid: { sy-msgid }| ).
    out->write( |  sy-msgno: { sy-msgno }| ).
    out->write( |  sy-msgty: { sy-msgty }| ).
    out->write( |  sy-msgv1: { sy-msgv1 }| ).
    out->write( |  sy-msgv2: { sy-msgv2 }| ).
    out->write( |  sy-msgv3: { sy-msgv3 }| ).
    out->write( |  sy-msgv4: { sy-msgv4 }| ).
    out->write( |  sy-subrc: { sy-subrc }| ).
    out->write( |  sy-sysid: { sy-sysid }| ).
    out->write( |  sy-tabix: { sy-tabix }| ).
    out->write( |  sy-uname: { sy-uname }| ).
  ENDMETHOD.

  METHOD output_standard_system_fields.
    out->write( |Zusätzliche freigegebene Systemfelder in Standard ABAP:| ).
    out->write( |  sy-abcde: { sy-abcde }| ).
    out->write( |  sy-binpt: { sy-binpt }| ).
    out->write( |  sy-calld: { sy-calld }| ).
    out->write( |  sy-callr: { sy-callr }| ).
    out->write( |  sy-colno: { sy-colno }| ).
    out->write( |  sy-cpage: { sy-cpage }| ).
    out->write( |  sy-cprog: { sy-cprog }| ).
    out->write( |  sy-cucol: { sy-cucol }| ).
    out->write( |  sy-curow: { sy-curow }| ).
    out->write( |  sy-datar: { sy-datar }| ).
    out->write( |  sy-datlo: { sy-datlo }| ).
    out->write( |  sy-datum: { sy-datum }| ).
    out->write( |  sy-dayst: { sy-dayst }| ).
    out->write( |  sy-dbnam: { sy-dbnam }| ).
    out->write( |  sy-dbsys: { sy-dbsys }| ).
    out->write( |  sy-dyngr: { sy-dyngr }| ).
    out->write( |  sy-dynnr: { sy-dynnr }| ).
    out->write( |  sy-fdayw: { sy-fdayw }| ).
    out->write( |  sy-host: { sy-host }| ).
    out->write( |  sy-ldbpg: { sy-ldbpg }| ).
    out->write( |  sy-lilli: { sy-lilli }| ).
    out->write( |  sy-linct: { sy-linct }| ).
    out->write( |  sy-linno: { sy-linno }| ).
    out->write( |  sy-linsz: { sy-linsz }| ).
    out->write( |  sy-lisel: { sy-lisel }| ).
    out->write( |  sy-listi: { sy-listi }| ).
    out->write( |  sy-loopc: { sy-loopc }| ).
    out->write( |  sy-lsind: { sy-lsind }| ).
    out->write( |  sy-macol: { sy-macol }| ).
    out->write( |  sy-marow: { sy-marow }| ).
    out->write( |  sy-modno: { sy-modno }| ).
    out->write( |  sy-opsys: { sy-opsys }| ).
    out->write( |  sy-pagno: { sy-pagno }| ).
    out->write( |  sy-pfkey: { sy-pfkey }| ).
    out->write( |  sy-saprl: { sy-saprl }| ).
    out->write( |  sy-scols: { sy-scols }| ).
    out->write( |  sy-slset: { sy-slset }| ).
    out->write( |  sy-spono: { sy-spono }| ).
    out->write( |  sy-srows: { sy-srows }| ).
    out->write( |  sy-staco: { sy-staco }| ).
    out->write( |  sy-staro: { sy-staro }| ).
    out->write( |  sy-stepl: { sy-stepl }| ).
    out->write( |  sy-tcode: { sy-tcode }| ).
    out->write( |  sy-tfill: { sy-tfill }| ).
    out->write( |  sy-timlo: { sy-timlo }| ).
    out->write( |  sy-title: { sy-title }| ).
    out->write( |  sy-tleng: { sy-tleng }| ).
    out->write( |  sy-tzone: { sy-tzone }| ).
    out->write( |  sy-ucomm: { sy-ucomm }| ).
    out->write( |  sy-uline: { sy-uline }| ).
    out->write( |  sy-uzeit: { sy-uzeit }| ).
    out->write( |  sy-vline: { sy-vline }| ).
    out->write( |  sy-wtitl: { sy-wtitl }| ).
    out->write( |  sy-zonlo: { sy-zonlo }| ).
  ENDMETHOD.

  METHOD output_internal_system_fields.
    out->write( |Interne Systemfelder:| ).
    out->write( |  sy-cfwae: { sy-cfwae }| ).
    out->write( |  sy-chwae: { sy-chwae }| ).
    out->write( |  sy-debug: { sy-debug }| ).
    out->write( |  sy-dsnam: { sy-dsnam }| ).
    out->write( |  sy-entry: { sy-entry }| ).
    out->write( |  sy-ffile: { sy-ffile }| ).
    out->write( |  sy-fleng: { sy-fleng }| ).
    out->write( |  sy-fodec: { sy-fodec }| ).
    out->write( |  sy-folen: { sy-folen }| ).
    out->write( |  sy-ftype: { sy-ftype }| ).
    out->write( |  sy-group: { sy-group }| ).
    out->write( |  sy-input: { sy-input }| ).
    out->write( |  sy-lpass: { sy-lpass }| ).
    out->write( |  sy-newpa: { sy-newpa }| ).
    out->write( |  sy-nrpag: { sy-nrpag }| ).
    out->write( |  sy-oncom: { sy-oncom }| ).
    out->write( |  sy-pauth: { sy-pauth }| ).
    out->write( |  sy-playo: { sy-playo }| ).
    out->write( |  sy-playp: { sy-playp }| ).
    out->write( |  sy-pnwpa: { sy-pnwpa }| ).
    out->write( |  sy-pri40: { sy-pri40 }| ).
    out->write( |  sy-prini: { sy-prini }| ).
    out->write( |  sy-prlog: { sy-prlog }| ).
    out->write( |  sy-repi2: { sy-repi2 }| ).
    out->write( |  sy-rstrt: { sy-rstrt }| ).
    out->write( |  sy-sfoff: { sy-sfoff }| ).
    out->write( |  sy-subcs: { sy-subcs }| ).
    out->write( |  sy-subty: { sy-subty }| ).
    out->write( |  sy-tabid: { sy-tabid }| ).
    out->write( |  sy-tlopc: { sy-tlopc }| ).
    out->write( |  sy-tstis: { sy-tstis }| ).
    out->write( |  sy-xcode: { sy-xcode }| ).
    out->write( |  sy-xform: { sy-xform }| ).
    out->write( |  sy-xprog: { sy-xprog }| ).
  ENDMETHOD.

  METHOD output_obsolete_system_fields.
    out->write( |Obsolete Systemfelder:| ).
    out->write( |  sy-appli: { sy-appli }| ).
    out->write( |  sy-batzd: { sy-batzd }| ).
    out->write( |  sy-batzm: { sy-batzm }| ).
    out->write( |  sy-batzo: { sy-batzo }| ).
    out->write( |  sy-batzs: { sy-batzs }| ).
    out->write( |  sy-batzw: { sy-batzw }| ).
    out->write( |  sy-brep4: { sy-brep4 }| ).
    out->write( |  sy-bspld: { sy-bspld }| ).
    out->write( |  sy-ccurs: { sy-ccurs }| ).
    out->write( |  sy-ccurt: { sy-ccurt }| ).
    out->write( |  sy-cdate: { sy-cdate }| ).
    out->write( |  sy-ctabl: { sy-ctabl }| ).
    out->write( |  sy-ctype: { sy-ctype }| ).
    out->write( |  sy-dcsys: { sy-dcsys }| ).
    out->write( |  sy-fmkey: { sy-fmkey }| ).
    out->write( |  sy-locdb: { sy-locdb }| ).
    out->write( |  sy-locop: { sy-locop }| ).
    out->write( |  sy-lstat: { sy-lstat }| ).
    out->write( |  sy-macdb: { sy-macdb }| ).
    out->write( |  sy-marky: { sy-marky }| ).
    out->write( |  sy-msgli: { sy-msgli }| ).
    out->write( |  sy-pagct: { sy-pagct }| ).
    out->write( |  sy-prefx: { sy-prefx }| ).
    out->write( |  sy-sfnam: { sy-sfnam }| ).
    out->write( |  sy-sponr: { sy-sponr }| ).
    out->write( |  sy-tfdsn: { sy-tfdsn }| ).
    out->write( |  sy-tmaxl: { sy-tmaxl }| ).
    out->write( |  sy-tname: { sy-tname }| ).
    out->write( |  sy-toccu: { sy-toccu }| ).
    out->write( |  sy-tpagi: { sy-tpagi }| ).
    out->write( |  sy-ttabc: { sy-ttabc }| ).
    out->write( |  sy-ttabi: { sy-ttabi }| ).
    out->write( |  sy-waers: { sy-waers }| ).
    out->write( |  sy-willi: { sy-willi }| ).
    out->write( |  sy-winco: { sy-winco }| ).
    out->write( |  sy-windi: { sy-windi }| ).
    out->write( |  sy-winro: { sy-winro }| ).
    out->write( |  sy-winsl: { sy-winsl }| ).
    out->write( |  sy-winx1: { sy-winx1 }| ).
    out->write( |  sy-winx2: { sy-winx2 }| ).
    out->write( |  sy-winy1: { sy-winy1 }| ).
    out->write( |  sy-winy2: { sy-winy2 }| ).
    out->write( |  sy-paart: { sy-paart }| ).
    out->write( |  sy-pdest: { sy-pdest }| ).
    out->write( |  sy-pexpi: { sy-pexpi }| ).
    out->write( |  sy-plist: { sy-plist }| ).
    out->write( |  sy-prabt: { sy-prabt }| ).
    out->write( |  sy-prbig: { sy-prbig }| ).
    out->write( |  sy-prcop: { sy-prcop }| ).
    out->write( |  sy-prdsn: { sy-prdsn }| ).
    out->write( |  sy-primm: { sy-primm }| ).
    out->write( |  sy-prnew: { sy-prnew }| ).
    out->write( |  sy-prrec: { sy-prrec }| ).
    out->write( |  sy-prrel: { sy-prrel }| ).
    out->write( |  sy-prtxt: { sy-prtxt }| ).
    out->write( |  sy-rtitl: { sy-rtitl }| ).
  ENDMETHOD.
ENDCLASS.
