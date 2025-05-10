*&---------------------------------------------------------------------*
* Program ID  : ZCMRA582
* Title       : [CM]수강신청 일자별 피크타임 DB분석
* Created By  : 김상현
* Created On  : 2019.09.05
* Frequency   :
* Category    :
* Description :
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zcmrk500 LINE-SIZE 200 MESSAGE-ID zmmmc NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
* INCLUDE
*----------------------------------------------------------------------*
INCLUDE zcmrk500_t01.
INCLUDE zcmrk500_alv.
INCLUDE zcmrk500_pbo.
INCLUDE zcmrk500_pai.
INCLUDE zcmrk500_f01.
*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'FC01'. PERFORM set_prev_period.
    WHEN 'FC02'. PERFORM set_next_period.
  ENDCASE.
*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM modify_screen.
  PERFORM set_perid_basic.
  PERFORM get_keydate.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_orgcd.
*  PERFORM f4_org_cd.
*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM init_proc.
*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM get_data.
  PERFORM get_stats.
  CALL SCREEN 100.
*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.
