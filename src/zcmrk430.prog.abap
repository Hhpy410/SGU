*&---------------------------------------------------------------------*
* Program ID  : ZCMRK430
* Title       : [CM]학부 재이수 횟수관리(정규학기 8회)(New)
* Created By  : Nexpus
* Created On  : 2024.11.14.
* Frequency   :
* Category    :
* Description : ZCMRA261 복사 수정
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zcmrk430 LINE-SIZE 200 MESSAGE-ID zmmmc NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
* INCLUDE
*----------------------------------------------------------------------*
INCLUDE zcmrk430_t01.
INCLUDE zcmrk430_alv.
INCLUDE zcmrk430_c01.
INCLUDE zcmrk430_pbo.
INCLUDE zcmrk430_pai.
INCLUDE zcmrk430_f01.
*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'FC01'. PERFORM set_prev_period.
    WHEN 'FC02'. PERFORM set_next_period.
  ENDCASE.

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
  PERFORM get_data.

  CALL SCREEN 100.
*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.
