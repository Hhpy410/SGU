*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'DOWN'. PERFORM get_file.
    WHEN 'STAT'. PERFORM get_stats.
    WHEN 'CANC'. PERFORM cancel_course.

    WHEN 'PUSH'.
      PERFORM call_push_popup.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  DATA: lv_chk.

  CASE ok_code.
    WHEN 'SEND'.
      PERFORM check_input_sms USING lv_chk.
      CHECK lv_chk IS INITIAL.
      PERFORM check_proc_continue USING 'PUSH를 전송하시겠습니까?' z_answer.
      CHECK z_answer IS NOT INITIAL.
      PERFORM send_sms_proc.
    WHEN 'CANC'.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.
