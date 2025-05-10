*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CREATE_DOCKING_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_docking_container .
* Docking Container Object 선언.
  CREATE OBJECT g_docking_container
    EXPORTING
      style     = cl_gui_control=>ws_child
      repid     = sy-cprog                          "현재 프로그램 ID
      dynnr     = sy-dynnr                          "현재 화면번호
      side      = g_docking_container->dock_at_left "CONTAINER POS
      lifetime  = cl_gui_control=>lifetime_imode
      extension = gc_extension                      "CONTAINER SIZE
    EXCEPTIONS
      OTHERS    = 1.
  IF sy-subrc = 1.
    MESSAGE 'fail create object g_docking_container' TYPE 'I'.
  ENDIF.

* Splitter Container Object 선언.
  CREATE OBJECT g_splitter
    EXPORTING
      parent  = g_docking_container
      rows    = 1
      columns = 1.                  " 1개의 ROW, 2개의 COLUME
*
  CALL METHOD g_splitter->set_column_width
    EXPORTING
      id    = 1
      width = 20.

* assign G_Container1 & 2 with any columns
  g_container  = g_splitter->get_container( row = 1 column = 1 ).
*  g_container2  = g_splitter->get_container( row = 1 column = 2 ).
ENDFORM.                    " CREATE_DOCKING_CONTAINER
*&---------------------------------------------------------------------*
*&      Form  CREATE_GRID_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_grid_object .
*
* Create Code type ALV List
  CREATE OBJECT g_grid
    EXPORTING
      i_parent = g_container.

  gs_layout-sel_mode   = 'D'. "'A'.
  gs_layout-cwidth_opt = 'A'.
* gs_layout-zebra      = 'X'.
  gs_layout-ctab_fname = 'COLOR'.
  gs_layout-stylefname = 'CELLTAB'.

ENDFORM.                    " CREATE_GRID_OBJECT
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv_screen .

  DATA: ls_variant TYPE disvariant.
  CLEAR: ls_variant.
  ls_variant-report = sy-repid.

  CALL METHOD g_grid->set_table_for_first_display
    EXPORTING
      is_layout       = gs_layout
*     IT_TOOLBAR_EXCLUDING = GT_FCODE
      i_save          = 'A'
      i_default       = 'X'
      is_variant      = ls_variant
*     i_bypassing_buffer   = 'X'
    CHANGING
      it_sort         = gt_sort[]
      it_fieldcatalog = gt_grid_fcat[]
      it_outtab       = <fs_tab>.

ENDFORM.                    " DISPLAY_ALV_SCREEN
*&---------------------------------------------------------------------*
*&      Form  MAKE_GRID_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_GRID_FCAT  text
*----------------------------------------------------------------------*
FORM make_grid_field_catalog  CHANGING pt_fieldcat TYPE lvc_t_fcat.

  DATA : lt_fieldcat TYPE slis_t_fieldcat_alv,
         ls_fcat     TYPE lvc_s_fcat,
         lv_tabname  TYPE slis_tabname.

  lv_tabname = gv_tname.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = lv_tabname
      i_client_never_display = gc_set
      i_inclname             = sy-repid
      i_bypassing_buffer     = gc_set
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc = 0.
    PERFORM transfer_slis_to_lvc CHANGING lt_fieldcat pt_fieldcat.
  ENDIF.

  DEFINE set_fcat.
    ls_fcat-col_pos   = &1.
    ls_fcat-outputlen = &2.
    ls_fcat-coltext   = &3.

  END-OF-DEFINITION.

*  LOOP AT pt_fieldcat INTO ls_fcat.
*    CLEAR ls_fcat-key.
*    CASE ls_fcat-fieldname.
*      WHEN 'NEW'.        set_fcat: 01  05  '신규'.
*      WHEN 'TYPE'.       set_fcat: 02  05  '오류'.
*      WHEN 'EMSG'.       set_fcat: 03  05  '비고'.
*      WHEN 'PERYR'.      set_fcat: 04  05  '학년도'.
*      WHEN 'PERID'.      set_fcat: 05  05  '학기'.
*      WHEN 'ST_NUM'.     set_fcat: 04  05  '학번'.
*      WHEN 'ST_NAME'.    set_fcat: 06  05  '이름'.
*      WHEN 'OBJID'.      set_fcat: 07  05  'stobjid'.
*      WHEN 'SHORT1'.     set_fcat: 08  05  '선택1(과목코드)'.
*      WHEN 'SM_STEXT1'.  set_fcat: 09  20  '선택1(과목명)'.
*      WHEN 'SM_OBJID1'.  set_fcat: 10  50  '선택1(smobjid)'.
*      WHEN 'SHORT2'.     set_fcat: 11  05  '선택2(과목코드)'.
*      WHEN 'SM_STEXT2'.  set_fcat: 12  20  '선택2(과목명)'.
*      WHEN 'SM_OBJID2'.  set_fcat: 13  50  '선택2(smobjid)'.
*      WHEN 'ERDAT'.      set_fcat: 14  05  '저장일자'.
*      WHEN 'ERTIM'.      set_fcat: 15  05  '저장시간'.
*      WHEN 'SMNUM'.      set_fcat: 16  05  '과목코드'.
*      WHEN OTHERS. ls_fcat-no_out = gc_set.
*    ENDCASE.
*
*    IF ls_fcat-fieldname = 'NEW'.
*      ls_fcat-checkbox = 'X'.
*    ENDIF.
*
*    IF p_stp1 = 'X'. "신청가능과목업로드
*      IF ls_fcat-fieldname = 'ST_NUM'     OR
*         ls_fcat-fieldname = 'ST_NAME'    OR
*         ls_fcat-fieldname = 'OBJID'      OR
*         ls_fcat-fieldname = 'SHORT1'     OR
*         ls_fcat-fieldname = 'SM_STEXT1'  OR
*         ls_fcat-fieldname = 'SM_OBJID1'  OR
*         ls_fcat-fieldname = 'SHORT2'     OR
*         ls_fcat-fieldname = 'SM_STEXT2'  OR
*         ls_fcat-fieldname = 'SM_OBJID2'  OR
*         ls_fcat-fieldname = 'ERDAT'      OR
*         ls_fcat-fieldname = 'ERTIM'.
*
*        ls_fcat-no_out = 'X'.
*      ENDIF.
*    ELSE.            "신청내역보기
*      IF ls_fcat-fieldname = 'NEW'      OR
*          ls_fcat-fieldname = 'TYPE'    OR
*          ls_fcat-fieldname = 'EMSG'    OR
*          ls_fcat-fieldname = 'SMNUM'.
*        ls_fcat-no_out = 'X'.
*      ENDIF.
*    ENDIF.
*
*    MODIFY pt_fieldcat FROM ls_fcat.
*  ENDLOOP.

ENDFORM.                    " MAKE_GRID_FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  BUILD_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_sort .

  CLEAR: gt_sort.
  CLEAR: gs_sort.

** 신청가능과목
*  IF p_stp1 = 'X'.
*    gs_sort-spos      = 1.
*    gs_sort-up        = 'X'.
*    gs_sort-fieldname = 'STNO'. "학번
*    APPEND gs_sort TO gt_sort.
*
*    gs_sort-spos      = 1.
*    gs_sort-up        = 'X'.
*    gs_sort-fieldname = 'SSSHORT'. "분반코드
*    APPEND gs_sort TO gt_sort.
*  ENDIF.

ENDFORM.                    " BUILD_SORT
*&---------------------------------------------------------------------*
*&      Form  REFRESH_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM refresh_grid .
  CLEAR: gs_scroll.
  gs_scroll-row = 'X'.
  gs_scroll-col = 'X'.
  CALL METHOD g_grid->refresh_table_display
    EXPORTING
      is_stable = gs_scroll.
ENDFORM.                    " REFRESH_GRID
*&---------------------------------------------------------------------*
*&      Form  TRANSFER_SLIS_TO_LVC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_FIELDCAT  text
*      <--P_PT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM transfer_slis_to_lvc  CHANGING pt_fieldcat TYPE slis_t_fieldcat_alv
                                   pt_field TYPE lvc_t_fcat.

  DATA : lt_fieldcat TYPE kkblo_t_fieldcat.

  CALL FUNCTION 'REUSE_ALV_TRANSFER_DATA'
    EXPORTING
      it_fieldcat = pt_fieldcat
    IMPORTING
      et_fieldcat = lt_fieldcat.

  CALL FUNCTION 'LVC_TRANSFER_FROM_KKBLO'
    EXPORTING
      it_fieldcat_kkblo = lt_fieldcat
    IMPORTING
      et_fieldcat_lvc   = pt_field.
ENDFORM.                    " TRANSFER_SLIS_TO_LVC
*&---------------------------------------------------------------------*
*&      Form  INIT_PROC
*&---------------------------------------------------------------------*
*       학년도/학기에 해당하는 학사력을 읽어온다.
*----------------------------------------------------------------------*
FORM init_proc.

* 현재학년도 학기
  PERFORM set_current_period.

* 사용자의 권한조직 취득
*  PERFORM get_user_authorg.

