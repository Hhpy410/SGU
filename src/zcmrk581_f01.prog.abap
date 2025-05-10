*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM top_of_page.

ENDFORM.                    "top_of_page
*&---------------------------------------------------------------------*
*&      Form  pf_status
*&---------------------------------------------------------------------
FORM pf_status_set USING  ft_extab TYPE slis_t_extab.

* 감추려는 버튼은 lc_extab에 append함
  SET PF-STATUS '0100' EXCLUDING ft_extab.

ENDFORM.                    "PF_STATUS_SET
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
  gs_layout-cwidth_opt = 'A'. "'A'.
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
*  PERFORM DATA_GRID_SCREEN_CONTROL .

  DATA: ls_variant TYPE disvariant.
  CLEAR: ls_variant.
  ls_variant-report = sy-repid.

  CALL METHOD g_grid->set_table_for_first_display
    EXPORTING
      is_layout       = gs_layout
*     IT_TOOLBAR_EXCLUDING = GT_FCODE
      i_save          = 'X' "'A'
      i_default       = 'X'
      is_variant      = ls_variant
    CHANGING
      it_sort         = gt_sort[]
      it_fieldcatalog = gt_grid_fcat[]
      it_outtab       = gt_data[].

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
         lv_tabname  TYPE slis_tabname,
         lv_str      TYPE string,
         lv_chk(1).

  FIELD-SYMBOLS <fs> TYPE any.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'GT_DATA'
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

  LOOP AT pt_fieldcat INTO ls_fcat.
    CLEAR: ls_fcat-key.
    ls_fcat-no_zero = 'X'.
    CASE ls_fcat-fieldname.
*     WHEN 'SEQ'.         ls_fcat-col_pos = 01. ls_fcat-coltext = '순번'.
      WHEN 'UNAME'.       ls_fcat-col_pos = 02. ls_fcat-coltext = '학번'.
      WHEN 'DATUM'.       ls_fcat-col_pos = 03. ls_fcat-coltext = '접속일자'.
      WHEN 'UZEIT'.       ls_fcat-col_pos = 04. ls_fcat-coltext = '접속시간'.
      WHEN 'LOGTP'.       ls_fcat-col_pos = 05. ls_fcat-coltext = '진행단계'.
      WHEN 'LOGNO'.       ls_fcat-col_pos = 06. ls_fcat-coltext = '연번'.
      WHEN 'SHOST'.       ls_fcat-col_pos = 07. ls_fcat-coltext = 'HOST'.
      WHEN 'IPADDR'.      ls_fcat-col_pos = 08. ls_fcat-coltext = 'IP주소'.
      WHEN 'NATIO'.       ls_fcat-col_pos = 09. ls_fcat-coltext = '접속국가'.
      WHEN 'SAINT'.       ls_fcat-col_pos = 10. ls_fcat-coltext = 'EP세션'.
      WHEN 'OS'.          ls_fcat-col_pos = 11. ls_fcat-coltext = 'OS'.
      WHEN 'BROWSER'.     ls_fcat-col_pos = 12. ls_fcat-coltext = 'Browser'.
*     WHEN 'TYPE'.        ls_fcat-col_pos = 13. ls_fcat-coltext = '타입'.
      WHEN 'MESSAGE'.     ls_fcat-col_pos = 14. ls_fcat-coltext = '메시지'.
      WHEN OTHERS.        ls_fcat-no_out  = 'X'.
    ENDCASE.

    IF ls_fcat-fieldname = 'SAINT'.
*     ls_fcat-checkbox = 'X'.
      ls_fcat-just = 'C'.
    ENDIF.

    MODIFY pt_fieldcat FROM ls_fcat.
  ENDLOOP.

* 값 없는 필드는 자동으로 감추기...
*  LOOP AT pt_fieldcat INTO ls_fcat.
*    CLEAR: lv_str, lv_chk.
*    CONCATENATE 'gt_data-' ls_fcat-fieldname INTO lv_str.
*    LOOP AT gt_data.
*      ASSIGN (lv_str) TO <fs>.
*      IF <fs> IS NOT INITIAL.
*        lv_chk = 'X'.
*        EXIT.
*      ENDIF.
*    ENDLOOP.
*    IF lv_chk IS INITIAL.
*      ls_fcat-no_out = 'X'.
*      MODIFY pt_fieldcat FROM ls_fcat.
*    ENDIF.
*  ENDLOOP.

ENDFORM.                    " MAKE_GRID_FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  BUILD_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_sort .

  CLEAR: gt_sort[], gs_sort.
  gs_sort-up = 'X'.
  gs_sort-fieldname = 'SEQ'.    APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'UNAME'.  APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'DATUM'.  APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'UZEIT'.  APPEND gs_sort TO gt_sort.
* gs_sort-fieldname = 'LOGTP'.  APPEND gs_sort TO gt_sort.

