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
      rows    = 3
      columns = 1.
  CALL METHOD g_splitter->set_row_height
    EXPORTING
      id     = 1
      height = 20.
  CALL METHOD g_splitter->set_row_height
    EXPORTING
      id     = 2
      height = 20.
  CALL METHOD g_splitter->set_row_height
    EXPORTING
      id     = 3
      height = 60.

* assign G_Container1 & 2 with any columns
  g_container  = g_splitter->get_container( row = 2 column = 1 ).
  g_container2 = g_splitter->get_container( row = 1 column = 1 ).
  g_container3 = g_splitter->get_container( row = 3 column = 1 ).

* Splitter Container Object 선언.
*  CREATE OBJECT g_splitter2
*    EXPORTING
*      parent  = g_container
*      rows    = 1
*      columns = 2.
*  CALL METHOD g_splitter2->set_column_width
*    EXPORTING
*      id    = 1
*      width = 50.
*  CALL METHOD g_splitter2->set_column_width
*    EXPORTING
*      id    = 2
*      width = 50.
*
** Get id of sub-screen
*  g_container3 = g_splitter2->get_container( row = 1 column = 1 ).
*  g_container4 = g_splitter2->get_container( row = 1 column = 2 ).

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
  CREATE OBJECT g_grid2
    EXPORTING
      i_parent = g_container2.

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
FORM display_alv_screen.
*  PERFORM DATA_GRID_SCREEN_CONTROL .

  DATA: ls_variant TYPE disvariant.
  CLEAR: ls_variant.
  ls_variant-report = sy-repid.

  gs_layout-grid_title = '30분 통계(매 10초 동안 발생한 이벤트 건수)'.

  CALL METHOD g_grid->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout
      it_toolbar_excluding = gt_fcode
      i_save               = 'A'
      i_default            = 'X'
      is_variant           = ls_variant
*     i_bypassing_buffer   = 'X'
    CHANGING
      it_sort              = gt_sort[]
      it_fieldcatalog      = gt_grid_fcat[]
      it_outtab            = gt_data[]
      it_filter            = gt_filt[].

ENDFORM.                    " DISPLAY_ALV_SCREEN
*&---------------------------------------------------------------------*
*&      Form  BUILD_COLOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_color .

* <LVC_S_SCOL-COLOR-COL>
* 0 COL_BACKGROUND GUI-dependent
* 1 COL_HEADING    gray-blue
* 2 COL_NORMAL     light gray
* 3 COL_TOTAL      yellow
* 4 COL_KEY        blue-green
* 5 COL_POSITIVE   green
* 6 COL_NEGATIVE   red
* 7 COL_GROUP      orange
* <LVC_S_SCOL-COLOR-INT>
* 1 dark
* 0 light
* <LVC_S_SCOL-COLOR-INV>
* 1 colored neutral
* 0 black   colored


*  DATA: lt_color    TYPE lvc_t_scol,
*        ls_color    TYPE lvc_s_scol.
*
*  ls_color-color-col = 6.
*  ls_color-color-int = 0.
*  ls_color-color-inv = 0.
*
*  LOOP AT gt_data.
*    CLEAR: lt_color[].
*
*    IF gt_data-short1 IS NOT INITIAL AND gt_data-smtx1  IS INITIAL.
*      ls_color-fname     = 'SHORT1'.
*      INSERT ls_color INTO TABLE lt_color.
*    ENDIF.
*    IF gt_data-short2 IS NOT INITIAL AND gt_data-smtx2  IS INITIAL.
*      ls_color-fname     = 'SHORT2'.
*      INSERT ls_color INTO TABLE lt_color.
*    ENDIF.
*    IF gt_data-short3 IS NOT INITIAL AND gt_data-smtx3  IS INITIAL.
*      ls_color-fname     = 'SHORT3'.
*      INSERT ls_color INTO TABLE lt_color.
*    ENDIF.
*    IF gt_data-short4 IS NOT INITIAL AND gt_data-smtx4  IS INITIAL.
*      ls_color-fname     = 'SHORT4'.
*      INSERT ls_color INTO TABLE lt_color.
*    ENDIF.
*    IF gt_data-short5 IS NOT INITIAL AND gt_data-smtx5  IS INITIAL.
*      ls_color-fname     = 'SHORT5'.
*      INSERT ls_color INTO TABLE lt_color.
*    ENDIF.
*    IF gt_data-short6 IS NOT INITIAL AND gt_data-smtx6  IS INITIAL.
*      ls_color-fname     = 'SHORT6'.
*      INSERT ls_color INTO TABLE lt_color.
*    ENDIF.
*
*    INSERT LINES OF lt_color INTO TABLE gt_data-color .
*    MODIFY gt_data.
*  ENDLOOP.

ENDFORM.                    " BUILD_COLOR
*&---------------------------------------------------------------------*
*&      Form  MAKE_GRID_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_GRID_FCAT  text
*----------------------------------------------------------------------*
FORM make_grid_field_catalog  CHANGING pt_fieldcat TYPE lvc_t_fcat.

  DATA : lt_fieldcat TYPE slis_t_fieldcat_alv,
         ff          TYPE lvc_s_fcat,
         lv_tabname  TYPE slis_tabname,
         lv_str      TYPE string,
         lv_chk(1).

  FIELD-SYMBOLS <fs> TYPE any.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'GT_DATA' "/////
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

  LOOP AT pt_fieldcat INTO ff.
    CLEAR: ff-key.
    ff-just = 'C'.
    CASE ff-fieldname.
      WHEN 'BOOKDATE'.  ff-col_pos = 01.  ff-coltext = '수강일자'.
