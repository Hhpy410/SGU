*&---------------------------------------------------------------------*
*& Include          MZCMRK_DEMO1_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-001.

  PARAMETER p_torg LIKE hrp1000-objid AS LISTBOX USER-COMMAND top
                                    VISIBLE LENGTH 25 OBLIGATORY
                                    DEFAULT '30000002'.
  PARAMETERS: p_peryr LIKE hrp1739-peryr
                           AS LISTBOX VISIBLE LENGTH 20
                           USER-COMMAND tim.              "학년도
  PARAMETERS: p_perid LIKE hrp1739-perid OBLIGATORY
                           AS LISTBOX VISIBLE LENGTH 20
                             USER-COMMAND tim.            "학기
  PARAMETERS: p_datum LIKE sy-datum OBLIGATORY.           "표준일자
SELECTION-SCREEN END OF BLOCK b01.


SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-002.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 33.
    PARAMETERS: p_1oobj TYPE hrp1000-objid  MODIF ID org."학과
    SELECTION-SCREEN COMMENT 1(10) TEXT-003
      MODIF ID org FOR FIELD p_1oobj.
    SELECTION-SCREEN POSITION 42.
    PARAMETERS: p_1txt LIKE hrp1000-stext
                       VISIBLE LENGTH 20 MODIF ID org.
  SELECTION-SCREEN END  OF LINE.

  SELECT-OPTIONS s_dat FOR sy-datum DEFAULT sy-datum NO-EXTENSION.
  SELECT-OPTIONS: s_smsht FOR  hrp1000-short
                         NO INTERVALS MODIF ID r2.
  PARAMETERS:     p_smtx LIKE hrp1000-stext
                         MODIF ID r2.
  SELECT-OPTIONS: s_sest FOR  hrp1000-short
                         NO INTERVALS MODIF ID r2.
  SELECT-OPTIONS: s_inst FOR  pa0001-pernr
                         NO INTERVALS MODIF ID r2
                         MATCHCODE OBJECT prem.

SELECTION-SCREEN END OF BLOCK b02.

*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_torg. " 소속구분
*---------------------------------------------------------------------*
  PERFORM get_request_for_f4_torg(zcms0) USING 'P_TORG' p_torg.

*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_peryr.
*---------------------------------------------------------------------*
  PERFORM get_request_for_f4_peryr(zcms11) USING  p_peryr
                                                  p_torg.

*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_perid.
*---------------------------------------------------------------------*
  PERFORM get_request_for_f4_perid(zcms11) USING  p_perid
                                                  '1'.

*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_1oobj .
*---------------------------------------------------------------------*
  PERFORM get_request_for_f4_1oobj(zcms11) TABLES gt_orgs
                                           USING p_torg p_datum p_1oobj.
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_smsht-low.
*---------------------------------------------------------------------*
  PERFORM get_value_request_smsht(zcms11)  USING s_smsht-low p_datum.

*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_smtx.
*---------------------------------------------------------------------*
  PERFORM get_value_request_smtxt(zcms11)  USING p_smtx p_datum..


*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_sest-low.
*---------------------------------------------------------------------*
  PERFORM get_value_request_se(zcms11) USING s_sest-low p_datum.


*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*----------------------------------------------------------------------*
  PERFORM set_modify_screen.
  PERFORM get_datum.
  PERFORM get_text1000(zcms11) USING p_1oobj p_1txt p_datum.

*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
*----------------------------------------------------------------------*
