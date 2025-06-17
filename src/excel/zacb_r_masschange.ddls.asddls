@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Massenänderung'
define root view entity ZACB_R_MassChange
  as select from zacb_massc as MassChange
{
  key mass_change_uuid                      as MassChangeUUID,
      @Semantics.largeObject: {
        mimeType: 'TemplateFileMimetype',
        fileName: 'TemplateFilename',
        contentDispositionPreference: #INLINE,
        acceptableMimeTypes: [ 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ]
      }
      template_file_content                 as TemplateFileContent,
      @Semantics.mimeType: true
      template_file_mimetype                as TemplateFileMimetype,
      template_filename                     as TemplateFilename,
      @Semantics.largeObject: {
        mimeType: 'ProcessingFileMimetype',
        fileName: 'ProcessingFilename',
        contentDispositionPreference: #INLINE,
        acceptableMimeTypes: [ 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ]
      }
      processing_file_content               as ProcessingFileContent,
      @Semantics.mimeType: true
      processing_file_mimetype              as ProcessingFileMimetype,
      processing_filename                   as ProcessingFilename,
      processing_status                     as ProcessingStatus,
      change_description                    as ChangeDescription,
      change_title                          as ChangeTitle,
      @Semantics.user.createdBy: true
      created_by                            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by                 as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at                 as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                       as LastChangedAt,
      cast( case when $projection.TemplateFilename is initial
        then ' '
        else 'X'
      end as abap_boolean preserving type ) as TemplateFileExists,
      cast( case when $projection.ProcessingFilename is initial
        then ' '
        else 'X'
      end as abap_boolean preserving type ) as ProcessingFileExists

}
