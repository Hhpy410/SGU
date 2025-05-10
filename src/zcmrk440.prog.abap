*&---------------------------------------------------------------------*
* Program ID  : ZCMRK440
* Title       : [CM]재이수 처리
* Created By  : NEXPUS
* Created On  : 2024.11.14
* Frequency   : CM
* Category    :
* Description :
*&---------------------------------------------------------------------*
REPORT zcmrk440 NO STANDARD PAGE HEADING MESSAGE-ID zcm11.
*----------------------------------------------------------------------*
* INCLUDE
*----------------------------------------------------------------------*
INCLUDE zcmrk440_t01.
INCLUDE zcmrk440_cls.
INCLUDE zcmrk440_sel.
INCLUDE zcmrk440_pbo.
INCLUDE zcmrk440_pai.
INCLUDE zcmrk440_f01.
*&---------------------------------------------------------------------*
INITIALIZATION.
*&---------------------------------------------------------------------*
  PERFORM initialization.

*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_1oobj. " 소속
*---------------------------------------------------------------------*
  PERFORM get_request_for_f4_org USING p_1oobj.

*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_perid.
*---------------------------------------------------------------------*
  PERFORM get_request_for_f4_perid(zcms11) USING  p_perid '001'.


*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*----------------------------------------------------------------------*
  PERFORM set_modify_screen.
  PERFORM get_datum.

*----------------------------------------------------------------------*
AT SELECTION-SCREEN .
*----------------------------------------------------------------------*
  CASE sy-ucomm.
    WHEN 'XX1'.
      PERFORM set_default_2oobj_val.

    WHEN OTHERS.

  ENDCASE.
*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM get_data_comm.
  PERFORM get_data_select.
  CHECK gv_error IS INITIAL.
  CALL SCREEN 100.
