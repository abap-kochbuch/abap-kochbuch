"! <p class="shorttext synchronized" lang="en">Class for recipes</p>
CLASS zcl_acb_recipe DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "! @parameter recipe_id | Transfer of a recipe ID
    "! @raising zcx_acb_recipe_not_found  | error, if no entry for the recipe ID can be found {@link ZCX_ACB_RECIPE_NOT_FOUND}.
    METHODS constructor IMPORTING recipe_id TYPE zacb_recipe_id RAISING zcx_acb_recipe_not_found.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      "! Unique identifier for a recipe
      recipe_id   TYPE zacb_recipe_id,
      "! Describing the ingredients
      recipe_text TYPE zacb_recipe_text,
      "! Name des Rezepts
      recipe_name TYPE zacb_recipe_name,
      "! All ingredients for the sample recipe
      "! <ul><li>Quantity: 100</li>
      "!      <li>Unit: g</li>
      "!      <li>Name: Flour</li></ul>
      ingredients TYPE TABLE OF zacb_ingredient.
    "! Load the <em>recipe information</em> using the recipe ID in table <strong>ZACB_RECIPE</strong>
    "! @raising zcx_acb_recipe_not_found  | error, if no entry for the recipe ID can be found  {@link ZCX_ACB_RECIPE_NOT_FOUND}.
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
