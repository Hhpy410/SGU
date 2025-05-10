*&---------------------------------------------------------------------*
*&  Include           MZCMR5060I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  CASE ok_code.
    WHEN 'EXIT' OR 'CANC' OR 'BACK' .
      CLEAR ok_code .
      LEAVE TO SCREEN 0 .
  ENDCASE.
ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command INPUT.
  CASE ok_code.
    WHEN 'INFO'.    " Error List
      CLEAR ok_code .
      PERFORM display_error_list .
    WHEN 'CRTE' .   "등록생성
      CLEAR ok_code .
      PERFORM save_data_registration .
    WHEN 'DELE' .   "등록취소
      CLEAR ok_code .
      PERFORM save_cancel_registration .
*    WHEN 'SMS'.
*      READ TABLE gt_grid WITH KEY mark = 'X'.
*      IF sy-subrc <> 0.
*        MESSAGE w001 WITH '레코드를  선택하세요'.
*      ELSE.
*        CALL SCREEN '0200' STARTING AT 30 5.
*      ENDIF.
  ENDCASE .
ENDMODULE.                 " USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXITPOP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exitpop INPUT.

  gv_return = 'E' .
  LEAVE TO SCREEN 0.

ENDMODULE.                 " EXITPOP  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_TELNO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_telno INPUT.

  PERFORM check_telnos .

ENDMODULE.                 " CHECK_TELNO  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  DATA : l_chk2   TYPE c .

  CASE sy-ucomm .
    WHEN 'SAVE'.
      CLEAR: zflag.
      PERFORM check_proc_continue USING z_answer.
      IF z_answer IS NOT INITIAL.
        PERFORM check_input_sms USING l_chk2 .

        CHECK l_chk2 IS INITIAL .
        PERFORM send_sms_proc.
         "//__ASPN10 2024.04.25 :: CALL SCREEN 0400 생성X -> 주석  : BEGIN
*        CALL SCREEN  0400 STARTING AT 10 3
*                          ENDING   AT 80 20.
         "//__ASPN10 2024.04.25 :: CALL SCREEN 0400 생성X -> 주석  : END
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE .
*  IF sy-ucomm = 'CLOSE'.
*    LEAVE TO SCREEN 0.
*  ENDIF.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
