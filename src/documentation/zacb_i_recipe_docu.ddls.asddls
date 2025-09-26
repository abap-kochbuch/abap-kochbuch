@EndUserText.label: 'CDS Entity Recipe'
define view entity ZACB_I_Recipe_DOCU
  as select from zacb_recipe
{
  key recipe_id             as RecipeId,
      recipe_name           as RecipeName,
      recipe_text           as RecipeText,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy
}
