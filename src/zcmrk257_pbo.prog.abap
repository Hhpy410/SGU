*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  CLEAR: gt_menu[].
  gt_menu-fcode = 'M2CRT'. APPEND gt_menu.
  gt_menu-fcode = 'RMDAT'. APPEND gt_menu.
  gt_menu-fcode = 'M2DAT'. APPEND gt_menu.
  gt_menu-fcode = 'ADCRT'. APPEND gt_menu.
  gt_menu-fcode = 'CLCRT'. APPEND gt_menu.
  gt_menu-fcode = 'EXPD'.  APPEND gt_menu.

  IF sy-tcode = 'ZCMRK257G'.
  ELSE.
    CASE 'X'.
      WHEN p_quota.
        DELETE gt_menu WHERE fcode = 'EXPD'.
      WHEN p_limit.
        DELETE gt_menu WHERE fcode = 'M2CRT'.
        DELETE gt_menu WHERE fcode = 'RMDAT'.
        DELETE gt_menu WHERE fcode = 'M2DAT'.
        DELETE gt_menu WHERE fcode = 'ADCRT'.
        DELETE gt_menu WHERE fcode = 'CLCRT'.
    ENDCASE.
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
    PERFORM set_f4_field2.
    PERFORM assign_grid_event_handlers.
    PERFORM make_grid_field_catalog  CHANGING gt_grid_fcat.
    PERFORM make_grid_field_catalog2 CHANGING gt_grid_fcat2.
    PERFORM make_exclude_code USING gt_fcode.
    PERFORM build_sort.
    PERFORM display_alv_screen.
  ELSE .
    PERFORM make_grid_field_catalog CHANGING gt_grid_fcat.
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
  SET TITLEBAR 'T200'.
ENDMODULE.                 " STATUS_0200  OUTPUT
