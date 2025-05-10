*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  gv_answer = 'J'.
  READ TABLE gt_data WITH KEY edit = 'X'.
  IF sy-subrc = 0.
    PERFORM confirm_message USING '변경사항을 저장하지 않고 종료합니다.'.
  ENDIF.
  CHECK gv_answer = 'J'.
  CLEAR: g_grid, g_grid2. "//////업로드 직후 F8시,,,,
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'SAVE'. PERFORM save_data.  "저장
    WHEN 'EXPD'. PERFORM set_popup.  "쿼터풀기
    WHEN 'UPLO'. PERFORM set_upload. "업로드
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXITPOP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exitpop INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXITPOP  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE sy-ucomm .
    WHEN 'SAVE'.
      CASE 'X'.
        WHEN sc_group1. PERFORM set_expand USING ' '. "학년풀기(1-4)
        WHEN sc_group2. PERFORM set_expand USING 'X'. "학년풀기(*)
      ENDCASE.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
