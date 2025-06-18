@EndUserText.label: 'CDS-Entität Zutat'

define view entity ZACB_R_Review
  as select from zacb_review
  association to parent ZACB_R_Recipe as _Recipe on $projection.RecipeId = _Recipe.RecipeId
{
  key review_id             as ReviewId,
      recipe_id             as RecipeId,
      review_text           as Reviewtext,
      username              as Username,
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
      @Semantics.largeObject: {
        mimeType : 'Mimetype',
        fileName : 'Filename',
        contentDispositionPreference: #INLINE,
        acceptableMimeTypes: [ 'image/*' ]
      }
      @Semantics.imageUrl: true
      attachment            as Attachment,
      @Semantics.mimeType: true
      mimetype              as Mimetype,
      filename              as Filename,
      _Recipe
}
