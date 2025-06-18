@EndUserText.label: 'Label'
@AccessControl.authorizationCheck: #CHECK
define view entity ZACB_I_Label
  as select from ZACB_LABEL
  association to parent ZACB_I_Label_S as _LabelAll on $projection.SingletonID = _LabelAll.SingletonID
  association [0..*] to I_ConfignDeprecationCodeText as _ConfignDeprecationCodeText on $projection.ConfigDeprecationCode = _ConfignDeprecationCodeText.ConfigurationDeprecationCode
  composition [0..*] of ZACB_I_LabelText as _LabelText
{
  key LABEL_ID as LabelId,
  LABEL_COLOR as LabelColor,
  CONFIGDEPRECATIONCODE as ConfigDeprecationCode,
  @Semantics.systemDateTime.lastChangedAt: true
  LAST_CHANGED_AT as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _LabelAll,
  case when CONFIGDEPRECATIONCODE = 'W' then 2 when CONFIGDEPRECATIONCODE = 'E' then 1 else 3 end as ConfigDeprecationCode_Critlty,
  _ConfignDeprecationCodeText,
  _LabelText
  
}
