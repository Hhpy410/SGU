*&---------------------------------------------------------------------*
* Program ID  : ZCMRK120 (ref. ZCMRA491-조기취업승인관리)
* Title       : [CM]재이수 데이터 이관(HRP9562->HRP9566)
* Created By  : 정재현
* Created On  : 2024.10.08
* Changed By  :
* Changed On  :
* Frequency   :
* Category    :
* Description :
*&---------------------------------------------------------------------*
REPORT zcmrk120 LINE-SIZE 200 MESSAGE-ID zmmmc NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
* INCLUDE
*----------------------------------------------------------------------*
INCLUDE zcmrk120_t01.
INCLUDE zcmrk120_cls.
INCLUDE zcmrk120_sel.
INCLUDE zcmrk120_alv.
INCLUDE zcmrk120_pbo.
INCLUDE zcmrk120_pai.
INCLUDE zcmrk120_f01.
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
*--------------------------------------------------------------------*
  PERFORM set_period.
  PERFORM set_stobjid.
  PERFORM get_data.
  PERFORM grid_display_alv.
*--------------------------------------------------------------------*
