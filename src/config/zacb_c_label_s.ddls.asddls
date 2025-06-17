@EndUserText.label: 'Maintain Label Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity ZACB_C_Label_S
  provider contract transactional_query
  as projection on ZACB_I_Label_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _Label : redirected to composition child ZACB_C_Label
  
}
