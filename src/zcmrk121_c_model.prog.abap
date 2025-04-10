*&---------------------------------------------------------------------*
*&  Include           ZCMRA121_C_MODEL
*&---------------------------------------------------------------------*
CLASS zcl_model DEFINITION DEFERRED.

* cancel course
CLASS cancel_course_model        DEFINITION DEFERRED.
CLASS cancel_course_facade_model DEFINITION DEFERRED.

CLASS hrp1000_model DEFINITION DEFERRED.
*----------------------------------------------------------------------*
*       CLASS zcl_model DEFINITION
*----------------------------------------------------------------------*
CLASS zcl_model DEFINITION ABSTRACT.

  PUBLIC SECTION.

*   기준일
    DATA v_keyda TYPE datum.

    METHODS:
      init_wa         ABSTRACT IMPORTING ps_any TYPE any OPTIONAL,
      init_data       ABSTRACT IMPORTING pt_any TYPE ANY TABLE OPTIONAL,
      get_data        ABSTRACT,
      set_data_1      ABSTRACT,
      set_info_data_1 ABSTRACT,
      set_info_data_2 ABSTRACT,
      set_info_data_3 ABSTRACT,
      edit_data_1     ABSTRACT,
      edit_data_2     ABSTRACT,
      edit_data_3     ABSTRACT,
      get_count       ABSTRACT RETURNING VALUE(pv_count) TYPE i,
      set_progbar IMPORTING p_msg TYPE string.

ENDCLASS.
*----------------------------------------------------------------------*
*       CLASS cancel_course_facade_model DEFINITION
*----------------------------------------------------------------------*
CLASS cancel_course_facade_model DEFINITION INHERITING FROM zcl_model.

  PUBLIC SECTION.
    DATA: o_cancel_course TYPE REF TO cancel_course_model,
          o_hrp1000       TYPE REF TO hrp1000_model.

    METHODS:
      constructor,
      get_info_data,
      set_progress IMPORTING pv_cnt TYPE i
                             pv_tot TYPE char6,

      set_comp_msg IMPORTING p_msg TYPE string.

    METHODS:
      init_wa         REDEFINITION,
      init_data       REDEFINITION,
      get_data        REDEFINITION,
      set_data_1      REDEFINITION,
      set_info_data_1 REDEFINITION,
      set_info_data_2 REDEFINITION,
      set_info_data_3 REDEFINITION,
      edit_data_1     REDEFINITION,
      edit_data_2     REDEFINITION,
      edit_data_3     REDEFINITION,
      get_count       REDEFINITION.

    METHODS:
      get_cancel_course_model
        RETURNING VALUE(po_model) TYPE REF TO cancel_course_model.

    METHODS delete IMPORTING pt_rows       TYPE salv_t_row
                   RETURNING VALUE(pv_err) TYPE char01.

    METHODS cancel.

    METHODS prechk1 RETURNING VALUE(pv_msg) TYPE string.

    METHODS stop RETURNING VALUE(pv_err) TYPE char01.

  PRIVATE SECTION.
    DATA  l_err(1).

    DATA  v_answer(1).
    DATA  v_msg(200).
    DATA  v_tot(6).

    DATA: r_objid  TYPE RANGE OF hrp1000-objid,
          rs_objid LIKE LINE OF r_objid.

ENDCLASS.
*----------------------------------------------------------------------*
*       CLASS hrp1000_model DEFINITION
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
CLASS hrp1000_model DEFINITION.

  PUBLIC SECTION.
    DATA: t_hrp1000 TYPE TABLE OF hrp1000,
          s_hrp1000 TYPE hrp1000.

    METHODS:
      clear,

      set_data IMPORTING pv_otype TYPE hrp1000-otype
                         pv_objid TYPE hrp1000-objid,

      get_data IMPORTING pv_otype   TYPE hrp1000-otype
                         pv_objid   TYPE hrp1000-objid
               EXPORTING pt_hrp1000 TYPE ANY TABLE.

