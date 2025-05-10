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

  DATA: lv_width1 TYPE i,
        lv_width2 TYPE i.
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

  CASE 'X'.
    WHEN p_quota. lv_width1 = 100. lv_width2 =  0.
    WHEN p_limit. lv_width1 =  70. lv_width2 = 30.
  ENDCASE.

* Splitter Container Object 선언.
  CREATE OBJECT g_splitter
    EXPORTING
      parent  = g_docking_container
      rows    = 1
      columns = 2.                  " 1개의 ROW, 2개의 COLUME
*
  CALL METHOD g_splitter->set_column_width
    EXPORTING
      id    = 1
      width = lv_width1.

  CALL METHOD g_splitter->set_column_width
    EXPORTING
      id    = 2
      width = lv_width2.

* assign G_Container1 & 2 with any columns
  g_container   = g_splitter->get_container( row = 1 column = 1 ).
  g_container2  = g_splitter->get_container( row = 1 column = 2 ).


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
* Create Code type ALV List
  CREATE OBJECT g_grid
    EXPORTING
      i_parent = g_container.
  CREATE OBJECT g_grid2
    EXPORTING
      i_parent = g_container2.

  gs_layout-sel_mode   = 'D'. "'A'.
  gs_layout-cwidth_opt = 'A'.
* gs_layout-no_merging = 'X'.
* gs_layout-zebra      = 'X'.
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
*  PERFORM DATA_GRID_SCREEN_CONTROL .
  DATA: ls_variant TYPE disvariant.
  CLEAR: ls_variant.
  ls_variant-report = sy-repid.

  gs_layout-grid_title = '개설분반'.
  CALL METHOD g_grid->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout
      it_toolbar_excluding = gt_fcode
      i_save               = 'A'
      i_default            = 'X'
      is_variant           = ls_variant
    CHANGING
      it_sort              = gt_sort[]
      it_fieldcatalog      = gt_grid_fcat[]
      it_outtab            = gt_data[].

  CLEAR: gs_layout-cwidth_opt.
  gs_layout-grid_title = '담아놓기'.
  CALL METHOD g_grid2->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout
      it_toolbar_excluding = gt_fcode
      i_save               = 'A'
      i_default            = 'X'
      is_variant           = ls_variant
    CHANGING
*     it_sort              = gt_sort[]
      it_fieldcatalog      = gt_grid_fcat2[]
      it_outtab            = gt_cart[].

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
         fc          TYPE lvc_s_fcat,
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

  DATA: p1 TYPE i, p2 TYPE i, p3 TYPE i, p4 TYPE i.
  IF p_perid = '010'.
    p2 = 11. p3 = 12. p4 = 13. p1 = 14.
  ELSE.
    p1 = 11. p2 = 12. p3 = 13. p4 = 14.
  ENDIF.

  LOOP AT pt_fieldcat INTO fc.
    CASE fc-fieldname.
      WHEN 'EDIT'.       fc-col_pos = 01. fc-coltext = '변경'.
      WHEN 'TYPE'.       fc-col_pos = 02. fc-coltext = '타입'.
      WHEN 'MESSAGE'.    fc-col_pos = 03. fc-coltext = '비고'.
*     WHEN 'PERYR'.      fc-col_pos = 04. fc-coltext = '학년도'.
*     WHEN 'PERID'.      fc-col_pos = 05. fc-coltext = '학기'.
*     WHEN 'ORGEH'.      fc-col_pos = 06. fc-coltext = 'O'.
      WHEN 'ORGTX'.      fc-col_pos = 07. fc-coltext = '개설학과'.
*     WHEN 'OBJID'.      fc-col_pos = 08. fc-coltext = 'SE'.
      WHEN 'SHORT'.      fc-col_pos = 09. fc-coltext = '분반코드'.
      WHEN 'STEXT'.      fc-col_pos = 10. fc-coltext = '과목명'.
      WHEN OTHERS.
        CASE 'X'.
          WHEN p_quota.
            CASE fc-fieldname.
              WHEN 'BOOK_KAPZ1'. fc-col_pos = p1. fc-coltext = '1학년'.   "순서주의
              WHEN 'BOOK_KAPZ2'. fc-col_pos = p2. fc-coltext = '2학년'.   "순서주의
              WHEN 'BOOK_KAPZ3'. fc-col_pos = p3. fc-coltext = '3학년'.   "순서주의
              WHEN 'BOOK_KAPZ4'. fc-col_pos = p4. fc-coltext = '4학년'.   "순서주의
              WHEN 'BOOK_KAPZG'. fc-col_pos = 15. fc-coltext = '교환학생'."순서주의
              WHEN 'BOOK_KAPZ'.  fc-col_pos = 16. fc-coltext = '대학원'.
              WHEN OTHERS.       fc-col_pos = 17. fc-no_out  = gc_set.
            ENDCASE.
          WHEN p_limit.
            CASE fc-fieldname.
              WHEN 'SEQNR'.      fc-col_pos = 09. fc-coltext = '순번'.
              WHEN 'APPLY_FG'.   fc-col_pos = 12. fc-coltext = '소속제한'.
              WHEN 'BOOK_FG'.    fc-col_pos = 13. fc-coltext = '수강구분'.
              WHEN 'BOOK_ORG'.   fc-col_pos = 14. fc-coltext = '소속ID'.
              WHEN 'BOOK_ORGTX'. fc-col_pos = 15. fc-coltext = '소속명'.
              WHEN OTHERS.       fc-col_pos = 18. fc-no_out  = gc_set.
            ENDCASE.
        ENDCASE.
    ENDCASE.

    IF fc-fieldname = 'EDIT'.
      fc-checkbox = 'X'.
      fc-outputlen = 3.
    ENDIF.
    IF fc-fieldname = 'ORGTX' OR
       fc-fieldname = 'SHORT' OR
       fc-fieldname = 'SEQNR'.
      fc-key = 'X'.
    ENDIF.
    IF fc-fieldname = 'APPLY_FG'.
      fc-checkbox = 'X'.
    ENDIF.
    IF fc-fieldname = 'EDIT' OR
       fc-fieldname = 'TYPE' OR
       fc-fieldname = 'MESSAGE'.
      fc-emphasize = 'C300'.
    ENDIF.

    MODIFY pt_fieldcat FROM fc.
  ENDLOOP.

