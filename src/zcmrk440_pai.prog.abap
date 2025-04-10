*&---------------------------------------------------------------------*
*& Include          ZCMR1050_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.


  CASE 'X'.
    WHEN p_r01.
      gt_menu-fcode = 'REPSTS'.     APPEND gt_menu.

    WHEN p_r02.

      gt_menu-fcode = 'REPEAT'.     APPEND gt_menu.

    WHEN OTHERS.

  ENDCASE.

  SET PF-STATUS 'S0100' EXCLUDING gt_menu.

*  DATA(lv_tdata) = |{ p_datum DATE = USER } 기준|.

  DESCRIBE TABLE gt_data1.
  SET TITLEBAR 'T0100' WITH  sy-tfill '건'.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE ok_code.
    WHEN 'REFRESH'.
      PERFORM get_data_select.

    WHEN 'REPEAT'.  "  재이수 처리
      PERFORM proc_repeat_sm .

    WHEN 'REPSTS'.  "  재이수 대체처리
      PERFORM proc_repsts_sm .

    WHEN 'DELE'. "  삭제
      PERFORM del_data.

    WHEN OTHERS.

  ENDCASE.

  CLEAR ok_code.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE ok_code.
    WHEN 'OK200'.

    WHEN OTHERS.

  ENDCASE.
  CLEAR ok_code.

ENDMODULE.
