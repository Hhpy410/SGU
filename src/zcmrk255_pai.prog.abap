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
    WHEN 'RELO'.                 PERFORM get_data.
    WHEN 'MODE0'. gv_mode = '0'. PERFORM get_data.
    WHEN 'MODE1'. gv_mode = '1'. PERFORM get_data.
    WHEN 'MODE2'. gv_mode = '2'. PERFORM get_data.
    WHEN 'MODE3'. gv_mode = '3'. PERFORM get_data.
    WHEN 'MODE4'. gv_mode = '4'. PERFORM get_data.
    WHEN 'PUSH'.
      PERFORM excute_push_message..
  ENDCASE.
  PERFORM build_color.
  PERFORM refresh_grid.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
