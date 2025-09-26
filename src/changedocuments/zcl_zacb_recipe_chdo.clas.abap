class ZCL_ZACB_RECIPE_CHDO definition
  public
  create public .

public section.

  interfaces IF_CHDO_ENHANCEMENTS .

  types:
     BEGIN OF TY_ZACB_INGREDIENT .
      INCLUDE TYPE ZACB_INGREDIENT.
      INCLUDE TYPE IF_CHDO_OBJECT_TOOLS_REL=>TY_ICDIND.
 TYPES END OF TY_ZACB_INGREDIENT .
  types:
    TT_ZACB_INGREDIENT TYPE STANDARD TABLE OF TY_ZACB_INGREDIENT .

  class-data OBJECTCLASS type IF_CHDO_OBJECT_TOOLS_REL=>TY_CDOBJECTCL read-only value 'ZACB_RECIPE' ##NO_TEXT.

  class-methods WRITE
    importing
      !OBJECTID type IF_CHDO_OBJECT_TOOLS_REL=>TY_CDOBJECTV
      !UTIME type IF_CHDO_OBJECT_TOOLS_REL=>TY_CDUZEIT
      !UDATE type IF_CHDO_OBJECT_TOOLS_REL=>TY_CDDATUM
      !USERNAME type IF_CHDO_OBJECT_TOOLS_REL=>TY_CDUSERNAME
      !PLANNED_CHANGE_NUMBER type IF_CHDO_OBJECT_TOOLS_REL=>TY_PLANCHNGNR default SPACE
      !OBJECT_CHANGE_INDICATOR type IF_CHDO_OBJECT_TOOLS_REL=>TY_CDCHNGINDH default 'U'
      !PLANNED_OR_REAL_CHANGES type IF_CHDO_OBJECT_TOOLS_REL=>TY_CDFLAG default SPACE
      !NO_CHANGE_POINTERS type IF_CHDO_OBJECT_TOOLS_REL=>TY_CDFLAG default SPACE
      !XZACB_INGREDIENT type TT_ZACB_INGREDIENT optional
      !YZACB_INGREDIENT type TT_ZACB_INGREDIENT optional
      !UPD_ZACB_INGREDIENT type IF_CHDO_OBJECT_TOOLS_REL=>TY_CDCHNGINDH default SPACE
      !O_ZACB_RECIPE type ZACB_RECIPE optional
      !N_ZACB_RECIPE type ZACB_RECIPE optional
      !UPD_ZACB_RECIPE type IF_CHDO_OBJECT_TOOLS_REL=>TY_CDCHNGINDH default SPACE
    exporting
      value(CHANGENUMBER) type IF_CHDO_OBJECT_TOOLS_REL=>TY_CDCHANGENR
    raising
      CX_CHDO_WRITE_ERROR .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZACB_RECIPE_CHDO IMPLEMENTATION.


  method WRITE.
*"----------------------------------------------------------------------
*"         this WRITE method is generated for object ZACB_RECIPE
*"         never change it manually, please!        :18.07.2025
*"         All changes will be overwritten without a warning!
*"
*"         CX_CHDO_WRITE_ERROR is used for error handling
*"----------------------------------------------------------------------

    DATA: l_upd        TYPE if_chdo_object_tools_rel=>ty_cdchngind.

    CALL METHOD cl_chdo_write_tools=>changedocument_open
      EXPORTING
        objectclass             = objectclass
        objectid                = objectid
        planned_change_number   = planned_change_number
        planned_or_real_changes = planned_or_real_changes.

    IF ( YZACB_INGREDIENT IS INITIAL ) AND
       ( XZACB_INGREDIENT IS INITIAL ).
      l_upd  = space.
    ELSE.
      l_upd = UPD_ZACB_INGREDIENT.
    ENDIF.

    IF l_upd NE space.
      CALL METHOD CL_CHDO_WRITE_TOOLS=>changedocument_multiple_case
        EXPORTING
          tablename              = 'ZACB_INGREDIENT'
          change_indicator       = UPD_ZACB_INGREDIENT
          docu_delete            = ''
          docu_insert            = ''
          docu_delete_if         = ''
          docu_insert_if         = ''
          table_old              = YZACB_INGREDIENT
          table_new              = XZACB_INGREDIENT
                  .
    ENDIF.

     IF ( N_ZACB_RECIPE IS INITIAL ) AND
        ( O_ZACB_RECIPE IS INITIAL ).
       l_upd  = space.
     ELSE.
       l_upd = UPD_ZACB_RECIPE.
     ENDIF.

     IF  l_upd  NE space.
       CALL METHOD CL_CHDO_WRITE_TOOLS=>changedocument_single_case
         EXPORTING
           tablename              = 'ZACB_RECIPE'
           workarea_old           = O_ZACB_RECIPE
           workarea_new           = N_ZACB_RECIPE
           change_indicator       = UPD_ZACB_RECIPE
           docu_delete            = ''
           docu_insert            = ''
           docu_delete_if         = ''
           docu_insert_if         = ''
                  .
     ENDIF.

    CALL METHOD cl_chdo_write_tools=>changedocument_close
      EXPORTING
        objectclass             = objectclass
        objectid                = objectid
        date_of_change          = udate
        time_of_change          = utime
        username                = username
        object_change_indicator = object_change_indicator
        no_change_pointers      = no_change_pointers
      IMPORTING
        changenumber            = changenumber.

  endmethod.
ENDCLASS.