* 버튼
  CONCATENATE icon_column_left  '' INTO sscrfields-functxt_01.
  CONCATENATE icon_column_right '' INTO sscrfields-functxt_02.

* 안내
*  CONCATENATE icon_information
*  `조기 취업 승인 학부생은 성적 부여 시 최대 B+까지 성적을 부여한다.`
*  INTO t_001.

  PERFORM set_current_period. "현재학년도 학기

ENDFORM.                    " INIT_PROC
*&---------------------------------------------------------------------*
*&      Form  set_current_period
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_current_period.

  DATA: lt_hrtimeinfo TYPE zcms023_tab,
        ls_timeinfo   TYPE zcms023,
        lv_keydate    TYPE datum.

* 한달 후의 학사력으로 조회
  lv_keydate = sy-datum + 30.

  CALL FUNCTION 'ZCM_GET_TIMELIMITS'
    EXPORTING
      iv_o         = '30000002'
      iv_timelimit = '0100'
      iv_keydate   = lv_keydate
    IMPORTING
      et_timeinfo  = lt_hrtimeinfo.

  CHECK NOT lt_hrtimeinfo[] IS INITIAL.

  LOOP AT lt_hrtimeinfo INTO ls_timeinfo.
    t_peryr = f_peryr = ls_timeinfo-peryr.
    t_perid = f_perid = ls_timeinfo-perid.
  ENDLOOP.

ENDFORM.                    " set_current_period
*&---------------------------------------------------------------------*
*&      Form  modify_screen
*&---------------------------------------------------------------------*
*       화면조정
*----------------------------------------------------------------------*
FORM modify_screen.

*  LOOP AT SCREEN.
*    CASE screen-group1.
*      WHEN 'SP1'.
*        IF p_stp1 IS INITIAL.
*          screen-active = 0.
*        ELSE.
*          screen-active = 1.
*        ENDIF.
*    ENDCASE.
*    MODIFY SCREEN.
*
*  ENDLOOP.

ENDFORM.                    " modify_screen
*&---------------------------------------------------------------------*
*&      Form  SET_PREV_PERIOD
*&---------------------------------------------------------------------*
FORM set_prev_period .

  CASE f_perid.
    WHEN '010'. f_perid = '021'. f_peryr = f_peryr - 1.
    WHEN '011'. f_perid = '010'.
    WHEN '020'. f_perid = '011'.
    WHEN '021'. f_perid = '020'.
  ENDCASE.
  t_peryr = f_peryr.
  t_perid = f_perid.

ENDFORM.                    " SET_PREV_PERIOD
*&---------------------------------------------------------------------*
*&      Form  SET_NEXT_PERIOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_next_period .

* 정규학기만
  CALL FUNCTION 'ZCM_LIST_BOX_PYEAR_PERID'
    EXPORTING
      year_field  = 'F_PERYR'
      perid_field = 'F_PERID'.

  CALL FUNCTION 'ZCM_LIST_BOX_PYEAR_PERID'
    EXPORTING
      year_field  = 'T_PERYR'
      perid_field = 'T_PERID'.

ENDFORM.                    " SET_NEXT_PERIOD
*&---------------------------------------------------------------------*
*&      Form  SET_PERID_BASIC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_perid_basic.

* 정규학기만
  CALL FUNCTION 'ZCM_LIST_BOX_PYEAR_PERID'
    EXPORTING
      year_field  = 'F_PERYR'
      perid_field = 'F_PERID'.

  CALL FUNCTION 'ZCM_LIST_BOX_PYEAR_PERID'
    EXPORTING
      year_field  = 'T_PERYR'
      perid_field = 'T_PERID'.

ENDFORM.                    " SET_PERID_BASIC
*&---------------------------------------------------------------------*
*&      Form  SET_CONFIRM
*&---------------------------------------------------------------------*
FORM set_confirm USING p_msg.

  CLEAR: gv_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      textline1 = p_msg
      titel     = '확인'
    IMPORTING
      answer    = gv_answer.
  IF gv_answer NE 'J'. "실행확인
    MESSAGE '실행이 중단되었습니다.' TYPE 'E'. EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_PROGTEXT
*&---------------------------------------------------------------------*
FORM set_progtext USING p_msg .

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = p_msg
    EXCEPTIONS
      OTHERS = 0.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_PROGRESS
*&---------------------------------------------------------------------*
FORM set_progress USING p_cur_cnt.

  DATA: lv_msg TYPE string, c(5),t(10).
  c = p_cur_cnt. t = gv_tot. CONDENSE: c, t.
  CONCATENATE c ` / ` t INTO lv_msg.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = lv_msg
    EXCEPTIONS
      OTHERS = 0.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form migration1
*&---------------------------------------------------------------------*
FORM migration2.

  PERFORM set_confirm USING 'Migration2 실행하시겠습니까?'.

  PERFORM set_progtext USING '[migration2] get hrp1001 table'.
  CLEAR: gt_h1001[], gt_h1001.
  CHECK gt_data[] IS NOT INITIAL.
  SELECT *
    INTO TABLE @gt_h1001
    FROM hrp1001
     FOR ALL ENTRIES IN @gt_data
   WHERE otype = 'SM'
     AND objid = @gt_data-h506_resmid
     AND plvar = '01'
     AND rsign = 'B'
     AND relat = '506'
     AND istat = '1'
     AND infty = '1001'
     AND subty = 'B506'
     AND sclas = 'ST'
     AND sobid = @gt_data-sobid.

  CHECK gt_h1001[] IS NOT INITIAL.
  PERFORM set_progtext USING '[migration2] get hrpad506 table relate with hrp1001 table'.
  SELECT *
    INTO TABLE gt_hrpad506
    FROM hrpad506
     FOR ALL ENTRIES IN gt_h1001
   WHERE adatanr = gt_h1001-adatanr
     AND hrpad506~smstatus IN ('01', '02', '03'). "01: 수강신청됨, 02: 완료(성공), 03: 완료(실패)

  PERFORM set_progtext USING '[migration2] set hrpad506 id'.

  DESCRIBE TABLE gt_data LINES gv_tot.
  CLEAR gv_update_record.
  CLEAR: gv_cnt, gv_100_cnt, gv_1000_cnt.
  LOOP AT gt_data.
    ADD 1 TO gv_cnt.
    ADD 1 TO gv_100_cnt.
    ADD 1 TO gv_1000_cnt.
    IF gv_100_cnt = 100.
      CLEAR: gv_100_cnt, gv_1000_cnt.
      PERFORM set_progress USING sy-tabix.
    ENDIF.

    DATA lt_id TYPE TABLE OF hrpad506-id.
*    lt_id = VALUE #(
*      FOR gs_h1001 IN gt_h1001
*        WHERE ( otype = 'SM' AND
*                objid = gt_data-h506_resmid AND "retake smobjid
*                rsign = 'B' AND
*                relat = '506' AND
*                subty = 'B506' AND
*                sclas = 'ST' AND
*                sobid = gt_data-objid )"stobjid
*      FOR gs_hrpad506 IN gt_hrpad506
*        WHERE ( adatanr = gs_h1001-adatanr AND
*                peryr   = gt_data-h506_reperyr AND
*                perid   = gt_data-h506_reperid )
*      ( gs_hrpad506-id )
*    ).
    SELECT id
      FROM zv_piqmodbooked2
     WHERE plvar = '01'
       AND otype = 'SM'
       AND objid = @gt_data-h506_resmid "retake smobjid
       AND sclas = 'ST'
       AND sobid = @gt_data-objid "stobjid
       AND peryr = @gt_data-h506_reperyr
       AND perid = @gt_data-h506_reperid
       AND smstatus IN ('01', '02', '03') "01: 수강신청됨, 02: 완료(성공), 03: 완료(실패)
      INTO TABLE @lt_id.

    CHECK lt_id IS NOT INITIAL.
    DESCRIBE TABLE lt_id LINES DATA(id_cnt).
    CHECK id_cnt = 1.
    READ TABLE lt_id INTO DATA(id) INDEX 1.
    CHECK sy-subrc IS INITIAL.
    gt_data-h506_reid = id.

*   mark
    gt_data-migration2 = 'X'.

    MODIFY gt_data.
    ADD 1 TO gv_update_record.

  ENDLOOP.

  CLEAR gv_msg.
  CONCATENATE `처리 되었습니다. (처리: ` gv_update_record `건)`
         INTO gv_msg.
  MESSAGE gv_msg TYPE 'S'.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form migration1
*&---------------------------------------------------------------------*
FORM migration1.

  PERFORM set_confirm USING 'Migration1 실행하시겠습니까?'.

  CLEAR gv_update_record.
  LOOP AT gt_data.

    gt_data-h506_reperyr = gt_data-repeatyr.
    gt_data-h506_reperid = gt_data-repeatid.
    gt_data-h506_resmid  = gt_data-rep_module.
*   gt_data-h506_stobjid = gt_data-objid.

