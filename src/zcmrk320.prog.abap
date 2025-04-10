*&---------------------------------------------------------------------*
*& Report ZCMRK310
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcmrk320 NO STANDARD PAGE HEADING MESSAGE-ID zcm05.

INCLUDE mzcmrk320_top.
INCLUDE mzcmrk320_c01.
INCLUDE mzcmrk320_sel.
INCLUDE mzcmrk320_o01.
INCLUDE mzcmrk320_i01.
INCLUDE mzcmrk320_f01.

INITIALIZATION.
  PERFORM init_proc.

START-OF-SELECTION.
  PERFORM get_data_select.

  PERFORM grid_display_alv.


END-OF-SELECTION.