ENDFORM.                    " BUILD_SORT
*&---------------------------------------------------------------------*
*&      Form  DATA_GRID_SCREEN_CONTROL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_grid_screen_control .

  DATA: lt_celltab TYPE lvc_t_styl,
        lv_index   TYPE i.

  LOOP AT gt_data.
    lv_index = sy-tabix.
    CLEAR: lt_celltab[], lt_celltab.
    CLEAR: gt_data-celltab[].
    PERFORM fill_celltab_grid CHANGING lt_celltab.
    INSERT LINES OF lt_celltab INTO TABLE gt_data-celltab.
    MODIFY gt_data INDEX lv_index.
  ENDLOOP.

ENDFORM.                    " DATA_GRID_SCREEN_CONTROL
*&---------------------------------------------------------------------*
*&      Form  REFRESH_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM refresh_grid .
  CALL METHOD g_grid->set_filter_criteria
    EXPORTING
      it_filter = gt_filt.

  CLEAR: gs_scroll.
  gs_scroll-row = 'X'.
  gs_scroll-col = 'X'.
  CALL METHOD g_grid->refresh_table_display
    EXPORTING
      is_stable = gs_scroll.
ENDFORM.                    " REFRESH_GRID
*&---------------------------------------------------------------------*
*&      Form  FILL_CELLTAB_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_CELLTAB  text
*----------------------------------------------------------------------*
FORM fill_celltab_grid  CHANGING pt_celltab TYPE lvc_t_styl.
  DATA: ls_celltab TYPE lvc_s_styl .

  DATA : l_fieldcat TYPE lvc_s_fcat.

  LOOP AT gt_grid_fcat INTO l_fieldcat.
    ls_celltab-fieldname = l_fieldcat-fieldname.
    CASE ls_celltab-fieldname.
      WHEN 'VERNR' OR 'TEXT' OR 'SPROG' OR 'EPROG'.
        ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled .
        INSERT ls_celltab INTO TABLE pt_celltab.
      WHEN OTHERS.
        ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
        INSERT ls_celltab INTO TABLE pt_celltab.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " FILL_CELLTAB_GRID
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
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_proc.

* 현재학년도 학기
  PERFORM set_current_period.

  CONCATENATE icon_column_left  '' INTO sscrfields-functxt_01.
  CONCATENATE icon_column_right '' INTO sscrfields-functxt_02.

*  t_001 = icon_information && `로그인(18.08.14~), 메인화면(18.08.14~), 오류메시지(18.08.10~)`.

  IF sy-sysid = 'UPS'.
    p_peryr = '2016'.
    p_perid = '011'.
  ENDIF.

  CLEAR: p_datum[], p_datum.
  p_datum-sign   = 'I'.
  p_datum-option = 'BT'.
  p_datum-low    = sy-datum.
  p_datum-high   = sy-datum.
  APPEND p_datum.

  CLEAR: p_uzeit[], p_uzeit.
  p_uzeit-sign   = 'I'.
  p_uzeit-option = 'BT'.
  p_uzeit-low    = '000000'.
  p_uzeit-high   = '240000'.
*(1차학사력 기준으로...
  SELECT SINGLE uzeit INTO p_uzeit-low
    FROM zcmt2018_time WHERE datum = sy-datum.
*)
  APPEND p_uzeit.

* HANA test
  IF sy-sysid = 'DEV' OR sy-sysid = 'QAS'.
    con_name = |{ con_name }_HANA|.
  ENDIF.

ENDFORM.                    " INIT_PROC

*&---------------------------------------------------------------------*
*&      Form  modify_screen
*&---------------------------------------------------------------------*
*       화면조정
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_screen.

  LOOP AT SCREEN.
    IF screen-name = '%F%_S017_1000' OR
       screen-name = 'P_XE617'.
      IF p_step2 = 'X'.
        screen-active = 1.
        MODIFY SCREEN.
      ELSE.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " modify_screen
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .

  PERFORM get_rdata.    "원시데이터
  PERFORM set_merge.    "데이터머지
  PERFORM set_gdata.    "컬러/IP
  PERFORM set_seqno.    "순번/통계
  PERFORM set_filter.   "점검대상

  SORT gt_data BY seq uname datum uzeit logtp.
  DESCRIBE TABLE gt_data LINES gv_total.
  IF gv_total = 0.
    MESSAGE '조회된 데이터가 없습니다' TYPE 'S'.
    STOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID_INDEX  text
*      -->P_E_COLUMN_ID_FIELDNAME  text
*----------------------------------------------------------------------*
FORM display_hotspot_click  USING  p_row    LIKE lvc_s_row-index
                                   p_column LIKE lvc_s_col-fieldname.

  DATA: lt_seltab TYPE STANDARD TABLE OF rsparams WITH HEADER LINE.
  DATA: seltab LIKE LINE OF lt_seltab.

  READ TABLE gt_data INDEX p_row.
*  CASE p_column .
*    WHEN 'RECEIVE_CELLNO'.
*      PERFORM get_users USING gt_data-receive_cellno.
*    WHEN 'SENDER_CELLNO'.
*      PERFORM get_users USING gt_data-sender_cellno.
*  ENDCASE .

