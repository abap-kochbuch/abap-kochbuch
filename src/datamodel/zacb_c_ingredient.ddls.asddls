@EndUserText.label: 'Projection Entity Ingredient'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZACB_C_Ingredient
  as projection on ZACB_R_Ingredient as Ingredient
{
  key RecipeId,
  key IngredientId,
      Name,
      Quantity,
      Unit,
      LocalLastChangedAt,
      LocalLastChangedBy,
      LastChangedAt,
      LastChangedBy,
      CreatedAt,
      CreatedBy,
      _Recipe : redirected to parent ZACB_C_Recipe
}