*     WHEN 'BOOKTIME'.  ff-col_pos = 02.  ff-coltext = '최초저장'.
      WHEN 'UGREG'.     ff-col_pos = 03.  ff-coltext = '학부'.
      WHEN 'BEGUZ'.     ff-col_pos = 04.  ff-coltext = '피크시작'.
      WHEN 'ENDUZ'.     ff-col_pos = 05.  ff-coltext = '피크종료'.
      WHEN 'TOTST'.     ff-col_pos = 06.  ff-coltext = '인원소계'.
      WHEN 'TOTSM'.     ff-col_pos = 07.  ff-coltext = '과목소계'.
      WHEN 'T0000'.     ff-col_pos = 08.  ff-coltext = '00:00'.
      WHEN 'T0010'.     ff-col_pos = 09.  ff-coltext = '00:10'.
      WHEN 'T0020'.     ff-col_pos = 10.  ff-coltext = '00:20'.
      WHEN 'T0030'.     ff-col_pos = 11.  ff-coltext = '00:30'.
      WHEN 'T0040'.     ff-col_pos = 12.  ff-coltext = '00:40'.
      WHEN 'T0050'.     ff-col_pos = 13.  ff-coltext = '00:50'.
      WHEN 'T0100'.     ff-col_pos = 14.  ff-coltext = '01:00'.
      WHEN 'T0110'.     ff-col_pos = 15.  ff-coltext = '01:10'.
      WHEN 'T0120'.     ff-col_pos = 16.  ff-coltext = '01:20'.
      WHEN 'T0130'.     ff-col_pos = 17.  ff-coltext = '01:30'.
      WHEN 'T0140'.     ff-col_pos = 18.  ff-coltext = '01:40'.
      WHEN 'T0150'.     ff-col_pos = 19.  ff-coltext = '01:50'.
      WHEN 'T0200'.     ff-col_pos = 20.  ff-coltext = '02:00'.
      WHEN 'T0210'.     ff-col_pos = 21.  ff-coltext = '02:10'.
      WHEN 'T0220'.     ff-col_pos = 22.  ff-coltext = '02:20'.
      WHEN 'T0230'.     ff-col_pos = 23.  ff-coltext = '02:30'.
      WHEN 'T0240'.     ff-col_pos = 24.  ff-coltext = '02:40'.
      WHEN 'T0250'.     ff-col_pos = 25.  ff-coltext = '02:50'.
      WHEN 'T0300'.     ff-col_pos = 26.  ff-coltext = '03:00'.
      WHEN 'T0310'.     ff-col_pos = 27.  ff-coltext = '03:10'.
      WHEN 'T0320'.     ff-col_pos = 28.  ff-coltext = '03:20'.
      WHEN 'T0330'.     ff-col_pos = 29.  ff-coltext = '03:30'.
      WHEN 'T0340'.     ff-col_pos = 30.  ff-coltext = '03:40'.
      WHEN 'T0350'.     ff-col_pos = 31.  ff-coltext = '03:50'.
      WHEN 'T0400'.     ff-col_pos = 32.  ff-coltext = '04:00'.
      WHEN 'T0410'.     ff-col_pos = 33.  ff-coltext = '04:10'.
      WHEN 'T0420'.     ff-col_pos = 34.  ff-coltext = '04:20'.
      WHEN 'T0430'.     ff-col_pos = 35.  ff-coltext = '04:30'.
      WHEN 'T0440'.     ff-col_pos = 36.  ff-coltext = '04:40'.
      WHEN 'T0450'.     ff-col_pos = 37.  ff-coltext = '04:50'.
      WHEN 'T0500'.     ff-col_pos = 38.  ff-coltext = '05:00'.
      WHEN 'T0510'.     ff-col_pos = 39.  ff-coltext = '05:10'.
      WHEN 'T0520'.     ff-col_pos = 40.  ff-coltext = '05:20'.
      WHEN 'T0530'.     ff-col_pos = 41.  ff-coltext = '05:30'.
      WHEN 'T0540'.     ff-col_pos = 42.  ff-coltext = '05:40'.
      WHEN 'T0550'.     ff-col_pos = 43.  ff-coltext = '05:50'.
      WHEN 'T0600'.     ff-col_pos = 44.  ff-coltext = '06:00'.
      WHEN 'T0610'.     ff-col_pos = 45.  ff-coltext = '06:10'.
      WHEN 'T0620'.     ff-col_pos = 46.  ff-coltext = '06:20'.
      WHEN 'T0630'.     ff-col_pos = 47.  ff-coltext = '06:30'.
      WHEN 'T0640'.     ff-col_pos = 48.  ff-coltext = '06:40'.
      WHEN 'T0650'.     ff-col_pos = 49.  ff-coltext = '06:50'.
      WHEN 'T0700'.     ff-col_pos = 50.  ff-coltext = '07:00'.
      WHEN 'T0710'.     ff-col_pos = 51.  ff-coltext = '07:10'.
      WHEN 'T0720'.     ff-col_pos = 52.  ff-coltext = '07:20'.
      WHEN 'T0730'.     ff-col_pos = 53.  ff-coltext = '07:30'.
      WHEN 'T0740'.     ff-col_pos = 54.  ff-coltext = '07:40'.
      WHEN 'T0750'.     ff-col_pos = 55.  ff-coltext = '07:50'.
      WHEN 'T0800'.     ff-col_pos = 56.  ff-coltext = '08:00'.
      WHEN 'T0810'.     ff-col_pos = 57.  ff-coltext = '08:10'.
      WHEN 'T0820'.     ff-col_pos = 58.  ff-coltext = '08:20'.
      WHEN 'T0830'.     ff-col_pos = 59.  ff-coltext = '08:30'.
      WHEN 'T0840'.     ff-col_pos = 60.  ff-coltext = '08:40'.
      WHEN 'T0850'.     ff-col_pos = 61.  ff-coltext = '08:50'.
      WHEN 'T0900'.     ff-col_pos = 62.  ff-coltext = '09:00'.
      WHEN 'T0910'.     ff-col_pos = 63.  ff-coltext = '09:10'.
      WHEN 'T0920'.     ff-col_pos = 64.  ff-coltext = '09:20'.
      WHEN 'T0930'.     ff-col_pos = 65.  ff-coltext = '09:30'.
      WHEN 'T0940'.     ff-col_pos = 66.  ff-coltext = '09:40'.
      WHEN 'T0950'.     ff-col_pos = 67.  ff-coltext = '09:50'.
      WHEN 'T1000'.     ff-col_pos = 68.  ff-coltext = '10:00'.
      WHEN OTHERS.      ff-col_pos = 69.  ff-no_out  = gc_set.
    ENDCASE.

    IF ff-fieldname CP 'BOOK*'.
      ff-key = 'X'.
    ENDIF.
    IF ff-fieldname = 'BEGUZ' OR
       ff-fieldname = 'ENDUZ'.
      ff-edit_mask = '__:__'.
    ENDIF.
    IF ff-fieldname = 'UGREG'.
      ff-checkbox = 'X'.
    ENDIF.
    IF ff-fieldname = 'TOTSM' OR
       ff-fieldname = 'TOTST'.
      ff-emphasize = 'C300'.
      ff-do_sum = 'X'.
    ENDIF.
    IF ff-fieldname CP 'T*'.
      CLEAR: ff-just.
    ENDIF.

    MODIFY pt_fieldcat FROM ff.
  ENDLOOP.

