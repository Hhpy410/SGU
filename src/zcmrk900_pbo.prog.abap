*&---------------------------------------------------------------------*
*& Include          ZCMRK900_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  IF sy-sysid = 'DEV'.
  ELSE.
    gt_menu-fcode = 'SAVE'.     APPEND gt_menu.
    gt_menu-fcode = 'USELIST'.  APPEND gt_menu.
    gt_menu-fcode = 'CRTALIAS'. APPEND gt_menu.
    gt_menu-fcode = 'CORRALL'. APPEND gt_menu.
  ENDIF.
  SET PF-STATUS 'S0100' EXCLUDING gt_menu.

  DESCRIBE TABLE gt_data1.
  SET TITLEBAR 'T0100' WITH  sy-tfill '건'.
ENDMODULE.
