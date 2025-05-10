*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
*
*  DATA: c(3).
*  CASE p_perid.
*    WHEN '010'.  c = '1'.
*    WHEN '011'.  c = '하계'.
*    WHEN '020'.  c = '2'.
*    WHEN '021'.  c = '동계'.
*    WHEN OTHERS. c = p_perid.
*  ENDCASE.
*  SET TITLEBAR 'T100' WITH p_peryr c gv_count.
*
** 버튼감추기
*  CLEAR: gt_menu[].
**  CASE 'X'.
**    WHEN p_stp2.
**      gt_menu-fcode = 'FORM'. "#EC CI_USAGE_OK[2270335]
**      APPEND gt_menu. "양식내려받기
**      gt_menu-fcode = 'UPLO'. APPEND gt_menu. "업로드(화면)
**      gt_menu-fcode = 'ZTRN'. APPEND gt_menu. "저장하기
**
**  ENDCASE.
*  SET PF-STATUS '0100' EXCLUDING gt_menu.

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
*    PERFORM build_color.
    PERFORM display_alv_screen.
  ELSE .
    PERFORM refresh_grid.
  ENDIF.
ENDMODULE.                 " DISPLAY_ALV_DATA_100  OUTPUT
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

* SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module DISPLAY_ALV_DATA_S200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE display_alv_data_s200 OUTPUT.

  SET PF-STATUS 'S200'.
*  SET TITLEBAR 'T200' WITH p_peryr gs_perit-perit.

  PERFORM modify_screen_200.

  PERFORM create_display_falv_s200.

ENDMODULE.
