*&---------------------------------------------------------------------*
* Program ID  : ZCMRA254 -> ZCMRK254
* Title       : [CM]학부 계절학기 취소신청(SWCL) 내역조회
* Created By  : jjh
* Created On  : 2025.01.02
* Frequency   :
* Category    :
* Description :
*&---------------------------------------------------------------------*
REPORT zcmrk254 LINE-SIZE 200 MESSAGE-ID zmmmc NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
* INCLUDE
*----------------------------------------------------------------------*
INCLUDE zcmrk254_t01.
INCLUDE zcmrk254_sel.
INCLUDE zcmrk254_alv.
INCLUDE zcmrk254_c01.
INCLUDE zcmrk254_pbo.
INCLUDE zcmrk254_pai.
INCLUDE zcmrk254_f01.
*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM set_p_strda. "조회하려는 수강취소기간

AT SELECTION-SCREEN OUTPUT.
  PERFORM set_perid_basic.
  PERFORM modify_screen.
*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM init_proc.
*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM get_evob.
  PERFORM get_tuit.
  PERFORM get_data.
  CALL SCREEN 100.
*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.
