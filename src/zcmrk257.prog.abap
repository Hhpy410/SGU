*&---------------------------------------------------------------------*
* Program ID  : ZCMRA257 -> ZCMRK257
* Title       : [CM]수강신청 제한조건 일괄입력(신버전)
* Created By  : J.H. Jung
* Created On  : 2024.02.03
* Frequency   :
* Category    :
* Description :
*&---------------------------------------------------------------------*
REPORT zcmrk257 LINE-SIZE 200 MESSAGE-ID zmmmc NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
* INCLUDE
*----------------------------------------------------------------------*
INCLUDE zcmrk257_t01.
INCLUDE zcmrk257_alv.
INCLUDE zcmrk257_scr.
INCLUDE zcmrk257_c01.
INCLUDE zcmrk257_pbo.
INCLUDE zcmrk257_pai.
INCLUDE zcmrk257_f01.
*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'FC01'. PERFORM set_prev_period.
    WHEN 'FC02'. PERFORM set_next_period.
    WHEN 'FC03'. PERFORM form_get.
  ENDCASE.

AT SELECTION-SCREEN OUTPUT.
  PERFORM set_perid_basic.
  PERFORM modify_screen.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_orgcd.
  PERFORM org_f4_entry.
*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM init_proc.
*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM get_evob.    "개설과목
  PERFORM get_data.    "자료조회
  PERFORM adjust_data. "순번조정(최초)
  PERFORM add_cart.    "카트채움(최초)
  CALL SCREEN 100.
*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.
