CLASS zcl_acb_user_conversion_demo DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    DATA converter TYPE REF TO zif_acb_user_converter.
ENDCLASS.


CLASS zcl_acb_user_conversion_demo IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA converter TYPE REF TO zif_acb_user_converter.

    DATA(use_parallel) = abap_true. " Adjustable in the debugger

    CASE use_parallel.
      WHEN abap_true.
        converter = NEW zcl_acb_user_conv_parallel( ).
      WHEN abap_false.
        converter = NEW zcl_acb_user_converter( ).
    ENDCASE.

    DATA(csv) = concat_lines_of(
      table = VALUE string_table(
        ( |{ cl_abap_context_info=>get_user_technical_name( ) };Manfred;Mustermann;;X;X| )
        ( `VOGTSR;Rawia;Vogts;vogtsr@example.com` )
        ( `KOCHK;Kjara;Koch;kochk@example.com` )
        ( `GABLERM;Mandalena;Gabler;gablerm@example.com` )
        ( `SCHAEFERK;Kim;Schäfer;schaeferk@example.com` )
        ( `SCHULTHEISSV;Verona;Schultheiss;schultheissv@example.com` )
        ( `ROTHBAUERM;Mariona;Rothbauer;rothbauerm@example.com` )
        ( `SCHULZM;Margitte;Schulz;schulzm@example.com` )
        ( `HOLZERS;Saria;Holzer;holzers@example.com` )
        ( `STEINK;Kim;Stein;steink@example.com` )
        ( `GROSSY;Yanthe;Groß;grossy@example.com` )
        ( `ROTM;Mariele;Rot;rotm@example.com` )
        ( `INGERSLEBENA;Agilrich;Ingersleben;ingerslebena@example.com` )
        ( `FAERBERD;Denise;Färber;faerberd@example.com` )
        ( `MARQUARDTA;Arnoldine;Marquardt;marquardta@example.com` )
        ( `BESTW;Walther;Best;bestw@example.com` )
        ( `KAISERP;Paulinus;Kaiser;kaiserp@example.com` )
        ( `SCHULTESV;Veronika;Schultes;schultesv@example.com` )
        ( `BRUHNO;Olrik;Bruhn;bruhno@example.com` )
        ( `VOIGTSF;Filina;Voigts;voigtsf@example.com` )
        ( `WEBERS;Seppi;Weber;webers@example.com` )
        ( `SCHMIDTS;Sieglind;Schmidt;schmidts@example.com` )
        ( `KNOPPR;Rogert;Knopp;knoppr@example.com` )
        ( `ZIEGLERS;Samanta;Ziegler;zieglers@example.com` )
        ( `SCHUCHARDTJ;Jaluna;Schuchardt;schuchardtj@example.com` )
        ( `WEBERO;Ommo;Weber;webero@example.com` )
        ( `FALKENRAHTH;Hildemar;Falkenrath;falkenrahth@example.com` )
        ( `BRODBECKK;Kati;Brodbeck;brodbeckk@example.com` )
        ( `HOELZERP;Pía;Hölzer;hoelzerp@example.com` )
        ( `KRAEMERT;Thielko;Krämer;kraemert@example.com` )
        ( `FISCHERG;Georgie;Fischer;fischerg@example.com` )
        ( `KRONA;Ailina;Kron;krona@example.com` )
        ( `SCHULTHEISSX;Xanthia;Schultheiß;schultheissx@example.com` )
        ( `LEHMANNW;Wilhelm;Lehmann;lehmannw@example.com` )
        ( `SEEGERL;Leanca;Seeger;seegerl@example.com` )
        ( `WEBERL;Laura;Weber;weberl@example.com` )
        ( `GEIGERJ;Jojo;Geiger;geigerj@example.com` )
        ( `BOECKERD;Dana;Böcker;boeckerd@example.com` )
        ( `SHRIVERM;Maximilia;Shriver;shriverm@example.com` )
        ( `BELTZN;Niklaus;Beltz;beltzn@example.com` )
        ( `FRANKL;Leocadia;Frank;frankl@example.com` )
        ( `DOEJ;John;Doe;;X;;` )
        ( `SMITHJ;Jane;Smith;;;` ) )
      sep   = |\n| ).

    TRY.
        DATA(conversion_result) = converter->convert_csv_to_users( csv       = csv
                                                                   delimiter = ';' ).
        out->write( conversion_result ).
      CATCH zcx_acb_user_conversion_error INTO DATA(error).
        out->write( error ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
