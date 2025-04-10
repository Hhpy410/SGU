**&---------------------------------------------------------------------*
**&  Include           ZCMRA121_C_CTRL
**&---------------------------------------------------------------------*
*CLASS cancel_course_mng DEFINITION DEFERRED.
***---------------------------------------------------------------------*
*** CLASS zcl_control
***---------------------------------------------------------------------*
*CLASS zcl_control DEFINITION ABSTRACT.
*
*  PUBLIC SECTION.
*
*    METHODS:
*
*      constructor IMPORTING po_model TYPE REF TO zcl_model,
*
**     common
*      set_progbar IMPORTING p_msg TYPE string,
*
**     data
*      init_data IMPORTING pt_any TYPE ANY TABLE OPTIONAL,
*      get_data,
*      edit_data_1,
*      set_info_data_1,
*      edit_data_2,
*      set_info_data_2,
*      edit_data_3,
*      set_info_data_3,
*      get_count RETURNING VALUE(pv_count) TYPE i,
*      chk_data RETURNING VALUE(is_success) TYPE abap_bool,
*
*      get_view_data
*        ABSTRACT RETURNING VALUE(po_model) TYPE REF TO object.
*
*  PRIVATE SECTION.
*    DATA: o_model TYPE REF TO zcl_model.
*
*ENDCLASS.
**----------------------------------------------------------------------*
** CLASS cancel_course_mng definition, 교류정보
**----------------------------------------------------------------------*
*CLASS cancel_course_mng DEFINITION INHERITING FROM zcl_control.
*
*  PUBLIC SECTION.
*
*    METHODS:
*      constructor
*        IMPORTING po_model TYPE REF TO cancel_course_facade_model,
*
*      save,
*      get_fcat EXPORTING pt_fcat TYPE abap_compdescr_tab,
*      del_zero IMPORTING pv_fname TYPE abap_compdescr-name
*               CHANGING  pv_val   TYPE string,
*
*      get_cancel_mng EXPORTING pt_outtab TYPE ANY TABLE,
*
**     view
*      get_view_data REDEFINITION.
*
*    METHODS delete.
*    METHODS cancel.
*    METHODS stop.
*
*  PRIVATE SECTION.
*    DATA o_model TYPE REF TO cancel_course_facade_model.
*    DATA l_err(1).
*
*    DATA v_answer(1).
*    DATA v_msg(200).
*    DATA v_tot(6).
*
*ENDCLASS.
**----------------------------------------------------------------------*
**----------------------------------------------------------------------*
**----------------------------------------------------------------------*
** IMPLEMENTATION
**----------------------------------------------------------------------*
**----------------------------------------------------------------------*
**----------------------------------------------------------------------*
**----------------------------------------------------------------------*
** CLASS zcl_control IMPLEMENTATION
**----------------------------------------------------------------------*
*CLASS zcl_control IMPLEMENTATION.
*
*  METHOD constructor.
*
*    o_model = po_model.
*
*  ENDMETHOD.
*
*  METHOD get_count.
*
*    pv_count = o_model->get_count( ).
*
*  ENDMETHOD.
*
*  METHOD init_data.
*
*    o_model->init_data( EXPORTING pt_any = pt_any  ).
*
*  ENDMETHOD.
*
*  METHOD get_data.
*
*    o_model->get_data( ).
*
*  ENDMETHOD.
*
*  METHOD chk_data.
*  ENDMETHOD.
*
*  METHOD edit_data_1.
*
*    o_model->edit_data_1( ).
*
*  ENDMETHOD.
*
*  METHOD set_info_data_1.
*
*    o_model->set_info_data_1( ).
*
*  ENDMETHOD.
*
*  METHOD edit_data_2.
*
*    o_model->edit_data_2( ).
*
*  ENDMETHOD.
*
*  METHOD set_info_data_2.
*
*    o_model->set_info_data_2( ).
*
*  ENDMETHOD.
*
*  METHOD edit_data_3.
*
*    o_model->edit_data_3( ).
*
*  ENDMETHOD.
*
*  METHOD set_info_data_3.
*
*    o_model->set_info_data_3( ).
*
*  ENDMETHOD.
*
*  METHOD set_progbar.
*
*    DATA: lv_msg TYPE string.
*    CONCATENATE `[ ` p_msg ` ] 항목을 조회중입니다.` INTO lv_msg.
*    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*      EXPORTING
*        text   = lv_msg
*      EXCEPTIONS
*        OTHERS = 0.
*
*  ENDMETHOD.
*
*ENDCLASS.
**----------------------------------------------------------------------*
** CLASS cancel_course_mng IMPLEMENTATION
**----------------------------------------------------------------------*
*CLASS cancel_course_mng IMPLEMENTATION.
*
*  METHOD save.
*
**    DATA lo_view TYPE REF TO cancel_mng_view.
**    PERFORM get_cancel_mng_view CHANGING lo_view.
**
**    DATA lt_rows TYPE salv_t_row.
**    CLEAR lt_rows.
**    lo_view->get_srows( IMPORTING pt_rows = lt_rows ).
**
**    DATA lv_answer.
**    DATA lv_msg(200).
**    DATA lv_tot(6).
**
**    CLEAR: lv_answer,
**           lv_msg,
**           lv_tot.
**
**    IF lt_rows IS INITIAL.
**      MESSAGE '저장할 라인을 선택하세요.' TYPE 'E'. "복수선택
**
**    ELSE.
**      DESCRIBE TABLE lt_rows LINES lv_tot.
**      CONCATENATE lv_tot ` 건 ` TEXT-t01 INTO lv_msg.
**      PERFORM popup_okay USING lv_msg CHANGING lv_answer.
**
**    ENDIF.
*
*
*  ENDMETHOD.
*
*  METHOD constructor.
*
*    super->constructor( po_model = po_model ).
*    o_model = po_model.
*
*  ENDMETHOD.
*
*  METHOD get_fcat.
*
**    o_view->get_fcat( IMPORTING pt_fcat = pt_fcat ).
*
*  ENDMETHOD.
*
*  METHOD del_zero.
*    SHIFT pv_val LEFT DELETING LEADING '0'. "00000000 제거
*  ENDMETHOD.
*
*  METHOD get_cancel_mng.
*
**    o_model->get_data( IMPORTING pt_cancel_mng = pt_outtab ).
*
*  ENDMETHOD.
*
*  METHOD get_view_data.
*
*    po_model = o_model->get_cancel_course_model( ).
*
*  ENDMETHOD.
*
*  METHOD delete.
*
**    DATA lo_view TYPE REF TO cancel_mng_view.
**    PERFORM get_cancel_mng_view CHANGING lo_view.
**
**    DATA lt_rows TYPE salv_t_row.
**    CLEAR lt_rows.
**    lo_view->get_srows( IMPORTING pt_rows = lt_rows ).
**
**    CLEAR: v_answer,
**           v_msg,
**           v_tot.
**
**    IF lt_rows IS INITIAL.
**      MESSAGE '라인을 선택하세요.' TYPE 'E'. "복수선택
**
**    ELSE.
**      DESCRIBE TABLE lt_rows LINES v_tot.
**      CONCATENATE v_tot ` 건 ` TEXT-t01 INTO v_msg.
**      PERFORM popup_okay USING v_msg CHANGING v_answer.
**
**    ENDIF.
**
**    CHECK v_answer = 'J'.
**
***   pt_row : 선택라인
**    CLEAR l_err.
**    l_err = o_model->delete( EXPORTING pt_rows = lt_rows ).
**    IF l_err IS INITIAL.
**      MESSAGE '삭제하였습니다.' TYPE 'I'.
**    ENDIF.
*
*  ENDMETHOD.
*
*  METHOD stop.
*
**   실행확인
*    CLEAR: v_answer, v_msg.
**    v_msg = TEXT-t03.
*    CONCATENATE TEXT-t03 ` ` TEXT-t04 INTO v_msg.
*    PERFORM popup_okay USING v_msg CHANGING v_answer.
*    CHECK v_answer = 'J'.
*
*    l_err = o_model->stop( ).
*    IF l_err IS INITIAL.
*      MESSAGE '상태변경 완료' TYPE 'I'.
*    ENDIF.
*
*  ENDMETHOD.
*
*  METHOD cancel.
*
**   실행확인
*    CLEAR: v_answer, v_msg.
*    CONCATENATE TEXT-t02 ` ` TEXT-t05 INTO v_msg.
*    PERFORM popup_okay USING v_msg CHANGING v_answer.
*
*    CHECK v_answer = 'J'.
*
*    CLEAR v_msg.
*    v_msg = o_model->prechk1( ).
*    IF v_msg IS NOT INITIAL.
*      MESSAGE v_msg TYPE 'I'.
*      EXIT.
*
*    ENDIF.
*
*    o_model->clear_hs_key( ).
*    o_model->make_hs_key( ).
*    o_model->set_data( EXPORTING pt_sel_rows = lt_rows ).


*    l_err = o_model->cancel( ).
*    IF l_err IS INITIAL.
*      MESSAGE '상태변경 완료' TYPE 'I'.
*    ENDIF.
*
*  ENDMETHOD.
*
*    ENDCLASS.
