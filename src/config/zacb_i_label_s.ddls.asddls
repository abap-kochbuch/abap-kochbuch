@EndUserText.label: 'Label Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZACB_I_Label_S
  as select from I_Language
    left outer join ZACB_LABEL on 0 = 0
  composition [0..*] of ZACB_I_Label as _Label
{
  key 1 as SingletonID,
  _Label,
  max( ZACB_LABEL.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
