CLASS zcl_acb_demo_generator DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    TYPES: BEGIN OF user_details,
             first_name TYPE zacb_first_name,
             last_name  TYPE zacb_last_name,
           END OF user_details.
    CLASS-METHODS determine_user_details IMPORTING user_name     TYPE cl_abap_context_info=>ty_user_name
                                         RETURNING VALUE(result) TYPE user_details.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_acb_demo_generator IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA nrlevel_recipe TYPE zacb_recipe_id.

    out->write( |🍽️ Demodatengenerierung für ABAP Kochbuch 👨‍🍳| ).

    out->write( |1. 🗑️ Lösche bestehende Tabelleninhalte| ).

    " _DATAMODEL
    DELETE FROM zacb_recipe.
    DELETE FROM zacb_recipe_d.
    DELETE FROM zacb_ingredient.
    DELETE FROM zacb_ingredien_d.
    DELETE FROM zacb_review.
    DELETE FROM zacb_review_d.
    DELETE FROM zacb_user.

    " _CONFIG
    DELETE FROM zacb_label.
    DELETE FROM zacb_label_d.
    DELETE FROM zacb_labelt.
    DELETE FROM zacb_labelt_d.
    DELETE FROM zacb_label_d_s.

    DATA(myself) = cl_abap_context_info=>get_user_technical_name( ).
    DATA(now) = cl_abap_tstmp=>utclong2tstmp( utclong_current( ) ).

    out->write( |2. 🍝 Erstelle neue Tabelleninhalte| ).
    out->write( |Benutzer: { myself }  | &&
                |Zeit: { now TIMESTAMP = ISO TIMEZONE = 'UTC' } UTC| ).

    DATA: BEGIN OF new_entries,
            recipe     TYPE i,
            ingredient TYPE i,
            review     TYPE i,
            user       TYPE i,
            label      TYPE i,
            labelt     TYPE i,
          END OF new_entries.


    INSERT zacb_recipe FROM TABLE @( VALUE #(
      created_by            = myself
      created_at            = now
      local_last_changed_by = myself
      local_last_changed_at = now
      last_changed_by       = myself
      last_changed_at       = now
      ( recipe_id = '00001' recipe_name = 'Reis mit Fleisch'     recipe_text = 'Reis mit Fleisch für 2 Personen - lecker wie bei Mutter'                published = abap_true   )
      ( recipe_id = '00002' recipe_name = 'Spaghetti Carbonara'  recipe_text = 'Carbonara für 1 bis 2 Personen - nur echt mit Sahne und viel Pfeffer'   published = abap_false  )
      ( recipe_id = '00003' recipe_name = 'Nudelauflauf'         recipe_text = 'Nudelauf, 3 bis 4 Portionen - MUSKAT nicht vergessen(!)'                published = abap_true   )
      ( recipe_id = '00004' recipe_name = 'Apfelpfannkuchen'     recipe_text = 'Apfelpfannkuchen - 2 Stück - auch als Apfelkaiserschmarrn'              published = abap_true   )
      ( recipe_id = '00005' recipe_name = 'Bahmi Goreng'         recipe_text = 'Gebackene Nudeln mit Fleisch'                                           published = abap_false  )
      ( recipe_id = '00006' recipe_name = 'Bauernfrüstück'       recipe_text = 'Ein Frühstückklassiker'                                                 published = abap_false  )
      ( recipe_id = '00007' recipe_name = 'Bernburger Zwiebeln'  recipe_text = 'Eines meiner Lieblingsessen aus meiner Kindheit.'                       published = abap_true   )
      ( recipe_id = '00008' recipe_name = 'Einfache Kekse'       recipe_text = 'Geht schnell - sind aber recht hart'                                    published = abap_false  )
      ( recipe_id = '00009' recipe_name = 'Friko mit Kartoffelp' recipe_text = 'Ein Gericht wenns mal schnell gehen soll - schmeckt ganz gut.'          published = abap_false  )
      ( recipe_id = '00010' recipe_name = 'Komar-Kekse'          recipe_text = 'Relativ einfach, verdammt süß dafür aber weich'                         published = abap_true   ) ) ).
    new_entries-recipe = sy-dbcnt.
    nrlevel_recipe = sy-dbcnt.

    INSERT zacb_ingredient FROM TABLE @( VALUE #(
      created_by            = myself
      created_at            = now
      local_last_changed_by = myself
      local_last_changed_at = now
      last_changed_by       = myself
      last_changed_at       = now
      ( recipe_id = '00001' ingredient_id = '00001' name = 'Reis'                      quantity = 150 unit = 'G' )
      ( recipe_id = '00001' ingredient_id = '00002' name = 'Putenschnitzel'            quantity = 2   unit = 'ST' )
      ( recipe_id = '00001' ingredient_id = '00003' name = 'Gemüsebrühe'               quantity = 3   unit = 'TL' )
      ( recipe_id = '00001' ingredient_id = '00004' name = 'Zwiebel'                   quantity = 2   unit = 'ST' )
      ( recipe_id = '00001' ingredient_id = '00005' name = 'Rosmarinpulver'            quantity = 2   unit = 'ST' )
      ( recipe_id = '00001' ingredient_id = '00006' name = 'Pfeffer'                   quantity = 1   unit = 'TL' )
      ( recipe_id = '00001' ingredient_id = '00007' name = 'Salz'                      quantity = 1   unit = 'TL' )
      ( recipe_id = '00001' ingredient_id = '00008' name = 'Olivenöl'                  quantity = 2   unit = 'EL' )
      ( recipe_id = '00001' ingredient_id = '00009' name = 'Erbsen'                    quantity = 300 unit = 'G' )
      ( recipe_id = '00001' ingredient_id = '00010' name = 'Reibkäse'                  quantity = 4   unit = 'EL' )
      ( recipe_id = '00002' ingredient_id = '00001' name = 'Zwiebel'                   quantity = 1   unit = 'ST' )
      ( recipe_id = '00002' ingredient_id = '00002' name = 'Gekochter Schinken Schei.' quantity = 2   unit = 'ST' )
      ( recipe_id = '00002' ingredient_id = '00003' name = 'Olivenöl'                  quantity = 2   unit = 'EL' )
      ( recipe_id = '00002' ingredient_id = '00004' name = 'Sahne'                     quantity = 200 unit = 'G' )
      ( recipe_id = '00002' ingredient_id = '00005' name = 'Eier'                      quantity = 1   unit = 'ST' )
      ( recipe_id = '00002' ingredient_id = '00006' name = 'Reibkäse (vllt Mozarella)' quantity = 125 unit = 'G' )
      ( recipe_id = '00002' ingredient_id = '00007' name = 'Spaghetti (No.3 schnell)'  quantity = 200 unit = 'G' )
      ( recipe_id = '00002' ingredient_id = '00008' name = 'Pfeffer'                   quantity = 1   unit = 'ST' )
      ( recipe_id = '00002' ingredient_id = '00009' name = 'Pfeffer (etwas mehr!)'     quantity = 1   unit = 'ST' )
      ( recipe_id = '00003' ingredient_id = '00001' name = 'Nudeln (z. B. Penne)'      quantity = 200 unit = 'G' )
      ( recipe_id = '00003' ingredient_id = '00002' name = 'Salami'                    quantity = 100 unit = 'G' )
      ( recipe_id = '00003' ingredient_id = '00003' name = 'Zwiebel'                   quantity = 1   unit = 'ST' )
      ( recipe_id = '00003' ingredient_id = '00004' name = 'Milch'                     quantity = 250 unit = 'ML' )
      ( recipe_id = '00003' ingredient_id = '00005' name = 'Ei'                        quantity = 1   unit = 'ST' )
      ( recipe_id = '00003' ingredient_id = '00006' name = 'Tomatenmark'               quantity = 2   unit = 'EL' )
      ( recipe_id = '00003' ingredient_id = '00007' name = 'Salz'                      quantity = 2   unit = 'TL' )
      ( recipe_id = '00003' ingredient_id = '00008' name = 'Muskat (wichtig)'          quantity = 1   unit = 'EL' )
      ( recipe_id = '00004' ingredient_id = '00001' name = 'Äpfel (sauer)'             quantity = 2   unit = 'ST' )
      ( recipe_id = '00004' ingredient_id = '00002' name = 'Mehl'                      quantity = 125 unit = 'G' )
      ( recipe_id = '00004' ingredient_id = '00003' name = 'Eier'                      quantity = 2   unit = 'ST' )
      ( recipe_id = '00004' ingredient_id = '00004' name = 'Zucker'                    quantity = 12  unit = 'G' )
      ( recipe_id = '00004' ingredient_id = '00005' name = 'Milch'                     quantity = 185 unit = 'G' )
      ( recipe_id = '00004' ingredient_id = '00006' name = 'Wasser'                    quantity = 60  unit = 'ML' )
      ( recipe_id = '00004' ingredient_id = '00007' name = 'Margarine'                 quantity = 200 unit = 'G' )
      ( recipe_id = '00005' ingredient_id = '00001' name = 'Nudeln'                    quantity = 45  unit = 'G' )
      ( recipe_id = '00005' ingredient_id = '00002' name = 'Hühnerfleisch'             quantity = 400 unit = 'G' )
      ( recipe_id = '00005' ingredient_id = '00003' name = 'gekochter Schinken'        quantity = 100 unit = 'G' )
      ( recipe_id = '00005' ingredient_id = '00004' name = 'Porree'                    quantity = 1   unit = 'ST' )
      ( recipe_id = '00005' ingredient_id = '00005' name = 'Zwiebeln'                  quantity = 2   unit = 'ST' )
      ( recipe_id = '00005' ingredient_id = '00006' name = 'rote Paprikaschote'        quantity = 1   unit = 'ST' )
      ( recipe_id = '00005' ingredient_id = '00007' name = 'Sellerie'                  quantity = 75  unit = 'G' )
      ( recipe_id = '00006' ingredient_id = '00001' name = 'Kartoffelnn'               quantity = 450 unit = 'G' )
      ( recipe_id = '00006' ingredient_id = '00002' name = 'Speck'                     quantity = 80  unit = 'G' )
      ( recipe_id = '00006' ingredient_id = '00003' name = 'Milch'                     quantity = 3   unit = 'EL' )
      ( recipe_id = '00006' ingredient_id = '00004' name = 'Schinkenwürfel'            quantity = 125 unit = 'G' )
      ( recipe_id = '00006' ingredient_id = '00005' name = 'Tomaten'                   quantity = 2   unit = 'ST' )
      ( recipe_id = '00006' ingredient_id = '00006' name = 'Schnittlauch'              quantity = 1   unit = 'ST' )
      ( recipe_id = '00006' ingredient_id = '00007' name = 'Salz'                      quantity = 5   unit = 'G' )
      ( recipe_id = '00007' ingredient_id = '00001' name = 'Hammelfleisch'             quantity = 500 unit = 'G' )
      ( recipe_id = '00007' ingredient_id = '00002' name = 'Zwiebeln'                  quantity = 3   unit = 'ST' )
      ( recipe_id = '00007' ingredient_id = '00003' name = 'Knoblauchzehen'            quantity = 2   unit = 'ST' )
      ( recipe_id = '00007' ingredient_id = '00004' name = 'Salz'                      quantity = 5   unit = 'G' )
      ( recipe_id = '00007' ingredient_id = '00005' name = 'Pfeffer'                   quantity = 5   unit = 'SG' )
      ( recipe_id = '00007' ingredient_id = '00006' name = 'Kümmel'                    quantity = 1   unit = 'TL' )
      ( recipe_id = '00007' ingredient_id = '00007' name = 'Kartoffeln'                quantity = 750 unit = 'G' )
      ( recipe_id = '00007' ingredient_id = '00008' name = 'Kartoffeln'                quantity = 750 unit = 'G' )
      ( recipe_id = '00007' ingredient_id = '00009' name = 'Speisestärke'              quantity = 1   unit = 'EL' )
      ( recipe_id = '00007' ingredient_id = '00010' name = 'Weißbrotwürfel'            quantity = 2   unit = 'EL' )
      ( recipe_id = '00008' ingredient_id = '00001' name = 'Hammelfleisch'             quantity = 500 unit = 'G' )
      ( recipe_id = '00008' ingredient_id = '00002' name = 'Zwiebeln'                  quantity = 3   unit = 'ST' )
      ( recipe_id = '00008' ingredient_id = '00003' name = 'Knoblauchzehen'            quantity = 2   unit = 'ST' )
      ( recipe_id = '00008' ingredient_id = '00004' name = 'Salz'                      quantity = 5   unit = 'G' )
      ( recipe_id = '00008' ingredient_id = '00005' name = 'Pfeffer'                   quantity = 5   unit = 'SG' )
      ( recipe_id = '00008' ingredient_id = '00006' name = 'Kümmel'                    quantity = 1   unit = 'TL' )
      ( recipe_id = '00008' ingredient_id = '00007' name = 'Kartoffeln'                quantity = 750 unit = 'G' )
      ( recipe_id = '00008' ingredient_id = '00008' name = 'Kartoffeln'                quantity = 750 unit = 'G' )
      ( recipe_id = '00008' ingredient_id = '00009' name = 'Speisestärke'              quantity = 1   unit = 'EL' )
      ( recipe_id = '00008' ingredient_id = '00010' name = 'Weißbrotwürfel'            quantity = 2   unit = 'EL' )
      ( recipe_id = '00009' ingredient_id = '00001' name = 'Milch'                     quantity = 500 unit = 'ML' )
      ( recipe_id = '00009' ingredient_id = '00002' name = 'Rama'                      quantity = 1   unit = 'EL' )
      ( recipe_id = '00009' ingredient_id = '00003' name = 'Kartoffelpüree'            quantity = 2   unit = 'ST' )
      ( recipe_id = '00009' ingredient_id = '00004' name = 'Wasser'                    quantity = 1   unit = 'L' )
      ( recipe_id = '00009' ingredient_id = '00005' name = 'Buletten'                  quantity = 4   unit = 'ST' )
      ( recipe_id = '00009' ingredient_id = '00006' name = 'Paprikasosse'              quantity = 500 unit = 'ML' )
      ( recipe_id = '00010' ingredient_id = '00001' name = 'Mehl'                      quantity = 250 unit = 'G' )
      ( recipe_id = '00010' ingredient_id = '00002' name = 'Butter'                    quantity = 125 unit = 'G' )
      ( recipe_id = '00010' ingredient_id = '00003' name = 'Brauner Zucker'            quantity = 125 unit = 'G' )
      ( recipe_id = '00010' ingredient_id = '00004' name = 'Eier'                      quantity = 3   unit = 'ST' )
      ( recipe_id = '00010' ingredient_id = '00005' name = 'Vanillearoma'              quantity = 1   unit = 'TL' )
      ( recipe_id = '00010' ingredient_id = '00006' name = 'Salz'                      quantity = 1   unit = 'TL' )
      ( recipe_id = '00010' ingredient_id = '00007' name = 'Zimt'                      quantity = 1   unit = 'TL' )
      ( recipe_id = '00010' ingredient_id = '00008' name = 'Granulierter Zucker'       quantity = 1   unit = 'ST' )  ) ).
    new_entries-ingredient = sy-dbcnt.

    INSERT zacb_review FROM TABLE @( VALUE #(
      local_last_changed_by = myself
      local_last_changed_at = now
      last_changed_by       = myself
      last_changed_at       = now
      created_by            = myself
      created_at            = now
      ( review_id = xco_cp=>uuid( )->value recipe_id = '0001' username = myself     review_text = 'Sehr lecker!' )
      ( review_id = xco_cp=>uuid( )->value recipe_id = '0001' username = 'PATRICKW' review_text = 'Ich nehme deutlich mehr Salz' )
      ( review_id = xco_cp=>uuid( )->value recipe_id = '0001' username = 'PATRICKH' review_text = 'Die Schnitzel sollten geklopft werden' )
      ( review_id = xco_cp=>uuid( )->value recipe_id = '0002' username = 'PATRICKW' review_text = 'Mehr Salz' )
      ( review_id = xco_cp=>uuid( )->value recipe_id = '0003' username = 'PATRICKW' review_text = 'Meersalz?' )
      ( review_id = xco_cp=>uuid( )->value recipe_id = '0004' username = myself     review_text = 'Das Wenden ist unmöglich, außerdem sehr viel Apfel oder nicht?' ) ) ).
    new_entries-review = sy-dbcnt.

    DATA(my_details) = determine_user_details( EXACT #( myself ) ).

    INSERT zacb_user FROM TABLE @( VALUE #(
      ( username = myself     last_name  = my_details-last_name first_name = my_details-first_name author = abap_true admin = abap_true )
      ( username = 'PATRICKW' last_name  = 'W.'                 first_name = 'Patrick' )
      ( username = 'PATRICKH' last_name  = 'H.'                 first_name = 'Patrick' )
      ( username = 'LEONR'    last_name  = 'R.'                 first_name = 'Leon' ) ) ).
    new_entries-user = sy-dbcnt.

    INSERT zacb_label FROM TABLE @( VALUE #(
      last_changed_at       = now
      local_last_changed_at = now
      ( label_id = 'CHEAP'       label_color = '3'   configdeprecationcode = 'W' )
      ( label_id = 'FAST_DISH'   label_color = '2'   configdeprecationcode = space )
      ( label_id = 'INEXPENSIVE' label_color = space configdeprecationcode = space )
      ( label_id = 'MIGRATED'    label_color = '1'   configdeprecationcode = 'E' )
      ( label_id = 'VEGETARIAN'  label_color = '1'   configdeprecationcode = 'E' ) ) ).
    new_entries-label = sy-dbcnt.

    INSERT zacb_labelt FROM TABLE @( VALUE #(
      language              = 'D'
      local_last_changed_at = now
      ( label_id = 'CHEAP'       label_text = 'Kostengünstig (obs.)' )
      ( label_id = 'FAST_DISH'   label_text = 'Schnellgericht' )
      ( label_id = 'INEXPENSIVE' label_text = 'Kostengünstig' )
      ( label_id = 'MIGRATED'    label_text = 'Migrationsdaten' )
      ( label_id = 'VEGETARIAN'  label_text = 'Vegetarisch' ) ) ).
    new_entries-labelt = sy-dbcnt.

    out->write( |Neue Datensätze:| ).
    out->write( |  ZACB_RECIPE    : { new_entries-recipe NUMBER = USER }| ).
    out->write( |  ZACB_INGREDIENT: { new_entries-ingredient NUMBER = USER }| ).
    out->write( |  ZACB_REVIEW    : { new_entries-review NUMBER = USER }| ).
    out->write( |  ZACB_USER      : { new_entries-user NUMBER = USER }| ).
    out->write( |  ZACB_LABEL     : { new_entries-label NUMBER = USER }| ).
    out->write( |  ZACB_LABELT    : { new_entries-labelt NUMBER = USER }| ).

    out->write( |3. 🍝 Erstelle Nummernkreisintervall| ).
    DATA(numberrange) = NEW zcl_acb_numberrange( ).
    IF numberrange->exists_interval( ).
      numberrange->update_interval(  0 ).
      numberrange->delete_interval( ).
      COMMIT WORK.
    ENDIF.
    numberrange->create_interval( ).
    numberrange->update_interval(  CONV #( nrlevel_recipe ) ).
    COMMIT WORK.
  ENDMETHOD.

  METHOD determine_user_details.
    TRY.
        DATA(partner) = cl_abap_context_info=>get_user_business_partner_id( user_name ).
        SELECT SINGLE
          FROM ('I_BusinessPartner') " Nicht released im BTP ABAP Trial :(
          FIELDS FirstName, LastName
          WHERE BusinessPartner = @partner
          INTO @result.
        IF result IS NOT INITIAL.
          RETURN.
        ENDIF.
      CATCH cx_abap_context_info_error
            cx_sy_dynamic_osql_error ##NO_HANDLER.
    ENDTRY.

    TRY.
        DATA(formatted_name) = cl_abap_context_info=>get_user_formatted_name( user_name ).
        IF     formatted_name IS NOT INITIAL
           AND formatted_name NP '++++++++-++++-++++-++++-++++++++++++'. " UUID
          SPLIT formatted_name AT space INTO result-first_name result-last_name.
          RETURN.
        ENDIF.
      CATCH cx_abap_context_info_error ##NO_HANDLER.
    ENDTRY.

    RETURN VALUE #( first_name = 'Manfred'
                    last_name  = 'Mustermann' ).
  ENDMETHOD.
ENDCLASS.