* 값 없는 필드는 자동으로 감추기...
*  LOOP AT pt_fieldcat INTO fc.
*    CLEAR: lv_str, lv_chk.
*    CONCATENATE 'gt_data-' fc-fieldname INTO lv_str.
*
*    LOOP AT gt_data.
*      ASSIGN (lv_str) TO <fs>.
*      IF <fs> IS NOT INITIAL.
*        lv_chk = 'X'.
*        EXIT.
*      ENDIF.
*    ENDLOOP.
*
*    IF lv_chk IS INITIAL.
*      fc-no_out = 'X'.
*      MODIFY pt_fieldcat FROM fc.
*    ENDIF.
*  ENDLOOP.

ENDFORM.                    " MAKE_GRID_FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  MAKE_GRID_FIELD_CATALOG2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_GRID_FCAT  text
*----------------------------------------------------------------------*
FORM make_grid_field_catalog2  CHANGING pt_fieldcat TYPE lvc_t_fcat.

  DATA : lt_fieldcat TYPE slis_t_fieldcat_alv,
         fc          TYPE lvc_s_fcat,
         lv_tabname  TYPE slis_tabname,
         lv_str      TYPE string,
         lv_chk(1).

  FIELD-SYMBOLS <fs> TYPE any.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'GT_CART'
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

  LOOP AT pt_fieldcat INTO fc.
    CASE fc-fieldname.
*      WHEN 'EDIT'.
*        fc-col_pos = 01.
*        fc-coltext = '변경'.
*        fc-checkbox = 'X'.
*        fc-outputlen = 3.
      WHEN 'BOOK_FG'.
        fc-col_pos = 02.
        fc-coltext = '수강구분'.
        fc-outputlen = 6.
        fc-edit = 'X'.
      WHEN 'BOOK_ORG'.
        fc-col_pos = 03.
        fc-coltext = '소속ID'.
        fc-outputlen = 8.
        fc-edit = 'X'.
      WHEN 'BOOK_ORGTX'.
        fc-col_pos = 04.
        fc-coltext = '소속명'.
        fc-outputlen = 20.
      WHEN OTHERS.
        fc-no_out  = gc_set.
    ENDCASE.

*-- F4
    IF fc-fieldname = 'BOOK_ORG'.
      fc-f4availabl = 'X'.
      fc-just  = 'L'.
    ENDIF.

    MODIFY pt_fieldcat FROM fc.
  ENDLOOP.

ENDFORM.                    " MAKE_GRID_FIELD_CATALOG2
*&---------------------------------------------------------------------*
*&      Form  BUILD_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_sort .

  CLEAR: gt_sort, gs_sort.
  gs_sort-up        = 'X'.
  gs_sort-spos      = 1.
  gs_sort-fieldname = 'PERYR'. APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'PERID'. APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'ORGEH'. APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'ORGTX'. APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'SHORT'. APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'STEXT'. APPEND gs_sort TO gt_sort.

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

*  LOOP AT gt_data.
*    lv_index = sy-tabix.
*    CLEAR: lt_celltab[], lt_celltab.
*    CLEAR: gt_data-celltab[].
*    PERFORM fill_celltab_grid CHANGING lt_celltab.
*    INSERT LINES OF lt_celltab INTO TABLE gt_data-celltab.
*    MODIFY gt_data INDEX lv_index.
*  ENDLOOP.

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

  CALL METHOD g_grid->set_frontend_fieldcatalog
    EXPORTING
      it_fieldcatalog = gt_grid_fcat[].

  CLEAR: gs_scroll.
  gs_scroll-row = 'X'.
  gs_scroll-col = 'X'.

  CALL METHOD g_grid->refresh_table_display
    EXPORTING
      is_stable = gs_scroll.

  PERFORM refresh_grid2. "카트...

ENDFORM.                    " REFRESH_GRID
*&---------------------------------------------------------------------*
*&      Form  REFRESH_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM refresh_grid2 .

  CALL METHOD g_grid2->set_frontend_fieldcatalog
    EXPORTING
      it_fieldcatalog = gt_grid_fcat2[].

  CLEAR: gs_scroll.
  gs_scroll-row = 'X'.
  gs_scroll-col = 'X'.

  CALL METHOD g_grid2->refresh_table_display
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

* 사용자의 권한조직 취득
*  PERFORM get_user_authorg.

  t_001 = icon_information && `학년순서 1학기: 2-3-4-1 / 나머지: 1-2-3-4`.
  t_002 = icon_information && `소속제한 유효일자는 "1900.01.01 ~ 9999.12.31"로 자동세팅`.
  t_003 = icon_information && `검색조건 우선순위: 분반코드 > 과목코드 > 개설학과`.
  t_004 = icon_warning     && `인원제한(쿼터) 작업은 학사지원팀과 국제팀 동시 작업금지`.
  t_005 = icon_warning     && `엑셀업로드 양식의 항목순서(1,2,3,4학년)를 변경하면 안됨`.

* 버튼
  CONCATENATE icon_column_left  '' INTO sscrfields-functxt_01.
  CONCATENATE icon_column_right '' INTO sscrfields-functxt_02.
  CONCATENATE icon_xls '양식 내려받기' INTO sscrfields-functxt_03.

  PERFORM get_inft.     "소속명칭

  IF sy-sysid = 'UPS'.
    p_orgcd = '30000018'.
    p_peryr = '2016'.
    p_perid = '010'.
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
    IF screen-name = 'P_LIMIT'. "소속제한
      IF sy-tcode = 'ZCMRK257G'.
        screen-input = 0.
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

  CHECK gt_evob[] IS NOT INITIAL.

* 제한조건
  CLEAR: gt_9551[], gt_9551.
  SELECT *
    INTO TABLE gt_9551
    FROM hrp9551
     FOR ALL ENTRIES IN gt_evob
   WHERE plvar = '01'
     AND otype = 'SE'
     AND objid = gt_evob-seobjid
     AND begda = gt_evob-sebegda.
  SORT gt_9551 BY objid.

* 메인
  CLEAR: gt_data[], gt_data.
  LOOP AT gt_evob.
    CLEAR: gt_data.
    PERFORM set_inits. "개설기본정보

    READ TABLE gt_9551 WITH KEY objid = gt_data-objid BINARY SEARCH.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING gt_9551 TO gt_data.
      CASE 'X'.
*----------------------------------------------------------------------*
        WHEN p_quota. "인원제한입력
          APPEND gt_data.
