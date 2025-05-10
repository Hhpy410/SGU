*&---------------------------------------------------------------------*
*& Include          ZCMR1050_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK bl0 WITH FRAME TITLE TEXT-t10.
  PARAMETER: p_1oobj  LIKE hrp1000-objid  AS LISTBOX VISIBLE LENGTH 25
                                          OBLIGATORY USER-COMMAND xx1.

  PARAMETERS: p_peryr LIKE hrp1739-peryr OBLIGATORY
                      AS LISTBOX VISIBLE LENGTH 25 USER-COMMAND xxx MODIF ID per . "학년도

  PARAMETERS: p_perid LIKE hrp1739-perid OBLIGATORY
                      AS LISTBOX VISIBLE LENGTH 25 USER-COMMAND xxx MODIF ID per. "학기

  PARAMETER: p_datum TYPE sydatum DEFAULT sy-datum OBLIGATORY MODIF ID dat.

  SELECT-OPTIONS: s_stno12 FOR cmacbpst-student12 NO INTERVALS. "학번

SELECTION-SCREEN END OF BLOCK bl0.


SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-t20.
  PARAMETERS  p_r01 TYPE char01 RADIOBUTTON GROUP r1 DEFAULT 'X'
                                 USER-COMMAND r01.

  PARAMETERS p_chk01 TYPE flag AS CHECKBOX DEFAULT 'X' MODIF ID c1.
*  SELECTION-SCREEN COMMENT 10(40) FOR FIELD p_chk01.
  SELECTION-SCREEN COMMENT /1(50) TEXT-c01.

  SELECTION-SCREEN SKIP 1.

  PARAMETERS  p_r02 TYPE char01 RADIOBUTTON GROUP r1.
SELECTION-SCREEN END OF BLOCK bl1.
