INTERFACE zif_acb_user_converter
  PUBLIC.

  TYPES users TYPE SORTED TABLE OF zacb_user WITH UNIQUE KEY username.

  METHODS convert_csv_to_users
    IMPORTING csv           TYPE string
              delimiter     TYPE string
    RETURNING VALUE(result) TYPE users
    RAISING   zcx_acb_user_conversion_error.
ENDINTERFACE.
