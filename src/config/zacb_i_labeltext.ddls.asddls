@EndUserText.label: 'Label Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity ZACB_I_LabelText
  as select from zacb_labelt
  association [1..1] to ZACB_I_Label_S as _LabelAll on $projection.SingletonID = _LabelAll.SingletonID
  association to parent ZACB_I_Label as _Label on $projection.LabelId = _Label.LabelId
  association [0..*] to I_LanguageText as _LanguageText on $projection.Language = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key language as Language,
  key label_id as LabelId,
  @Semantics.text: true
  label_text as LabelText,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  1 as SingletonID,
  _LabelAll,
  _Label,
  _LanguageText
  
}