ENDCLASS.
*----------------------------------------------------------------------*
*  CLASS cancel_course_model DEFINITION
*----------------------------------------------------------------------*
CLASS cancel_course_model DEFINITION.

  PUBLIC SECTION.
    DATA: t_zcmta235_cancel TYPE TABLE OF zcmta235_cancel,
          s_zcmta235_cancel TYPE zcmta235_cancel.

    DATA  v_hs_key TYPE char20.

    METHODS:
      constructor,
      clear,
      get_data.

    METHODS db_delete IMPORTING pt_sync       TYPE ANY TABLE
                      RETURNING VALUE(pv_err) TYPE char01.

    METHODS db_active RETURNING VALUE(pv_err) TYPE char01.

    METHODS db_not_use IMPORTING pt_sync       TYPE ANY TABLE
                       RETURNING VALUE(pv_err) TYPE char01.

    METHODS prechk1 RETURNING VALUE(pv_msg) TYPE string.

    METHODS:
      clear_hs_key,
      get_hs_key EXPORTING pv_hs_key TYPE char20,
      make_hs_key.

    METHODS:
      set_cancel_data IMPORTING po_hrp1000    TYPE REF TO hrp1000_model
                      RETURNING VALUE(pv_err) TYPE char01.
    METHODS:
      cancel,
      trans RETURNING VALUE(pv_err) TYPE char01.

ENDCLASS.
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* IMPLEMENTATION
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* CLASS cancel_course_facade_model IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS cancel_course_facade_model IMPLEMENTATION.

  METHOD constructor.

    super->constructor( ).
    CREATE OBJECT o_cancel_course.
    CREATE OBJECT o_hrp1000.

  ENDMETHOD.

  METHOD get_cancel_course_model.

    IF o_cancel_course IS BOUND.
      po_model = o_cancel_course.
    ENDIF.

  ENDMETHOD.

  METHOD set_comp_msg.

    DATA: lv_msg TYPE string.
    CONCATENATE `[ ` p_msg ` ] 완료` INTO lv_msg.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        text   = lv_msg
      EXCEPTIONS
        OTHERS = 0.

  ENDMETHOD.

  METHOD set_progress.

    DATA: lv_msg TYPE string, c(5),t(5).
    c = pv_cnt. t = pv_tot. CONDENSE: c, t.
    CONCATENATE c ` / ` t INTO lv_msg.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        text   = lv_msg
      EXCEPTIONS
        OTHERS = 0.

  ENDMETHOD.

  METHOD edit_data_1.

*    DATA ls_cancel_course TYPE ty_cancel_course.
*    CLEAR ls_cancel_course.
*    LOOP AT o_cancel_course->t_cancel_course INTO ls_cancel_course.
*
***     시한
**      IF ls_cancel_course-timelimit = '0300'.
**        ls_cancel_course-timelimitx = '수강신청기간'.
**      ELSEIF ls_cancel_course-timelimit = '4240'.
**        ls_cancel_course-timelimitx = '변경기간'.
**      ENDIF.
*
*      IF ls_cancel_course-smstatus = '04'.
*        ls_cancel_course-smstatusx = '수강취소'.
*      ENDIF.
*
*      IF ls_cancel_course-active = 'X'.
*        ls_cancel_course-status = icon_led_green.
*        ls_cancel_course-statux = '사용중'.
*      ELSE.
*        ls_cancel_course-status = icon_led_red.
*        ls_cancel_course-statux = '사용안함'.
*      ENDIF.
*
*      MODIFY o_cancel_course->t_cancel_course FROM ls_cancel_course.
*
*    ENDLOOP.

  ENDMETHOD.

  METHOD init_wa.
  ENDMETHOD.

  METHOD init_data.
  ENDMETHOD.

  METHOD edit_data_2.
  ENDMETHOD.

  METHOD edit_data_3.
  ENDMETHOD.

  METHOD set_data_1.
  ENDMETHOD.

  METHOD set_info_data_1.
*    set_progbar( EXPORTING p_msg = '교류정보' ).
*    o_9850->init( ).
*
*    set_progbar( EXPORTING p_msg = '교류정보 텍스트' ).
*    o_zcmt9850->set_data( ).
    LOOP AT gt_rows INTO gs_rows.
      READ TABLE gt_data INTO DATA(ls_data) INDEX gs_rows-index.
      CHECK sy-subrc = 0.

      o_hrp1000->set_data( pv_otype = 'SE'
                           pv_objid = ls_data-packnumber ).
    ENDLOOP.

  ENDMETHOD.

  METHOD set_info_data_2.
  ENDMETHOD.

  METHOD set_info_data_3.
  ENDMETHOD.

  METHOD get_data.
    o_cancel_course->get_data( ).
  ENDMETHOD.

  METHOD get_count.
    DESCRIBE TABLE o_cancel_course->t_zcmta235_cancel LINES pv_count.
  ENDMETHOD.

  METHOD get_info_data.

