*&---------------------------------------------------------------------*
*& Include          MZCMRK990_SEL
*&---------------------------------------------------------------------*

SELECT-OPTIONS : s_objid FOR hrp9566-objid NO INTERVALS.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_objid-LOW.
  PERFORM f4_O_ID.
