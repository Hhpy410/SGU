*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

* 버튼감추기
  CLEAR: gt_menu[].
  IF p_sel2 <> 'X' OR p_exp <> 'X'.
    gt_menu-fcode = 'ADD1'. APPEND gt_menu.
  ENDIF.

  IF p_sel1 <> 'X'.
    gt_menu-fcode = 'ADD2'. APPEND gt_menu."강제연장
  ENDIF.

  SET PF-STATUS '0100' EXCLUDING gt_menu.
  SET TITLEBAR 'T100' WITH p_peryr p_perid gv_tot.

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
    PERFORM make_exclude_code USING gt_fcode.
    PERFORM build_sort.
    PERFORM display_alv_screen.
  ELSE .
    PERFORM data_grid_screen_control.
    PERFORM refresh_grid.
  ENDIF.
ENDMODULE.                 " DISPLAY_ALV_DATA_100  OUTPUT
