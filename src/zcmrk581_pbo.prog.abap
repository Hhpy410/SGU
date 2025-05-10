*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  READ TABLE p_datum INDEX 1.
  SET PF-STATUS '0100'.
  SET TITLEBAR 'T100' WITH gv_total p_datum-low p_datum-high.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_ALV_DATA_100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_alv_data_100 OUTPUT.
  IF g_grid IS INITIAL .
    PERFORM create_docking_container.
    PERFORM create_grid_object.
    PERFORM register_grid_event.
    PERFORM assign_grid_event_handlers.
    PERFORM make_grid_field_catalog CHANGING gt_grid_fcat.
    PERFORM build_sort.
    PERFORM display_alv_screen.
  ELSE .
    PERFORM data_grid_screen_control.
    PERFORM refresh_grid.
  ENDIF.
ENDMODULE.                 " DISPLAY_ALV_DATA_100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS '0200'.
*  SET TITLEBAR 'xxx'.
ENDMODULE.                 " STATUS_0200  OUTPUT