*----------------------------------------------------------------------*
        WHEN p_limit. "소속제한입력
          CLEAR: lt_cart[], lt_cart.
*          copy_row: 01,02,03,04,05,06,07,08,09,10,11,12,13,14,15.
          LOOP AT lt_cart.
            gt_data-book_fg  = lt_cart-book_fg.
            gt_data-book_org = lt_cart-book_org.
            APPEND gt_data.
          ENDLOOP.
          IF sy-subrc <> 0. "없으면...
            APPEND gt_data.
          ENDIF.
*----------------------------------------------------------------------*
      ENDCASE.
    ELSE.
      gt_data-type = 'E'.
      gt_data-message = '인포타입 누락'.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE gt_data LINES gv_tot.
  IF gv_tot = 0.
    MESSAGE '데이터가 존재하지 않습니다.' TYPE 'S'. STOP.
  ENDIF.

ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  CHANGE_MODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_mode .

  IF gv_mode = 'D' .
    CALL METHOD g_grid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.
    gv_mode = 'M' .
  ELSE .
    CALL METHOD g_grid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 0.
    gv_mode = 'D' .
  ENDIF .

ENDFORM.                    " CHANGE_MODE
*&---------------------------------------------------------------------*
*&      Form  MAKE_EXCLUDE_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FCODE  text
*----------------------------------------------------------------------*
FORM make_exclude_code  USING pt_fcode TYPE ui_functions.
  DATA: ls_fcode TYPE ui_func.
  CLEAR: pt_fcode, pt_fcode[].
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_subtot.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_sum.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_average .
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_mb_sum.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_mb_subtot.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_maximum.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_minimum.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_detail.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_views.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_print.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_mb_export.
  APPEND ls_fcode TO gt_fcode.
*  ls_fcode  = cl_gui_alv_grid=>mc_mb_filter.
*  APPEND ls_fcode TO gt_fcode.
*  ls_fcode  = cl_gui_alv_grid=>mc_fc_find.
*  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_check.
  APPEND ls_fcode TO gt_fcode.
*  ls_fcode  = cl_gui_alv_grid=>mc_mb_variant. "레이아웃
*  APPEND ls_fcode TO gt_fcode.
ENDFORM.                    " MAKE_EXCLUDE_CODE
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

  SET HANDLER g_event_receiver_grid->handle_data_changed  FOR g_grid. "Data changed
  SET HANDLER g_event_receiver_grid->handle_hotspot_click FOR g_grid. "Hotspot Click
  SET HANDLER g_event_receiver_grid->handle_toolbar1      FOR g_grid.
  SET HANDLER g_event_receiver_grid->handle_user_command  FOR g_grid.
  CALL METHOD g_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 0.

  SET HANDLER g_event_receiver_grid->handle_data_changed  FOR g_grid2. "Data changed
  SET HANDLER g_event_receiver_grid->handle_hotspot_click FOR g_grid2. "Hotspot Click
  SET HANDLER g_event_receiver_grid->handle_toolbar2      FOR g_grid2.
  SET HANDLER g_event_receiver_grid->handle_user_command  FOR g_grid2.
  SET HANDLER g_event_receiver_grid->handle_onf4          FOR g_grid2.
  CALL METHOD g_grid2->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.

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

* Enter event
  CALL METHOD g_grid2->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.
* Modify event
  CALL METHOD g_grid2->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.                    " REGISTER_GRID_EVENT
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
  CASE p_column .
    WHEN 'STSHORT'.
*      PERFORM call_transaction_piqst00(zcmsubpool)
*        USING gt_data-stobjid.
  ENDCASE .
ENDFORM.                    " DISPLAY_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*&      Form  GRID_DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*      -->P_E_ONF4  text
*----------------------------------------------------------------------*
FORM grid_data_changed
        USING p_data_changed  TYPE REF TO cl_alv_changed_data_protocol
              p_onf4          TYPE any.

  DATA: lv_objid TYPE hrobjid.
  DATA: ls_fcat LIKE LINE OF p_data_changed->mt_fieldcatalog.
  READ TABLE p_data_changed->mt_fieldcatalog INTO ls_fcat INDEX 1.
  CHECK sy-subrc = 0.

  CASE ls_fcat-tabname.
    WHEN 'GT_DATA'. "++++++++++++++++++++++++++++++++++++++++++++++++++
*      LOOP AT p_data_changed->mt_good_cells INTO gs_mod_cells.
*        MODIFY gt_data INDEX gs_mod_cells-row_id
*                       TRANSPORTING (gs_mod_cells-fieldname) edit.
*      ENDLOOP.
    WHEN 'GT_CART'. "++++++++++++++++++++++++++++++++++++++++++++++++++
      LOOP AT p_data_changed->mt_good_cells INTO gs_mod_cells.
        gt_cart-edit = 'X'.
        CASE gs_mod_cells-fieldname.
          WHEN 'BOOK_FG'.
            MODIFY gt_cart INDEX gs_mod_cells-row_id
                           TRANSPORTING (gs_mod_cells-fieldname) edit.
          WHEN 'BOOK_ORG'.
            PERFORM get_orgtx USING gs_mod_cells-value gt_cart-book_orgtx.
            MODIFY gt_cart INDEX gs_mod_cells-row_id
                           TRANSPORTING (gs_mod_cells-fieldname) edit book_orgtx.
        ENDCASE.
      ENDLOOP.
      PERFORM refresh_grid2.
  ENDCASE.

ENDFORM.                    " GRID_DATA_CHANGED
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

* 정규학기만
  CALL FUNCTION 'ZCM_LIST_BOX_PYEAR_PERID'
    EXPORTING
      year_field  = 'P_PERYR'
      perid_field = 'P_PERID'.

ENDFORM.                    " SET_PERID_BASIC
*&---------------------------------------------------------------------*
*&      Form  SET_PREV_PERIOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_prev_period .

  CASE p_perid.
    WHEN '010'. p_perid = '021'. p_peryr = p_peryr - 1.
    WHEN '011'. p_perid = '010'.
    WHEN '020'. p_perid = '011'.
    WHEN '021'. p_perid = '020'.
  ENDCASE.

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

  CASE p_perid.
    WHEN '010'. p_perid = '011'.
    WHEN '011'. p_perid = '020'.
    WHEN '020'. p_perid = '021'.
    WHEN '021'. p_perid = '010'. p_peryr = p_peryr + 1.
  ENDCASE.

