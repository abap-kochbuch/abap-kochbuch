@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZACB_R_MASSCHANGE'
define root view entity ZACB_C_MassChange
  provider contract transactional_query
  as projection on ZACB_R_MassChange
{
  key MassChangeUUID,
  TemplateFileContent,
  TemplateFileMimetype,
  TemplateFilename,
  ProcessingFileContent,
  ProcessingFileMimetype,
  ProcessingFilename,
  ProcessingStatus,
  ChangeDescription,
  ChangeTitle,
  CreatedBy,
  CreatedAt,
  LocalLastChangedAt,
  TemplateFileExists,
  ProcessingFileExists
}
