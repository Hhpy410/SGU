*&---------------------------------------------------------------------*
*& Include          MZCMRK310_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN FUNCTION KEY 1.
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


AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'FC01'.
      PERFORM form_get.
  ENDCASE.
