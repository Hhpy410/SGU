*&---------------------------------------------------------------------*
*& Include          ZCMRK900_PAI
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

    WHEN 'SAVE'.
      PERFORM save_change_data.

    WHEN 'USELIST'.
      PERFORM check_uselist.

    WHEN 'USEUI5'.
      PERFORM check_uselist_u4a.

*    WHEN 'USEUI5SRC'.
*      PERFORM check_uselist_source.

    WHEN 'CRTALIAS'.
      PERFORM auto_create_alias.

    WHEN 'CORRALL'. " CTS 전체 묶기
      PERFORM corr_check_all.

    WHEN OTHERS.

  ENDCASE.

  CLEAR ok_code.


ENDMODULE.
