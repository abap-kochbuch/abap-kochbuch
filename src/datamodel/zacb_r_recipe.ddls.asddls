@AccessControl.authorizationCheck: #MANDATORY
@EndUserText.label: 'CDS Entity Recipe'
define root view entity ZACB_R_Recipe
  as select from zacb_recipe
  composition [0..*] of ZACB_R_Ingredient as _Ingredient
  composition [0..*] of ZACB_R_Review as _Review
  
{
  key recipe_id as RecipeId,
  recipe_name as RecipeName,
  recipe_text as RecipeText,
  published as Published,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  _Ingredient,
  _Review
}
