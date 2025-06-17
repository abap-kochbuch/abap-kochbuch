@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projectionsentitätat RezeptE'
@ObjectModel.semanticKey: [ 'RecipeID' ]
define root view entity ZACB_C_Recipe
  provider contract transactional_query
  as projection on ZACB_R_Recipe
{
  key RecipeId,
      RecipeName,
      RecipeText,
      Published,
      LocalLastChangedAt,
      LocalLastChangedBy,
      LastChangedAt,
      LastChangedBy,
      CreatedAt,
      CreatedBy,
      _Ingredient : redirected to composition child ZACB_C_Ingredient,
      _Review     : redirected to composition child ZACB_C_Review

}