*(  재이수 확정
    gt_data-h506_repeatfg = 'X'.
    IF gt_data-no_cnt = 'X'.
      CLEAR gt_data-h506_repeatfg.
    ENDIF.
*)

*   etc
    gt_data-sobid = gt_data-objid.

*   mark
    gt_data-migration1 = 'X'.

    MODIFY gt_data.
    ADD 1 TO gv_update_record.

  ENDLOOP.

  CLEAR gv_msg.
  CONCATENATE `처리 되었습니다. (처리: ` gv_update_record `건)`
         INTO gv_msg.
  MESSAGE gv_msg TYPE 'S'.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  POPUP_OKAY
*&---------------------------------------------------------------------*
* confirm popup
*----------------------------------------------------------------------*
FORM popup_okay USING    p_text
                CHANGING p_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
*     TITLEBAR       = ' '
*     DIAGNOSE_OBJECT             = ' '
      text_question  = p_text
      text_button_1  = '확인'
*     ICON_BUTTON_1  = ' '
      text_button_2  = '취소'
*     ICON_BUTTON_2  = ' '
      default_button = '1'
*     DISPLAY_CANCEL_BUTTON       = 'X'
    IMPORTING
      answer         = p_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.

  CASE sy-subrc.
    WHEN 1.
      MESSAGE 'text_not_found' TYPE 'I'.
    WHEN 2.
      MESSAGE 'popup 에러' TYPE 'I'.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PROGRESS_DISPLAY
*&---------------------------------------------------------------------*
FORM progress_display USING percent ptext.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = percent
      text       = ptext
    EXCEPTIONS
      OTHERS     = 0.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  get_apply_data
*&---------------------------------------------------------------------*
*  개설신청, 신청내역조회
*----------------------------------------------------------------------*
FORM get_apply_data.
*
** alv layout 설정
*  UNASSIGN <fs_tab>.
*  gv_tname = 'GT_APPLY_DATA'.
*
*  DATA lr_stobjid TYPE RANGE OF hrobjid.
*  CLEAR lr_stobjid.
*  PERFORM get_r_stobjid CHANGING lr_stobjid.
*
*  SELECT *
*    INTO CORRESPONDING FIELDS OF TABLE gt_apply_data
*    FROM zcmt2200
*   WHERE peryr = p_peryr "학년도
*     AND perid = p_perid "학기
*     AND objid IN lr_stobjid.
*
*  PERFORM get_st_info.
*  PERFORM get_sm_info.
*
** 기타정보
*  LOOP AT gt_apply_data .
*
**   st info(학번,이름)
*    READ TABLE gt_st_info WITH KEY st_objid = gt_apply_data-objid.
*    IF sy-subrc = 0.
*      gt_apply_data-st_num  = gt_st_info-st_num.  "학번
*      gt_apply_data-st_name = gt_st_info-st_name. "이름
*
*    ENDIF.
*
**   학생 선택과목1 정보(학번,이름)
*    READ TABLE gt_se_info WITH KEY se_short = gt_apply_data-short1.
*    IF sy-subrc = 0.
*      gt_apply_data-sm_objid1 = gt_se_info-se_objid.
*      gt_apply_data-sm_stext1 = gt_se_info-se_stext. "과목명
*
*    ENDIF.
*
**   학생 선택과목2 정보(학번,이름)
*    READ TABLE gt_se_info WITH KEY se_short = gt_apply_data-short2.
*    IF sy-subrc = 0.
*      gt_apply_data-sm_objid2 = gt_se_info-se_objid.
*      gt_apply_data-sm_stext2 = gt_se_info-se_stext. "과목명
*
*    ENDIF.
*
*    MODIFY gt_apply_data .
*  ENDLOOP.
*
** for alv
*  ASSIGN gt_apply_data[] TO <fs_tab>.
*  CLEAR gv_count.
*  DESCRIBE TABLE gt_apply_data  LINES gv_count.
*  IF gv_count = 0.
*    MESSAGE '조회 결과가 없습니다' TYPE 'S'.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_DATA_CHK
*&---------------------------------------------------------------------*
*  gt_data_create internal table에서 오류 check
*----------------------------------------------------------------------*
FORM create_data_chk.

  PERFORM get_sm_info.

  DEFINE set_err_msg.
    gt_data_create-type = 'E'.
    CONCATENATE &1 ' 오류 ' INTO gt_data_create-emsg.

  END-OF-DEFINITION.

  LOOP AT gt_data_create WHERE new = 'X'.

    IF gt_data_create-peryr IS INITIAL.
      set_err_msg: '학년도'.
    ELSEIF gt_data_create-perid IS INITIAL.
      set_err_msg: '학기'.
    ELSEIF gt_data_create-stno IS INITIAL.
      set_err_msg: '학번'.
    ELSEIF gt_data_create-ssshort IS INITIAL.
      set_err_msg: '분반코드'.
    ENDIF.

*   분반코드 chk
    IF gt_data_create-ssshort IS NOT INITIAL.
      READ TABLE gt_se_info WITH KEY se_short = gt_data_create-ssshort.
      IF sy-subrc <> 0.
        set_err_msg: '과목번호'.
      ENDIF.
    ENDIF.

*   success 표시
    IF gt_data_create-emsg IS INITIAL.
      gt_data_create-type = 'S'.
    ENDIF.

    MODIFY gt_data_create.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_ST_INFO
*&---------------------------------------------------------------------*
*  gt_st_info setting
*----------------------------------------------------------------------*
FORM get_st_info.

  DATA: lr_stobjid TYPE RANGE OF hrobjid,
        ls_stobjid LIKE LINE OF lr_stobjid.

  CLEAR: lr_stobjid[], lr_stobjid.
  LOOP AT gt_apply_data .
    CLEAR ls_stobjid.
    ls_stobjid-sign = 'I'.
    ls_stobjid-option = 'EQ'.
    ls_stobjid-low = gt_apply_data-objid. "stobjid
    APPEND ls_stobjid TO lr_stobjid.
  ENDLOOP.

* st info(학번,이름)
  SELECT  objid AS st_objid
          short AS st_num   "학번(예. 20130709)
          stext AS st_name   "이름
    INTO TABLE gt_st_info
    FROM hrp1000
   WHERE
         plvar  = '01'
     AND otype  = 'ST'
     AND istat  = '1'
     AND begda <= sy-datum
     AND endda >= sy-datum
     AND langu  = '3'
     AND objid  IN lr_stobjid. "stobjid

* 중복제거
  DELETE ADJACENT DUPLICATES FROM gt_st_info COMPARING st_objid.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  get_sm_info
*&---------------------------------------------------------------------*
*  gt_se_info setting
*----------------------------------------------------------------------*
FORM get_sm_info.
*  DATA: lr_sm TYPE RANGE OF short_d,
*        ls_sm LIKE LINE OF lr_sm.
*  CLEAR: lr_sm[], lr_sm.
*
*  CASE 'X'.
*    WHEN p_stp1.
*
*      LOOP AT gt_data_create WHERE new = 'X'.
*        CLEAR ls_sm.
*        ls_sm-sign = 'I'.
*        ls_sm-option = 'EQ'.
*        ls_sm-low = gt_data_create-ssshort.
*        APPEND ls_sm TO lr_sm.
*
*      ENDLOOP.
*
*    WHEN p_stp2. "신청내역조회
*
*      LOOP AT gt_apply_data .
*
*        CLEAR ls_sm.
*        ls_sm-sign = 'I'.
*        ls_sm-option = 'EQ'.
*
**       sm short1(선택1 과목코드)
*        IF gt_apply_data-short1 IS NOT INITIAL.
*          ls_sm-low = gt_apply_data-short1.
*          APPEND ls_sm TO lr_sm.
*        ENDIF.
*
**       sm short2(선택2 과목코드)
*        IF gt_apply_data-short2 IS NOT INITIAL.
*          ls_sm-low = gt_apply_data-short2.
*          APPEND ls_sm TO lr_sm.
*        ENDIF.
*
*      ENDLOOP.
*
*    WHEN OTHERS.
*  ENDCASE.
*
** 학생 선택 과목정보(학번,이름)
*  SELECT objid AS sm_objid
*         short AS sm_short  "과목코드(예. EDUC427)
*         stext AS sm_stext  "과목명  (예. 심리학연구법)
*    INTO TABLE gt_se_info
*    FROM hrp1000
*   WHERE
*         plvar  = '01'
*     AND otype  = 'SM'
*     AND istat  = '1'
*     AND begda <= sy-datum
*     AND endda >= sy-datum
*     AND langu  = '3'
*     AND short IN lr_sm.  "과목번호
*
** 중복제거
*  DELETE ADJACENT DUPLICATES FROM gt_se_info COMPARING se_objid.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  get_upload_data
*&---------------------------------------------------------------------*
*  업로드된 학생(과목) 보기
*----------------------------------------------------------------------*
FORM get_upload_data.
*
*  CLEAR: gt_data_create[], gt_data_create.
*  SELECT *
*    INTO CORRESPONDING FIELDS OF TABLE gt_data_create
*    FROM zcmta491_regist
*   WHERE peryr = p_peryr  "학년도
*     AND perid = p_perid. "학기
*
** alv layout 설정
*  UNASSIGN <fs_tab>.
*  gv_tname = 'GT_DATA_CREATE'.
*  ASSIGN gt_data_create[] TO <fs_tab>.
*
*  CLEAR gv_count.
*  DESCRIBE TABLE gt_data_create LINES gv_count.
*  IF gv_count = 0.
*    MESSAGE '조회 결과가 없습니다' TYPE 'S'.
*  ENDIF.
*
**  PERFORM create_data_chk.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_R_STOBJID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_r_stobjid CHANGING pr_stobjid TYPE ty_r_hrobjid.

  DATA: BEGIN OF lt_stobjid OCCURS 0,
          objid TYPE hrobjid,
        END OF lt_stobjid.
  CLEAR: lt_stobjid[], lt_stobjid.

  CHECK p_stno IS NOT INITIAL.
  SELECT stobjid
    INTO TABLE lt_stobjid
    FROM cmacbpst
   WHERE student12 IN p_stno.

  CHECK lt_stobjid[] IS NOT INITIAL.
  SORT lt_stobjid. "ASPN08 중복제거 전 SORT구문 추가 2024.02.19
  DELETE ADJACENT DUPLICATES FROM lt_stobjid.

  DATA ls_stobjid LIKE LINE OF pr_stobjid.
  CLEAR ls_stobjid.
  CLEAR pr_stobjid.
  LOOP AT lt_stobjid .
    CLEAR ls_stobjid.
    ls_stobjid-sign = 'I'.
    ls_stobjid-option = 'EQ'.
    ls_stobjid-low = lt_stobjid-objid. "stobjid
    APPEND ls_stobjid TO pr_stobjid.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_period