ENDFORM.                    " SET_NEXT_PERIOD
*&---------------------------------------------------------------------*
*&      Form  org_f4_entry
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM org_f4_entry.

  CLEAR: gt_vrm[], gt_vrm.

  SELECT map_cd2 com_nm
    INTO (gt_vrm-key, gt_vrm-text)
    FROM zcmt0101
   WHERE grp_cd IN ('100','109').
    APPEND gt_vrm.
  ENDSELECT.

* gt_vrm-key  = '32000000'. gt_vrm-text = '(서강대학교)'. APPEND gt_vrm.
* gt_vrm-key  = '30000200'. gt_vrm-text = '(전문대학원)'. APPEND gt_vrm.
* gt_vrm-key  = '30000300'. gt_vrm-text = '(특수대학원)'. APPEND gt_vrm.
  SORT gt_vrm.
  DELETE ADJACENT DUPLICATES FROM gt_vrm COMPARING ALL FIELDS.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'P_ORGCD'
      values          = gt_vrm[]
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.

ENDFORM.                    " ORG_LIST_ENTRY
**&---------------------------------------------------------------------*
**&      Form  FORM_GET
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
*FORM form_get USING p_param.
*
** MESSAGE '업로드 엑셀양식을 다운로드 합니다.' TYPE 'I'.
*  CALL FUNCTION 'ZCM_MANUAL_PUBLISH'
*    EXPORTING
*      file_name = p_param.
*
*ENDFORM.                    " FORM_GET
*&---------------------------------------------------------------------*
*&      Form  FORM_GET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM form_get.

* MESSAGE '업로드 엑셀양식을 다운로드 합니다.' TYPE 'I'.
  CALL FUNCTION 'ZCM_MANUAL_PUBLISH'
    EXPORTING
      file_name = 'ZCMRA257'.

ENDFORM.                    " FORM_GET
*&---------------------------------------------------------------------*
*&      Form  SET_UPLO_QUOTA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_uplo_quota.

  DATA: filepath LIKE sapb-sappfad,
        filename LIKE rlgrap-filename.
  TYPES truxs_t_text_data(4096) TYPE c OCCURS 0.
  DATA: v_data  TYPE truxs_t_text_data.
  DATA: lv_msg TYPE string.

* 엑셀상의 필드순서대로 매핑됨
  DATA: BEGIN OF lt_form OCCURS 0,
          short(12),
          book_kapz1 TYPE numc05,
          book_kapz2 TYPE numc05,
          book_kapz3 TYPE numc05,
          book_kapz4 TYPE numc05,
          book_kapzg TYPE numc05, "교환(신규)
        END OF lt_form.

  IF sy-tcode = 'ZCMRK257G'.
    lv_msg = '교환학생'.
  ELSE.
    lv_msg = '정규학생'.
  ENDIF.
  lv_msg = '화면을 비우고 인원제한(' && lv_msg && ')을 업로드합니다.'.
  PERFORM confirm_message USING lv_msg.
  CHECK gv_answer = 'J'.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
*     def_filename     = '*.xls'
      mask             = ',*.xls,*.xlsx,*.*.'
      mode             = 'O'
    IMPORTING
      filename         = filepath
    EXCEPTIONS
      inv_winsys       = 1
      no_batch         = 2
      selection_cancel = 3
      selection_error  = 4.
  IF sy-subrc <> 0.
    MESSAGE '파일을 열 수 없습니다.' TYPE 'E'.
  ENDIF.
  filename = filepath.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     i_field_seperator    = ''
      i_line_header        = 'X'
      i_tab_raw_data       = v_data
      i_filename           = filename
    TABLES
      i_tab_converted_data = lt_form
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
    MESSAGE '파일을 변환할 수 없습니다.' TYPE 'E'.
  ENDIF.
  SORT lt_form BY short.

  CLEAR: gt_data[], gv_cur.
  LOOP AT lt_form.
    IF sy-tcode = 'ZCMRK257G'.
      lt_form-book_kapzg = lt_form-book_kapz1. "1학년->교환이동...

      lt_form-book_kapz1 = gt_data-book_kapz1.
      lt_form-book_kapz2 = gt_data-book_kapz2.
      lt_form-book_kapz3 = gt_data-book_kapz3.
      lt_form-book_kapz4 = gt_data-book_kapz4.

    ENDIF.

    CLEAR gt_data.
    MOVE-CORRESPONDING lt_form TO gt_data. "화면복사
    gt_data-edit = 'X'.
    ADD 1 TO gv_cur.
    READ TABLE gt_evob WITH KEY ssshort = lt_form-short BINARY SEARCH. "분반
    IF sy-subrc = 0. "개설...
      PERFORM set_inits. "개설기본정보
*     gt_data-apply_fg = 'X'.
      gt_data-type     = 'R'.
      gt_data-message  = '생성예정(저장필요)'.
    ELSE.
      gt_data-type     = 'E'.
      gt_data-message  = '개설안됨(권한없음)'.
    ENDIF.
    APPEND gt_data.
  ENDLOOP.

  IF gv_cur > 0.
    MESSAGE '업로드(' && gv_cur && '건) 되었습니다.' TYPE 'I'.
  ELSE.
    MESSAGE '처리할 대상이 없습니다.' TYPE 'I'.
  ENDIF.

  PERFORM adjust_data. "순번조정(업로드1)

ENDFORM.                    " SET_UPLO_QUOTA
*&---------------------------------------------------------------------*
*&      Form  SET_UPLO_LIMIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_uplo_limit.

  DATA: filepath LIKE sapb-sappfad,
        filename LIKE rlgrap-filename.
  TYPES truxs_t_text_data(4096) TYPE c OCCURS 0.
  DATA: v_data  TYPE truxs_t_text_data.

  DATA: BEGIN OF lt_form OCCURS 0,
          short(12),
          book_fg(1),
          book_org(8),
        END OF lt_form.

  PERFORM confirm_message USING '화면을 비우고 소속제한을 업로드합니다.'.
  CHECK gv_answer = 'J'.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
