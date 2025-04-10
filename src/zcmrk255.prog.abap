*&---------------------------------------------------------------------*
* Program ID  : ZCMRk255 <- zcmra255
* Title       : [CM]수강신청과목 담아놓기 신청내역
* Created By  : 정재현
* Created On  : 20241119
*&---------------------------------------------------------------------*
REPORT zcmrk255 LINE-SIZE 200 MESSAGE-ID zmmmc NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
* INCLUDE
*----------------------------------------------------------------------*
INCLUDE zcmrk255_t01.
INCLUDE zcmrk255_sel.
INCLUDE zcmrk255_alv.
INCLUDE zcmrk255_pbo.
INCLUDE zcmrk255_pai.
INCLUDE zcmrk255_f00.
INCLUDE zcmrk255_f01.
*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'FC01'. PERFORM set_prev_period.
    WHEN 'FC02'. PERFORM set_next_period.
    WHEN 'FC03'. PERFORM set_stats.
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
*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.
  CALL SCREEN 100.