*&---------------------------------------------------------------------*
FORM set_period.

  DATA: lv_peryr TYPE piqperyr,
        lv_perid TYPE piqperid.

  DATA  ls_period TYPE ty_period.

  lv_peryr = f_peryr.
  lv_perid = f_perid.

  CLEAR gt_period.
  DO 500 TIMES.
    CLEAR  ls_period.
    ls_period-peryr = lv_peryr.
    ls_period-perid = lv_perid.

    CASE ls_period-perid.
      WHEN '001' OR '010' OR '011'.
        ls_period-keyda+0(4) = ls_period-peryr.
        ls_period-keyda+4(4) = '0401'.
      WHEN '002' OR '020' OR '021'.
        ls_period-keyda+0(4) = ls_period-peryr.
        ls_period-keyda+4(4) = '1001'.
    ENDCASE.
    APPEND ls_period TO gt_period.

    IF lv_peryr = t_peryr AND
       lv_perid = t_perid.
      EXIT. "종료
    ENDIF.

    CASE lv_perid. "다음 학년도/학기
      WHEN '010'.
        lv_perid = '011'.
      WHEN '011'.
        lv_perid = '020'.
      WHEN '020'.
        lv_perid = '021'.
      WHEN '021'.
        lv_perid = '010'. lv_peryr = lv_peryr + 1.
    ENDCASE.
  ENDDO.

  SORT gt_period BY peryr perid.
  DELETE ADJACENT DUPLICATES FROM gt_period COMPARING peryr perid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_stobjid
*&---------------------------------------------------------------------*
FORM set_stobjid.

  CHECK p_stno IS NOT INITIAL.
  SELECT student12, stobjid
    FROM cmacbpst
   WHERE student12 IN @p_stno
    INTO TABLE @DATA(lt_cmacbpst).

  CHECK lt_cmacbpst IS NOT INITIAL.
  LOOP AT lt_cmacbpst INTO DATA(ls_cmacbpst).

    gr_stobjid-sign   = 'I'.
    gr_stobjid-option = 'EQ'.
    gr_stobjid-low    = ls_cmacbpst-stobjid.
    APPEND gr_stobjid.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_data.

  PERFORM get_underlying_data.
*  PERFORM get_hrpad506.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_hrpad506
*&---------------------------------------------------------------------*
FORM get_hrpad506.

*  CHECK gt_data[] IS NOT INITIAL.
*  SELECT gt_data-objid AS objid
*     INTO CORRESPONDING FIELDS OF TABLE gt_hrpad506
*    FROM hrp1001
*     FOR ALL ENTRIES IN gt_data
*   WHERE otype = 'SM'
*     AND objid = gt_data-sm_id "smobjid
*     AND rsign = 'B'
*     AND relat = '506'
*     AND istat = '1'
*     AND infty = '1001'
*     AND subty = 'B506'
*     AND sclas = 'ST'
*     AND sobid = gt_data-objid. "stobjid


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_underlying_data.


  LOOP AT gt_period INTO DATA(ps_period).
    DATA lt_data LIKE TABLE OF gt_data.
    SELECT zcmt9562~piqperyr AS peryr, "수강신청학년도
           zcmt9562~piqperid AS perid, "수강신청학기
           hrp9562~objid,     "student objid
           zcmta446~student12, "학번
*          hrp1000~stext,
           zcmta446~st_stscd, "학적상태
*          zcmt0101~com_nm,
           zcmta446~o_objid,
           zcmta446~o_short,
           zcmta446~sc_objid1, "1전공  objid
           zcmta446~sc_short1, "1전공명
           zcmt9562~adatanr,
           zcmt9562~sm_id,
           zcmt9562~repeatyr,
           zcmt9562~repeatid,
           zcmt9562~rep_module,
           zcmt9562~con_grd,
           zcmt9562~credit,
           zcmt9562~repeat_cd,
           zcmt9562~no_cnt,

           hrpad506~adatanr  AS h506_adatanr,
           hrpad506~reperyr  AS h506_reperyr,
           hrpad506~reperid  AS h506_reperid,
           hrpad506~resmid   AS h506_resmid,
           hrpad506~reid     AS h506_reid,
           hrpad506~repeatfg AS h506_repeatfg
      FROM hrp9562
      INNER JOIN zcmt9562
              ON zcmt9562~adatanr = hrp9562~adatanr
             AND zcmt9562~piqperyr = @ps_period-peryr
             AND zcmt9562~piqperid = @ps_period-perid
      INNER JOIN zcmta446
              ON stobjid = hrp9562~objid
      LEFT OUTER JOIN hrp1001
                   ON hrp1001~otype = 'SM'
                  AND hrp1001~objid = zcmt9562~sm_id "smobjid
                  AND hrp1001~plvar = '01'
                  AND hrp1001~rsign = 'B'
                  AND hrp1001~relat = '506'
                  AND hrp1001~istat = '1'
                  AND hrp1001~infty = '1001'
                  AND hrp1001~subty = 'B506'
                  AND hrp1001~sclas = 'ST'
                  AND hrp1001~sobid = hrp9562~objid
      INNER JOIN hrpad506
              ON hrpad506~adatanr = hrp1001~adatanr
             AND hrpad506~smstatus IN ('01', '02', '03') "01:수강신청, 02:완료(성공, 03:완료(실패)
             AND hrpad506~peryr   = @ps_period-peryr
             AND hrpad506~perid   = @ps_period-perid
     WHERE hrp9562~plvar  = '01'
       AND hrp9562~otype  = 'ST'
       AND hrp9562~objid IN @gr_stobjid
       AND hrp9562~istat  = '1'
       AND hrp9562~begda <= @sy-datum
       AND hrp9562~endda >= @sy-datum
       AND hrp9562~infty  = '9562'
      INTO CORRESPONDING FIELDS OF TABLE @lt_data.
    CHECK sy-subrc IS INITIAL.
    APPEND LINES OF lt_data TO gt_data.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_display_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM grid_display_alv .

  IF go_grid IS INITIAL .
    go_grid ?= lcl_alv_grid=>create( CHANGING ct_table = gt_data[] ).
    go_grid->title_v1 =
      | 재이수 데이터 이관 / | &&
      |{ f_peryr }-{ f_perid } ~ { t_peryr }-{ t_perid } / | &&
      |{ lines( gt_data ) } 건|.

    PERFORM grid_field_catalog.
    PERFORM grid_layout.
    PERFORM grid_sort.

*    PERFORM build_color.
*    PERFORM grid_color.

    PERFORM grid_gui_status.

    go_grid->display( ).

  ELSE.
    go_grid->soft_refresh( ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM grid_field_catalog .


  LOOP AT go_grid->fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).

    IF <fs_fcat>-outputlen >= 30.
      <fs_fcat>-outputlen = 20.
    ENDIF.

    IF <fs_fcat>-outputlen <= 5.
      <fs_fcat>-outputlen = 5.
    ENDIF.

    CASE <fs_fcat>-fieldname.
      WHEN 'MIGRATION1'.
        <fs_fcat>-reptext = 'Migration1'.
        <fs_fcat>-checkbox   = 'X'.
      WHEN 'MIGRATION2'.
        <fs_fcat>-reptext = 'Migration2'.
        <fs_fcat>-checkbox   = 'X'.
      WHEN 'SAVE'.
        <fs_fcat>-reptext = 'Save'.
        <fs_fcat>-checkbox   = 'X'.
      WHEN 'PERYR' OR 'PERID' OR 'STID'.
