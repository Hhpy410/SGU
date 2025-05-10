*&---------------------------------------------------------------------*
*&  Include           MZCMR5060SEL
*&---------------------------------------------------------------------*
PARAMETERS: p_bukrs LIKE bkpf-bukrs DEFAULT '1000' NO-DISPLAY .
PARAMETERS: p_orgcd LIKE zcmt0700-orgcd OBLIGATORY DEFAULT '30000002'
                         AS LISTBOX VISIBLE LENGTH 25 USER-COMMAND ok .
PARAMETERS: p_orgcd2 LIKE hrp9580-objid OBLIGATORY DEFAULT '30000205'
                          AS LISTBOX VISIBLE LENGTH 20 MODIF ID mod .
PARAMETERS: p_peryr LIKE hrp9580-zperyr OBLIGATORY
                         AS LISTBOX VISIBLE LENGTH 20,  "학년도
            p_perid LIKE hrp9580-zperid OBLIGATORY DEFAULT '010'
                         AS LISTBOX VISIBLE LENGTH 20 .  "학기

SELECT-OPTIONS: s_stno12 FOR cmacbpst-student12 . "학번

PARAMETERS: p_none AS CHECKBOX.

*SELECTION-SCREEN BEGIN OF BLOCK b2 .
*  PARAMETERS p_old RADIOBUTTON GROUP ver.
*  PARAMETERS p_new RADIOBUTTON GROUP ver.
*SELECTION-SCREEN END  OF BLOCK b2.

*----------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_orgcd .
*----------------------------------------------------------------*
  PERFORM orgcd_f4_entry.
*----------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_orgcd2 .
*----------------------------------------------------------------*
  PERFORM orgcd2_f4_entry.

*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT .
*----------------------------------------------------------------------*
  PERFORM set_modify_screen.
*  학년도/학기
  PERFORM f4_pyear_perid .

*----------------------------------------------------------------------*
AT SELECTION-SCREEN .
*----------------------------------------------------------------------*
