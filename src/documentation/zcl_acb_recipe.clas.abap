"! <p class="shorttext synchronized" lang="de">Klasse für Rezepte</p>
CLASS zcl_acb_recipe DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "! @parameter recipe_id | Übergabe einer Rezept-ID
    "! @raising zcx_acb_recipe_not_found  | Fehler, wenn kein Eintrag zur Rezept-ID gefunden werden kann {@link ZCX_ACB_RECIPE_NOT_FOUND}.
    METHODS constructor IMPORTING recipe_id TYPE zacb_recipe_id RAISING zcx_acb_recipe_not_found.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      "! Eindeutiger Identifier für ein Rezept
      recipe_id   TYPE zacb_recipe_id,
      "! Beschreibung der Zubereitung
      recipe_text TYPE zacb_recipe_text,
      "! Name des Rezepts
      recipe_name TYPE zacb_recipe_name,
      "! Alle Zutaten für das Rezeptbeispiel
      "!  <ul><li>Menge: 100</li>
      "!      <li>Einheit: g</li>
      "!      <li>Name: Mehl</li></ul>
      ingredients TYPE TABLE OF zacb_ingredient.
    "! Laden der <em>Rezeptinformationen</em> anhand der Rezept-ID in der Tabelle <strong>ZACB_RECIPE</strong>
    "! @raising zcx_acb_recipe_not_found  | Fehler, wenn kein Eintrag zur Rezept-ID gefunden werden kann {@link ZCX_ACB_RECIPE_NOT_FOUND}.
    METHODS load_recipe RAISING zcx_acb_recipe_not_found.

ENDCLASS.



CLASS zcl_acb_recipe IMPLEMENTATION.
  METHOD constructor.
    me->recipe_id = recipe_id.
    load_recipe( ).
  ENDMETHOD.

  METHOD load_recipe.

    SELECT SINGLE FROM zacb_recipe
      FIELDS *
      WHERE recipe_id = @me->recipe_id
      INTO @DATA(recipe).

    IF sy-subrc = 0.
      me->recipe_text = recipe-recipe_text.
      me->recipe_name = recipe-recipe_name.
    ELSE.
      RAISE EXCEPTION TYPE zcx_acb_recipe_not_found.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
