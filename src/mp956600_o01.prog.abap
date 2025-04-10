*----------------------------------------------------------------------*
***INCLUDE MP956600_B01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module SET_DDLB OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_ddlb OUTPUT.
  TYPES: BEGIN OF vrm_value,
           key(40)  TYPE c,
           text(80) TYPE c,
         END OF vrm_value,

         vrm_values TYPE vrm_value OCCURS 0.

  DATA: values TYPE vrm_values WITH HEADER LINE.

  SELECT scaleid text FROM t7piqscalet
    INTO TABLE values
    WHERE langu = sy-langu.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'P9566-RE_SCALE'
      values = values[].

ENDMODULE.