*     def_filename     = '*.xls'
      mask             = ',*.xls,*.xlsx,*.*.'
      mode             = 'O'
    IMPORTING
      filename         = filepath
    EXCEPTIONS
      inv_winsys       = 1
      no_batch         = 2
      selection_cancel = 3
      selection_error  = 4.
  IF sy-subrc <> 0.
    MESSAGE '파일을 열 수 없습니다.' TYPE 'E'.
  ENDIF.
  filename = filepath.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     i_field_seperator    = ''
      i_line_header        = 'X'
      i_tab_raw_data       = v_data
      i_filename           = filename
    TABLES
      i_tab_converted_data = lt_form
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
    MESSAGE '파일을 변환할 수 없습니다.' TYPE 'E'.
  ENDIF.
  SORT lt_form BY short.

  CLEAR: gt_data[].
  LOOP AT lt_form.
    CLEAR: gt_data.
    MOVE-CORRESPONDING lt_form TO gt_data.
    gt_data-edit = 'X'.
    READ TABLE gt_evob WITH KEY ssshort = lt_form-short BINARY SEARCH. "분반
    IF sy-subrc = 0. "개설...
      PERFORM set_inits. "개설기본정보
      gt_data-apply_fg = 'X'.
      gt_data-type     = 'R'.
      gt_data-message  = '생성예정(저장필요)'.
    ELSE.
      gt_data-type     = 'E'.
      gt_data-message  = '개설안됨(권한없음)'.
    ENDIF.
    APPEND gt_data.
  ENDLOOP.

  IF gv_cur > 0.
    MESSAGE '업로드(' && gv_cur && '건) 되었습니다.' TYPE 'I'.
  ELSE.
    MESSAGE '처리할 대상이 없습니다.' TYPE 'I'.
  ENDIF.

  PERFORM adjust_data. "순번조정(업로드2)

ENDFORM.                    " SET_UPLO_LIMIT
*&---------------------------------------------------------------------*
*&      Form  GET_EVOB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_evob .

  CHECK p_peryr IS NOT INITIAL.
  CHECK p_perid IS NOT INITIAL.

  DATA: lt_evob TYPE zcmscourse OCCURS 0 WITH HEADER LINE.
  DATA: lv_keywd TYPE stext.

  CLEAR: gt_evob[], gt_evob.
  IF p_senum[] IS NOT INITIAL.
    LOOP AT p_senum.
      CLEAR: lt_evob[], lt_evob.
      lv_keywd = p_senum-low.
      CALL FUNCTION 'ZCM_GET_COURSE_DETAIL'
        EXPORTING
          i_peryr  = p_peryr
          i_perid  = p_perid
          i_stype  = '6' "분반코드
          i_kword  = lv_keywd
        TABLES
          e_course = lt_evob.
      APPEND LINES OF lt_evob TO gt_evob.
    ENDLOOP.
  ELSEIF p_smnum[] IS NOT INITIAL.
    LOOP AT p_smnum.
      CLEAR: lt_evob[], lt_evob.
      lv_keywd = p_smnum-low.
      CALL FUNCTION 'ZCM_GET_COURSE_DETAIL'
        EXPORTING
          i_peryr  = p_peryr
          i_perid  = p_perid
          i_stype  = '3' "과목코드
          i_kword  = lv_keywd
        TABLES
          e_course = lt_evob.
      APPEND LINES OF lt_evob TO gt_evob.
    ENDLOOP.
  ELSE.
    CLEAR: lt_evob[], lt_evob.
    lv_keywd = p_orgcd.
    CALL FUNCTION 'ZCM_GET_COURSE_DETAIL'
      EXPORTING
        i_peryr  = p_peryr
        i_perid  = p_perid
        i_stype  = '1' "개설학과
        i_kword  = lv_keywd
      TABLES
        e_course = lt_evob.
    APPEND LINES OF lt_evob TO gt_evob.
  ENDIF.
  SORT gt_evob BY seobjid.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_ORGTX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_orgtx USING p_org p_orgtx.

  CLEAR: p_orgtx.
  CHECK p_org IS NOT INITIAL.

  READ TABLE gt_1000 WITH KEY objid = p_org BINARY SEARCH.
  IF sy-subrc = 0.
    p_orgtx = gt_1000-stext.
  ELSE.
    p_orgtx = '(알수없음:' && p_org && ')'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM handle_user_command  USING    p_ucomm.
  CASE p_ucomm.
    WHEN 'CKDAT'. PERFORM check_data.
    WHEN 'UCDAT'. PERFORM unchk_data.
    WHEN 'M2CRT'. PERFORM move2_cart.
    WHEN 'RMDAT'. PERFORM delete_data.
    WHEN 'M2DAT'. PERFORM move2_data.
    WHEN 'ADCRT'. PERFORM add_cart.
    WHEN 'CLCRT'. PERFORM delete_cart.
  ENDCASE.
  PERFORM refresh_grid. "전체GRID
ENDFORM.                    " HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  GET_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_rows USING p_grid TYPE REF TO cl_gui_alv_grid p_msg.

  CLEAR: gt_rows[], gt_rows.
  CALL METHOD p_grid->get_selected_rows
    IMPORTING
      et_index_rows = gt_rows.
  DESCRIBE TABLE gt_rows LINES gv_sel.
  IF gv_sel = 0.
    MESSAGE p_msg TYPE 'I'.
