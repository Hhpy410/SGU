*&---------------------------------------------------------------------*
*& Include          MZCMRK310_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-b01.
  PARAMETERS: p_orgcd LIKE hrp1000-objid OBLIGATORY USER-COMMAND tim
                        AS LISTBOX VISIBLE LENGTH 30.

  PARAMETERS: p_peryr LIKE piqstregper-peryr OBLIGATORY
                        AS LISTBOX VISIBLE LENGTH 30 USER-COMMAND tim.
  PARAMETERS: p_perid LIKE piqstregper-perid OBLIGATORY
                        AS LISTBOX VISIBLE LENGTH 30 USER-COMMAND tim.

  SELECT-OPTIONS: s_smsht FOR hrp1000-short NO INTERVALS.
  SELECT-OPTIONS: s_sesht FOR hrp1000-short NO INTERVALS.

SELECTION-SCREEN END OF BLOCK bl1.


SELECTION-SCREEN BEGIN OF SCREEN 210 AS SUBSCREEN .

  PARAMETERS : p_k1 LIKE hrp9551-book_kapz AS LISTBOX VISIBLE LENGTH 10 OBLIGATORY DEFAULT 1.
  PARAMETERS : p_k2 LIKE hrp9551-book_kapz AS LISTBOX VISIBLE LENGTH 10 OBLIGATORY DEFAULT 1.
  PARAMETERS : p_k3 LIKE hrp9551-book_kapz AS LISTBOX VISIBLE LENGTH 10 OBLIGATORY DEFAULT 1.
  PARAMETERS : p_k4 LIKE hrp9551-book_kapz AS LISTBOX VISIBLE LENGTH 10 OBLIGATORY DEFAULT 1.

SELECTION-SCREEN END OF SCREEN 210.
SELECTION-SCREEN BEGIN OF SCREEN 310 AS SUBSCREEN .

  SELECTION-SCREEN SKIP 1.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_r1 RADIOBUTTON GROUP g1 DEFAULT 'X' USER-COMMAND rr1.
    SELECTION-SCREEN COMMENT (20) FOR FIELD p_r1.

    PARAMETERS p_r2 RADIOBUTTON GROUP g1 .
    SELECTION-SCREEN COMMENT (20) FOR FIELD p_r2.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN END OF SCREEN 310.

*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_smsht-low.
*---------------------------------------------------------------------*
  PERFORM get_value_request_smsht(zcms11)  USING s_smsht-low gv_keydt.

*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_sesht-low.
*---------------------------------------------------------------------*
  PERFORM get_value_request_se(zcms11) USING s_sesht-low gv_keydt.

*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*----------------------------------------------------------------------*
  PERFORM get_datum.
