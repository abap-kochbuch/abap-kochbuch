@EndUserText.label: 'CDS Entity Ingredient'
define view entity ZACB_R_Ingredient
  as select from zacb_ingredient
  association to parent ZACB_R_Recipe as _Recipe on $projection.RecipeId = _Recipe.RecipeId
{
  key recipe_id             as RecipeId,
  key ingredient_id         as IngredientId,
      name                  as Name,
      quantity              as Quantity,
      unit                  as Unit,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      _Recipe
}
