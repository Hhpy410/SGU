*&---------------------------------------------------------------------*
*& Include          MZCMRK010_PAI
*&---------------------------------------------------------------------*
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
    WHEN 'SETT'.
      PERFORM setting_popup.
    WHEN 'DEL_506'.
      PERFORM delete_booking_data.
    WHEN 'QT'.
      PERFORM update_qt_hrp9551.
    WHEN 'ADD'.
      PERFORM add_to_cart.
    WHEN 'SESS'.
      PERFORM st_session_del.
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
    WHEN 'OK'.
      PERFORM save_zcmtk222.
    WHEN OTHERS.

  ENDCASE.

  CLEAR ok_code.

ENDMODULE.