*   MESSAGE '라인(n)을 선택하세요.' TYPE 'I'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MOVE2_CART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM move2_cart .

  PERFORM get_rows USING g_grid '개설분반에서 라인(n)을 선택하세요.'.
  CHECK gv_sel > 0.

  PERFORM confirm_message USING '선택한 분반의 소속제한을 담아놓기합니다.'.
  CHECK gv_answer = 'J'.

  PERFORM get_selno USING ''. "선택라인->분반

  CLEAR: gt_cart[], gt_cart. "카트삭제
  LOOP AT gt_data WHERE objid IN r_objid.
    CHECK gt_data-book_fg  IS NOT INITIAL
       OR gt_data-book_org IS NOT INITIAL.
    MOVE-CORRESPONDING gt_data TO gt_cart.
    gt_cart-edit = 'X'.
    APPEND gt_cart.
  ENDLOOP.

  PERFORM add_cart. "카트채움(담기)

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DELETE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_data .

  PERFORM get_rows USING g_grid '개설분반에서 라인(n)을 선택하세요.'.
  CHECK gv_sel > 0.

  PERFORM confirm_message USING '선택한 분반의 소속제한을 삭제합니다.'.
  CHECK gv_answer = 'J'.

  PERFORM get_selno USING ''. "선택라인->분반

  LOOP AT gt_data WHERE objid IN r_objid.
    gt_data-edit = 'X'.
    gt_data-type = 'R'.
    gt_data-message = '삭제예정(저장필요)'.
    CLEAR: gt_data-book_fg,
           gt_data-book_org,
           gt_data-book_orgtx.
    MODIFY gt_data.
  ENDLOOP.

  PERFORM adjust_data. "순번조정(삭제)

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MOVE2_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM move2_data .

  PERFORM get_rows USING g_grid2 '담아놓기에서 라인(n)을 선택하세요.'.
  CHECK gv_sel > 0.

  PERFORM confirm_message USING '선택한 담아놓기를 개설분반에 적용합니다.'.
  CHECK gv_answer = 'J'.

  CLEAR: lt_cart[], lt_cart.
  LOOP AT gt_rows INTO gs_rows.
    READ TABLE gt_cart INDEX gs_rows-index.
    CHECK sy-subrc = 0.
    CHECK gt_cart-book_fg  IS NOT INITIAL
       OR gt_cart-book_org IS NOT INITIAL.
    MOVE-CORRESPONDING gt_cart TO lt_cart.
    APPEND lt_cart.
  ENDLOOP.

  SORT lt_cart.
  DELETE ADJACENT DUPLICATES FROM lt_cart COMPARING ALL FIELDS.

  IF lt_cart[] IS INITIAL.
    MESSAGE '적용할 내용이 없습니다.' TYPE 'I'. EXIT.
  ENDIF.

*----------------------------------------------------------------------*

  PERFORM get_rows USING g_grid '개설분반에서 라인(n)을 선택하세요.'.
  CHECK gv_sel > 0.

  PERFORM get_selno USING ''. "선택라인->분반

  DELETE gt_data WHERE objid IN r_objid. "먼저삭제..

  LOOP AT r_objid.
    CLEAR: gt_data.
    READ TABLE gt_evob WITH KEY seobjid = r_objid-low BINARY SEARCH. "개설찾기...
    CHECK sy-subrc = 0.
    PERFORM set_inits. "개설기본정보
    LOOP AT lt_cart.
      MOVE-CORRESPONDING lt_cart TO gt_data.
      gt_data-edit     = 'X'.
      gt_data-apply_fg = 'X'.
      gt_data-type     = 'R'.
      gt_data-message  = '변경예정(저장필요)'.
      APPEND gt_data.
    ENDLOOP.
  ENDLOOP.

  PERFORM adjust_data. "순번조정(담기)

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_CART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_cart .

  DELETE gt_cart WHERE book_fg  IS INITIAL
                   AND book_org IS INITIAL.
  SORT gt_cart.
  DELETE ADJACENT DUPLICATES FROM gt_cart COMPARING ALL FIELDS.

  CLEAR: gt_cart.
  APPEND gt_cart.
  APPEND gt_cart.
  APPEND gt_cart.
  APPEND gt_cart.
  APPEND gt_cart.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DELETE_CART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_cart .

  PERFORM confirm_message USING '담아놓기를 모두 삭제합니다.'.
  CHECK gv_answer = 'J'.

  CLEAR: gt_cart[], gt_cart.
  PERFORM add_cart. "카트채움(삭제)

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_EXPAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_expand USING p_all .

  DATA: lv_max TYPE i.
  DATA: lv_msg(80) TYPE c.

  IF p_all = 'X'. lv_msg = '(전체)'. ELSE. lv_msg = '(1-4학년)'. ENDIF.
  lv_msg = '선택한 분반의 인원을 최댓값' && lv_msg && '으로 확장합니다.'.

  PERFORM confirm_message USING lv_msg.
  CHECK gv_answer = 'J'.

  LOOP AT gt_rows INTO gs_rows.
    READ TABLE gt_data INDEX gs_rows-index.
    CHECK sy-subrc = 0.
    CHECK gt_data-type <> 'E'. "에러아닌건...

    CLEAR: lv_max. "최대인원...
    IF gt_data-book_kapz1 > lv_max. lv_max = gt_data-book_kapz1. ENDIF.
    IF gt_data-book_kapz2 > lv_max. lv_max = gt_data-book_kapz2. ENDIF.
    IF gt_data-book_kapz3 > lv_max. lv_max = gt_data-book_kapz3. ENDIF.
    IF gt_data-book_kapz4 > lv_max. lv_max = gt_data-book_kapz4. ENDIF.
*(교환포함 학년풀기: 2020.08.19 김상현(feat.최석형)
* 202180820,jjh,이정민: 최댓값(전체)로 확장을 선택하면, 교환학생 포함해서 확장되고 쿼터가 0인 학년으로도 확장된다.
* 단,교환학생의 쿼터가 0 이면 최대값으로 변경하지 않고, 0으로 둔다.
    DATA(lv_min) = 1.
    IF p_all = 'X'.
      IF gt_data-book_kapzg > lv_max. lv_max = gt_data-book_kapzg. ENDIF.
      lv_min = 0.
    ENDIF.
*)
    IF gt_data-book_kapz1 >= lv_min. gt_data-book_kapz1 = lv_max. ENDIF.
    IF gt_data-book_kapz2 >= lv_min. gt_data-book_kapz2 = lv_max. ENDIF.
    IF gt_data-book_kapz3 >= lv_min. gt_data-book_kapz3 = lv_max. ENDIF.
    IF gt_data-book_kapz4 >= lv_min. gt_data-book_kapz4 = lv_max. ENDIF.
    IF gt_data-book_kapzg >  1.      gt_data-book_kapzg = lv_max. ENDIF.

    gt_data-edit     = 'X'.
    gt_data-type     = 'R'.
    gt_data-message  = '변경예정(저장필요)'.
    MODIFY gt_data INDEX gs_rows-index.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_data .

  DATA: lv_dbcnt TYPE i.

  PERFORM get_rows USING g_grid '개설분반에서 라인(n)을 선택하세요.'.
  CHECK gv_sel > 0.

  PERFORM confirm_message USING '선택한 분반의 최종내역을 저장합니다.'.
  CHECK gv_answer = 'J'.

  SORT gt_evob BY seobjid. "/////중요...
  CASE 'X'.
    WHEN p_quota. PERFORM save_quota. "인원제한
    WHEN p_limit. PERFORM save_limit. "소속제한
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_INFT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_inft .

  CLEAR: gt_1000[], gt_1000.
  SELECT *
    INTO TABLE gt_1000
    FROM hrp1000
   WHERE plvar  = '01'
     AND otype  = 'O'
     AND langu  = '3'
     AND begda <= sy-datum
     AND endda >= sy-datum.
  SORT gt_1000 BY objid.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADJUST_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM adjust_data .

  DATA: lv_objid    TYPE hrobjid,
        lv_seqnr(2) TYPE n. "순번
  DATA: lv_before TYPE i,   "조정전
        lv_after  TYPE i,   "조정후
        lv_diff   TYPE i.

  DESCRIBE TABLE gt_data LINES lv_before. "조정전..