*    me->set_progbar( EXPORTING p_msg = '교류정보' ).
*    o_9850->init( ).

  ENDMETHOD.

  METHOD delete.

*    DATA ls_cancel_course    TYPE ty_cancel_course.
*    DATA lt_zcmt2018_sync TYPE TABLE OF zcmt2018_sync.
*    DATA ls_zcmt2018_sync TYPE zcmt2018_sync.
*    DATA ls_rows          TYPE lvc_s_row.
*
*    CLEAR lt_zcmt2018_sync.
*    LOOP AT pt_rows INTO ls_rows.
*
*      CLEAR ls_cancel.
*      READ TABLE o_cancel_course->t_zcmta235_cancel INDEX ls_rows
*      INTO ls_cancel.
*      IF sy-subrc = 0.
*        CLEAR ls_zcmt2018_sync.
*        MOVE-CORRESPONDING ls_cancel TO ls_zcmt2018_sync.
*        APPEND ls_zcmt2018_sync TO lt_zcmt2018_sync.
*      ENDIF.
*
*    ENDLOOP.
*
*    CHECK lt_zcmt2018_sync IS NOT INITIAL.
*
*    CLEAR pv_err.
*    pv_err = o_cancel_course->db_delete( pt_sync = lt_zcmt2018_sync ).

  ENDMETHOD.

  METHOD prechk1.

    CLEAR pv_msg.
    IF gt_rows[] IS INITIAL.
      pv_msg = `처리할 라인을 선택하세요.`.
    ENDIF.

    CHECK pv_msg IS INITIAL.

    LOOP AT gt_rows INTO gs_rows.
      READ TABLE gt_data INTO DATA(ls_data) INDEX gs_rows-index.
      CHECK sy-subrc = 0.

      IF ls_data-type <> 'E' AND ls_data-type <> 'W'.
        pv_msg = `정상적인 수강신청 내역은 삭제할 수 없습니다.`.
        EXIT.
      ENDIF.

      IF ls_data-short IS INITIAL.
        pv_msg = `학번이 없습니다.`.
        EXIT.
      ENDIF.

      IF ls_data-packnumber IS INITIAL.
        pv_msg = `수강취소 분반이 없습니다.`.
        EXIT.
      ENDIF.

      IF ls_data-smstatus <> '01'.
        pv_msg = `수강신청 상태가 아닙니다.`.
        EXIT.
      ENDIF.

      IF ls_data-stscd <> '2000'.
        pv_msg = `학적상태 휴학(2000)인 학생만 수강취소 가능합니다.`.
        EXIT.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD cancel.

*   실행확인
    CLEAR: v_answer, v_msg.
*    CONCATENATE TEXT-t02 ` ` TEXT-t05 INTO v_msg.
    v_msg = TEXT-t03.
    PERFORM popup_okay USING v_msg CHANGING v_answer.

    CHECK v_answer = 'J'.

    CLEAR v_msg.
    v_msg = o_cancel_course->prechk1( ).
    IF v_msg IS NOT INITIAL.
      MESSAGE v_msg TYPE 'I'.
      EXIT.

    ENDIF.

    set_info_data_1( ).

    o_cancel_course->clear_hs_key( ).
    o_cancel_course->make_hs_key( ).
    DATA(lv_err) =
      o_cancel_course->set_cancel_data(
        EXPORTING po_hrp1000 = o_hrp1000 ).

    CHECK l_err IS INITIAL.
    lv_err = o_cancel_course->trans( ).

*    IF lv_err IS INITIAL.
*      MESSAGE '[성공]수강과목 취소완료' TYPE 'I'.
*    ELSE.
*      MESSAGE '[실패]수강과목 취소, 다시 실행하세요.' TYPE 'I'.
*    ENDIF.

  ENDMETHOD.

  METHOD stop.
  ENDMETHOD.

ENDCLASS.
*----------------------------------------------------------------------*
* CLASS zcl_model IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS zcl_model IMPLEMENTATION.

  METHOD set_progbar.

    DATA: lv_msg TYPE string.
    CONCATENATE `[ ` p_msg ` ] 항목을 조회중입니다.` INTO lv_msg.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        text   = lv_msg
      EXCEPTIONS
        OTHERS = 0.

  ENDMETHOD.

