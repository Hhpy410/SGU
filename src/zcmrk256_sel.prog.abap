*&---------------------------------------------------------------------*
*& Include          MZCMRK990_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK bl0 WITH FRAME TITLE TEXT-t01.

  SELECTION-SCREEN SKIP 1.

  PARAMETERS p_peryr LIKE hrp1739-peryr OBLIGATORY
                      AS LISTBOX VISIBLE LENGTH 25 USER-COMMAND xxx . "학년도

  PARAMETERS p_perid LIKE hrp1739-perid OBLIGATORY
                      AS LISTBOX VISIBLE LENGTH 25 USER-COMMAND xxx . "학년도

  SELECT-OPTIONS p_smnum FOR hrp1000-short NO INTERVALS. "과목코드
  SELECT-OPTIONS p_stno FOR hrp1000-mc_short NO INTERVALS. "학번.

  SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN END OF BLOCK bl0.

*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_objid-low.
*  PERFORM f4_o_id.
