@EndUserText.label: 'CDS-Entität Zutat'
define view entity ZACB_I_Recipe_CDBO
  as select from zacb_recipe
{
  key recipe_id,
      recipe_name,
      recipe_text,
      @Semantics.user.createdBy: true
      created_by,
      @Semantics.systemDateTime.createdAt: true
      created_at,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at,
      @Semantics.user.lastChangedBy: true
      last_changed_by
}
