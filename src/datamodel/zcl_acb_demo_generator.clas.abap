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

    out->write( |🍽️ Demo data generation for ABAP Cookbook 👨‍🍳| ).

    out->write( |1. 🗑️ Deleting existing table contents| ).

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

    out->write( |2. 🍝 Creating new table contents| ).
    out->write( |User: { myself }  | &&
                |Time: { now TIMESTAMP = ISO TIMEZONE = 'UTC' } UTC| ).

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
      ( recipe_id = '00001' recipe_name = 'Rice with Meat' recipe_text = 'Rice with Meat for 2 people - delicious like mom''s' published = abap_true )
      ( recipe_id = '00002' recipe_name = 'Spaghetti Carbonara' recipe_text = 'Carbonara for 1 to 2 people - only authentic with cream and lots of pepper' published = abap_false )
      ( recipe_id = '00003' recipe_name = 'Pasta Bake' recipe_text = 'Pasta Bake, 3 to 4 servings - don''t forget the nutmeg(!)' published = abap_true )
      ( recipe_id = '00004' recipe_name = 'Apple Pancakes' recipe_text = 'Apple Pancakes - 2 pieces - also as Apple Kaiserschmarrn' published = abap_true )
      ( recipe_id = '00005' recipe_name = 'Bahmi Goreng' recipe_text = 'Baked Noodles with Meat' published = abap_false )
      ( recipe_id = '00006' recipe_name = 'Farmer''s Breakfast' recipe_text = 'A Breakfast Classic' published = abap_false )
      ( recipe_id = '00007' recipe_name = 'Bernburger Onions' recipe_text = 'One of my favorite childhood meals.' published = abap_true )
      ( recipe_id = '00008' recipe_name = 'Simple Cookies' recipe_text = 'Quick to make - but quite hard' published = abap_false )
      ( recipe_id = '00009' recipe_name = 'Meatballs w/ Potatoes' recipe_text = 'A dish for when you need something quick - tastes quite good.' published = abap_false )
      ( recipe_id = '00010' recipe_name = 'Komar Cookies' recipe_text = 'Relatively simple, incredibly sweet but soft' published = abap_true ) ) ).
    new_entries-recipe = sy-dbcnt.
    nrlevel_recipe = sy-dbcnt.

    INSERT zacb_ingredient FROM TABLE @( VALUE #(
      created_by            = myself
      created_at            = now
      local_last_changed_by = myself
      local_last_changed_at = now
      last_changed_by       = myself
      last_changed_at       = now
      ( recipe_id = '00001' ingredient_id = '00001' name = 'Rice' quantity = 150 unit = 'G' )
      ( recipe_id = '00001' ingredient_id = '00002' name = 'Turkey Schnitzel' quantity = 2 unit = 'PC' )
      ( recipe_id = '00001' ingredient_id = '00003' name = 'vegetable broth' quantity = 3 unit = 'TS' )
      ( recipe_id = '00001' ingredient_id = '00004' name = 'Onion' quantity = 2 unit = 'PC' )
      ( recipe_id = '00001' ingredient_id = '00005' name = 'Rosemary powder' quantity = 2 unit = 'PC' )
      ( recipe_id = '00001' ingredient_id = '00006' name = 'Pepper' quantity = 1 unit = 'TS' )
      ( recipe_id = '00001' ingredient_id = '00007' name = 'Salt' quantity = 1 unit = 'TS' )
      ( recipe_id = '00001' ingredient_id = '00008' name = 'Olive Oil' quantity = 2 unit = 'T' )
      ( recipe_id = '00001' ingredient_id = '00009' name = 'Peas' quantity = 300 unit = 'G' )
      ( recipe_id = '00001' ingredient_id = '00010' name = 'grated cheese' quantity = 4 unit = 'T' )
      ( recipe_id = '00002' ingredient_id = '00001' name = 'Onion' quantity = 1 unit = 'PC' )
      ( recipe_id = '00002' ingredient_id = '00002' name = 'Boiled Ham Schei.' quantity = 2 unit = 'PC' )
      ( recipe_id = '00002' ingredient_id = '00003' name = 'Olive Oil' quantity = 2 unit = 'T' )
      ( recipe_id = '00002' ingredient_id = '00004' name = 'Cream' quantity = 200 unit = 'G' )
      ( recipe_id = '00002' ingredient_id = '00005' name = 'Eggs' quantity = 1 unit = 'PC' )
      ( recipe_id = '00002' ingredient_id = '00006' name = 'grated cheese (possibly mozzarella)' quantity = 125 unit = 'G' )
      ( recipe_id = '00002' ingredient_id = '00007' name = 'Spaghetti (No.3 quick)' quantity = 200 unit = 'G' )
      ( recipe_id = '00002' ingredient_id = '00008' name = 'Pepper' quantity = 1 unit = 'PC' )
      ( recipe_id = '00002' ingredient_id = '00009' name = 'Pepper (a little more!)' quantity = 1 unit = 'PC' )
      ( recipe_id = '00003' ingredient_id = '00001' name = 'Pasta (e.g. penne)' quantity = 200 unit = 'G' )
      ( recipe_id = '00003' ingredient_id = '00002' name = 'Salami' quantity = 100 unit = 'G' )
      ( recipe_id = '00003' ingredient_id = '00003' name = 'Onion' quantity = 1 unit = 'PC' )
      ( recipe_id = '00003' ingredient_id = '00004' name = 'Milk' quantity = 250 unit = 'ML' )
      ( recipe_id = '00003' ingredient_id = '00005' name = 'Egg' quantity = 1 unit = 'PC' )
      ( recipe_id = '00003' ingredient_id = '00006' name = 'Tomato paste' quantity = 2 unit = 'T' )
      ( recipe_id = '00003' ingredient_id = '00007' name = 'Salt' quantity = 2 unit = 'TS' )
      ( recipe_id = '00003' ingredient_id = '00008' name = 'Nutmeg (important)' quantity = 1 unit = 'T' )
      ( recipe_id = '00004' ingredient_id = '00001' name = 'Apples (sour)' quantity = 2 unit = 'PC' )
      ( recipe_id = '00004' ingredient_id = '00002' name = 'Flour' quantity = 125 unit = 'G' )
      ( recipe_id = '00004' ingredient_id = '00003' name = 'Eggs' quantity = 2 unit = 'PC' )
      ( recipe_id = '00004' ingredient_id = '00004' name = 'Sugar' quantity = 12 unit = 'G' )
      ( recipe_id = '00004' ingredient_id = '00005' name = 'Milk' quantity = 185 unit = 'G' )
      ( recipe_id = '00004' ingredient_id = '00006' name = 'Water' quantity = 60 unit = 'ML' )
      ( recipe_id = '00004' ingredient_id = '00007' name = 'Margarine' quantity = 200 unit = 'G' )
      ( recipe_id = '00005' ingredient_id = '00001' name = 'Pasta' quantity = 45 unit = 'G' )
      ( recipe_id = '00005' ingredient_id = '00002' name = 'Chicken Meat' quantity = 400 unit = 'G' )
      ( recipe_id = '00005' ingredient_id = '00003' name = 'cooked ham' quantity = 100 unit = 'G' )
      ( recipe_id = '00005' ingredient_id = '00004' name = 'Leek' quantity = 1 unit = 'PC' )
      ( recipe_id = '00005' ingredient_id = '00005' name = 'Onions' quantity = 2 unit = 'PC' )
      ( recipe_id = '00005' ingredient_id = '00006' name = 'red pepper' quantity = 1 unit = 'PC' )
      ( recipe_id = '00005' ingredient_id = '00007' name = 'Celery' quantity = 75 unit = 'G' )
      ( recipe_id = '00006' ingredient_id = '00001' name = 'Potato' quantity = 450 unit = 'G' )
      ( recipe_id = '00006' ingredient_id = '00002' name = 'Bacon' quantity = 80 unit = 'G' )
      ( recipe_id = '00006' ingredient_id = '00003' name = 'Milk' quantity = 3 unit = 'T' )
      ( recipe_id = '00006' ingredient_id = '00004' name = 'Ham cubes' quantity = 125 unit = 'G' )
      ( recipe_id = '00006' ingredient_id = '00005' name = 'Tomatoes' quantity = 2 unit = 'PC' )
      ( recipe_id = '00006' ingredient_id = '00006' name = 'Chives' quantity = 1 unit = 'PC' )
      ( recipe_id = '00006' ingredient_id = '00007' name = 'Salt' quantity = 5 unit = 'G' )
      ( recipe_id = '00007' ingredient_id = '00001' name = 'Mutton' quantity = 500 unit = 'G' )
      ( recipe_id = '00007' ingredient_id = '00002' name = 'Onions' quantity = 3 unit = 'PC' )
      ( recipe_id = '00007' ingredient_id = '00003' name = 'Garlic cloves' quantity = 2 unit = 'PC' )
      ( recipe_id = '00007' ingredient_id = '00004' name = 'Salt' quantity = 5 unit = 'G' )
      ( recipe_id = '00007' ingredient_id = '00005' name = 'Pepper' quantity = 5 unit = 'G' )
      ( recipe_id = '00007' ingredient_id = '00006' name = 'Caraway seeds' quantity = 1 unit = 'TS' )
      ( recipe_id = '00007' ingredient_id = '00007' name = 'Potatoes' quantity = 750 unit = 'G' )
      ( recipe_id = '00007' ingredient_id = '00008' name = 'Potatoes' quantity = 750 unit = 'G' )
      ( recipe_id = '00007' ingredient_id = '00009' name = 'Cornstarch' quantity = 1 unit = 'T' )
      ( recipe_id = '00007' ingredient_id = '00010' name = 'White Bread Cubes' quantity = 2 unit = 'T' )
      ( recipe_id = '00008' ingredient_id = '00001' name = 'Lamb' quantity = 500 unit = 'G' )
      ( recipe_id = '00008' ingredient_id = '00002' name = 'Onions' quantity = 3 unit = 'PC' )
      ( recipe_id = '00008' ingredient_id = '00003' name = 'Garlic Cloves' quantity = 2 unit = 'PC' )
      ( recipe_id = '00008' ingredient_id = '00004' name = 'Salt' quantity = 5 unit = 'G' )
      ( recipe_id = '00008' ingredient_id = '00005' name = 'Pepper' quantity = 5 unit = 'SG' )
      ( recipe_id = '00008' ingredient_id = '00006' name = 'Caraway seeds' quantity = 1 unit = 'TS' )
      ( recipe_id = '00008' ingredient_id = '00007' name = 'Potatoes' quantity = 750 unit = 'G' )
      ( recipe_id = '00008' ingredient_id = '00008' name = 'Potatoes' quantity = 750 unit = 'G' )
      ( recipe_id = '00008' ingredient_id = '00009' name = 'Starch' quantity = 1 unit = 'T' )
      ( recipe_id = '00008' ingredient_id = '00010' name = 'White bread cubes' quantity = 2 unit = 'T' )
      ( recipe_id = '00009' ingredient_id = '00001' name = 'Milk' quantity = 500 unit = 'ML' )
      ( recipe_id = '00009' ingredient_id = '00002' name = 'Rama' quantity = 1 unit = 'T' )
      ( recipe_id = '00009' ingredient_id = '00003' name = 'Mashed Potatoes' quantity = 2 unit = 'PC' )
      ( recipe_id = '00009' ingredient_id = '00004' name = 'Water' quantity = 1 unit = 'L' )
      ( recipe_id = '00009' ingredient_id = '00005' name = 'Meatballs' quantity = 4 unit = 'PC' )
      ( recipe_id = '00009' ingredient_id = '00006' name = 'pepper sauce' quantity = 500 unit = 'ML' )
      ( recipe_id = '00010' ingredient_id = '00001' name = 'Flour' quantity = 250 unit = 'G' )
      ( recipe_id = '00010' ingredient_id = '00002' name = 'Butter' quantity = 125 unit = 'G' )
      ( recipe_id = '00010' ingredient_id = '00003' name = 'Brown Sugar' quantity = 125 unit = 'G' )
      ( recipe_id = '00010' ingredient_id = '00004' name = 'Eggs' quantity = 3 unit = 'PC' )
      ( recipe_id = '00010' ingredient_id = '00005' name = 'Vanilla aroma' quantity = 1 unit = 'TS' )
      ( recipe_id = '00010' ingredient_id = '00006' name = 'Salt' quantity = 1 unit = 'TS' )
      ( recipe_id = '00010' ingredient_id = '00007' name = 'Cinnamon' quantity = 1 unit = 'TS' )
      ( recipe_id = '00010' ingredient_id = '00008' name = 'Granulated sugar' quantity = 1 unit = 'PC' ) ) ).
    new_entries-ingredient = sy-dbcnt.

    INSERT zacb_review FROM TABLE @( VALUE #(
      local_last_changed_by = myself
      local_last_changed_at = now
      last_changed_by       = myself
      last_changed_at       = now
      created_by            = myself
      created_at            = now
      ( review_id = xco_cp=>uuid( )->value recipe_id = '0001' username = myself review_text = 'Very tasty!' )
      ( review_id = xco_cp=>uuid( )->value recipe_id = '0001' username = 'PATRICKW' review_text = 'I use a lot more salt' )
      ( review_id = xco_cp=>uuid( )->value recipe_id = '0001' username = 'PATRICKH' review_text = 'The schnitzels should be pounded' )
      ( review_id = xco_cp=>uuid( )->value recipe_id = '0002' username = 'PATRICKW' review_text = 'More salt' )
      ( review_id = xco_cp=>uuid( )->value recipe_id = '0003' username = 'PATRICKW' review_text = 'Sea salt?' )
      ( review_id = xco_cp=>uuid( )->value recipe_id = '0004' username = myself review_text = 'Turning is impossible, and there''s a lot of apple, isn''t there?' ) ) ).
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
      language              = 'E'
      local_last_changed_at = now
      ( label_id = 'CHEAP'       label_text = 'Cheap (obsol.)' )
      ( label_id = 'FAST_DISH'   label_text = 'Fast dish' )
      ( label_id = 'INEXPENSIVE' label_text = 'Inexpensive' )
      ( label_id = 'MIGRATED'    label_text = 'Migrated' )
      ( label_id = 'VEGETARIAN'  label_text = 'Vegetarian' ) ) ).
    new_entries-labelt = sy-dbcnt.

    out->write( |New records:| ).
    out->write( |  ZACB_RECIPE    : { new_entries-recipe NUMBER = USER }| ).
    out->write( |  ZACB_INGREDIENT: { new_entries-ingredient NUMBER = USER }| ).
    out->write( |  ZACB_REVIEW    : { new_entries-review NUMBER = USER }| ).
    out->write( |  ZACB_USER      : { new_entries-user NUMBER = USER }| ).
    out->write( |  ZACB_LABEL     : { new_entries-label NUMBER = USER }| ).
    out->write( |  ZACB_LABELT    : { new_entries-labelt NUMBER = USER }| ).

    out->write( |3. 🍝 Creating number range interval| ).
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
          FROM ('I_BusinessPartner') " Not released in the BTP ABAP Trial :(
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
