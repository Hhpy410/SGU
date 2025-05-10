*&---------------------------------------------------------------------*
* Program ID  : ZCMRK121 < zcmra121
* Title       : [CM]학부/대학원 수강신청 점검대상
* Created By  : 정재현
* Created On  : 2024/11/27
* Frequency   :
* Category    :
* Description :
*&---------------------------------------------------------------------*
REPORT zcmrk121 LINE-SIZE 200 MESSAGE-ID zmmmc NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
* INCLUDE
*----------------------------------------------------------------------*
INCLUDE zcm_common_type1.
INCLUDE zcm_common_t01.
INCLUDE zcm_common_alv01.
INCLUDE zcm_common_f01.
INCLUDE zcmrk121_t01.
INCLUDE zcmrk121_c_model.
INCLUDE zcmrk121_c_view.
INCLUDE zcmrk121_c_ctrl.
INCLUDE zcmrk121_c01.
INCLUDE zcmrk121_alv.
INCLUDE zcmrk121_scr.
INCLUDE zcmrk121_pbo.
INCLUDE zcmrk121_pai.
INCLUDE zcmrk121_f01.
*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'FC01'. PERFORM set_prev_period.
    WHEN 'FC02'. PERFORM set_next_period.
    WHEN 'FC03'. PERFORM form_get.
    WHEN 'FC04'. PERFORM call_tcode USING 'ZCMR9000'.
    WHEN 'FC05'. PERFORM set_cexcn.
  ENDCASE.

AT SELECTION-SCREEN OUTPUT.
  PERFORM set_perid_basic.
  PERFORM modify_screen.
  PERFORM show_pic. "이미지샘플

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_orgcd.
  PERFORM f4_org_cd.
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
