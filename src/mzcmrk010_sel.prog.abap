*&---------------------------------------------------------------------*
*& Include          MZCMRK010_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-b01.
  PARAMETERS: p_orgcd LIKE hrp1000-objid OBLIGATORY USER-COMMAND tim
                        AS LISTBOX VISIBLE LENGTH 30.

  PARAMETERS: p_peryr LIKE piqstregper-peryr OBLIGATORY
                        AS LISTBOX VISIBLE LENGTH 30 USER-COMMAND tim.
  PARAMETERS: p_perid LIKE piqstregper-perid OBLIGATORY
                        AS LISTBOX VISIBLE LENGTH 30 USER-COMMAND tim.

  SELECT-OPTIONS : s_smstat FOR hrpad506-smstatus.

  SELECT-OPTIONS : s_bookdt FOR hrpad506-bookdate.
  SELECT-OPTIONS : s_booktm FOR hrpad506-booktime.

SELECTION-SCREEN END OF BLOCK bl1.


AT SELECTION-SCREEN OUTPUT.
  PERFORM get_datum.
