@EndUserText.label: 'Maintain Label'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZACB_C_Label
  as projection on ZACB_I_Label
{
  key LabelId,
  LabelColor,
  @ObjectModel.text.element: [ 'ConfigurationDeprecation_Text' ]
  ConfigDeprecationCode,
  LastChangedAt,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LabelAll : redirected to parent ZACB_C_Label_S,
  ConfigDeprecationCode_Critlty,
  _ConfignDeprecationCodeText.ConfignDeprecationCodeName as ConfigurationDeprecation_Text : localized,
  _LabelText : redirected to composition child ZACB_C_LabelText,
  _LabelText.LabelText : localized
  
}
