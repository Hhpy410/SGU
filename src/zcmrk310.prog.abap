*&---------------------------------------------------------------------*
*& Report ZCMRK310
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcmrk310 NO STANDARD PAGE HEADING MESSAGE-ID zcm05.

INCLUDE mzcmrk310_top.
INCLUDE mzcmrk310_c01.
INCLUDE mzcmrk310_sel.
INCLUDE mzcmrk310_o01.
INCLUDE mzcmrk310_i01.
INCLUDE mzcmrk310_f01.

INITIALIZATION.
  PERFORM init_proc.
*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM check_orgcd.
  PERFORM get_data_select.

  PERFORM grid_display_alv.

END-OF-SELECTION.