* 순번초기화
  LOOP AT gt_data.
    CLEAR: gt_data-seqnr.
    PERFORM get_orgtx USING gt_data-book_org gt_data-book_orgtx. "소속명..
    MODIFY gt_data.
  ENDLOOP.

* 중복제거
  SORT gt_data.
  DELETE ADJACENT DUPLICATES FROM gt_data COMPARING ALL FIELDS.
  SORT gt_data BY objid book_fg book_org.

* 채번
  LOOP AT gt_data.
    IF gt_data-objid <> lv_objid.
      CLEAR: lv_seqnr.
    ENDIF.
    ADD 1 TO lv_seqnr.
    gt_data-seqnr = lv_seqnr.
    lv_objid = gt_data-objid.
    MODIFY gt_data.
  ENDLOOP.

  DESCRIBE TABLE gt_data LINES lv_after. "조정후..
  lv_diff = lv_before - lv_after.
  IF lv_diff > 0.
    MESSAGE '중복제거(' && lv_diff && '건) 되었습니다.' TYPE 'I'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CALL_TCODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_tcode USING p_tcode.

*  SET PARAMETER ID: 'OTYPE' FIELD 'O'.
*  SET PARAMETER ID: 'SHORT' FIELD '30000002'.
  CALL TRANSACTION p_tcode.

ENDFORM.                    " CALL_TCODE
*&---------------------------------------------------------------------*
*&      Form  CONFIRM_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_message USING p_msg.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      textline1      = p_msg
      textline2      = '진행하시겠습니까?'
      titel          = '실행확인'
      cancel_display = ' '
    IMPORTING
      answer         = gv_answer.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_SELNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_selno USING p_type. "' ':전체,'R':R타입

  CLEAR: r_objid[], r_objid. "선택분반
  LOOP AT gt_rows INTO gs_rows.
    READ TABLE gt_data INDEX gs_rows-index.
    CHECK sy-subrc = 0.
    CHECK p_type = '' OR gt_data-type = p_type. "' ':전체,'R':R타입
    r_objid-sign   = 'I'.
    r_objid-option = 'EQ'.
    r_objid-low    = gt_data-objid.
    APPEND r_objid.
  ENDLOOP.

  SORT r_objid BY low.
  DELETE ADJACENT DUPLICATES FROM r_objid COMPARING low.

  IF r_objid[] IS INITIAL.
    MESSAGE '선택된 분반이 없습니다.' TYPE 'I'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_INITS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_inits .
  gt_data-orgeh = gt_evob-oobjid.
  gt_data-orgtx = gt_evob-ostext.
  gt_data-objid = gt_evob-seobjid.
  gt_data-short = gt_evob-ssshort.
  gt_data-stext = gt_evob-smstext.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_UPLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_upload.
  SORT gt_evob BY ssshort. "/////중요...
  CASE 'X'.
    WHEN p_quota. PERFORM set_uplo_quota. "인원제한
    WHEN p_limit. PERFORM set_uplo_limit. "소속제한
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_MESSAGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_messages USING p_objid p_type p_message.
  CHECK p_objid IS NOT INITIAL.
  LOOP AT gt_data WHERE objid = p_objid.
    CLEAR: gt_data-edit.
    gt_data-type = p_type.
    gt_data-message = p_message && '(' && sy-dbcnt && '건)'.
    MODIFY gt_data.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_data .

  PERFORM get_rows USING g_grid '개설분반에서 라인(n)을 선택하세요.'.
  CHECK gv_sel > 0.

  PERFORM get_selno USING ''. "선택라인->분반

  LOOP AT gt_data WHERE objid IN r_objid.
    CHECK gt_data-apply_fg = space.
    gt_data-edit = 'X'.
    gt_data-type = 'R'.
    gt_data-message = '변경예정(저장필요)'.
    gt_data-apply_fg = 'X'.
    MODIFY gt_data.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UNCHK_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM unchk_data .

  PERFORM get_rows USING g_grid '개설분반에서 라인(n)을 선택하세요.'.
  CHECK gv_sel > 0.

  PERFORM get_selno USING ''. "선택라인->분반

  LOOP AT gt_data WHERE objid IN r_objid.
    CHECK gt_data-apply_fg = 'X'.
    gt_data-edit = 'X'.
    gt_data-type = 'R'.
    gt_data-message = '변경예정(저장필요)'.
    CLEAR: gt_data-apply_fg.
    MODIFY gt_data.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  on_f4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->SENDER         text