ENDCLASS.
*----------------------------------------------------------------------*
* CLASS cancel_course_model IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS cancel_course_model IMPLEMENTATION.

  METHOD constructor.
  ENDMETHOD.

  METHOD clear.
    CLEAR me->t_zcmta235_cancel.
  ENDMETHOD.

  METHOD get_data.

*    SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE t_cancel_course
*      FROM zcmt2018_sync
*     WHERE peryr = p_peryr
*       AND perid = p_perid
*       AND smstatus = '04'. "취소

  ENDMETHOD.

  METHOD db_delete.

    CHECK pt_sync IS NOT INITIAL.
    DATA lt_zcmt2018_sync TYPE TABLE OF zcmt2018_sync.
    MOVE-CORRESPONDING pt_sync TO lt_zcmt2018_sync.

    CHECK lt_zcmt2018_sync IS NOT INITIAL.

    CLEAR pv_err.
    DELETE zcmt2018_sync FROM TABLE lt_zcmt2018_sync.
    IF sy-subrc <> 0.
      pv_err = 'X'.
    ENDIF.

  ENDMETHOD.

  METHOD db_active.

*    UPDATE zcmt2018_sync
*       SET active = 'X'
*     WHERE peryr = p_peryr AND perid = p_perid.
*    IF sy-subrc <> 0.
*      pv_err = 'X'.
*    ENDIF.

  ENDMETHOD.

  METHOD db_not_use.

    CHECK pt_sync IS NOT INITIAL.
    DATA lt_zcmt2018_sync TYPE TABLE OF zcmt2018_sync.
    MOVE-CORRESPONDING pt_sync TO lt_zcmt2018_sync.

    CHECK lt_zcmt2018_sync IS NOT INITIAL.
    DATA ls_zcmt2018_sync TYPE zcmt2018_sync.
    LOOP AT lt_zcmt2018_sync INTO ls_zcmt2018_sync.
      CLEAR ls_zcmt2018_sync-active.
      MODIFY lt_zcmt2018_sync FROM ls_zcmt2018_sync.
    ENDLOOP.

    CLEAR pv_err.
    MODIFY zcmt2018_sync FROM TABLE lt_zcmt2018_sync.
    IF sy-subrc <> 0.
      pv_err = 'X'.
    ENDIF.

  ENDMETHOD.

  METHOD prechk1.

    CLEAR pv_msg.
    IF gt_rows[] IS INITIAL.
      pv_msg = `처리할 라인을 선택하세요.`.
    ENDIF.

    CHECK pv_msg IS INITIAL.

    LOOP AT gt_rows INTO gs_rows.
      READ TABLE gt_data INTO DATA(ls_data) INDEX gs_rows-index.
      CHECK sy-subrc = 0.

      IF ls_data-type <> 'E' AND ls_data-type <> 'W'.
        pv_msg = `정상적인 수강신청 내역은 삭제할 수 없습니다.`.
        EXIT.
      ENDIF.

      IF ls_data-short IS INITIAL.
        pv_msg = `학번이 없습니다.`.
        EXIT.
      ENDIF.

      IF ls_data-packnumber IS INITIAL.
        pv_msg = `수강취소 분반이 없습니다.`.
        EXIT.
      ENDIF.

      IF ls_data-smstatus <> '01'.
        pv_msg = `수강신청 상태가 아닙니다.`.
        EXIT.
      ENDIF.

      IF ls_data-stscd <> '2000'.
        pv_msg = `학적상태 휴학(2000)인 학생만 수강취소 가능합니다.`.
        EXIT.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD clear_hs_key.

    CLEAR me->v_hs_key.

  ENDMETHOD.

  METHOD cancel.

  ENDMETHOD.

  METHOD get_hs_key.

    CHECK me->v_hs_key IS NOT INITIAL.
    pv_hs_key = me->v_hs_key.

  ENDMETHOD.

  METHOD make_hs_key.

    DATA lv_hs_key TYPE string.

    DO 10 TIMES.
      CLEAR lv_hs_key.
      CALL FUNCTION 'ZHR_GET_RANDOM_STRING'
        EXPORTING
          i_charlength = 20
        IMPORTING
          e_retv       = lv_hs_key.

      SELECT SINGLE *
        INTO @DATA(ls_zcmta235_cancel)
        FROM zcmta235_cancel
       WHERE hs_key = @lv_hs_key.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
    ENDDO.

    IF lv_hs_key IS NOT INITIAL.
      me->v_hs_key = lv_hs_key.
    ENDIF.

  ENDMETHOD.

  METHOD trans.

    CHECK me->v_hs_key IS NOT INITIAL.

