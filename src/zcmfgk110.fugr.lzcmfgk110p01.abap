*----------------------------------------------------------------------*
***INCLUDE LZCMFGK110P01.
*----------------------------------------------------------------------*
CLASS lcl_alv_grid DEFINITION INHERITING FROM zcl_falv.

  PUBLIC SECTION.

  PROTECTED SECTION.
    METHODS evf_user_command REDEFINITION.
    METHODS evf_hotspot_click REDEFINITION.
    METHODS evf_top_of_page REDEFINITION.
    METHODS evf_data_changed REDEFINITION.
    METHODS evf_onf4 REDEFINITION.
    METHODS evf_double_click REDEFINITION.
  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_alv_grid IMPLEMENTATION.

  METHOD evf_user_command.
    CASE e_ucomm.
      WHEN zcl_falv=>fc_back OR zcl_falv=>fc_exit OR zcl_falv=>fc_cancel OR zcl_falv=>fc_up.
        LEAVE TO SCREEN 0.
      WHEN OTHERS.
        PERFORM ev_user_command USING e_ucomm me.
    ENDCASE.
  ENDMETHOD.
  METHOD evf_hotspot_click.
    PERFORM ev_hotspot_click USING es_row_no-row_id e_column_id-fieldname.
  ENDMETHOD.
  METHOD evf_top_of_page.
    PERFORM ev_top_of_page USING e_dyndoc_id.
  ENDMETHOD.
  METHOD evf_data_changed.
    PERFORM ev_data_changed USING er_data_changed.
  ENDMETHOD.
  METHOD evf_onf4.
    PERFORM ev_on_f4 USING e_fieldname e_fieldvalue es_row_no-row_id.
  ENDMETHOD.
  METHOD evf_double_click.
    PERFORM ev_double_click USING e_row.
  ENDMETHOD.
ENDCLASS.
