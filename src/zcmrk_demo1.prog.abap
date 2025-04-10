*&---------------------------------------------------------------------*
*& Report ZCMRK_DEMO1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcmrk_demo1.


INCLUDE mzcmrk_demo1_top.
INCLUDE mzcmrk_demo1_c01.
INCLUDE mzcmrk_demo1_sel.
INCLUDE mzcmrk_demo1_f01.


START-OF-SELECTION.

  PERFORM get_data_select.

  CHECK gt_data[] IS NOT INITIAL.
  PERFORM grid_display_alv.
