*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  PERFORM set_titlebar.
  CLEAR: gt_menu[], gt_menu.
  SET PF-STATUS '0100' EXCLUDING gt_menu.
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
    PERFORM make_grid_field_catalog CHANGING gt_grid_fcat.
    PERFORM make_exclude_code USING gt_fcode.
    PERFORM build_sort.
    PERFORM build_color.
    PERFORM set_stats_alv. "통계(ALV)
    PERFORM set_chart_gen. "차트
    PERFORM display_alv_screen.
  ELSE .
    PERFORM data_grid_screen_control.
    PERFORM refresh_grid.
  ENDIF.
ENDMODULE.                 " DISPLAY_ALV_DATA_100  OUTPUT