*   parameter
    CLEAR gt_sel.
    CLEAR gs_sel.
    gs_sel-selname = 'P_TYPE1'."파일업로드
    gs_sel-low = ' '.
    APPEND gs_sel TO gt_sel.

    CLEAR gs_sel.
    gs_sel-selname = 'P_TYPE2'."직접입력
    gs_sel-low = ' '.
    APPEND gs_sel TO gt_sel.

    CLEAR gs_sel.
    gs_sel-selname = 'P_TYPE3'."전송처리
    gs_sel-low = 'X'.
    APPEND gs_sel TO gt_sel.

    FREE MEMORY ID 'HS_KEY'.
    EXPORT memory_abap FROM me->v_hs_key TO MEMORY ID 'HS_KEY'.
    SUBMIT zcmra235 WITH SELECTION-TABLE gt_sel AND RETURN.

    CLEAR pv_err.
    IMPORT memory_abap TO pv_err FROM MEMORY ID 'TRANS_ERROR'.

    IF pv_err = 'X'.
      MESSAGE `[ERROR][취소 실패]` TYPE 'I'.
    ENDIF.

  ENDMETHOD.

  METHOD set_cancel_data.

    pv_err = 'X'.
    CHECK me->v_hs_key IS NOT INITIAL.

    CLEAR t_zcmta235_cancel.
    LOOP AT gt_rows INTO gs_rows.
      READ TABLE gt_data INTO DATA(ls_data) INDEX gs_rows-index.
      CHECK sy-subrc = 0.

      CLEAR s_zcmta235_cancel.
      s_zcmta235_cancel-hs_key = me->v_hs_key.
      s_zcmta235_cancel-stnum = ls_data-short.

      READ TABLE po_hrp1000->t_hrp1000
      INTO DATA(ls_hrp1000)
      WITH KEY otype = 'SE'
               objid = ls_data-packnumber.
      CHECK sy-subrc = 0.

      SPLIT ls_hrp1000-short AT '-' INTO DATA(lv_smnum) DATA(lv_senum).
      s_zcmta235_cancel-smnum = lv_smnum.
      s_zcmta235_cancel-senum = lv_senum.

      s_zcmta235_cancel-erdat  = sy-datum.
      s_zcmta235_cancel-erzet  = sy-uzeit.
      s_zcmta235_cancel-ernam  = sy-uname.
      APPEND s_zcmta235_cancel TO t_zcmta235_cancel.

    ENDLOOP.

    CHECK t_zcmta235_cancel IS NOT INITIAL.
    INSERT zcmta235_cancel FROM TABLE t_zcmta235_cancel.
    IF sy-subrc = 0.
      COMMIT WORK.
      CLEAR pv_err.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
*----------------------------------------------------------------------*
* CLASS hrp1000_model IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS hrp1000_model IMPLEMENTATION.

  METHOD clear.

    CLEAR: me->t_hrp1000.

  ENDMETHOD.

  METHOD set_data.

    SELECT *
      INTO TABLE @DATA(lt_hrp1000)
      FROM hrp1000
     WHERE plvar  = '01'
       AND otype  = @pv_otype
       AND objid  = @pv_objid
       AND istat  = 1
       AND begda <= @sy-datum
       AND endda >= @sy-datum
       AND langu  = '3' "KO
       AND infty  = '1000'.
    APPEND LINES OF lt_hrp1000 TO me->t_hrp1000.
    SORT me->t_hrp1000 BY otype objid.
    DELETE ADJACENT DUPLICATES FROM me->t_hrp1000 COMPARING otype objid.

  ENDMETHOD.

  METHOD get_data.

    CHECK t_hrp1000 IS NOT INITIAL.

*    DATA: lt_zcmt0101 TYPE TABLE OF zcmt0101,
*          ls_zcmt0101 TYPE zcmt0101.
*    CLEAR: lt_zcmt0101,
*           ls_zcmt0101.
*    LOOP AT t_zcmt0101 INTO ls_zcmt0101
*    WHERE grp_cd = '105'.
*      APPEND ls_zcmt0101 TO lt_zcmt0101.
*    ENDLOOP.
*
*    pt_zcmt0101 = lt_zcmt0101.

  ENDMETHOD.

ENDCLASS.