*        <fs_fcat>-no_out = 'X'.
      WHEN 'SOBID'.
        <fs_fcat>-no_out = 'X'.
      WHEN 'O_OBJID'.
        <fs_fcat>-reptext = '소속학과' .
      WHEN 'O_SHORT'.
        <fs_fcat>-reptext = '소속학과명'.
      WHEN 'SC_OBJID1'.
        <fs_fcat>-reptext = '제1전공'.
      WHEN 'SC_STEXT1'.
        <fs_fcat>-reptext = '제1전공명'.
        <fs_fcat>-outputlen = 16.
      WHEN 'SC_OBJID2'.
        <fs_fcat>-reptext = '제2전공'.
      WHEN 'SC_STEXT2'.
        <fs_fcat>-reptext = '제2전공명'.
        <fs_fcat>-outputlen = 16.
      WHEN 'STNO'.
*        <fs_fcat>-reptext = '학번' .
*        <fs_fcat>-outputlen = 12.
      WHEN 'STNM'.
*       <fs_fcat>-reptext = '성명' .
*       <fs_fcat>-outputlen = 16.
        <fs_fcat>-no_out = 'X'.
      WHEN 'ST_STSCD'.
        <fs_fcat>-reptext = '학적상태'.
      WHEN 'ST_STSCDT'.
        <fs_fcat>-no_out = 'X'.
      WHEN 'NO_CNT'.
        <fs_fcat>-reptext = 'Exclude'.
      WHEN 'H506_ADATANR'.
        <fs_fcat>-reptext = 'ADATANR'.
        <fs_fcat>-emphasize = 'C300'.
      WHEN 'H506_REPERYR'.
        <fs_fcat>-reptext = '재수강학년도'.
        <fs_fcat>-emphasize = 'C300'.
      WHEN 'H506_REPERID'.
        <fs_fcat>-reptext = '재수강학기'.
        <fs_fcat>-emphasize = 'C300'.
      WHEN 'H506_RESMID'.
        <fs_fcat>-reptext = '재수강SMID'.
        <fs_fcat>-emphasize = 'C300'.
      WHEN 'H506_REID'.
        <fs_fcat>-reptext = '재수강_수강신청ID'.
        <fs_fcat>-emphasize = 'C300'.
      WHEN 'H506_REPEATFG'.
        <fs_fcat>-reptext = 'Include'.
        <fs_fcat>-emphasize = 'C300'.

    ENDCASE.

    <fs_fcat>-scrtext_l = <fs_fcat>-scrtext_m = <fs_fcat>-scrtext_s = <fs_fcat>-reptext.
  ENDLOOP.

  go_grid->set_frontend_fieldcatalog( go_grid->fcat ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM grid_layout .

*  go_grid->layout->set_cwidth_opt( abap_true ).
*  go_grid->layout->set_zebra( abap_true ).
  go_grid->layout->set_sel_mode( 'D' ).
  go_grid->layout->set_no_toolbar( abap_false ).

  go_grid->layout->set_info_fname( 'ROW_COLOR' ).
*  go_grid->layout->set_ctab_fname( 'color' ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_sort
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM grid_sort .
*go_grid->sort = VALUE #( ( fieldname = 'OBJ_ID' up = abap_true )
*                           ( fieldname = 'DATUM'  up = abap_true )
*                           ( fieldname = 'UNAME'  up = abap_true )
*                           ( fieldname = 'UZEIT'  up = abap_true ) ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_color
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM grid_color.

*  DATA ls_color_yellow TYPE lvc_s_colo.
** yellow
*  ls_color_yellow-col = 3.
*  ls_color_yellow-int = 0.
*  ls_color_yellow-inv = 0.
*
*  go_grid->set_cell_color( iv_fieldname = 'H506_ADATANR'
*                           iv_color = ls_color_yellow
*                           iv_row = 1 ).




  go_grid->set_row_color(  iv_color = 'C300' "yellow
                           iv_row = 2 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_color
*&---------------------------------------------------------------------*
FORM build_color.
*
** <LVC_S_SCOL-COLOR-COL>
** 0 COL_BACKGROUND GUI-dependent
** 1 COL_HEADING    gray-blue
** 2 COL_NORMAL     light gray
** 3 COL_TOTAL      yellow
** 4 COL_KEY        blue-green
** 5 COL_POSITIVE   green
** 6 COL_NEGATIVE   red
** 7 COL_GROUP      orange
** <LVC_S_SCOL-COLOR-INT>
** 1 dark
** 0 light
** <LVC_S_SCOL-COLOR-INV>
** 1 colored neutral
** 0 black   colored
*  DATA: lt_color        TYPE lvc_t_scol,
*
*        ls_color_blue   TYPE lvc_s_scol,
*        ls_color_yellow TYPE lvc_s_scol,
*        ls_color_green  TYPE lvc_s_scol.
*
*  CLEAR: ls_color_blue,
*         ls_color_yellow,
*         ls_color_green.
** blue
*  ls_color_blue-color-col = 4.
*  ls_color_blue-color-int = 0.
*  ls_color_blue-color-inv = 0.
*
** yellow
*  ls_color_yellow-color-col = 3.
*  ls_color_yellow-color-int = 0.
*  ls_color_yellow-color-inv = 0.
*
** green
*  ls_color_green-color-col = 5.
*  ls_color_green-color-int = 0.
*  ls_color_green-color-inv = 0.
*
** internal table color 설정
*  LOOP AT gt_data.
*
*    CLEAR lt_color.
*
**   yellow
*    ls_color_yellow-fname = 'H506_ADATANR'.
*    INSERT ls_color_yellow INTO TABLE lt_color.
*
*    ls_color_yellow-fname = 'H506_REPERYR'.
*    INSERT ls_color_yellow INTO TABLE lt_color.
*
*    ls_color_yellow-fname = 'H506_REPERID'.
*    INSERT ls_color_yellow INTO TABLE lt_color.
*
*    ls_color_yellow-fname = 'H506_RESMID'.
*    INSERT ls_color_yellow INTO TABLE lt_color.
*
*    ls_color_yellow-fname = 'H506_REID'.
*    INSERT ls_color_yellow INTO TABLE lt_color.
*
*    ls_color_yellow-fname = 'H506_REPEATFG'.
*    INSERT ls_color_yellow INTO TABLE lt_color.
*
*    INSERT LINES OF lt_color INTO TABLE gt_data-color.
*    MODIFY gt_data.
*  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_gui_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM grid_gui_status .
  go_grid->gui_status->fully_dynamic = abap_true.
  go_grid->exclude_functions = go_grid->gui_status->edit_buttons( ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_01
    iv_text   = '새로고침'
    iv_icon   = icon_refresh ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_02
    iv_text   = 'Migration1(Underlying)'
    iv_icon   = icon_xxl ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_03
    iv_text   = 'Migration2(수강신청ID)'
    iv_icon   = icon_insert_multiple_lines ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_04
    iv_text   = 'Confirm'
    iv_icon   = icon_create ).
*
*  go_grid->gui_status->add_button(
*    iv_button = zcl_falv_dynamic_status=>b_05
*    iv_text   = '변경'
*    iv_icon   = icon_change ).
*
*  go_grid->gui_status->add_button(
*    iv_button = zcl_falv_dynamic_status=>b_06
*    iv_text   = '삭제'
*    iv_icon   = icon_delete ).

*  go_grid->gui_status->add_button(
*    iv_button = zcl_falv_dynamic_status=>b_07
*    iv_text   = '다운로드'
*    iv_icon   = icon_export ).

*  go_grid->gui_status->hide_button( zcl_falv_dynamic_status=>b_02 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_toolbar_button
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM grid_toolbar_button .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_f4_field
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM grid_f4_field .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ev_user_command
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&      --> ME
*&---------------------------------------------------------------------*
FORM ev_user_command  USING  p_ucomm
                             po_me TYPE REF TO lcl_alv_grid.

  IF po_me = go_grid.
    CASE p_ucomm.
      WHEN zcl_falv_dynamic_status=>b_01. "새로고침
*        PERFORM get_data_select.

      WHEN zcl_falv_dynamic_status=>b_02." Migration1(Underlying data)
        PERFORM migration1.

      WHEN zcl_falv_dynamic_status=>b_03." Migration1(수강신청 ID Update)
        PERFORM migration2.

      WHEN zcl_falv_dynamic_status=>b_04." 저장        .
        PERFORM confirm.

      WHEN zcl_falv_dynamic_status=>b_05." 변경
        PERFORM change_line.

      WHEN zcl_falv_dynamic_status=>b_06." 삭제
        PERFORM delete_line.

      WHEN zcl_falv_dynamic_status=>b_07."
        DATA(lv_xstr) = go_grid->export_to_excel( ).

        zcmcl000=>set_cache_url(
          EXPORTING
            iv_contents = lv_xstr                 " 파일 CONTENTS
            iv_doc_type = 'XLSX'           " SAP 아카이브링크: 문서클래스
            iv_filename = '임시파일.xlsx'                  " 파일명
            iv_open     = 'X'                " URL 창 열기 여부
        ).

      WHEN OTHERS.
    ENDCASE.
  ELSE.
    CASE p_ucomm.
      WHEN zcl_falv_dynamic_status=>b_01.
      WHEN zcl_falv_dynamic_status=>b_02.
        LEAVE TO SCREEN 0.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.

  po_me->soft_refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ev_hotspot_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_ROW_NO_ROW_ID
*&      --> E_COLUMN_ID_FIELDNAME
*&---------------------------------------------------------------------*
FORM ev_hotspot_click  USING p_row p_fieldname.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ev_top_of_page
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM ev_top_of_page  USING    po_dyndoc_id TYPE REF TO cl_dd_document.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form EV_ON_F4
*&---------------------------------------------------------------------*
FORM ev_on_f4  USING    p_fieldname  p_fieldvalue  p_row.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_top_of_page
*&---------------------------------------------------------------------*
FORM grid_top_of_page .

ENDFORM.

*&---------------------------------------------------------------------*
*& Form EV_data_changed
*&---------------------------------------------------------------------*
FORM ev_data_changed  USING po_data_changed TYPE REF TO cl_alv_changed_data_protocol
                            po_me TYPE REF TO lcl_alv_grid..

  DATA : ls_celltab   TYPE lvc_s_styl.
  DATA : lt_celltab   TYPE lvc_t_styl.
  DATA : ls_mod_cells TYPE lvc_s_modi.
  DATA : lv_index     TYPE c.

  FIELD-SYMBOLS : <fs_modi>  TYPE any.
  FIELD-SYMBOLS : <fs_value>  TYPE any.

*  go_grid->set_frontend_layout( go_grid->lvc_layout ).
*  go_grid->soft_refresh( ).

  IF po_me = go_grid2.
    LOOP AT po_data_changed->mt_mod_cells INTO ls_mod_cells.

      READ TABLE gt_stsm ASSIGNING FIELD-SYMBOL(<fs_stsm>) INDEX ls_mod_cells-row_id.
      IF sy-subrc = 0.
        "체인지 필드 변경
        UNASSIGN <fs_value>.
        ASSIGN COMPONENT 'CHANGE_FG' OF STRUCTURE <fs_stsm> TO <fs_value>.
        IF <fs_value> IS ASSIGNED.
          <fs_value> = 'X'.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  po_me->soft_refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form upload_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM upload_data .
*
**--------------------------------------------------------------------*
** # 29.08.2024 14:24:49 # 엑셀 업로드
**--------------------------------------------------------------------*
*  CLEAR : gt_log, gt_log[].
*
*  CALL METHOD zcmcl000=>excel_to_itab
*    EXPORTING
*      iv_begin_row = 2
*    IMPORTING
*      ev_error     = DATA(lv_error)
*      ev_msg       = DATA(lv_msg)
*    CHANGING
*      ct_data      = gt_form[].
*
*  IF lv_error IS NOT INITIAL.
*    MESSAGE s001 WITH lv_msg DISPLAY LIKE 'E'.
*    EXIT.
*  ENDIF.
*
**--------------------------------------------------------------------*
*  DATA lt_upload TYPE TABLE OF zcmta491_regist WITH HEADER LINE.
*  DATA ls_cmacbpst TYPE cmacbpst.
*  DATA ls_seobj    TYPE hrp1000.
*  DATA ls_olddata  TYPE zcmta491_regist.
*  DATA lv_tabix    TYPE sytabix.
*  DATA lv_sobid    TYPE sobid.
*  DATA lv_text(100).
*
*  LOOP AT gt_form ASSIGNING FIELD-SYMBOL(<fs_form>).
*    lv_tabix = sy-tabix.
*
*    CLEAR ls_cmacbpst.
*    SELECT SINGLE * INTO ls_cmacbpst
*           FROM cmacbpst
*           WHERE student12 = <fs_form>-stno.
*    IF sy-subrc <> 0.
*      gt_log-code1 = lv_tabix.
*      gt_log-code2 = <fs_form>-stno.
*      gt_log-logtx = '유효하지 않는 학번입니다.'.
*      APPEND gt_log.
*      CONTINUE.
*    ENDIF.
*
*    CLEAR ls_seobj.
*    SELECT SINGLE * INTO ls_seobj
*           FROM hrp1000
*           WHERE plvar = '01'
*           AND   otype = 'SE'
*           AND   begda <= gs_timelimits-ca_lendda
*           AND   endda >= gs_timelimits-ca_lendda
*           AND   langu = '3'
*           AND   short = <fs_form>-ssshort.
*    IF sy-subrc <> 0.
*      gt_log-code1 = lv_tabix.
*      gt_log-code2 = |{ <fs_form>-stno }-{ <fs_form>-ssshort }|.
*      gt_log-logtx = '유효하지 않는 분반번호입니다.'.
*      APPEND gt_log.
*      CONTINUE.
*    ENDIF.
*
*    lv_sobid = ls_cmacbpst-stobjid.
*    SELECT SINGLE * INTO @DATA(ls_v_piqmodbooked)
*           FROM v_piqmodbooked
*           WHERE sobid = @lv_sobid
*           AND   perid = @p_perid
*           AND   peryr = @p_peryr
*           AND   packnumber = @ls_seobj-objid.
*    IF sy-subrc <> 0.
*      gt_log-code1 = lv_tabix.
*      gt_log-code2 = |{ <fs_form>-stno }-{ <fs_form>-ssshort }|.
*      gt_log-logtx = '해당학기 유효하지 않는 학생의 분반번호입니다.'.
*      APPEND gt_log.
*      CONTINUE.
*    ENDIF.
*
*    CLEAR ls_olddata.
*    SELECT SINGLE * INTO ls_olddata
*           FROM zcmta491_regist
*           WHERE peryr = p_peryr
*           AND perid = p_perid
*           AND stno = <fs_form>-stno
*           AND ssshort = <fs_form>-ssshort.
*    IF sy-subrc = 0.
*      gt_log-code1 = lv_tabix.
*      gt_log-code2 = |{ <fs_form>-stno }-{ <fs_form>-ssshort }|.
*      gt_log-logtx = '이미 업로드된 내역이 존재합니다.'.
*      APPEND gt_log.
*      CONTINUE.
*    ENDIF.
*
*    lt_upload-peryr    = p_peryr.
*    lt_upload-perid    = p_perid.
*    lt_upload-stno     = <fs_form>-stno.
*    lt_upload-ssshort  = <fs_form>-ssshort.
*
*    zcmcl000=>set_time_stemp( CHANGING cs_data = lt_upload ).
*
*    APPEND lt_upload. CLEAR lt_upload.
*  ENDLOOP.
*
*
*  PERFORM popup_log_display.
*
*
*  IF lt_upload[] IS NOT INITIAL.
*
*    MODIFY zcmta491_regist  FROM TABLE lt_upload.
*    IF sy-subrc = 0.
*      DESCRIBE TABLE lt_upload.
*
*      lv_text = |{ sy-tfill }건 업로드 되었습니다.|.
*      MESSAGE s001 WITH lv_text.
*      PERFORM get_data_select.
*    ELSE.
*      MESSAGE e013.
*    ENDIF.
*
*  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form tabline_to_itab
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ALSMEX_TABLINE
*&---------------------------------------------------------------------*
FORM tabline_to_itab  TABLES   pt_tabline STRUCTURE alsmex_tabline.

  DATA ls_tabline TYPE alsmex_tabline.
  FIELD-SYMBOLS: <fs> .

  CLEAR gt_form[].
  LOOP AT pt_tabline INTO ls_tabline.

    ASSIGN COMPONENT ls_tabline-col OF STRUCTURE gt_form TO <fs>.
    CHECK <fs> IS ASSIGNED.

    <fs> = ls_tabline-value.

    AT END OF row.
      APPEND gt_form. CLEAR gt_form.
    ENDAT.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_display_falv_s200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_display_falv_s200 .

  IF go_grid2 IS INITIAL.

    go_grid2 ?= zcl_falv=>create( EXPORTING i_subclass = cl_abap_classdescr=>describe_by_name( p_name = 'LCL_ALV_GRID' )
                                            i_parent   = NEW cl_gui_custom_container( container_name = 'CONT2' )
                                            i_handle   = CONV slis_handl( '2' )
                                  CHANGING  ct_table   = gt_stsm[] ).

*--------------------------------------------------------------------*

*  go_grid2->layout->set_cwidth_opt( abap_true ).
    go_grid2->layout->set_zebra( abap_true ).
    go_grid2->layout->set_sel_mode( 'D' ).
    go_grid2->layout->set_no_toolbar( abap_false ).

    go_grid2->exclude_functions = go_grid2->gui_status->edit_buttons( ).

*--------------------------------------------------------------------*
    LOOP AT go_grid2->fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).

      CASE <fs_fcat>-fieldname.
        WHEN 'STID' OR 'PERID' OR 'CHANGE_FG'.
          <fs_fcat>-no_out = 'X'.

        WHEN 'STNO'.
          <fs_fcat>-reptext = '학번'.
          <fs_fcat>-no_out = 'X'.
        WHEN 'STNM'.
          <fs_fcat>-reptext = '성명' .
          <fs_fcat>-outputlen = 20.
          <fs_fcat>-no_out = 'X'.

        WHEN 'SSSHORT'.
          <fs_fcat>-reptext = '분반코드'.

        WHEN 'SSOBJID'.
          <fs_fcat>-reptext = '분반ID' .

        WHEN 'SSOSTEXT'.
          <fs_fcat>-reptext = '분반명' .
          <fs_fcat>-outputlen = 20.

        WHEN 'CHECK'.
          <fs_fcat>-reptext = '선택' .
          <fs_fcat>-edit = 'X'.
          <fs_fcat>-checkbox = 'X'.
          <fs_fcat>-outputlen = 5.
          <fs_fcat>-just      = 'C'.


        WHEN 'ERNAM'.
          <fs_fcat>-no_out = 'X'.
        WHEN 'ERDAT'.
          <fs_fcat>-no_out = 'X'.
        WHEN 'ERTIM'.
          <fs_fcat>-no_out = 'X'.

      ENDCASE.

      <fs_fcat>-scrtext_l = <fs_fcat>-scrtext_m = <fs_fcat>-scrtext_s = <fs_fcat>-reptext.
    ENDLOOP.

    go_grid2->set_frontend_fieldcatalog( go_grid2->fcat ).

    go_grid2->set_editable( abap_true ).

    go_grid2->display( ).

  ELSE.
    go_grid2->soft_refresh( ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_popup_s200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_popup_s200 .
  IF gv_mode = 'C'.
    CLEAR gs_s200.
    CLEAR : gt_stsm[].
  ENDIF.
  CALL SCREEN 200 STARTING AT 10 10 .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ST_SM_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_st_sm_info .
*
*  CLEAR : gt_stsm, gt_stsm[].
*
*  DATA ls_cmacbpst TYPE cmacbpst.
*
*  DATA lt_data_old TYPE TABLE OF zcmta491_regist WITH HEADER LINE.
*  DATA lv_sobid TYPE sobid.
*
*  SELECT SINGLE * INTO ls_cmacbpst
*         FROM cmacbpst
*         WHERE student12 = gs_s200-stno.
*  IF sy-subrc = 0.
*    lv_sobid = ls_cmacbpst-stobjid.
*
*    SELECT SINGLE * INTO @DATA(ls_stobj)
*           FROM hrp1000
*           WHERE plvar = '01'
*           AND   otype = 'ST'
*           AND   objid = @ls_cmacbpst-stobjid
*           AND   begda <= @gs_timelimits-ca_lendda
*           AND   endda >= @gs_timelimits-ca_lendda
*           AND   langu = @sy-langu.
*    IF sy-subrc = 0.
*      gs_s200-stid = ls_stobj-objid.
*      gs_s200-stnm = ls_stobj-stext.
*    ENDIF.
*
*    SELECT * INTO TABLE @DATA(lt_booked)
*             FROM v_piqmodbooked
*             WHERE sobid = @lv_sobid
*             AND   perid = @p_perid
*             AND   peryr = @p_peryr.
*
*    SELECT * INTO TABLE lt_data_old
*             FROM zcmta491_regist
*             WHERE peryr = p_peryr
*             AND   perid = p_perid
*             AND   stno  = gs_s200-stno.
*
*    SORT lt_data_old BY ssshort.
*
*    LOOP AT lt_booked ASSIGNING FIELD-SYMBOL(<fs_booked>).
*      gt_stsm-stid = ls_cmacbpst-stobjid.
*      gt_stsm-stno = ls_cmacbpst-student12.
*      gt_stsm-peryr = <fs_booked>-peryr.
*      gt_stsm-perid = <fs_booked>-perid.
*      gt_stsm-perit = gs_perit-perit.
*
*      gt_stsm-ssobjid = <fs_booked>-packnumber.
*      SELECT SINGLE * INTO @DATA(ls_seobj)
*             FROM hrp1000
*             WHERE plvar = '01'
*             AND   otype = 'SE'
*             AND   objid = @gt_stsm-ssobjid
*             AND   begda <= @gs_timelimits-ca_lendda
*             AND   endda >= @gs_timelimits-ca_lendda
*             AND   langu = @sy-langu.
*      IF sy-subrc = 0.
*        gt_stsm-ssshort = ls_seobj-short.
*        gt_stsm-ssostext = ls_seobj-stext.
*      ENDIF.
*
*      READ TABLE lt_data_old WITH KEY ssshort = gt_stsm-ssshort BINARY SEARCH.
*      IF sy-subrc = 0.
*        gt_stsm-ernam = lt_data_old-ernam.
*        gt_stsm-erdat = lt_data_old-erdat.
*        gt_stsm-ertim = lt_data_old-ertim.
*        gt_stsm-check = 'X'." 이미 저장된 내역...
*      ENDIF.
*      APPEND gt_stsm. CLEAR gt_stsm.
*    ENDLOOP.
*
*    SORT gt_stsm BY ssshort.
*
*  ELSE.
*    CLEAR gs_s200.
*    MESSAGE i001 WITH '정확하지 않는 학번입니다.' DISPLAY LIKE 'E'.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm
*&---------------------------------------------------------------------*
FORM confirm.

  DATA: lv_text1(100),
        lv_text2(100).
  lv_text1 = '이관 하시겠습니까?'.
  PERFORM data_popup_to_confirm_yn(zcms0)  USING gv_answer
                                                 '확인'
                                                 lv_text1
                                                 lv_text2.
  CHECK gv_answer = 'J'.

  CLEAR gt_row.
  CALL METHOD go_grid->get_selected_rows
    IMPORTING
      et_index_rows = gt_row.

  CLEAR gv_selected_num.
  DESCRIBE TABLE gt_row LINES gv_selected_num.
  IF gv_selected_num IS INITIAL.
    MESSAGE '처리할 라인을 선택하세요.' TYPE 'E'.
  ENDIF.

  CHECK gv_selected_num > 0.
  CLEAR gv_update_record.
  LOOP AT gt_row INTO gs_row.
    READ TABLE gt_data INDEX gs_row-index.
    CHECK sy-subrc IS INITIAL.
    UPDATE hrpad506
        SET reperyr  = gt_data-h506_reperyr
            reperid  = gt_data-h506_reperid
            resmid   = gt_data-h506_resmid
            reid     = gt_data-h506_reid
            repeatfg = gt_data-h506_repeatfg
      WHERE adatanr = gt_data-h506_adatanr.
    CHECK sy-subrc IS INITIAL.

*   mark
    gt_data-save = 'X'.
    MODIFY gt_data INDEX gs_row-index.

    ADD 1 TO gv_update_record.
  ENDLOOP.

  CLEAR gv_msg.
  CONCATENATE `이관 되었습니다. (선택: ` gv_selected_num `건 / `
                                 `처리: ` gv_update_record `건)`
         INTO gv_msg.
  MESSAGE gv_msg TYPE 'S'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_line
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM change_line .

*  DATA: lv_lines LIKE sy-tabix.
*  DATA: lt_row_no TYPE lvc_t_roid,
*        ls_row_no TYPE lvc_s_roid.
*
*  DATA lv_text1(100).
*  DATA lv_text2(100).
*  DATA lv_messtxt(50).
*
*  DATA lv_succ TYPE i.
*
*  FIELD-SYMBOLS <fs_data> LIKE LINE OF gt_data.
*
*  CLEAR gv_mode.
*
** 선택한 데이터에 대해 처리한다.
*  CLEAR: lt_row_no, lt_row_no[].
*  CALL METHOD go_grid->get_selected_rows
*    IMPORTING
*      et_row_no = lt_row_no.
*
*  DESCRIBE TABLE lt_row_no LINES lv_lines.
*
*  IF lv_lines = 1.
*    LOOP AT lt_row_no INTO ls_row_no .
*      READ TABLE gt_data INDEX ls_row_no-row_id ASSIGNING <fs_data>.
*      IF sy-subrc = 0 .
*        gs_s200-stno = <fs_data>-stno.
*        PERFORM get_st_sm_info.
*        gv_mode = 'M'.
*        PERFORM call_popup_s200.
*      ENDIF.
*    ENDLOOP.
*  ELSE.
*    MESSAGE s108(zcm01) DISPLAY LIKE 'E'."하나의 ROW만 선택하세요.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_line
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_line .
*  DATA: lv_lines LIKE sy-tabix.
*  DATA: lt_row_no TYPE lvc_t_roid,
*        ls_row_no TYPE lvc_s_roid.
*
*  DATA lv_text1(100).
*  DATA lv_text2(100).
*  DATA lv_messtxt(50).
*
*  DATA lv_succ TYPE i.
*
*  FIELD-SYMBOLS <fs_data> LIKE LINE OF gt_data.
*
*  CLEAR gv_mode.
*
** 선택한 데이터에 대해 처리한다.
*  CLEAR: lt_row_no, lt_row_no[].
*  CALL METHOD go_grid->get_selected_rows
*    IMPORTING
*      et_row_no = lt_row_no.
*
*  DESCRIBE TABLE lt_row_no LINES lv_lines.
*
*  IF lv_lines >= 1.
*
*    lv_text1 = '삭제하시겠습니까?'.
*    PERFORM data_popup_to_confirm_yn(zcms0)  USING gv_answer
*                                                   '확인'
*                                                   lv_text1
*                                                   lv_text2.
*    CHECK gv_answer = 'J'.
*
*    LOOP AT lt_row_no INTO ls_row_no .
*      READ TABLE gt_data INDEX ls_row_no-row_id ASSIGNING <fs_data>.
*      IF sy-subrc = 0 .
*        DELETE FROM zcmta491_regist WHERE peryr = p_peryr
*                                    AND   perid = p_perid
*                                    AND   stno  = <fs_data>-stno
*                                    AND   ssshort  = <fs_data>-ssshort.
*      ENDIF.
*    ENDLOOP.
*
*    PERFORM get_data_select.
*
*
*  ELSE.
*    MESSAGE s001(zcm01) WITH '라인을 선택하세요.' DISPLAY LIKE 'E'."
*  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_screen_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_screen_200 .
  LOOP AT SCREEN.
    IF gv_mode = 'M'.
      IF screen-group1 = 'ST'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_log_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM popup_log_display .

*  CHECK gt_log[] IS NOT INITIAL.
*
*  DATA(lr_log) = NEW cl_bal_logobj( ).
*
*  LOOP AT gt_log  .
*    lr_log->add_errortext( |{ gt_log-code1 }-{ gt_log-code2 }-{ gt_log-logtx }| ).
*  ENDLOOP.
*
*  lr_log->display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ST_BASE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_st_base_data .
**--------------------------------------------------------------------*
*
*  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_data
*           FROM zcmta491_regist
*           WHERE peryr = p_peryr
*           AND   perid = p_perid
*           AND   stno  IN p_stno.
*
**--------------------------------------------------------------------*
*  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
*
*    SELECT SINGLE * INTO @DATA(ls_stobj)
*           FROM hrp1000
*           WHERE plvar = '01'
*           AND   otype = 'ST'
*           AND   begda <= @gs_timelimits-ca_lendda
*           AND   endda >= @gs_timelimits-ca_lendda
*           AND   langu = @sy-langu
*           AND   short = @<fs_data>-stno.
*    IF sy-subrc = 0.
*      <fs_data>-stid  = ls_stobj-objid.
*      <fs_data>-stnm  = ls_stobj-stext.
*    ENDIF.
*
*    SELECT SINGLE * INTO @DATA(ls_seobj)
*           FROM hrp1000
*           WHERE plvar = '01'
*           AND   otype = 'SE'
*           AND   begda <= @gs_timelimits-ca_lendda
*           AND   endda >= @gs_timelimits-ca_lendda
*           AND   langu = @sy-langu
*           AND   short = @<fs_data>-ssshort.
*    IF sy-subrc = 0.
*      <fs_data>-ssobjid  = ls_seobj-objid.
*      <fs_data>-ssostext = ls_seobj-stext.
*    ENDIF.
*
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ST_INFO_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_st_info_data .
*
*  DATA lt_stobj TYPE TABLE OF hrobject WITH HEADER LINE.
*
*  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
*    lt_stobj-plvar = '01'.
*    lt_stobj-otype = 'ST'.
*    lt_stobj-objid = <fs_data>-stid.
*    APPEND lt_stobj. CLEAR lt_stobj.
*  ENDLOOP.
*
*  SORT lt_stobj.
*  DELETE ADJACENT DUPLICATES FROM lt_stobj COMPARING ALL FIELDS.
*
**--------------------------------------------------------------------*
** # 19.08.2024 15:42:36 # 소속정보
**--------------------------------------------------------------------*
*
*  CALL METHOD zcmcl000=>get_st_major
*    EXPORTING
*      it_stobj   = lt_stobj[]
*      iv_keydate = gs_timelimits-ca_lendda
*    IMPORTING
*      et_stmajor = DATA(et_stmajor).
*
**--------------------------------------------------------------------*
** # 19.08.2024 15:42:43 # 진급정보
**--------------------------------------------------------------------*
*  CALL METHOD zcmcl000=>get_st_progression
*    EXPORTING
*      it_stobj   = lt_stobj[]
*      iv_keydate = gs_timelimits-ca_lendda
*    IMPORTING
*      et_stprog  = DATA(et_stprog).
*
**--------------------------------------------------------------------*
** # 20.08.2024 16:53:42 # 학적상태
**--------------------------------------------------------------------*
*  CALL METHOD zcmcl000=>get_st_status
*    EXPORTING
*      it_stobj    = lt_stobj[]                 " ST 오브젝트 테이블
*      iv_keydate  = gs_timelimits-ca_lendda         " 일자
*    IMPORTING
*      et_ststatus = DATA(et_ststatus).                 " 학생 학적상태 HRP9530
*
**--------------------------------------------------------------------*
** # 19.08.2024 16:00:25 # 학업정보
**--------------------------------------------------------------------*
*  CALL METHOD zcmcl000=>get_aw_acwork
*    EXPORTING
*      it_stobj  = lt_stobj[]
*      i_peryr   = p_peryr
*      i_perid   = p_perid
*      i_compl   = ''
*    IMPORTING
*      et_acwork = DATA(et_acwork).
*
*  SORT et_acwork BY objid peryr perid packnumber.
*
**--------------------------------------------------------------------*
** # 19.08.2024 15:47:06 # ST INFO
**--------------------------------------------------------------------*
*  LOOP AT gt_data ASSIGNING <fs_data>.
*    READ TABLE  et_stmajor WITH KEY st_objid = <fs_data>-stid BINARY SEARCH ASSIGNING FIELD-SYMBOL(<fs_stmajor>).
*    IF sy-subrc = 0.
*      <fs_data>-o_objid   = <fs_stmajor>-o_objid.
*      <fs_data>-o_short   = <fs_stmajor>-o_short.
*      <fs_data>-sc_objid1 = <fs_stmajor>-sc_objid1.
*      <fs_data>-sc_stext1 = <fs_stmajor>-sc_stext1.
*      <fs_data>-sc_objid2 = <fs_stmajor>-sc_objid2.
*      <fs_data>-sc_stext2 = <fs_stmajor>-sc_stext2.
*    ENDIF.
*    READ TABLE  et_stprog  WITH KEY objid = <fs_data>-stid BINARY SEARCH ASSIGNING FIELD-SYMBOL(<fs_stprog>).
*    IF sy-subrc = 0.
*      <fs_data>-iprcl = <fs_stprog>-iprcl.
*      <fs_data>-iacst = <fs_stprog>-iacst.
*    ENDIF.
*    READ TABLE  et_ststatus  WITH KEY objid = <fs_data>-stid BINARY SEARCH ASSIGNING FIELD-SYMBOL(<fs_ststatus>).
*    IF sy-subrc = 0.
*      <fs_data>-sts_cd   = <fs_ststatus>-sts_cd.
*      <fs_data>-sts_cd_t = <fs_ststatus>-sts_cd_t.
*    ENDIF.
*    READ TABLE  et_acwork  WITH KEY objid = <fs_data>-stid
*                                    peryr = p_peryr
*                                    perid = p_perid
*                                    packnumber = <fs_data>-ssobjid
*                                    BINARY SEARCH ASSIGNING FIELD-SYMBOL(<fs_acwork>).
*    IF sy-subrc = 0.
*      <fs_data>-category  = <fs_acwork>-category.
*      <fs_data>-categoryt = <fs_acwork>-categoryt.
*      <fs_data>-gradesym  = <fs_acwork>-gradesym.
*      <fs_data>-cpattemp  = <fs_acwork>-cpattemp.
*      <fs_data>-cpgained  = <fs_acwork>-cpgained.
*    ENDIF.
*
*    <fs_data>-cpunit = 'CRH'.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ST_COMM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_st_comm_data .
**--------------------------------------------------------------------*
*  CLEAR gs_perit.
*  CLEAR gs_timelimits.
*  CLEAR gt_data.
*  CLEAR gt_data[].
**--------------------------------------------------------------------*
*  zcmcl000=>get_timelimits(
*    EXPORTING
*      iv_o          = '30000002'                " 소속 오브젝트 ID
*      iv_timelimit  = '0100'           " 시한
*      iv_peryr      = p_peryr                 " 학년도
*      iv_perid      = p_perid                 " 학기
*    IMPORTING
*      et_timelimits = DATA(et_timelimits)
*  ).
*  READ TABLE et_timelimits INDEX 1 INTO gs_timelimits.
**--------------------------------------------------------------------*
*
*  SELECT SINGLE * INTO gs_perit
*         FROM t7piqperiodt
*         WHERE spras = sy-langu
*         AND   perid = p_perid.
**--------------------------------------------------------------------*


ENDFORM.