* 값 없는 필드는 자동으로 감추기...
*  LOOP AT pt_fieldcat INTO ff.
*    CLEAR: lv_str, lv_chk.
*    CONCATENATE 'gt_data-' ff-fieldname INTO lv_str.
*    LOOP AT gt_data.
*      ASSIGN (lv_str) TO <fs>.
*      IF <fs> IS NOT INITIAL.
*        lv_chk = 'X'.
*        EXIT.
*      ENDIF.
*    ENDLOOP.
*    IF lv_chk IS INITIAL.
*      ff-no_out = 'X'.
*      MODIFY pt_fieldcat FROM ff.
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

  CLEAR: gt_sort.
  CLEAR: gs_sort.

  gs_sort-spos      = 1.
  gs_sort-up        = 'X'.
  gs_sort-fieldname = 'BOOKDATE'. APPEND gs_sort TO gt_sort.

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

* 버튼
  CONCATENATE icon_column_left  '' INTO sscrfields-functxt_01.
  CONCATENATE icon_column_right '' INTO sscrfields-functxt_02.

  t_001 = icon_information && `"수강 신청이 취소됨" 과목을 포함하면, 과거학기의 피크타임도 분석가능함`.
  t_002 = icon_information && `동등학위(이전) 과목은 제외함`.
  t_003 = icon_final_date.

* 학사력(2차)
*  CLEAR: gt_time[], gt_time.
*  SELECT * INTO TABLE gt_time FROM zcmt2018_time.
*
**(임의추가:1일2회...
** PERFORM set_duplday USING '20210818' '100000'.
** PERFORM set_duplday USING '20210819' '100000'.
** PERFORM set_duplday USING '20220817' '100000'.
** PERFORM set_duplday USING '20220818' '100000'.
*  PERFORM set_duplday USING '20241104' '100000'.
*  PERFORM set_duplday USING '20241105' '100000'.
*  PERFORM set_duplday USING '20241106' '100000'.
*  PERFORM set_duplday USING '20241107' '100000'.
*  PERFORM set_duplday USING '20241108' '100000'.
*  PERFORM set_duplday USING '20241109' '100000'.
*)
*  SORT gt_time BY datum uzeit.

  CASE sy-sysid.
    WHEN 'QAS'.  p_peryr = '2024'. p_perid = '020'.
  ENDCASE.

ENDFORM.                    " INIT_PROC
*&---------------------------------------------------------------------*
*&      Form  SET_DUPLDAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_duplday USING p_day p_time.

  gt_time-datum = p_day.
  gt_time-uzeit = p_time.
  APPEND gt_time.
  t_003 = t_003 && ` ` && p_day+2 && `(` && p_time+0(2) && `), `.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_USER_AUTHORG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_user_authorg.

*  DATA: lv_profl TYPE profl.
*  REFRESH: gt_authobj.
*
*  CALL FUNCTION 'ZCM_USER_AUTHORITY'
*    EXPORTING
*      im_userid = sy-uname
**     IM_PROFL  =
*    TABLES
*      itab_auth = gt_authobj
*    EXCEPTIONS
*      no_authority_for_user = 1
*      OTHERS                = 2.
*
*  IF sy-subrc NE 0.
*    MESSAGE s000 WITH '사용자에게 부여된 권한이 없습니다.'.
*    STOP.
*  ENDIF.
*
*  SORT gt_authobj BY objid.
*  LOOP AT gt_authobj.
*    SELECT SINGLE profl INTO lv_profl FROM t77pq
*     WHERE profl = gt_authobj-objid.
*    IF sy-subrc = 0.
*      p_orgcd = lv_profl.
*      EXIT.
*    ENDIF.
*  ENDLOOP.