*      -->E_FIELDNAME    text
*      -->E_FIELDVALUE   text
*      -->ES_ROW_NO      text
*      -->ER_EVENT_DATA  text
*      -->ET_BAD_CELLS   text
*      -->E_DISPLAY      text
*----------------------------------------------------------------------*
FORM on_f4   USING  sender         TYPE REF TO cl_gui_alv_grid
                    e_fieldname    TYPE lvc_fname
                    e_fieldvalue   TYPE lvc_value
                    es_row_no      TYPE lvc_s_roid
                    er_event_data  TYPE REF TO cl_alv_event_data
                    et_bad_cells   TYPE lvc_t_modi
                    e_display      TYPE char01.

  DATA : i_input, i_row  TYPE i.
  i_input = ' '.

  DATA : selectfield  LIKE  help_info-fieldname,
         it_fields    LIKE  help_value OCCURS 1 WITH HEADER LINE,
         select_value LIKE  help_info-fldvalue,
         ld_tabix     LIKE  sy-tabix,
         ls_modi      TYPE lvc_s_modi.

  DATA : or_objec LIKE objec.
  CLEAR: or_objec .

  CHECK e_fieldname = 'BOOK_ORG'.

  CALL FUNCTION 'RH_OBJID_REQUEST'
    EXPORTING
      plvar             = '01' "planvar
      otype             = 'O'
      seark_begda       = '19000101'
      seark_endda       = '99991231'
      dynpro_repid      = sy-repid
      dynpro_dynnr      = sy-dynnr
      dynpro_plvarfield = '01'
      dynpro_otypefield = 'O'
      dynpro_searkfield = 'GT_CART-BOOK_ORG'
    IMPORTING
      sel_object        = or_objec
    EXCEPTIONS
      cancelled         = 1
      wrong_condition   = 2
      nothing_found     = 3
      internal_error    = 5
      OTHERS            = 6.

  select_value = or_objec-objid.
  ASSIGN er_event_data->m_data->* TO <f4tab>.

  ls_modi-row_id    = es_row_no-row_id.
  ls_modi-fieldname = e_fieldname.
  ls_modi-value     = select_value.
  APPEND ls_modi TO <f4tab>.

  IF select_value <> ''.
    er_event_data->m_event_handled = 'X'.
    READ TABLE gt_cart WITH KEY es_row_no-row_id.
    IF sy-subrc = 0.
      gt_cart-book_org   = select_value.
      gt_cart-book_orgtx = or_objec-short.
      MODIFY gt_cart INDEX es_row_no-row_id.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_F4_FIELD2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_f4_field2 .

  CLEAR: gt_f4[],gs_f4.
  gs_f4-fieldname = 'BOOK_ORG'.  "수강가능 소속
  gs_f4-register = 'X'.
  APPEND gs_f4 TO gt_f4.
  CLEAR gs_f4.

  CALL METHOD g_grid2->register_f4_for_fields
    EXPORTING
      it_f4 = gt_f4.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SAVE_QUOTA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM save_quota.

  CLEAR: gv_cur.
  LOOP AT gt_rows INTO gs_rows.
    READ TABLE gt_data INDEX gs_rows-index.
    CHECK sy-subrc = 0.
    CHECK gt_data-type = 'R'. "변경대상만...

    READ TABLE gt_evob WITH KEY seobjid = gt_data-objid BINARY SEARCH.
    IF sy-subrc = 0.
      CLEAR: hrp9551.
      SELECT SINGLE * "기본데이터 DB에서 취득...
        FROM hrp9551
       WHERE plvar = '01'
         AND otype = 'SE'
         AND objid = gt_evob-seobjid
         AND begda = gt_evob-sebegda.
      IF sy-subrc = 0.
        ADD 1 TO gv_cur.
*(교환학생 쿼터분리
        IF sy-tcode = 'ZCMRK257G'.
          hrp9551-book_kapzg = gt_data-book_kapzg. "교환
        ELSE.
          hrp9551-book_kapz4 = gt_data-book_kapz4. "4학년
          hrp9551-book_kapz3 = gt_data-book_kapz3. "3학년
          hrp9551-book_kapz2 = gt_data-book_kapz2. "2학년
          hrp9551-book_kapz1 = gt_data-book_kapz1. "1학년
          hrp9551-book_kapzg = gt_data-book_kapzg. "교환
          hrp9551-book_kapz  = gt_data-book_kapz.  "대학원
        ENDIF.
*)
        MODIFY hrp9551.
        IF sy-dbcnt = 1.
          CLEAR: gt_data-edit.
          gt_data-type = 'S'.
          gt_data-message = '저장성공(' && sy-dbcnt && '건)'.
        ELSE.
          gt_data-type = 'E'.
          gt_data-message = '저장실패(' && sy-dbcnt && '건)'.
        ENDIF.
      ELSE.
        gt_data-type = 'E'.
        gt_data-message = '인포타입(누락)'.
      ENDIF.
    ELSE.
      gt_data-type = 'E'.
      gt_data-message = '개설안됨(권한없음)'.
    ENDIF.
    MODIFY gt_data INDEX gs_rows-index.
  ENDLOOP.

  IF gv_cur > 0.
    MESSAGE '저장(' && gv_cur && '건) 되었습니다.' TYPE 'I'.
  ELSE.
    MESSAGE '처리할 대상이 없습니다.' TYPE 'I'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  save_limit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM save_limit.

  PERFORM get_selno USING 'R'. "선택라인->분반(R타입)
  CHECK r_objid[] IS NOT INITIAL.

  CLEAR: gv_cur.
  LOOP AT r_objid. "선택분반...
    READ TABLE gt_evob WITH KEY seobjid = r_objid-low BINARY SEARCH.
    IF sy-subrc = 0.
      CLEAR: hrp9552.
      SELECT SINGLE * "기본데이터 DB에서 취득...
        FROM hrp9552
       WHERE plvar = '01'
         AND otype = 'SE'
         AND objid = gt_evob-seobjid
         AND begda = gt_evob-sebegda.
      IF sy-subrc = 0.
        ADD 1 TO gv_cur.
        hrp9552-apply_fg = gt_data-apply_fg. "마지막이 반영되는건가..
*        ini_fields: 01,02,03,04,05,06,07,08,09,10,11,12,13,14,15. "초기화
        LOOP AT gt_data WHERE objid = gt_evob-seobjid.
          set_fields: 01,02,03,04,05,06,07,08,09,10,11,12,13,14,15. "필드세팅
        ENDLOOP.
        MODIFY hrp9552.
        IF sy-dbcnt = 1.
          PERFORM set_messages USING gt_evob-seobjid 'S' '저장성공'.
        ELSE.
          PERFORM set_messages USING gt_evob-seobjid 'E' '저장실패'.
        ENDIF.
      ELSE.
        PERFORM set_messages USING gt_evob-seobjid 'E' '인포타입(누락)'.
      ENDIF.
    ELSE.
      PERFORM set_messages USING gt_evob-seobjid 'E' '개설안됨(권한없음)'.
    ENDIF.
  ENDLOOP.

  IF gv_cur > 0.
    MESSAGE '저장(' && gv_cur && '건) 되었습니다.' TYPE 'I'.
  ELSE.
    MESSAGE '처리할 대상이 없습니다.' TYPE 'I'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_POPUP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_popup .

  PERFORM get_rows USING g_grid '개설분반에서 라인(n)을 선택하세요.'.
  CHECK gv_sel > 0.

  CALL SCREEN '0200' STARTING AT 30 5 ENDING AT 55 6.

ENDFORM.
