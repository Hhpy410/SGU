*----------------------------------------------------------------------*
***INCLUDE MP956600_I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  SET_MAX_GRD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_max_grd INPUT.

  DATA lt_grd TYPE TABLE OF t7piqscalegrade.

  CLEAR p9566-re_max_grd.
  SELECT * FROM t7piqscalegrade
    INTO TABLE lt_grd
    WHERE scaleid = p9566-re_scale.
  SORT lt_grd BY scaleid gradeno.

  READ TABLE lt_grd INTO DATA(ls_grd) INDEX 1.
  IF sy-subrc = 0.
    p9566-re_max_grd = ls_grd-gradeid.
  ENDIF.


ENDMODULE.
