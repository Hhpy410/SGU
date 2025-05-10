*&---------------------------------------------------------------------*
*& Report ZCMRK010
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcmrk010 MESSAGE-ID zcm05.

INCLUDE mzcmrk010_top.
INCLUDE mzcmrk010_cls.
INCLUDE mzcmrk010_sel.
INCLUDE mzcmrk010_pbo.
INCLUDE mzcmrk010_pai.
INCLUDE mzcmrk010_frm.

INITIALIZATION.
  PERFORM init_proc.

START-OF-SELECTION.
  PERFORM get_data_select.

  CALL SCREEN 0100.
