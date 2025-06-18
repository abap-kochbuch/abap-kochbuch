@EndUserText.label: 'Maintain Label Text'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZACB_C_LabelText
  as projection on ZACB_I_LabelText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Language,
  key LabelId,
  LabelText,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _Label : redirected to parent ZACB_C_Label,
  _LabelAll : redirected to ZACB_C_Label_S
  
}
