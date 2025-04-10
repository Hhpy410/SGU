*&---------------------------------------------------------------------*
*& Include          ZCMRK254_SEL
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-b01.

  PARAMETERS: p_peryr LIKE piqstregper-peryr OBLIGATORY
                        AS LISTBOX VISIBLE LENGTH 25 USER-COMMAND uc1.

  PARAMETERS: p_perid LIKE piqstregper-perid OBLIGATORY
                        AS LISTBOX VISIBLE LENGTH 25 USER-COMMAND uc2.

*SELECT-OPTIONS: p_strrs FOR hrpad506-storreason NO INTERVALS DEFAULT 'SWCL'.
  SELECT-OPTIONS: p_strda FOR hrpad506-stordate NO-EXTENSION.
  SELECTION-SCREEN SKIP 1.

  SELECT-OPTIONS: p_stnum FOR hrp1000-short NO INTERVALS.
  SELECTION-SCREEN SKIP 1.

  PARAMETERS: p_raw RADIOBUTTON GROUP gp1 DEFAULT 'X' USER-COMMAND uc3.
  PARAMETERS: p_sum RADIOBUTTON GROUP gp1.


  SELECTION-SCREEN SKIP 1.

  PARAMETERS: p_bigo AS CHECKBOX.
  PARAMETERS: p_canc AS CHECKBOX.

SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT 1(80) t_001.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT 1(80) t_002.