ENDFORM.                    " GET_USER_AUTHORG
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
    IF screen-name = 'P_KEYDA'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " modify_screen
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
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .

  PERFORM get_keydate.   "기준일자
  PERFORM get_bookdata.  "수강내역
  PERFORM get_infotype.  "인포타입
  PERFORM set_bookdate.  "일자시간
  PERFORM set_count.     "카운트

  DESCRIBE TABLE gt_data LINES gv_tot.
  DESCRIBE TABLE gt_a506 LINES gv_cnt.
  IF gv_tot = 0.
    MESSAGE '조회 결과가 없습니다' TYPE 'S'.
  ENDIF.

ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  check_proc_continue
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_proc_continue USING $answer $ztext.

  DATA: l_defaultoption, l_textline1(70),  l_textline2(70).

  CLEAR: $answer.

  CONCATENATE `[주의] ` $ztext INTO $ztext.

  l_defaultoption = 'N'.
  l_textline1     = $ztext.

  CLEAR: z_return.

  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption  = l_defaultoption
      textline1      = l_textline1
      textline2      = l_textline2
      titel          = '알  림'
      cancel_display = ''
    IMPORTING
      answer         = z_return.

  CHECK z_return  EQ 'J'.    "Yes
  $answer = 'X'.

ENDFORM.                    " check_proc_continue
*&---------------------------------------------------------------------*
*&      Form  GET_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_file .

  DATA: filepath LIKE sapb-sappfad.
  DATA: filename TYPE string.
  DATA: ls_fcat TYPE lvc_s_fcat,
        lv_fld  TYPE string,
        lv_val  TYPE string.
  FIELD-SYMBOLS <fs> TYPE any.

  DATA: lv_cnt     TYPE i,
        lc_cnt(10).
  DESCRIBE TABLE gt_data LINES lv_cnt.
  lc_cnt = lv_cnt.
  CONDENSE lc_cnt.
  SHIFT lc_cnt LEFT DELETING LEADING '0'.
  IF lc_cnt IS INITIAL. lc_cnt = '0'. ENDIF.

  CONCATENATE '수강통계(' lc_cnt '건)_'
              sy-datum+2 INTO filename.
  CONCATENATE filename '.xls' INTO filename.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = filename "'*.xls'
      mask             = ',*.xls,*.*.'
      mode             = 'S'
    IMPORTING
      filename         = filepath
    EXCEPTIONS
      inv_winsys       = 1
      no_batch         = 2
      selection_cancel = 3
      selection_error  = 4.

  CHECK sy-subrc = 0.
  filename = filepath.

  CLEAR: dat[], dat.

  PERFORM:
    t USING `<html>`,
    t USING `<meta http-equiv="content-type"`,
    t USING `content="application/vnd.ms-excel; charset=euc-kr">`,
    t USING `<style>td{text-align:left;font-size:8pt;`,
    t USING `mso-number-format:"@";}</style>`,
    t USING `<body>`,
    t USING `<table border="1">`,
    t USING `<tr bgcolor="#A3C1E4">`.

  LOOP AT gt_grid_fcat INTO ls_fcat.
    CHECK ls_fcat-no_out NE 'X'. "출력필드만...
    lv_val = ls_fcat-coltext.
    IF lv_val IS INITIAL.
      lv_val = ls_fcat-fieldname.
    ENDIF.
    CONDENSE lv_val.
    CONCATENATE `<td><b>` lv_val `</b></td>`
           INTO lv_val.
    PERFORM t USING lv_val.
  ENDLOOP.

  PERFORM t USING `</tr>`.

  LOOP AT gt_data.
    PERFORM t USING `<tr>`.
    LOOP AT gt_grid_fcat INTO ls_fcat.
      CHECK ls_fcat-no_out NE 'X'. "출력필드만...
      CLEAR: lv_fld.
      CONCATENATE 'gt_data-' ls_fcat-fieldname INTO lv_fld.
      ASSIGN (lv_fld) TO <fs>.
      lv_val = <fs>.
      CONDENSE lv_val.
      TRANSLATE lv_val USING `"〃`.
      CONCATENATE `<td>` lv_val `</td>`
             INTO lv_val.
      PERFORM t USING lv_val.
    ENDLOOP.
    PERFORM t USING `</tr>`.
  ENDLOOP.

  PERFORM:
    t USING `</table>`,
    t USING `</body>`,
    t USING `</html>`.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename = filename
      filetype = 'ASC'
    TABLES
      data_tab = dat.

ENDFORM.                    " GET_FILE
*&---------------------------------------------------------------------*
*&      Form  T
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_PERYR  text
*----------------------------------------------------------------------*
FORM t  USING    p_htm.
  dat-cot = p_htm.
  APPEND dat.
