*&---------------------------------------------------------------------*
*& Report ZCMRK410
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcmrk410.

INCLUDE mzcmrk410_top.
INCLUDE mzcmrk410_sel.
INCLUDE mzcmrk410_c01.
INCLUDE mzcmrk410_f01.

INITIALIZATION.
  PERFORM init_proc.

START-OF-SELECTION.
  PERFORM limit_user.
  PERFORM get_check.
  PERFORM check_st_auth.
  PERFORM get_course_detail.

  PERFORM grid_display_alv.
