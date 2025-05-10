*&---------------------------------------------------------------------*
* Program ID  : ZCMRA581 -> ZCMRK581
* Title       : [CM]수강신청 패턴분석(Timeline)
* Created By  : J.H. Jung
* Created On  : 2018.08.16.
* Frequency   :
* Category    :
* Description :
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zcmrk581 LINE-SIZE 200 MESSAGE-ID zmmmc NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
* INCLUDE
*----------------------------------------------------------------------*
INCLUDE ZCMRK581_T01.
INCLUDE ZCMRK581_ALV.
INCLUDE ZCMRK581_PBO.
INCLUDE ZCMRK581_PAI.
INCLUDE ZCMRK581_C01.
INCLUDE ZCMRK581_F01.
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
  CALL SCREEN 0100.
*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.