ENDFORM.                    " T
*&---------------------------------------------------------------------*
*&      Form  SET_STATS_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_stats_alv .

  PERFORM set_progbar USING '통계작성(ALV)'.

  DATA: xt_fieldcat TYPE lvc_t_fcat,
        xs_fcat     TYPE lvc_s_fcat.
  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        ls_fcat     TYPE lvc_s_fcat.
  DATA: lv_str      TYPE string.

  CHECK gt_stat[] IS NOT INITIAL.

  CLEAR: lt_fieldcat[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'GT_STAT' "/////
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
    PERFORM transfer_slis_to_lvc CHANGING lt_fieldcat xt_fieldcat.
  ENDIF.

  LOOP AT xt_fieldcat INTO xs_fcat.
    CLEAR: xs_fcat-key.
*   xs_fcat-outputlen = 8.
    CASE xs_fcat-fieldname.
      WHEN 'REGWINDOW'.
        xs_fcat-coltext = '학년구분'.
        xs_fcat-key = 'X'.
        xs_fcat-just = 'C'.
      WHEN 'KEYDA'.
        xs_fcat-coltext = '학적기준일'.
        xs_fcat-just = 'C'.
      WHEN 'TOST'.
        xs_fcat-coltext = '수강대상'.
        xs_fcat-do_sum = 'X'.
      WHEN 'REG1'.
        xs_fcat-coltext = '정규재학'.
        xs_fcat-do_sum = 'X'.
      WHEN 'REG2'.
        xs_fcat-coltext = '정규휴학'.
        xs_fcat-do_sum = 'X'.
      WHEN 'WISH'.
        xs_fcat-coltext = '담기인원'.
        xs_fcat-emphasize = 'C400'.
        xs_fcat-do_sum = 'X'.
      WHEN 'WISM'.
        xs_fcat-coltext = '담기과목'.
        xs_fcat-emphasize = 'C400'.
        xs_fcat-do_sum = 'X'.
      WHEN 'ST13'.
        xs_fcat-coltext = '신청인원'.
        xs_fcat-do_sum = 'X'.
      WHEN 'ST14'.                            "#EC CI_USAGE_OK[2296016]
        xs_fcat-coltext = '누적인원'.
        xs_fcat-do_sum = 'X'.
      WHEN 'BOOK'.
        xs_fcat-coltext = '신청과목'.
        xs_fcat-emphasize = 'C400'.
        xs_fcat-do_sum = 'X'.
      WHEN 'TRNC'.
        xs_fcat-coltext = '누적과목'.
        xs_fcat-emphasize = 'C400'.
        xs_fcat-do_sum = 'X'.
      WHEN 'CANC'.
        xs_fcat-coltext = '취소과목'.
        xs_fcat-emphasize = 'C400'.
        xs_fcat-do_sum = 'X'.
      WHEN OTHERS.
        xs_fcat-no_out = 'X'.
    ENDCASE.
    MODIFY xt_fieldcat FROM xs_fcat.
  ENDLOOP.

* PERFORM make_exclude_code USING gt_fcode.
* gs_layout-no_toolbar = 'X'.

  DATA: ls_variant TYPE disvariant.
  CLEAR: ls_variant.
  ls_variant-report = sy-repid.
  gs_layout-grid_title = '학년별 수강신청 대상'.

  CALL METHOD g_grid2->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout
      it_toolbar_excluding = gt_fcode
      i_save               = 'A'
      i_default            = 'X'
      is_variant           = ls_variant
*     i_bypassing_buffer   = 'X'
    CHANGING
*     it_sort              = gt_sort[]
      it_fieldcatalog      = xt_fieldcat[]
      it_outtab            = gt_stat[].

*  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
*    EXPORTING
*      i_title       = '학년통계'
*      i_tabname     = 'GT_STAT'
*      it_fieldcat   = lt_fieldcat
*    TABLES
*      t_outtab      = gt_stat
*    EXCEPTIONS
*      program_error = 1
*      OTHERS        = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_CHART_GEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_chart_gen .

  PERFORM set_progbar USING '차트생성'.

  DATA: lv_val   TYPE i,
        lv_fldnm TYPE string,
        lv_fldno TYPE i.
  DATA: lv_cnt TYPE i.
  FIELD-SYMBOLS: <fs> TYPE any.
  DATA: ls_fcat TYPE lvc_s_fcat.

*  CLEAR: gt_sels[], gs_sels. "ALV선택
*  CALL METHOD g_grid->get_selected_rows
*    IMPORTING
*      et_index_rows = gt_sels.
*  DESCRIBE TABLE gt_sels LINES lv_cnt.
*
*  IF lv_cnt > 0.
*    CLEAR: gt_filt[], gs_filt.
*  ELSE.
*    MESSAGE '선택된 라인이 없습니다.' TYPE 'S'.
*  ENDIF.

  CLEAR: column_texts[], column_texts.
  SORT gt_grid_fcat BY col_pos.
  LOOP AT gt_grid_fcat INTO ls_fcat WHERE fieldname BETWEEN 'T0000' AND 'T0500'.
    column_texts-coltxt = ls_fcat-fieldname+1(2) && ':' &&
                          ls_fcat-fieldname+3. "범주(시간대)
    APPEND column_texts.
  ENDLOOP.

  CLEAR: values[], values.
  LOOP AT gt_data WHERE ugreg = 'X'. "학부일정...
*  LOOP AT gt_sels INTO gs_sels.
*    READ TABLE gt_data INDEX gs_sels-index.
*    CHECK sy-subrc = 0.

    CLEAR: lv_fldno.
    values-rowtxt = gt_data-bookdate+4(4) && '(' && gt_data-beguz+0(2) && ')'. "일자시간

    LOOP AT gt_grid_fcat INTO ls_fcat WHERE fieldname BETWEEN 'T0000' AND 'T0500'.
      ADD 1 TO lv_fldno.
      lv_fldnm = 'gt_data-' && ls_fcat-fieldname. "필드라벨
      ASSIGN (lv_fldnm) TO <fs>.
      lv_val = <fs>. "필드값

      lv_fldnm = 'values-val' && lv_fldno. "필드라벨
      ASSIGN (lv_fldnm) TO <fs>.
      <fs> = lv_val. "필드값

    ENDLOOP.
    APPEND values.

*   CLEAR: gt_filt[], gs_filt.
    gs_filt-fieldname = 'BOOKDATE'.
    gs_filt-sign      = 'I'.
    gs_filt-option    = 'EQ'.
    gs_filt-low       = gt_data-bookdate.
    APPEND gs_filt TO gt_filt.
  ENDLOOP.

  CALL FUNCTION 'GFW_PRES_SHOW_MULT'
    EXPORTING
      parent            = g_container3
      presentation_type = 17
      header            = 'Subtotal of DB transactions by 10 sec during peaktime'
*     orientation       = gfw_orient_columns
      x_axis_title      = 'Timestamp (5 Min. Peaktime)'
      y_axis_title      = 'Number of Registration'
    TABLES
      values            = values
      column_texts      = column_texts
    EXCEPTIONS
      error_occurred    = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F4_ORG_CD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f4_org_cd .

  CLEAR: gt_vrm[], gt_vrm.
  gt_vrm-key = '32000000'. gt_vrm-text = '서강대학교'. APPEND gt_vrm.
  gt_vrm-key = '30000002'. gt_vrm-text = '학부'.       APPEND gt_vrm.
  gt_vrm-key = '30000100'. gt_vrm-text = '대학원'.     APPEND gt_vrm.
  gt_vrm-key = '30000200'. gt_vrm-text = '전문대학원'. APPEND gt_vrm.
  gt_vrm-key = '30000300'. gt_vrm-text = '특수대학원'. APPEND gt_vrm.
  SORT gt_vrm.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'P_ORGCD'
      values          = gt_vrm[]
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_BOOKDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_bookdata .

  CLEAR: s_smstt[], s_smstt.
  s_smstt-sign   = 'I'.
  s_smstt-option = 'EQ'.
  s_smstt-low    = '01'. APPEND s_smstt.
  s_smstt-low    = '02'. APPEND s_smstt.
  s_smstt-low    = '03'. APPEND s_smstt.
  IF p_sel2 = 'X'.
    s_smstt-low  = '04'. APPEND s_smstt.
  ENDIF.

*(테스트용..
  CLEAR: s_bookd[], s_bookd.
  IF p_bookd IS NOT INITIAL.
    s_bookd-sign   = 'I'.
    s_bookd-option = 'EQ'.
    s_bookd-low    = p_bookd. APPEND s_bookd.
  ENDIF.
*)

  PERFORM set_progbar USING '수강내역'.
  SELECT a~id b~objid a~smstatus a~bookdate a~booktime a~stordate
    INTO CORRESPONDING FIELDS OF TABLE gt_a506
    FROM hrpad506 AS a INNER JOIN hrp1001 AS b
                          ON b~adatanr = a~adatanr
   WHERE a~peryr  = p_peryr
     AND a~perid  = p_perid
     AND a~smstatus IN s_smstt "상태...
     AND a~bookdate IN s_bookd "테스트..
     AND a~transferflag <> 'X' "= ' '
     AND b~plvar  = '01'
     AND b~otype  = 'ST'.

  SORT gt_a506 BY bookdate booktime.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_INFOTYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_infotype .

  PERFORM set_progbar USING '개인데이터'.
* CLEAR: gt_1702[], gt_1702.
  IF gt_1702[] IS INITIAL. "속도문제...
    SELECT objid namzu titel
      INTO CORRESPONDING FIELDS OF TABLE gt_1702
      FROM hrp1702
     WHERE plvar  = '01'
       AND otype  = 'ST'
       AND begda <= p_keyda "sy-datum
       AND endda >= p_keyda."sy-datum
    SORT gt_1702 BY objid.
  ENDIF.

  PERFORM set_progbar USING '학업데이터'.
* CLEAR: gt_1705[], gt_1705.
  IF gt_1705[] IS INITIAL. "속도문제...
    SELECT objid regwindow book_cdt
      INTO CORRESPONDING FIELDS OF TABLE gt_1705
      FROM hrp1705
     WHERE plvar  = '01'
       AND otype  = 'ST'
       AND begda <= p_keyda "sy-datum
       AND endda >= p_keyda."sy-datum
    SORT gt_1705 BY objid.
  ENDIF.

  PERFORM set_progbar USING '학적상태'.
* CLEAR: gt_9530[], gt_9530.
  IF gt_9530[] IS INITIAL. "속도문제...
    SELECT objid sts_cd
      INTO CORRESPONDING FIELDS OF TABLE gt_9530
      FROM hrp9530
     WHERE plvar  = '01'
       AND otype  = 'ST'
       AND begda <= p_keyda "sy-datum
       AND endda >= p_keyda "sy-datum
       AND sts_cd IN ('1000','2000').
    SORT gt_9530 BY objid.
  ENDIF.

  PERFORM set_progbar USING '담아놓기'.
* CLEAR: gt_wish[], gt_wish.
  IF gt_wish[] IS INITIAL. "속도문제...
    SELECT *
      INTO TABLE gt_wish
      FROM zcmt2018_wish
     WHERE peryr = p_peryr
       AND perid = p_perid.
    SORT gt_wish BY objid.
    LOOP AT gt_wish.
      READ TABLE gt_1705 WITH KEY objid = gt_wish-objid BINARY SEARCH.
      IF sy-subrc = 0.
        gt_wish-ernam = gt_1705-regwindow. "임시...
      ENDIF.
      MODIFY gt_wish.
    ENDLOOP.
  ENDIF.

  PERFORM set_progbar USING '수강내역(추가)'.
  LOOP AT gt_a506.
    READ TABLE gt_1702 WITH KEY objid = gt_a506-objid BINARY SEARCH.
    IF sy-subrc = 0.
      gt_a506-namzu = gt_1702-namzu.
      gt_a506-titel = gt_1702-titel.
    ENDIF.
    READ TABLE gt_1705 WITH KEY objid = gt_a506-objid BINARY SEARCH.
    IF sy-subrc = 0.
      gt_a506-regwindow = gt_1705-regwindow.
    ENDIF.
    READ TABLE gt_9530 WITH KEY objid = gt_a506-objid BINARY SEARCH.
    IF sy-subrc = 0.
      gt_a506-sts_cd = gt_9530-sts_cd.
    ENDIF.
    MODIFY gt_a506.
  ENDLOOP.

  IF p_namzu = 'X'.
    DELETE gt_a506 WHERE namzu <> 'A0'. "학부생만..
  ENDIF.
  IF p_titel = 'X'.
    DELETE gt_a506 WHERE titel <> 'A0'. "정규생만..
  ENDIF.
  SORT gt_a506 BY bookdate booktime.

ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  set_time_for_test
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM set_time_for_test.
*
** 수강신청 테스트 시작시간
*  gt_data-beguz = p_bookt.
*  IF gt_data-beguz IS INITIAL.
*    READ TABLE gt_a506 INDEX 1.
*    IF sy-subrc = 0.
*      gt_data-beguz = gt_a506-booktime.
*
*    ENDIF.
*
*  ENDIF.
*
*  gt_data-enduz = gt_data-beguz + 1800. "30분
*
*ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_BOOKDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_bookdate.

*  DATA: lv_bookdate TYPE datum. "직전수강일자

  PERFORM set_progbar USING '일시/시간분석'.
  CLEAR: gt_data[], gt_data.

  READ TABLE gt_a506 WITH KEY bookdate = p_bookd BINARY SEARCH.
  CHECK sy-subrc = 0.

  gt_data-bookdate = p_bookd.

* 수강신청 테스트 시작시간
  gt_data-beguz = p_bookt.
  IF gt_data-beguz IS INITIAL.
    READ TABLE gt_a506 INDEX 1.
    IF sy-subrc = 0.
      gt_data-beguz = gt_a506-booktime.

    ENDIF.

  ENDIF.

  gt_data-enduz = gt_data-beguz + 1800. "30분
  gt_data-ugreg    = 'X'.
  APPEND gt_data.
*  SORT gt_data BY bookdate beguz. "booktime.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_COUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_count .

  DATA: lv_booktime TYPE uzeit. "시간변환용
  FIELD-SYMBOLS: <fs> TYPE any.
  DATA: lv_field TYPE string,
        lv_last1 TYPE c.

  PERFORM set_progbar USING '수강인원분석'.
  LOOP AT gt_data.
    READ TABLE gt_a506 WITH KEY bookdate = gt_data-bookdate BINARY SEARCH.
    CHECK sy-subrc = 0.
    CLEAR: s_stobj[].
    LOOP AT gt_a506 FROM sy-tabix.
      IF gt_a506-bookdate <> gt_data-bookdate. EXIT. ENDIF.
      CHECK gt_a506-booktime BETWEEN gt_data-beguz AND gt_data-enduz.

      ADD 1 TO gt_data-totsm. "무조건합산...
      s_stobj-low = gt_a506-objid. APPEND s_stobj. "학생수계산...

      lv_booktime = gt_a506-booktime - gt_data-beguz.
      lv_last1 = lv_booktime+5(1).
      lv_booktime+5(1) = '0'.
      IF lv_last1 BETWEEN '5' AND '9'.
        ADD 10 TO lv_booktime. "10초올림...
      ENDIF.
      lv_field = 'gt_data-t' && lv_booktime+2.
      ASSIGN (lv_field) TO <fs>.
      ADD 1 TO <fs>.
    ENDLOOP.

    SORT s_stobj BY low.
    DELETE ADJACENT DUPLICATES FROM s_stobj COMPARING low.
    DESCRIBE TABLE s_stobj LINES gt_data-totst. "학생수합산...

    MODIFY gt_data.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_KEYDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_keydate .

  DATA: lt_times TYPE piqtimelimits_tab,
        ls_times TYPE piqtimelimits.

  CLEAR: lt_times[], ls_times.
  CALL FUNCTION 'ZCM_GET_TIMELIMITS'
    EXPORTING
      iv_o          = '30000002'
      iv_timelimit  = '0100'
      iv_peryr      = p_peryr
      iv_perid      = p_perid
    IMPORTING
      et_timelimits = lt_times.

  READ TABLE lt_times INTO ls_times INDEX 1.
  IF sy-subrc = 0.
    p_keyda = ls_times-ca_lbegda.
  ELSE.
    p_keyda = sy-datum.
  ENDIF.

  gv_datum = sy-datum. "조회일자
  gv_uzeit = sy-uzeit. "조회시간

ENDFORM.
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
*&      Form  MAKE_EXCLUDE_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_exclude_code USING pt_fcode TYPE ui_functions.

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
  ls_fcode  = cl_gui_alv_grid=>mc_mb_variant. "레이아웃
  APPEND ls_fcode TO gt_fcode.


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
*&      Form  RELOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reload_data .
  PERFORM get_data.
  PERFORM get_stats.
  PERFORM set_chart_gen.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_STATS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_stats .

  PERFORM set_progbar USING '통계작성'.

  CHECK gt_a506[] IS NOT INITIAL.

  CLEAR: gt_stat[], gt_stat.
  gt_stat-regwindow = ' '. APPEND gt_stat.
  gt_stat-regwindow = '1'. APPEND gt_stat.
  gt_stat-regwindow = '2'. APPEND gt_stat.
  gt_stat-regwindow = '3'. APPEND gt_stat.
  gt_stat-regwindow = '4'. APPEND gt_stat.

  DEFINE get_stscd.
    LOOP AT gt_9530 WHERE sts_cd = '&1000'.
      READ TABLE gt_1702 WITH KEY objid = gt_9530-objid BINARY SEARCH.
      IF sy-subrc = 0 AND gt_1702-namzu = 'A0' AND gt_1702-titel = 'A0'.
        READ TABLE gt_1705 WITH KEY objid = gt_9530-objid BINARY SEARCH.
        IF sy-subrc = 0 AND gt_1705-regwindow = gt_stat-regwindow.
          ADD 1 TO gt_stat-reg&1.
          IF '&1000' = '1000' AND gt_1705-book_cdt > 0.
            ADD 1 TO gt_stat-tost.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  END-OF-DEFINITION.

  LOOP AT gt_stat.
* 기준일자
    gt_stat-keyda = p_keyda.

* 정규재학/정규휴학
    get_stscd: 1,2.

* 담아놓기
    LOOP AT gt_wish WHERE ernam = gt_stat-regwindow.
      ADD 1 TO gt_stat-wish.
      IF gt_wish-short1 IS NOT INITIAL. ADD 1 TO gt_stat-wism. ENDIF.
      IF gt_wish-short2 IS NOT INITIAL. ADD 1 TO gt_stat-wism. ENDIF.
      IF gt_wish-short3 IS NOT INITIAL. ADD 1 TO gt_stat-wism. ENDIF.
      IF gt_wish-short4 IS NOT INITIAL. ADD 1 TO gt_stat-wism. ENDIF.
      IF gt_wish-short5 IS NOT INITIAL. ADD 1 TO gt_stat-wism. ENDIF.
      IF gt_wish-short6 IS NOT INITIAL. ADD 1 TO gt_stat-wism. ENDIF.
    ENDLOOP.

* 신청과목/신청인원
    CLEAR: gt_copy[], gt_copy.
    gt_copy[] = gt_a506[].
    DELETE gt_copy WHERE regwindow <> gt_stat-regwindow OR smstatus  = '04'.
    DESCRIBE TABLE gt_copy LINES gt_stat-book. "신청과목
    SORT gt_copy BY objid.
    DELETE ADJACENT DUPLICATES FROM gt_copy COMPARING objid.
    DESCRIBE TABLE gt_copy LINES gt_stat-st13. "신청인원

* 취소과목
    CLEAR: gt_copy[], gt_copy.
    gt_copy[] = gt_a506[].
    DELETE gt_copy WHERE regwindow <> gt_stat-regwindow OR smstatus <> '04'.
    DESCRIBE TABLE gt_copy LINES gt_stat-canc. "취소과목

* 누적인원
    CLEAR: gt_copy[], gt_copy.
    gt_copy[] = gt_a506[].
    DELETE gt_copy WHERE regwindow <> gt_stat-regwindow.
    SORT gt_copy BY objid.
    DELETE ADJACENT DUPLICATES FROM gt_copy COMPARING objid.
    DESCRIBE TABLE gt_copy LINES gt_stat-st14. "누적인원

* 누적과목
    gt_stat-trnc = gt_stat-book + gt_stat-canc.

* 학년라벨
    IF gt_stat-regwindow IS NOT INITIAL.
      CONCATENATE gt_stat-regwindow '학년' INTO gt_stat-regwindow.
    ENDIF.
    MODIFY gt_stat.
  ENDLOOP.

  SORT gt_stat BY regwindow.

ENDFORM.
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
  lv_keydate = sy-datum + 60.

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
*&      Form  SET_CHART_CLEAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_chart_clear .
  CLEAR: gt_filt[], gt_filt.
* PERFORM set_chart_gen.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_TITLEBAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_titlebar.
*  READ TABLE p_datum INDEX 1.
*  DATA: lv_msg(40) TYPE c.
*  IF p_datum-low IS NOT INITIAL.
*    lv_msg = p_datum-low+2 && p_datum-high+2.
*    WRITE lv_msg USING EDIT MASK ` (__.__.__~__.__.__)` TO lv_msg.
*  ENDIF.
  DATA: lv_msg(40) TYPE c.
  lv_msg = p_bookd && p_bookt.
  WRITE lv_msg USING EDIT MASK ` (____.__.__ / __:__:__)` TO lv_msg.
  SET TITLEBAR 'T100' WITH p_peryr p_perid gv_tot gv_cnt lv_msg.
ENDFORM.