ENDFORM.                    " DISPLAY_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*&      Form  ASSIGN_GRID_EVENT_HANDLERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM assign_grid_event_handlers .
* GRID Event receiver object 선언.
  CREATE OBJECT g_event_receiver_grid.
* Hotspot Click
  SET HANDLER g_event_receiver_grid->handle_hotspot_click
                                     FOR g_grid .
ENDFORM.                    " ASSIGN_GRID_EVENT_HANDLERS
*&---------------------------------------------------------------------*
*&      Form  REGISTER_GRID_EVENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM register_grid_event .

* Enter event
  CALL METHOD g_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.
* Modify event
  CALL METHOD g_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.                    " REGISTER_GRID_EVENT
*&---------------------------------------------------------------------*
*&      Form  GET_STATS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_stats .

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        ls_fcat     TYPE slis_fieldcat_alv,
        lv_selec    TYPE slis_selfield.

  CHECK gt_data[] IS NOT INITIAL.

  CLEAR: gt_stat[], gt_stat.
  LOOP AT gt_data.
    MOVE-CORRESPONDING gt_data TO gt_stat.
    gt_stat-count = 1.
    COLLECT gt_stat.
    CLEAR   gt_stat.
  ENDLOOP.

  CHECK gt_stat[] IS NOT INITIAL.
  SORT gt_stat BY logtp count DESCENDING.

  CLEAR: lt_fieldcat[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'GT_STAT'
      i_client_never_display = 'X'
      i_inclname             = sy-repid
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  LOOP AT lt_fieldcat INTO ls_fcat.
    CLEAR: ls_fcat-key.
    CASE ls_fcat-fieldname.
      WHEN 'LOGTP'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '구분'.
        ls_fcat-outputlen = 20.
        ls_fcat-key = 'X'.
      WHEN 'COUNT'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '갯수'.
        ls_fcat-outputlen = 8.
        ls_fcat-do_sum = 'X'.
      WHEN OTHERS.
        ls_fcat-no_out = 'X'.
    ENDCASE.
    MODIFY lt_fieldcat FROM ls_fcat.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title       = '진행단계 유형'
      i_tabname     = 'GT_STAT'
      it_fieldcat   = lt_fieldcat
    IMPORTING
      es_selfield   = lv_selec
    TABLES
      t_outtab      = gt_stat
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.

* 필터설정(단수)
  CLEAR: gt_filt[], gs_filt.
  IF lv_selec IS NOT INITIAL.
    gs_filt-fieldname = lv_selec-fieldname.
    gs_filt-sign      = 'I'.
    gs_filt-option    = 'EQ'.
    gs_filt-low       = lv_selec-value.
    APPEND gs_filt TO gt_filt.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DEVIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_devis .

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        ls_fcat     TYPE slis_fieldcat_alv,
        lv_selec    TYPE slis_selfield.

  CHECK gt_data[] IS NOT INITIAL.

  CLEAR: gt_devi[], gt_devi.
  LOOP AT gt_data WHERE logtp = gv_bsp_login.
    MOVE-CORRESPONDING gt_data TO gt_devi.
    gt_devi-count = 1.
    COLLECT gt_devi.
    CLEAR   gt_devi.
  ENDLOOP.

  CHECK gt_devi[] IS NOT INITIAL.
  SORT gt_devi BY count DESCENDING.

  CLEAR: lt_fieldcat[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'GT_DEVI'
      i_client_never_display = 'X'
      i_inclname             = sy-repid
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  LOOP AT lt_fieldcat INTO ls_fcat.
    CLEAR: ls_fcat-key.
    CASE ls_fcat-fieldname.
      WHEN 'OS'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = 'OS'.
        ls_fcat-outputlen = 10.
        ls_fcat-key = 'X'.
      WHEN 'BROWSER'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = 'Browser'.
        ls_fcat-outputlen = 16.
        ls_fcat-key = 'X'.
      WHEN 'COUNT'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '갯수'.
        ls_fcat-outputlen = 8.
        ls_fcat-do_sum = 'X'.
      WHEN OTHERS.
        ls_fcat-no_out = 'X'.
    ENDCASE.
    MODIFY lt_fieldcat FROM ls_fcat.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title       = '로그인 유형'
      i_tabname     = 'GT_DEVI'
      it_fieldcat   = lt_fieldcat
    IMPORTING
      es_selfield   = lv_selec
    TABLES
      t_outtab      = gt_devi
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.

* 필터설정(복수)
  CLEAR: gt_filt[], gs_filt.
  IF lv_selec IS NOT INITIAL.
    READ TABLE gt_devi INDEX lv_selec-tabindex.
    CHECK sy-subrc = 0.
    gs_filt-fieldname = 'OS'.
    gs_filt-sign      = 'I'.
    gs_filt-option    = 'EQ'.
    gs_filt-low       = gt_devi-os.
    APPEND gs_filt TO gt_filt.
    gs_filt-fieldname = 'BROWSER'.
    gs_filt-low       = gt_devi-browser.
    APPEND gs_filt TO gt_filt.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_NATIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_natis .

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        ls_fcat     TYPE slis_fieldcat_alv,
        lv_selec    TYPE slis_selfield.

  CHECK gt_data[] IS NOT INITIAL.

  CLEAR: gt_nati[], gt_nati.
  LOOP AT gt_data.
    MOVE-CORRESPONDING gt_data TO gt_nati.
    gt_nati-count = 1.
    COLLECT gt_nati.
    CLEAR   gt_nati.
  ENDLOOP.

  CHECK gt_nati[] IS NOT INITIAL.
  SORT gt_nati BY count DESCENDING.

  CLEAR: lt_fieldcat[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'GT_NATI'
      i_client_never_display = 'X'
      i_inclname             = sy-repid
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  LOOP AT lt_fieldcat INTO ls_fcat.
    CLEAR: ls_fcat-key.
    CASE ls_fcat-fieldname.
      WHEN 'NATIO'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '국가'.
        ls_fcat-outputlen = 8.
        ls_fcat-key = 'X'.
      WHEN 'COUNT'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '갯수'.
        ls_fcat-outputlen = 8.
        ls_fcat-do_sum = 'X'.
      WHEN OTHERS.
        ls_fcat-no_out = 'X'.
    ENDCASE.
    MODIFY lt_fieldcat FROM ls_fcat.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title       = '국가별 유형'
      i_tabname     = 'GT_NATI'
      it_fieldcat   = lt_fieldcat
    IMPORTING
      es_selfield   = lv_selec
    TABLES
      t_outtab      = gt_nati
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.

* 필터설정(단수)
  CLEAR: gt_filt[], gs_filt.
  IF lv_selec IS NOT INITIAL.
    gs_filt-fieldname = lv_selec-fieldname.
    gs_filt-sign      = 'I'.
    gs_filt-option    = 'EQ'.
    gs_filt-low       = lv_selec-value.
    APPEND gs_filt TO gt_filt.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_RDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_rdata .
  PERFORM get_stnum.
  PERFORM get_login.
  PERFORM get_cookie.
  PERFORM get_wdlog.
  PERFORM get_input.
  PERFORM get_error.
  PERFORM get_book.
  PERFORM get_eplog.
  PERFORM get_unlock.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_SEQNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_seqno .

  DATA: lv_uname TYPE uname,
        lv_seq   TYPE i.
  DATA: lv_logtp(40) TYPE c.

* 학생 접속순번
  SORT gt_data BY datum DESCENDING uzeit DESCENDING.
  LOOP AT gt_data.
    gt_data-seq = sy-tabix.
    MODIFY gt_data.
  ENDLOOP.
  SORT gt_data BY uname seq.
  LOOP AT gt_data.
    IF lv_uname <> gt_data-uname.
      lv_seq = gt_data-seq.
    ELSE.
      gt_data-seq = lv_seq.
    ENDIF.
    lv_uname = gt_data-uname.
    MODIFY gt_data.
  ENDLOOP.

* 학생별 로그연번
  CLEAR: lv_seq.
  SORT gt_data BY uname logtp datum uzeit.
  LOOP AT gt_data.
    IF gt_data-uname <> lv_uname OR
       gt_data-logtp <> lv_logtp.
      CLEAR: lv_seq.
    ENDIF.
    ADD 1 TO lv_seq.
    gt_data-logno = lv_seq.
    lv_uname = gt_data-uname.
    lv_logtp = gt_data-logtp.
    MODIFY gt_data.
  ENDLOOP.

* 학생별 접속통계
  CLEAR: gt_logno[], gt_logno.
  LOOP AT gt_data.
    gt_logno-uname = gt_data-uname.
    gt_logno-datum = gt_data-datum.
    CASE gt_data-logtp.
      WHEN gv_bsp_login.
        gt_logno-login = 1.
      WHEN gv_wdp_smain.
        gt_logno-smain = 1.
        CONDENSE gt_data-message.
        IF gt_data-message+1(8) = '5002:200'.
          gt_logno-nc200 = 1.
        ENDIF.
      WHEN gv_wdp_mbook.
        gt_logno-mbook = 1.
      WHEN gv_wdp_input.
        gt_logno-input = 1.
      WHEN gv_wdp_error.
        gt_logno-error = 1.
      WHEN gv_bsp_xpage.
        gt_logno-xpage = 1.
        IF gt_data-msgno = '617'.
          gt_logno-xe617 = 1.
        ENDIF.
    ENDCASE.
    COLLECT gt_logno.
    CLEAR   gt_logno.
  ENDLOOP.
  SORT gt_logno.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_MERGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_merge .

  CLEAR: gt_data[], gt_data.
*----------------------------------------------------------------------*
  LOOP AT gt_login.
    CLEAR gt_data.
    MOVE-CORRESPONDING gt_login TO gt_data.
    gt_data-logtp   = gv_bsp_login. "BSP Login
    gt_data-message = gt_login-user_agent.
    PERFORM get_device.
    APPEND gt_data.
  ENDLOOP.
*----------------------------------------------------------------------*
  LOOP AT gt_cookie.
    CLEAR gt_data.
    MOVE-CORRESPONDING gt_cookie TO gt_data.
    gt_data-logtp   = gv_wdp_smain. "WD Main
    gt_data-message = `　` && gt_cookie-cookie.
    IF gt_data-saint = 'X'.
      gt_data-saint = '△'.
    ENDIF.
    APPEND gt_data.
  ENDLOOP.
*----------------------------------------------------------------------*
  LOOP AT gt_wdlog.
    CLEAR gt_data.
    MOVE-CORRESPONDING gt_wdlog TO gt_data.
    gt_data-logtp = gv_bsp_xpage. "X Page
    MESSAGE ID gt_wdlog-msgid TYPE 'S'
        NUMBER gt_wdlog-msgno
          WITH gt_wdlog-mpa01
               gt_wdlog-mpa02
               gt_wdlog-mpa03
               gt_wdlog-mpa04
          INTO gt_data-message.
    gt_data-message = `　　` && gt_wdlog-msgno && `_` && gt_data-message.
    APPEND gt_data.
  ENDLOOP.
*----------------------------------------------------------------------*
  LOOP AT gt_input.
    CLEAR gt_data.
    SELECT SINGLE student12 INTO gt_data-uname FROM cmacbpst WHERE stobjid = gt_input-stobj.
    gt_data-logtp   = gv_wdp_input. ""WD 6-Input
    gt_data-datum   = gt_input-sdate.
    gt_data-uzeit   = gt_input-uzeit.
    gt_data-message = `　　　` &&
                      gt_input-str1 && ` ` &&
                      gt_input-str2 && ` ` &&
                      gt_input-str3 && ` ` &&
                      gt_input-str4 && ` ` &&
                      gt_input-str5 && ` ` &&
                      gt_input-str6.
    APPEND gt_data.
  ENDLOOP.
*----------------------------------------------------------------------*
  LOOP AT gt_error.
    CLEAR gt_data.
    SELECT SINGLE student12 INTO gt_data-uname FROM cmacbpst WHERE stobjid = gt_error-stobj.
    gt_data-logtp   = gv_wdp_error. "WD Error
    gt_data-datum   = gt_error-sdate.
    gt_data-uzeit   = gt_error-stime.
    gt_data-msgid   = gt_error-eid.
    gt_data-msgno   = gt_error-enumber.
    gt_data-message = `　　　` && gt_error-enumber && `_` && gt_error-emessage.
    APPEND gt_data.
  ENDLOOP.
*----------------------------------------------------------------------*
  LOOP AT gt_book.
    CLEAR gt_data.
    MOVE-CORRESPONDING gt_book TO gt_data.
    gt_data-logtp = gv_wdp_mbook. "WD Booking
    READ TABLE gt_p1000 WITH KEY objid = gt_book-packnumber BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data-message = `　　　` && gt_p1000-short && ` (` && gt_p1000-stext && `)`.
    ENDIF.
    IF gt_book-aname <> gt_data-uname.
      gt_data-message = gt_data-message && '(' && gt_book-aname && ')'.
    ENDIF.
    CASE gt_book-smstatus.
      WHEN '04'.   gt_data-message = gt_data-message && '(-)'.
      WHEN OTHERS. gt_data-message = gt_data-message && '(+)'.
    ENDCASE.
    APPEND gt_data.
  ENDLOOP.
*----------------------------------------------------------------------*
  SORT gt_data BY uname.
  LOOP AT gt_eplog WHERE uname IN p_short.
    CLEAR gt_data.
    MOVE-CORRESPONDING gt_eplog TO gt_data.
    gt_data-logtp = gv_epl_login. "EP Login
    gt_data-saint = '△'.
    APPEND gt_data.
  ENDLOOP.
*----------------------------------------------------------------------*
  LOOP AT gt_unlock WHERE user_id IN p_short.
    CLEAR gt_data.
    gt_data-uname   = gt_unlock-user_id.
    gt_data-datum   = gt_unlock-reg_date.
    gt_data-uzeit   = gt_unlock-reg_time.
    gt_data-logtp   = gv_req_unlck. "REQ Unlock
    gt_data-message = gt_unlock-prc_date && gt_unlock-prc_time.
    WRITE gt_data-message USING EDIT MASK `(____.__.__ __:__:__)` TO gt_data-message.
    gt_data-message = gt_unlock-flag && ` ` && gt_data-message.
    PERFORM get_device.
    APPEND gt_data.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_FILTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_filter .

  CHECK p_step1 <> 'X'. "전체내역 아니면...

* 대상필터
  SORT gt_logno BY uname datum.
  LOOP AT gt_data.
    READ TABLE gt_logno WITH KEY uname = gt_data-uname
                                 datum = gt_data-datum BINARY SEARCH.
    IF sy-subrc = 0.
      IF gt_logno-xe617 = 0.
        DELETE gt_data. CONTINUE. "공통...
      ENDIF.
      CASE 'X'.
        WHEN p_step2. "617오류
          IF gt_logno-xe617 < p_xe617.
            DELETE gt_data. CONTINUE.
          ENDIF.
        WHEN p_step3. "617오류 + 쿠키없음
          IF gt_logno-nc200 > 0.
            DELETE gt_data. CONTINUE.
          ENDIF.
        WHEN p_step4. "617오류 + 미수강
          IF gt_logno-mbook > 0.
            DELETE gt_data. CONTINUE.
          ENDIF.
      ENDCASE.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_PREV_PERIOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_prev_period .

  DATA: lv_datum TYPE datum.
  READ TABLE p_datum INDEX 1.
  lv_datum = p_datum-low.

  CLEAR: p_datum[], p_datum.
  p_datum-sign   = 'I'.
  p_datum-option = 'EQ'.
  p_datum-low    = lv_datum - 1.
  p_datum-high   = lv_datum - 1.
  APPEND p_datum.

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

  DATA: lv_datum TYPE datum.
  READ TABLE p_datum INDEX 1.
  lv_datum = p_datum-low.

  CLEAR: p_datum[], p_datum.
  p_datum-sign   = 'I'.
  p_datum-option = 'EQ'.
  p_datum-low    = lv_datum + 1.
  p_datum-high   = lv_datum + 1.
  APPEND p_datum.

ENDFORM.                    " SET_NEXT_PERIOD
*&---------------------------------------------------------------------*
*&      Form  GET_DEVICE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_device .

*- OS
  IF     gt_login-user_agent CP '*Win*'.
    gt_data-os = 'Windows'.
  ELSEIF gt_login-user_agent CP '*Android*'.
    gt_data-os = 'Android'.
  ELSEIF gt_login-user_agent CP '*iPhone*'.
    gt_data-os = 'iOS'.
  ELSEIF gt_login-user_agent CP '*Mac*'.
    gt_data-os = 'Macintosh'.
  ELSEIF gt_login-user_agent CP '*Linux*'.
    gt_data-os = 'Linux'.
  ENDIF.

*- Browser
  IF     gt_login-user_agent CP '*MSIE*' OR
         gt_login-user_agent CP '*Trident*'.
    gt_data-browser = 'IE'.
  ELSEIF gt_login-user_agent CP '*Edge*' OR
         gt_login-user_agent CP '*EdgA*'.
    gt_data-browser = 'Egde'.
  ELSEIF gt_login-user_agent CP '*Edg*'.
    gt_data-browser = 'Egde2'.
  ELSEIF gt_login-user_agent CP '*Whale*'.
    gt_data-browser = 'Whale'.
  ELSEIF gt_login-user_agent CP '*Firefox*'.
    gt_data-browser = 'Firefox'.
  ELSEIF gt_login-user_agent CP '*OPR*'.
    gt_data-browser = 'Opera'.
  ELSEIF gt_login-user_agent CP '*Samsung*'.
    gt_data-browser = 'Samsung'.
  ELSEIF gt_login-user_agent CP '*KAKAO*'.
    gt_data-browser = 'KakaoTalk'.
  ELSEIF gt_login-user_agent CP '*UCBrowser*'.
    gt_data-browser = 'UC'.
  ELSEIF gt_login-user_agent CP '*baidubox*'.
    gt_data-browser = 'BaiduBox'.
  ELSEIF gt_login-user_agent CP '*NAVER*'.
    gt_data-browser = 'Naver'.
  ELSEIF gt_login-user_agent CP '*Daum*'.
    gt_data-browser = 'Daum'.
  ELSEIF gt_login-user_agent CP '*Chrome*'. "크롬은 마지막-1
    gt_data-browser = 'Chrome'.
  ELSEIF gt_login-user_agent CP '*Safari*'. "사파리는 제일마지막...
    gt_data-browser = 'Safari'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_GDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_gdata .

  DATA: lt_color TYPE lvc_t_scol,
        ls_color TYPE lvc_s_scol.

  LOOP AT gt_data.
*- IP대역
*   PERFORM conv_ipaddr USING gt_data-ipaddr.
    CALL FUNCTION 'ZCM_GET_IPADDR_NATIO'
      EXPORTING
        i_ipaddr = gt_data-ipaddr
      IMPORTING
        e_natio  = gt_data-natio.

*- 컬러
    CLEAR: lt_color[], ls_color.
    CASE gt_data-logtp.
      WHEN gv_epl_login. ls_color-color-col = 2.
      WHEN gv_bsp_login. ls_color-color-col = 3.
      WHEN gv_req_unlck. ls_color-color-col = 4.
      WHEN gv_wdp_smain. ls_color-color-col = 5.
      WHEN gv_bsp_xpage. ls_color-color-col = 6.
    ENDCASE.
    ls_color-color-int = 0.
    ls_color-color-inv = 0.
    IF gt_data-msgno = '617'.
      ls_color-color-int = 1.
      ls_color-color-inv = 1.
    ENDIF.
    ls_color-fname = 'DATUM'.   INSERT ls_color INTO TABLE lt_color.
    ls_color-fname = 'UZEIT'.   INSERT ls_color INTO TABLE lt_color.
    ls_color-fname = 'LOGTP'.   INSERT ls_color INTO TABLE lt_color.
    ls_color-fname = 'LOGNO'.   INSERT ls_color INTO TABLE lt_color.
    ls_color-fname = 'SHOST'.   INSERT ls_color INTO TABLE lt_color.
    ls_color-fname = 'IPADDR'.  INSERT ls_color INTO TABLE lt_color.
    ls_color-fname = 'NATIO'.   INSERT ls_color INTO TABLE lt_color.
    ls_color-fname = 'SAINT'.   INSERT ls_color INTO TABLE lt_color.
    ls_color-fname = 'OS'.      INSERT ls_color INTO TABLE lt_color.
    ls_color-fname = 'BROWSER'. INSERT ls_color INTO TABLE lt_color.
    ls_color-fname = 'MESSAGE'. INSERT ls_color INTO TABLE lt_color.
    INSERT LINES OF lt_color INTO TABLE gt_data-color .
    MODIFY gt_data.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CONNECT_DB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM connect.
  TRY .
      EXEC SQL.
        CONNECT TO :con_name
      ENDEXEC.                                          "#EC CI_EXECSQL
    CATCH cx_sy_native_sql_error INTO exc_ref.
      error_text = exc_ref->get_text( ).
      MESSAGE error_text TYPE 'I' RAISING sql_error.
  ENDTRY.
ENDFORM.                    " CONNECT_DB
*&---------------------------------------------------------------------*
*&      Form  DISCONNECT_DB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM disconnect.
  TRY .
      EXEC SQL.
        CONNECT TO :con_name
      ENDEXEC.                                          "#EC CI_EXECSQL
    CATCH cx_sy_native_sql_error INTO exc_ref.
      error_text = exc_ref->get_text( ).
      MESSAGE error_text TYPE 'I' RAISING sql_error.
  ENDTRY.
ENDFORM.                    "disconnect
*&---------------------------------------------------------------------*
*&      Form  APPEND_DATA
*&---------------------------------------------------------------------*
FORM append_data  .
  APPEND gt_eplog. CLEAR  gt_eplog.
ENDFORM.                    " APPEND_DATA
*&---------------------------------------------------------------------*
*&      Form  APPEND_DATA2
*&---------------------------------------------------------------------*
FORM append_data2  .
  APPEND gt_unlock. CLEAR  gt_unlock.
ENDFORM.                    " APPEND_DATA2
*&---------------------------------------------------------------------*
*&      Form  set_current_period
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
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
    p_peryr = ls_timeinfo-peryr.
    p_perid = ls_timeinfo-perid.
  ENDLOOP.

ENDFORM.                    " set_current_period
*&---------------------------------------------------------------------*
*&      Form  SET_PERID_BASIC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_perid_basic .

  CALL FUNCTION 'ZCM_LIST_BOX_PYEAR_PERID'
    EXPORTING
      year_field  = 'P_PERYR'
      perid_field = 'P_PERID'.

ENDFORM.                    " SET_PERID_BASIC
*&---------------------------------------------------------------------*
*&      Form  SET_PROGBAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_progbar USING p_msg.
  DATA: lv_msg TYPE string.
  CONCATENATE `[ ` p_msg ` ] in progress...` INTO lv_msg.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = lv_msg
    EXCEPTIONS
      OTHERS = 0.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_STNUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_stnum .
  PERFORM set_progbar USING 'Student Number'.
  CLEAR: p_objid[], p_objid.
  CHECK p_stnum[] IS NOT INITIAL.

  LOOP AT p_stnum.
    TRANSLATE p_stnum-low  TO UPPER CASE.
    TRANSLATE p_stnum-high TO UPPER CASE.
    MODIFY p_stnum.
  ENDLOOP.
  p_objid-sign   = p_short-sign   = 'I'.
  p_objid-option = p_short-option = 'EQ'.
  SELECT stobjid student12
    INTO (p_objid-low, p_short-low)
    FROM cmacbpst
   WHERE student12 IN p_stnum.
    APPEND p_objid.
    APPEND p_short.
  ENDSELECT.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_LOGIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_login .
  PERFORM set_progbar USING 'BSP Login'.
  CLEAR: gt_login[], gt_login.
  CHECK p_chk2 = 'X'.

  SELECT *
    INTO TABLE gt_login
    FROM zcmt2024_login
   WHERE datum IN p_datum
     AND uzeit IN p_uzeit
     AND uname IN p_short.
  SORT gt_login.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_COOKIE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_cookie .
  PERFORM set_progbar USING 'WD Main'.
  CLEAR: gt_cookie[], gt_cookie.
  CHECK p_chk4 = 'X'.

  SELECT *
    INTO TABLE gt_cookie
    FROM zcmt2024_cookie
   WHERE datum IN p_datum
     AND uzeit IN p_uzeit
     AND uname IN p_short.
  SORT gt_cookie.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_WDLOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_wdlog .
  PERFORM set_progbar USING 'X Page'.
  CLEAR: gt_wdlog[], gt_wdlog.
  CHECK p_chk8 = 'X'.

  SELECT *
    INTO TABLE gt_wdlog
    FROM zcmt2024_wdlog
   WHERE datum IN p_datum
     AND uzeit IN p_uzeit
     AND uname IN p_short.
  SORT gt_wdlog.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_input .
  PERFORM set_progbar USING 'WD 6-Input'.
  CLEAR: gt_input[], gt_input.
  CHECK p_chk6 = 'X'.

  SELECT *
    INTO TABLE gt_input
    FROM zcmt2024_input
   WHERE sdate IN p_datum
     AND stime IN p_uzeit
     AND stobj IN p_objid.
  SORT gt_input.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_error .
  PERFORM set_progbar USING 'WD Error'.
  CLEAR: gt_error[], gt_error.
  CHECK p_chk7 = 'X'.

  SELECT *
    INTO TABLE gt_error
    FROM zcmt2024_error
   WHERE sdate IN p_datum
     AND stime IN p_uzeit
     AND stobj IN p_objid.
  SORT gt_error.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_BOOK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_book .
  PERFORM set_progbar USING 'WD Booking'.
  CLEAR: gt_book[], gt_book.
  CHECK p_chk5 = 'X'.

  SELECT b~objid c~student12 a~bookdate a~booktime a~smstatus a~packnumber b~uname
    INTO TABLE gt_book
    FROM hrpad506 AS a INNER JOIN hrp1001 AS b
                          ON b~adatanr = a~adatanr
                       INNER JOIN cmacbpst AS c
                          ON c~stobjid = b~objid
   WHERE a~smstatus IN ('01','02','03','04')
     AND a~peryr = p_peryr
     AND a~perid = p_perid
     AND a~bookdate IN p_datum
     AND a~booktime IN p_uzeit
     AND b~plvar = '01'
     AND b~otype = 'ST'
     AND c~student12 IN p_short.
  SORT gt_book.

  CLEAR: gt_p1000[], gt_p1000.
  SELECT objid short stext
    INTO CORRESPONDING FIELDS OF TABLE gt_p1000
    FROM hrp1000
   WHERE plvar  = '01'
     AND otype  = 'SE'
     AND langu  = '3'
     AND begda <= sy-datum
     AND endda >= sy-datum.
  SORT gt_p1000 BY objid.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_EPLOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_eplog .
  PERFORM set_progbar USING 'EP Login'.
  CLEAR: gt_eplog[], gt_eplog.
  READ TABLE p_datum INDEX 1. CHECK sy-subrc = 0.
  READ TABLE p_uzeit INDEX 1. CHECK sy-subrc = 0.
  CHECK p_chk1 = 'X'.

  PERFORM connect.
  EXEC SQL PERFORMING append_data.
    SELECT syuname,
           sydate,
           sytime,
           hostnm,
           userip
      INTO :gt_eplog-uname,
           :gt_eplog-datum,
           :gt_eplog-uzeit,
           :gt_eplog-shost,
           :gt_eplog-ipaddr
      FROM EPLOGIN.EP_LOGIN_INFO
     WHERE sydate BETWEEN :p_datum-low AND :p_datum-high
       AND sytime BETWEEN :p_uzeit-low AND :p_uzeit-high
  ENDEXEC.                                              "#EC CI_EXECSQL
  PERFORM disconnect.
  SORT gt_eplog.

*(학번외 삭제...
  LOOP AT gt_eplog.
    SELECT COUNT(*) FROM cmacbpst WHERE student12 = gt_eplog-uname.
    IF sy-subrc <> 0.
      DELETE gt_eplog.
    ENDIF.
  ENDLOOP.
*)

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_UNLOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_unlock .
  PERFORM set_progbar USING 'REQ Unlock'.
  CLEAR: gt_unlock[], gt_unlock.
  READ TABLE p_datum INDEX 1. CHECK sy-subrc = 0.
  READ TABLE p_uzeit INDEX 1. CHECK sy-subrc = 0.
  CHECK p_chk3 = 'X'.

  PERFORM connect.
  EXEC SQL PERFORMING append_data2.
    SELECT user_id,
           TO_CHAR(reg_date,'YYYYMMDD'),
           TO_CHAR(reg_date,'HH24MISS'),
           TO_CHAR(prc_date,'YYYYMMDD'),
           TO_CHAR(prc_date,'HH24MISS'),
           flag
      INTO :gt_unlock-user_id,
           :gt_unlock-reg_date,
           :gt_unlock-reg_time,
           :gt_unlock-prc_date,
           :gt_unlock-prc_time,
           :gt_unlock-flag
      FROM SOGANG.REQ_LOCK_USER
     WHERE TO_CHAR(reg_date,'YYYYMMDD') BETWEEN :p_datum-low AND :p_datum-high
       AND TO_CHAR(reg_date,'HH24MISS') BETWEEN :p_uzeit-low AND :p_uzeit-high
  ENDEXEC.                                              "#EC CI_EXECSQL
  PERFORM disconnect.
  SORT gt_unlock.
ENDFORM.
