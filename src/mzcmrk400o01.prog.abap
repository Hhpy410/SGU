*&---------------------------------------------------------------------*
*&  Include           MZCMR5060O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_100 OUTPUT.
  DATA: lv_lines LIKE sy-tabix .
  CLEAR: gt_menu[],gt_menu .
  IF gt_error[] IS INITIAL .
    gt_menu-fcode = 'INFO' .  APPEND gt_menu .
  ELSE .
  ENDIF .
*
  PERFORM get_acad_year_perid(zcmr5050) USING p_peryr
                                           p_perid
                                  CHANGING gv_yeartxt
                                           gv_sesstxt.
  DESCRIBE TABLE gt_grid LINES lv_lines .
  SET PF-STATUS 'MENU' EXCLUDING gt_menu .
  SET TITLEBAR 'T100' WITH gv_yeartxt gv_sesstxt '(' lv_lines '명)' .
ENDMODULE.                 " STATUS_100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_ALV_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_alv_data OUTPUT.
  IF g_grid IS INITIAL .
    PERFORM create_docking_container.
    PERFORM create_grid_object.
    PERFORM alv_data_display .
  ELSE .
    PERFORM alv_refresh_grid .
  ENDIF.
ENDMODULE.                 " DISPLAY_ALV_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'PF0200' .
ENDMODULE.                 " STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_ORGEH  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_orgeh OUTPUT.

  CLEAR : gv_username .

  IF NOT zxit0010-userid IS INITIAL .
    SELECT SINGLE orgtx INTO gv_username
      FROM t527x
      WHERE sprsl = sy-langu
        AND orgeh = zxit0010-userid
        AND endda = '99991231'.

    IF gv_username IS INITIAL .
      MESSAGE '존재하지 않는 부서코드 입니다' TYPE 'S' .
    ENDIF .
  ENDIF .

ENDMODULE.                 " GET_ORGEH  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_screen OUTPUT.

  IF zflag = 'X'.
    CLEAR : zflag, zxit0010.
    LEAVE TO SCREEN 0.
  ENDIF.

ENDMODULE.                 " SET_SCREEN  OUTPUT
