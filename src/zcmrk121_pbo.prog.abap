*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR 'T100' WITH p_peryr p_perid gv_count gv_keyda.
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
*& Module INIT_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_0200 OUTPUT.

  CLEAR : gv_username.
  zxit0010-indate = sy-datum.
  zxit0010-intime = sy-uzeit.

  IF sy-sysid = 'DEV' AND sy-uname(4) = 'ASPN'.
    sy-uname = '302444'.
  ENDIF.

  SELECT SINGLE a~name_last
    INTO zxit0010-name
    FROM usr21 AS u INNER JOIN adrp AS a
                       ON u~persnumber = a~persnumber
                    INNER JOIN usr02 AS r
                       ON r~bname = u~bname
   WHERE u~bname = sy-uname.

  SELECT SINGLE orgeh
    INTO zxit0010-userid
    FROM pa0001
   WHERE pernr  = sy-uname
     AND begda <= sy-datum
     AND endda >= sy-datum.

  IF sy-subrc = 0.
    SELECT SINGLE orgtx INTO gv_username
      FROM t527x
      WHERE sprsl = '3'
        AND orgeh = zxit0010-userid
        AND endda = '99991231'.
    IF gv_username IS INITIAL .
      MESSAGE '존재하지 않는 부서코드 입니다' TYPE 'S' .
    ENDIF .
  ENDIF .


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS '0200'.
  SET TITLEBAR 'T200'.
ENDMODULE.
