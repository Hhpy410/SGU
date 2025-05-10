*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  DATA: c(3).
  CASE p_perid.
    WHEN '010'.  c = '1'.
    WHEN '011'.  c = '하계'.
    WHEN '020'.  c = '2'.
    WHEN '021'.  c = '동계'.
    WHEN OTHERS. c = p_perid.
  ENDCASE.

  SET TITLEBAR 'T100' WITH p_peryr c gv_count.
  IF p_stp3 = 'X'.
    SET TITLEBAR 'T200' WITH p_peryr c gv_count.
  ENDIF.


* 버튼감추기
  CLEAR: gt_menu[].
  CASE 'X'.
    WHEN p_stp1 OR p_stp2.
      gt_menu-fcode = 'MODE1'. APPEND gt_menu.
      gt_menu-fcode = 'MODE2'. APPEND gt_menu.
      gt_menu-fcode = 'MODE3'. APPEND gt_menu.
      gt_menu-fcode = 'MODE4'. APPEND gt_menu.
    WHEN p_stp3.
      gt_menu-fcode = 'RELO'.  APPEND gt_menu.
  ENDCASE.
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
    PERFORM build_sort.
    PERFORM build_color.
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
