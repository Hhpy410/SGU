*&---------------------------------------------------------------------*
*& Report ZCMRK_DEMO2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcmrk_demo2.

INCLUDE mzcmrk_demo2_top.
INCLUDE mzcmrk_demo2_cls.
INCLUDE mzcmrk_demo2_sel.
INCLUDE mzcmrk_demo2_pbo.
INCLUDE mzcmrk_demo2_pai.
INCLUDE mzcmrk_demo2_frm.

*----------------------------------------------------------------------*
INITIALIZATION.
*----------------------------------------------------------------------*
  PERFORM initialization.

*----------------------------------------------------------------------*
START-OF-SELECTION.
*----------------------------------------------------------------------*
  CHECK ( p_col * p_row ) <= 4.

  PERFORM get_basic_data.
  PERFORM get_data_select.

  CALL SCREEN 0100.
