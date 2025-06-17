@EndUserText.label: 'Projektionsentität Review'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZACB_C_Review
  as projection on ZACB_R_Review as Review
{
  key ReviewId,
      RecipeId,
      Reviewtext,
      Username,
      LocalLastChangedAt,
      LocalLastChangedBy,
      LastChangedAt,
      LastChangedBy,
      CreatedAt,
      CreatedBy,
      Attachment,
      Filename,
      Mimetype,
      _Recipe : redirected to parent ZACB_C_Recipe
}
