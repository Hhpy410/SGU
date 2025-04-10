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
*  PERFORM DATA_GRID_SCREEN_CONTROL .

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
      it_outtab       = gt_data[].

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


  DATA: lt_color TYPE lvc_t_scol,
        ls_color TYPE lvc_s_scol.

  ls_color-color-col = 6.
  ls_color-color-int = 0.
  ls_color-color-inv = 0.

  LOOP AT gt_data.
    CLEAR: lt_color[].

    IF gt_data-se_short IS NOT INITIAL AND gt_data-smtx1  IS INITIAL.
      ls_color-fname     = 'SHORT1'.
      INSERT ls_color INTO TABLE lt_color.
    ENDIF.
    IF gt_data-short2 IS NOT INITIAL AND gt_data-smtx2  IS INITIAL.
      ls_color-fname     = 'SHORT2'.
      INSERT ls_color INTO TABLE lt_color.
    ENDIF.
    IF gt_data-short3 IS NOT INITIAL AND gt_data-smtx3  IS INITIAL.
      ls_color-fname     = 'SHORT3'.
      INSERT ls_color INTO TABLE lt_color.
    ENDIF.
    IF gt_data-short4 IS NOT INITIAL AND gt_data-smtx4  IS INITIAL.
      ls_color-fname     = 'SHORT4'.
      INSERT ls_color INTO TABLE lt_color.
    ENDIF.
    IF gt_data-short5 IS NOT INITIAL AND gt_data-smtx5  IS INITIAL.
      ls_color-fname     = 'SHORT5'.
      INSERT ls_color INTO TABLE lt_color.
    ENDIF.
    IF gt_data-short6 IS NOT INITIAL AND gt_data-smtx6  IS INITIAL.
      ls_color-fname     = 'SHORT6'.
      INSERT ls_color INTO TABLE lt_color.
    ENDIF.

    INSERT LINES OF lt_color INTO TABLE gt_data-color .
    MODIFY gt_data.
  ENDLOOP.

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

*(학년순서
  DATA: s1 TYPE i, s2 TYPE i, s3 TYPE i, s4 TYPE i.
  IF p_perid = '010'.
    s1 = 3. s2 = 0. s3 = 1. s4 = 2.
  ELSE.
    s1 = 0. s2 = 1. s3 = 2. s4 = 3.
  ENDIF.
*)

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

  LOOP AT pt_fieldcat INTO ff.
    CASE ff-fieldname.
*     WHEN 'OBJID'.  ff-col_pos = 01.      ff-coltext = 'ST'.
      WHEN 'SHORT'.       ff-col_pos = 02.      ff-coltext = '학번'.
      WHEN 'STEXT'.       ff-col_pos = 03.      ff-coltext = '성명'.
      WHEN 'STS_CD_TXT'.  ff-col_pos = 03.      ff-coltext = '학적상태'.
      WHEN 'RGWIN'.       ff-col_pos = 04.      ff-coltext = '학년'.
      WHEN 'RGSEM'.       ff-col_pos = 04.      ff-coltext = '학기'.
      WHEN 'BKCDT'.  ff-col_pos = 04.      ff-coltext = '학점'.
*     WHEN 'PERYR'.  ff-col_pos = 05.      ff-coltext = '학년도'.
*     WHEN 'PERID'.  ff-col_pos = 06.      ff-coltext = '학기'.
      WHEN 'SE_SHORT'. ff-col_pos = 06.      ff-coltext = '분반코드'.
      WHEN 'SHORT1'. ff-col_pos = 07.      ff-coltext = '입력코드1'.
      WHEN 'SHORT2'. ff-col_pos = 08.      ff-coltext = '입력코드2'.
      WHEN 'SHORT3'. ff-col_pos = 09.      ff-coltext = '입력코드3'.
      WHEN 'SHORT4'. ff-col_pos = 10.      ff-coltext = '입력코드4'.
      WHEN 'SHORT5'. ff-col_pos = 11.      ff-coltext = '입력코드5'.
      WHEN 'SHORT6'. ff-col_pos = 12.      ff-coltext = '입력코드6'.
      WHEN 'SMCNT'.  ff-col_pos = 13.      ff-coltext = '입력수'.
      WHEN 'SMTX1'.  ff-col_pos = 14.      ff-coltext = '과목명1'.
      WHEN 'SMTX2'.  ff-col_pos = 15.      ff-coltext = '과목명2'.
      WHEN 'SMTX3'.  ff-col_pos = 16.      ff-coltext = '과목명3'.
      WHEN 'SMTX4'.  ff-col_pos = 17.      ff-coltext = '과목명4'.
      WHEN 'SMTX5'.  ff-col_pos = 18.      ff-coltext = '과목명5'.
      WHEN 'SMTX6'.  ff-col_pos = 19.      ff-coltext = '과목명6'.
      WHEN 'ERNAM'.  ff-col_pos = 20.      ff-coltext = '생성학번'.
      WHEN 'ERDAT'.  ff-col_pos = 21.      ff-coltext = '생성일자'.
      WHEN 'ERTIM'.  ff-col_pos = 22.      ff-coltext = '생성시간'.
      WHEN 'COMP'.   ff-col_pos = 23.      ff-coltext = '저장'.
      WHEN 'AENAM'.  ff-col_pos = 24.      ff-coltext = '저장학번'.
      WHEN 'AEDAT'.  ff-col_pos = 25.      ff-coltext = '저장일자'.
      WHEN 'AETIM'.  ff-col_pos = 26.      ff-coltext = '저장시간'.
      WHEN 'CTYPE1'.  ff-col_pos = 27.     ff-coltext = '구분'.
      WHEN 'RATEA'.  ff-col_pos = 28.      ff-coltext = '전체'.
      WHEN 'RATE1'.  ff-col_pos = 29 + s1. ff-coltext = '1학년'.
      WHEN 'RATE2'.  ff-col_pos = 29 + s2. ff-coltext = '2학년'.
      WHEN 'RATE3'.  ff-col_pos = 29 + s3. ff-coltext = '3학년'.
      WHEN 'RATE4'.  ff-col_pos = 29 + s4. ff-coltext = '4학년'.

      WHEN 'CTYPE2'.  ff-col_pos = 33.     ff-coltext = '구분'.
      WHEN 'APPCA'.  ff-col_pos = 34.      ff-coltext = '전체'.
      WHEN 'APPC1'.  ff-col_pos = 35 + s1. ff-coltext = '1학년'.
      WHEN 'APPC2'.  ff-col_pos = 35 + s2. ff-coltext = '2학년'.
      WHEN 'APPC3'.  ff-col_pos = 35 + s3. ff-coltext = '3학년'.
      WHEN 'APPC4'.  ff-col_pos = 35 + s4. ff-coltext = '4학년'.

      WHEN 'CTYPE3'.  ff-col_pos = 39.     ff-coltext = '구분'.
      WHEN 'KAPZA'.  ff-col_pos = 40.      ff-coltext = '전체'.
      WHEN 'KAPZ1'.  ff-col_pos = 41 + s1. ff-coltext = '1학년'.
      WHEN 'KAPZ2'.  ff-col_pos = 41 + s2. ff-coltext = '2학년'.
      WHEN 'KAPZ3'.  ff-col_pos = 41 + s3. ff-coltext = '3학년'.
      WHEN 'KAPZ4'.  ff-col_pos = 41 + s4. ff-coltext = '4학년'.
      WHEN OTHERS.   ff-no_out  = gc_set.
    ENDCASE.

    IF ff-fieldname = 'SHORT' OR
       ff-fieldname = 'STEXT'.
      ff-key = 'X'.
    ENDIF.

    IF ff-fieldname+0(5) = 'SHORT'.
      ff-emphasize = 'C300'.
    ENDIF.

    IF ff-fieldname = 'SE_SHORT'.
      ff-emphasize = 'C300'.
    ENDIF.

    IF ff-fieldname = 'COMP'.
      ff-checkbox = 'X'.
    ENDIF.

*   경쟁률
    IF ff-fieldname = 'CTYPE'  OR
       ff-fieldname = 'CTYPE1' OR
       ff-fieldname = 'RATEA'  OR
       ff-fieldname = 'RATE1'  OR
       ff-fieldname = 'RATE2'  OR
       ff-fieldname = 'RATE3'  OR
       ff-fieldname = 'RATE4'.
      ff-emphasize = 'C500'.
    ENDIF.

*   신청수
    IF ff-fieldname = 'CTYPE2' OR
       ff-fieldname = 'APPCA' OR
       ff-fieldname = 'APPC1' OR
       ff-fieldname = 'APPC2' OR
       ff-fieldname = 'APPC3' OR
       ff-fieldname = 'APPC4'.
      ff-emphasize = 'C110'.
    ENDIF.

*   정원
    IF ff-fieldname = 'CTYPE3' OR
       ff-fieldname = 'KAPZA' OR
       ff-fieldname = 'KAPZ1' OR
       ff-fieldname = 'KAPZ2' OR
       ff-fieldname = 'KAPZ3' OR
       ff-fieldname = 'KAPZ4'.
      ff-emphasize = 'C210'.
    ENDIF.

    IF ff-fieldname+0(4) = 'CVAL'.
      ff-just = 'C'.
    ENDIF.

    MODIFY pt_fieldcat FROM ff.
  ENDLOOP.

* 값 없는 필드는 자동으로 감추기...
  LOOP AT pt_fieldcat INTO ff.
    CLEAR: lv_str, lv_chk.
    CONCATENATE 'gt_data-' ff-fieldname INTO lv_str.

    LOOP AT gt_data.
      ASSIGN (lv_str) TO <fs>.
      IF <fs> IS NOT INITIAL.
        lv_chk = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_chk IS INITIAL.
      ff-no_out = 'X'.
      MODIFY pt_fieldcat FROM ff.
    ENDIF.

    IF p_stp1 = 'X'."담아놓기 내역
      IF ff-fieldname = 'SE_SHORT'. ff-no_out = 'X'. ENDIF.


      MODIFY pt_fieldcat FROM ff.
    ENDIF.
  ENDLOOP.

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
  gs_sort-fieldname = 'SHORT'. APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'STEXT'. APPEND gs_sort TO gt_sort.

  IF p_stp3 = 'X'.
    gs_sort-fieldname = 'SHORT1'. APPEND gs_sort TO gt_sort.
    gs_sort-fieldname = 'SMTX1'.  APPEND gs_sort TO gt_sort.
    gs_sort-fieldname = 'CTYPE1'.  APPEND gs_sort TO gt_sort.
  ENDIF.

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

* 사용자의 권한조직 취득
*  PERFORM get_user_authorg.

* 버튼
  CONCATENATE icon_column_left  '' INTO sscrfields-functxt_01.
  CONCATENATE icon_column_right '' INTO sscrfields-functxt_02.
  CONCATENATE icon_graphics '학년통계' INTO sscrfields-functxt_03.

* 안내
  CONCATENATE icon_information
  `룰1. [계절학기] 입력쿼터 그대로 경쟁률 계산` INTO t_001.

  CONCATENATE icon_information
  `룰2. [정규학기] 1학기: 2-3-4-1순, 2학기: 1-2-3-4순 쿼터차감 경쟁률 계산` INTO t_002.

  CONCATENATE icon_information
  `룰3. 미달된 학년의 여석을 다음학년 쿼터에 포함하여 경쟁률 계산` INTO t_003.

  CONCATENATE icon_information
  `룰4. 쿼터 없는 학년의 신청건도 전체 경쟁률에 포함` INTO t_004.

  CONCATENATE icon_information
  `룰5. 정규학기의 변경기간 이후 경쟁률 맞지않음` INTO t_005.


*{공통코드 설정(학적상태표기), 20170804, 정재현
  SELECT grp_cd com_cd com_nm
    INTO TABLE gt_0101
    FROM zcmt0101
   WHERE grp_cd = '160'.
*}

  IF sy-sysid = 'UPS'.
    p_peryr = '2015'.
    p_perid = '021'.
  ENDIF.

ENDFORM.                    " INIT_PROC
*&---------------------------------------------------------------------*
*&      Form  set_current_period
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_current_period.

  lv_keyda = sy-datum + 40.

  CLEAR: lt_tinfo[], ls_tinfo.
  CALL FUNCTION 'ZCM_GET_TIMELIMITS'
    EXPORTING
      iv_o         = '30000002'
      iv_timelimit = '0100'
      iv_keydate   = lv_keyda
    IMPORTING
      et_timeinfo  = lt_tinfo.

  READ TABLE lt_tinfo INTO ls_tinfo INDEX 1.
  IF sy-subrc = 0.
    MOVE ls_tinfo-peryr TO p_peryr.
    MOVE ls_tinfo-perid TO p_perid.
  ENDIF.

ENDFORM.                    " set_current_period
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

* 대문자로
  LOOP AT p_smnum.
    TRANSLATE p_smnum-low  TO UPPER CASE.
    TRANSLATE p_smnum-high TO UPPER CASE.
    MODIFY p_smnum.
  ENDLOOP.

  LOOP AT SCREEN.
    IF screen-name+0(7) = 'P_STNUM'.
      IF p_stp3 = 'X'.
        screen-input = 0.
        MODIFY SCREEN.
      ELSE.
        screen-input = 1.
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
FORM get_data .

  DATA: lv_int TYPE i.

* PERFORM set_buffer. "/$sync 버퍼싱크
  PERFORM get_evob.   "개설정보

* 초기화
  CLEAR: gt_data[] ,gt_data, "ALV
         gt_temp[] ,gt_temp.
  CLEAR: gt_wish[] ,gt_wish, "담아놓기
         gt_save[], gt_save. "실제저장
  CLEAR: gv_tot.

* 학번필터
  PERFORM get_stobj.

* 입력코드->과목코드
  LOOP AT p_smnum.
    p_smnum-option = 'CP'.
    TRANSLATE p_smnum-low TO UPPER CASE.
    p_smnum-low = p_smnum-low && '*'.
    MODIFY p_smnum.
  ENDLOOP.

* 담아놓기 RawData
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_wish
    FROM zcmtk310
   WHERE peryr = p_peryr
     AND perid = p_perid
     AND st_id IN s_stobj
     AND se_short IN p_smnum.
  SORT gt_wish BY st_id se_id.

  CASE 'X'.
    WHEN p_stp1. "담아놓기 +++++++++++++++++++++++++++++++++++++++++++++

      PERFORM get_date1. "학사력

      CLEAR: gt_temp[], gt_temp.
      MOVE-CORRESPONDING gt_wish[] TO gt_temp[].
      DELETE ADJACENT DUPLICATES FROM gt_temp COMPARING st_id.

      gv_status_txt = |[조회] { p_peryr }학년도 { p_perid }학기 담아놓기|.
      PERFORM set_progtext USING gv_status_txt.

      DESCRIBE TABLE gt_temp LINES gv_tot.
      LOOP AT gt_temp.
        ADD 1 TO gv_cnt.
        ADD 1 TO gv_100_cnt.
        ADD 1 TO gv_1000_cnt.
        IF gv_100_cnt = 100.
          CLEAR: gv_100_cnt, gv_1000_cnt.
          PERFORM set_progress USING sy-tabix.
        ENDIF.

        MOVE-CORRESPONDING gt_temp TO gt_data.
        gt_data-ctype1 = '담아놓기'.
        SELECT SINGLE regwindow regsemstr book_cdt
          INTO (gt_data-rgwin, gt_data-rgsem, gt_data-bkcdt)
          FROM hrp1705
         WHERE plvar  = '01'
           AND otype  = 'ST'
           AND objid  = gt_data-st_id
           AND begda <= gv_begda "sy-datum
           AND endda >= gv_begda."sy-datum.

        CLEAR: gt_data-smcnt.

        DATA lv_cnt TYPE i.
        LOOP AT gt_wish WHERE st_id = gt_temp-st_id.
          AT NEW st_id.
            CLEAR lv_cnt.
          ENDAT.
          ADD 1 TO lv_cnt.
          CASE lv_cnt.
            WHEN 1.
              set_se_short: 1 gt_wish-se_short.
            WHEN 2.
              set_se_short: 2 gt_wish-se_short.
            WHEN 3.
              set_se_short: 3 gt_wish-se_short.
            WHEN 4.
              set_se_short: 4 gt_wish-se_short.
            WHEN 5.
              set_se_short: 5 gt_wish-se_short.
            WHEN 6.
              set_se_short: 6 gt_wish-se_short.
          ENDCASE.
          ADD 1 TO gt_data-smcnt.

        ENDLOOP.

        SELECT SINGLE a~sts_cd "현재 학적상태(텍스트) 가져오기
          INTO gt_data-sts_cd
          FROM hrp9530 AS a
         WHERE a~plvar   =  '01'
           AND a~otype   =  'ST'
           AND a~istat   =  '1'
           AND a~begda  <= sy-datum
           AND a~endda  >= sy-datum
           AND a~objid   = gt_data-st_id. "stobjid

        PERFORM get_text_0101 USING    '160' gt_data-sts_cd
                              CHANGING gt_data-sts_cd_txt.
        APPEND gt_data.
      ENDLOOP.

    WHEN p_stp2. "실제저장 +++++++++++++++++++++++++++++++++++++++++++++

      PERFORM get_date3. "학사력

      CHECK gt_wish[] IS NOT INITIAL.
      SELECT *
        INTO TABLE gt_save
        FROM zcmt2024_input
       WHERE sdate BETWEEN gv_begda AND gv_endda.
      SORT gt_save BY stobj str1 sdate stime.
      DELETE ADJACENT DUPLICATES FROM gt_save COMPARING stobj str1.

      LOOP AT gt_save.
        READ TABLE gt_wish
          WITH KEY st_id = gt_save-stobj
                   se_short = gt_save-str1.
        CHECK sy-subrc = 0.
        CLEAR  gt_data.
        gt_data-st_id = gt_save-stobj.
        gt_data-aedat = gt_save-sdate.
        gt_data-aetim = gt_save-uzeit.
        gt_data-short1 = gt_save-str1.
        gt_data-ctype1  = '저장시도'.
        APPEND gt_data.

      ENDLOOP.


    WHEN p_stp3. "경쟁비율 +++++++++++++++++++++++++++++++++++++++++++++

      PERFORM get_date1. "학사력

      CLEAR: gt_temp[], gt_temp.
      LOOP AT gt_wish.
        gt_temp-se_short = gt_wish-se_short. APPEND gt_temp.
      ENDLOOP.
      SORT gt_temp BY se_short.
      DELETE ADJACENT DUPLICATES FROM gt_temp COMPARING se_short.
      DELETE gt_temp WHERE se_short IS INITIAL.
      DELETE gt_temp WHERE se_short NOT IN p_smnum. "필터

      LOOP AT gt_temp.
        READ TABLE gt_evob WITH KEY seshort = gt_temp-se_short
                                    BINARY SEARCH.
        CHECK sy-subrc = 0.
        CLEAR: g_appca,
               g_appc1,
               g_appc2,
               g_appc3,
               g_appc4,
               g_kapza,
               g_kapz1,
               g_kapz2,
               g_kapz3,
               g_kapz4,
               g_ratea,
               g_rate1,
               g_rate2,
               g_rate3,
               g_rate4.
        PERFORM get_competition_rate USING gt_temp-se_short.

        gt_temp-smtx1 = gt_evob-smstext.
        MOVE-CORRESPONDING gt_temp TO gt_data.

*        IF gv_mode = '3' OR gv_mode = '0'.
*          gt_data-ctype = '조정쿼터'.
*          gt_data-cvala = lv_int = g_kapza.
*          gt_data-cval1 = lv_int = g_kapz1.
*          gt_data-cval2 = lv_int = g_kapz2.
*          gt_data-cval3 = lv_int = g_kapz3.
*          gt_data-cval4 = lv_int = g_kapz4.
*          APPEND gt_data.
*        ENDIF.

        gt_data-ctype1 = '경쟁률'.
        gt_data-ratea = g_ratea.
        gt_data-rate1 = g_rate1.
        gt_data-rate2 = g_rate2.
        gt_data-rate3 = g_rate3.
        gt_data-rate4 = g_rate4.

        gt_data-ctype2 = '신청수'.
        gt_data-appca = lv_int = g_appca.
        gt_data-appc1 = lv_int = g_appc1.
        gt_data-appc2 = lv_int = g_appc2.
        gt_data-appc3 = lv_int = g_appc3.
        gt_data-appc4 = lv_int = g_appc4.

        gt_data-ctype3 = '입력쿼터'.
        gt_data-kapza = g_kapza. "전체
        gt_data-kapz1 = g_kapz1.
        gt_data-kapz2 = g_kapz2.
        gt_data-kapz3 = g_kapz3.
        gt_data-kapz4 = g_kapz4.

        APPEND gt_data.

      ENDLOOP.

      CLEAR: gt_temp[], gt_temp.

  ENDCASE.

  LOOP AT gt_data.
    SELECT SINGLE short stext "학번/성명
      INTO (gt_data-short, gt_data-stext)
      FROM hrp1000
     WHERE plvar  = '01'
       AND otype  = 'ST'
       AND objid  = gt_data-st_id
       AND langu  = '3'
       AND begda <= sy-datum
       AND endda >= sy-datum.

    set_smtx: 1,2,3,4,5,6. "과목명
    MODIFY gt_data.
  ENDLOOP.

  DESCRIBE TABLE gt_data LINES gv_count.
  IF gv_count = 0.
    MESSAGE '조회 결과가 없습니다' TYPE 'S'.
  ENDIF.

ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  get_competition_rate
*&---------------------------------------------------------------------*
*       경쟁률
*----------------------------------------------------------------------*
FORM get_competition_rate USING i_short TYPE short_d.

  CHECK gt_evob-peryr IS NOT INITIAL.
  CHECK gt_evob-perid IS NOT INITIAL.
  CHECK i_short      IS NOT INITIAL.

  DATA: lt_wish LIKE zcmtk310 OCCURS 0 WITH HEADER LINE.
  DATA: lt_1705 LIKE hrp1705       OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF lt_stat OCCURS 0,
          code TYPE short_d,
          rwin TYPE piqregwindow,
          appc TYPE i,
        END OF lt_stat.

  DATA: lv_rate TYPE zcgpa.

*"----------------------------------------------------------------------
* 담아놓기 조회

*  CLEAR: lt_wish[], lt_wish.
*  SELECT st_id se_short
*    INTO CORRESPONDING FIELDS OF TABLE lt_wish
*    FROM zcmtk310
*   WHERE peryr = gt_evob-peryr
*     AND perid = gt_evob-perid
*     AND se_short = i_short.
*  CHECK sy-subrc = 0.
*  SORT lt_wish BY st_id.
  CLEAR: lt_wish[], lt_wish.
  LOOP AT gt_wish WHERE peryr = gt_evob-peryr
                    AND perid = gt_evob-perid
                    AND se_short = i_short.
    lt_wish-st_id = gt_wish-st_id.
    lt_wish-se_short = gt_wish-se_short.
    APPEND lt_wish.

  ENDLOOP.

*"----------------------------------------------------------------------
* 학년 조회

  CLEAR: lt_1705[], lt_1705.
  SELECT objid regwindow
    INTO CORRESPONDING FIELDS OF TABLE lt_1705
    FROM hrp1705
     FOR ALL ENTRIES IN lt_wish
   WHERE plvar  = '01'
     AND otype  = 'ST'
     AND objid  = lt_wish-st_id
     AND begda <= sy-datum
     AND endda >= sy-datum.
  SORT lt_1705 BY objid.
  DELETE ADJACENT DUPLICATES FROM lt_1705 COMPARING objid.

*"----------------------------------------------------------------------
* 과목/학년별 통계

  CLEAR: lt_stat[], lt_stat.
  LOOP AT lt_wish.
    READ TABLE lt_1705 WITH KEY objid = lt_wish-st_id BINARY SEARCH.
    IF sy-subrc = 0.
      lt_stat-rwin = lt_1705-regwindow.
    ENDIF.
    lt_stat-appc = 1.
    lt_stat-code = lt_wish-se_short. COLLECT lt_stat.
    CLEAR: lt_stat.
  ENDLOOP.
  SORT lt_stat BY code rwin.
  DELETE lt_stat WHERE code IS INITIAL.

*"----------------------------------------------------------------------
* 신청수 계산

  LOOP AT lt_stat WHERE code = i_short. "FILTER(2차)
    CASE lt_stat-rwin.
      WHEN '1'.
        g_appc1 = lt_stat-appc.
      WHEN '2'.
        g_appc2 = lt_stat-appc.
      WHEN '3'.
        g_appc3 = lt_stat-appc.
      WHEN '4'.
        g_appc4 = lt_stat-appc.
    ENDCASE.
    ADD lt_stat-appc TO g_appca.
  ENDLOOP.

*"----------------------------------------------------------------------
* 쿼터 계산

  DEFINE set_diff.
    g_kapz&1 = gt_evob-kapz&1. "쿼터조정(&1)
    g_kapz&2 = 0.
    g_kapz&3 = 0.
    g_kapz&4 = 0.
    IF gt_evob-kapz&2 > 0. "쿼터조정(&2)
      g_kapz&2 = gt_evob-kapz&2 - gt_evob-kapz&1.
    ENDIF.
    IF gt_evob-kapz&3 > 0. "쿼터조정(&3)
      IF gt_evob-kapz&2 > 0.
        g_kapz&3 = gt_evob-kapz&3 - gt_evob-kapz&2.
      ELSE.
        g_kapz&3 = gt_evob-kapz&3 - gt_evob-kapz&1.
      ENDIF.
    ENDIF.
    IF gt_evob-kapz&4 > 0. "쿼터조정(&4)
      g_kapz&4 = g_kapza - g_kapz&1 - g_kapz&2 - g_kapz&3.
    ENDIF.
  END-OF-DEFINITION.

  DEFINE set_carr.
    IF g_kapz&2 > 0 AND g_appc&1 < g_kapz&1. "여석Toss(&1->&2)
      g_kapz&2 = g_kapz&2 + g_kapz&1 - g_appc&1.
    ENDIF.
    IF g_kapz&3 > 0 AND g_appc&2 < g_kapz&2. "여석Toss(&2->&3)
      g_kapz&3 = g_kapz&3 + g_kapz&2 - g_appc&2.
    ENDIF.
    IF g_kapz&4 > 0 AND g_appc&3 < g_kapz&3. "여석Toss(&3->&4)
      g_kapz&4 = g_kapz&4 + g_kapz&3 - g_appc&3.
    ENDIF.
  END-OF-DEFINITION.

*  IF g_kapza < gt_evob-kapz1. g_kapza = gt_evob-kapz1. ENDIF.
*  IF g_kapza < gt_evob-kapz2. g_kapza = gt_evob-kapz2. ENDIF.
*  IF g_kapza < gt_evob-kapz3. g_kapza = gt_evob-kapz3. ENDIF.
*  IF g_kapza < gt_evob-kapz4. g_kapza = gt_evob-kapz4. ENDIF.
*  CASE gt_evob-perid.
*    WHEN '011' OR '021'. "계절학기(그대로)
*      g_kapz1 = gt_evob-kapz1.
*      g_kapz2 = gt_evob-kapz2.
*      g_kapz3 = gt_evob-kapz3.
*      g_kapz4 = gt_evob-kapz4.
*
*    WHEN '010'. "1학기(2-3-4-1순)
*      set_diff: 2 3 4 1.
*      set_carr: 2 3 4 1.
*
*    WHEN '020'. "2학기(1-2-3-4순)
*      set_diff: 1 2 3 4.
*      set_carr: 1 2 3 4.
*
*  ENDCASE.
  SELECT SINGLE * FROM hrp9551
     INTO @DATA(ls_9551)
     WHERE plvar = '01'
       AND otype = 'SE'
       AND istat = '1'
       AND objid = @gt_evob-seobjid
       AND begda <= @gv_begda
       AND endda >= @gv_begda. "학사력100

  g_kapz1 = ls_9551-book_kapz1.
  g_kapz2 = ls_9551-book_kapz2.
  g_kapz3 = ls_9551-book_kapz3.
  g_kapz4 = ls_9551-book_kapz4.
  g_kapza = g_kapz1 + g_kapz2 + g_kapz3 + g_kapz4.

*"----------------------------------------------------------------------
* 경쟁률 계산
*  DEFINE set_rate.
*    CLEAR: lv_rate, g_rate&1.
*    IF g_kapz&1 > 0.
*      lv_rate = g_appc&1 / g_kapz&1.
*      IF lv_rate > 0.
*        g_rate&1 = lv_rate.
*        CONDENSE g_rate&1.
**(1:0.3 -> 0.3:1로 변경 2019.11.07(feat.최석형)
**       CONCATENATE `1 : ` g_rate&1 INTO g_rate&1.
*        CONCATENATE g_rate&1 ` : 1` INTO g_rate&1.
*        IF g_rate&1+0(1) = '.'. CONCATENATE `0` g_rate&1 INTO g_rate&1. ENDIF.
**)
*      ELSE.
*        g_rate&1 = '신청없음'.
*      ENDIF.
*    ELSE.
*      g_rate&1 = '쿼터없음'.
*    ENDIF.
*  END-OF-DEFINITION.
*
*  set_rate: a,1,2,3,4.
  PERFORM get_rate USING g_appc1 g_kapz1
                   CHANGING g_rate1.

  PERFORM get_rate USING g_appc2 g_kapz2
                   CHANGING g_rate2.

  PERFORM get_rate USING g_appc3 g_kapz3
                   CHANGING g_rate3.

  PERFORM get_rate USING g_appc4 g_kapz4
                   CHANGING g_rate4.

  PERFORM get_rate USING g_appca g_kapza
                   CHANGING g_ratea.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  get_rate
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_rate USING pv_appc
                    pv_kapz
              CHANGING pv_rate.

  CLEAR pv_rate.

  IF pv_kapz IS INITIAL.
    pv_rate = '쿼터없음'.
    RETURN.

  ENDIF.

  DATA lv_rt TYPE zcgpa.
  lv_rt = pv_appc / pv_kapz.

* 학사지원팀,20250207, 0.001의 경우에만 소수점3째자리에서 무조건 올림
  IF lv_rt IS INITIAL.
*   Perform division and shift 3 decimal places
    DATA lv_temp TYPE p LENGTH 6 DECIMALS 3.
    lv_temp = ( pv_appc / pv_kapz ) * 100.
    lv_temp = ceil( lv_temp ).

    lv_rt = lv_temp / 100.
  ENDIF.

  IF lv_rt > 0.
    pv_rate = lv_rt && ` : 1`.
  ELSE.
    pv_rate = '신청없음'.

  ENDIF.

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
    WHEN '010'.
      p_perid = '021'. p_peryr = p_peryr - 1.
    WHEN '011'.
      p_perid = '010'.
    WHEN '020'.
      p_perid = '011'.
    WHEN '021'.
      p_perid = '020'.
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
    WHEN '010'.
      p_perid = '011'.
    WHEN '011'.
      p_perid = '020'.
    WHEN '020'.
      p_perid = '021'.
    WHEN '021'.
      p_perid = '010'. p_peryr = p_peryr + 1.
  ENDCASE.

ENDFORM.                    " SET_NEXT_PERIOD
*&---------------------------------------------------------------------*
*&      Form  check_proc_continue
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_proc_continue USING $answer $ztext1 $ztext2.

  DATA: l_defaultoption, l_textline1(70),  l_textline2(70).

  CLEAR: $answer.

  l_defaultoption = 'N'.
  l_textline1     = $ztext1.
  l_textline2     = $ztext2.

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
*&      Form  SET_PROGRESS
*&---------------------------------------------------------------------*
FORM set_progress USING p_cur_cnt.

  DATA: lv_msg TYPE string, c(5),t(5).
  c = p_cur_cnt. t = gv_tot. CONDENSE: c, t.
  CONCATENATE c ` / ` t INTO lv_msg.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = lv_msg
    EXCEPTIONS
      OTHERS = 0.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_BUFFER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_buffer .

*  CALL FUNCTION 'SAPTUNE_RESET_BUFFER'
*    EXPORTING
*      buffername = 'TABL'
*    EXCEPTIONS
*      OTHERS     = 1.

ENDFORM.                    " SET_BUFFER
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
*&      Form  GET_EVOB
*&---------------------------------------------------------------------*
*       개설교과목 조회
*----------------------------------------------------------------------*
FORM get_evob.

  CHECK gt_evob[] IS INITIAL.

  gv_status_txt = |[조회] { p_peryr }학년도 { p_perid }학기 개설교과목|.
  PERFORM set_progtext USING gv_status_txt.
  CALL FUNCTION 'ZCM_GET_COURSE_DETAIL'
    EXPORTING
      i_peryr  = p_peryr
      i_perid  = p_perid
      i_stype  = '1'
      i_kword  = '30000002'
    TABLES
      e_course = gt_evob.

  LOOP AT gt_evob.
    CONCATENATE gt_evob-smshort '-' gt_evob-seshort
           INTO gt_evob-seshort.
    MODIFY gt_evob.
  ENDLOOP.
  SORT gt_evob BY seshort.

ENDFORM.                    " GET_EVOB
*&---------------------------------------------------------------------*
*&      Form  GET_DATE1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_date1 .

  CHECK lt_tlmts[] IS INITIAL.

  CALL FUNCTION 'ZCM_GET_TIMELIMITS'
    EXPORTING
      iv_o          = '30000002'
      iv_timelimit  = '0100' "표준학기
      iv_peryr      = p_peryr
      iv_perid      = p_perid
    IMPORTING
      et_timelimits = lt_tlmts.

  CLEAR: gv_begda, gv_endda.
  LOOP AT lt_tlmts INTO ls_tlmts.
    gv_begda = ls_tlmts-ca_lbegda.
    gv_endda = ls_tlmts-ca_lendda.
  ENDLOOP.

ENDFORM.                    " GET_DATE
*&---------------------------------------------------------------------*
*&      Form  GET_DATE3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_date3 .

  CHECK lt_tlmts[] IS INITIAL.

  CALL FUNCTION 'ZCM_GET_TIMELIMITS'
    EXPORTING
      iv_o          = '30000002'
      iv_timelimit  = '0300' "본수강신청
      iv_peryr      = p_peryr
      iv_perid      = p_perid
    IMPORTING
      et_timelimits = lt_tlmts.

  CLEAR: gv_begda, gv_endda.
  LOOP AT lt_tlmts INTO ls_tlmts.
    IF gv_begda IS INITIAL.
      gv_begda = ls_tlmts-ca_lbegda.
    ELSE.
      IF gv_begda > ls_tlmts-ca_lbegda.
        gv_begda = ls_tlmts-ca_lbegda.
      ENDIF.
    ENDIF.

    IF gv_endda IS INITIAL.
      gv_endda = ls_tlmts-ca_lendda.
    ELSE.
      IF gv_endda < ls_tlmts-ca_lendda.
        gv_endda = ls_tlmts-ca_lendda.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " GET_DATE
*&---------------------------------------------------------------------*
*&      Form  SET_STATS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_stats .

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        ls_fcat     TYPE slis_fieldcat_alv,
        lv_str      TYPE string.

  CHECK p_stp1 = 'X'. "담아놓기만
  MESSAGE '자세한 내역은 ZCMRA582 참고' TYPE 'I'.

  PERFORM get_data.
  CHECK gt_data[] IS NOT INITIAL.

  CLEAR: gt_stat[], gt_stat.
  LOOP AT gt_data.
    MOVE-CORRESPONDING gt_data TO gt_stat.
    gt_stat-stcnt = 1.
    IF gt_data-comp = 'X'.
      gt_stat-svcnt = 1.
    ENDIF.
    COLLECT gt_stat.
    CLEAR   gt_stat.
  ENDLOOP.

  LOOP AT gt_stat.
    SELECT COUNT(*)
      INTO gt_stat-total "재학생
      FROM hrp1705 AS a INNER JOIN hrp1702 AS b
                           ON b~plvar = a~plvar
                          AND b~otjid = a~otjid
                        INNER JOIN hrp9530 AS c
                           ON c~plvar = a~plvar
                          AND c~otjid = a~otjid
     WHERE a~plvar      = '01'
       AND a~otype      = 'ST'
       AND a~begda     <= gv_begda
       AND a~endda     >= gv_begda
       AND a~regwindow  = gt_stat-rgwin
       AND b~begda     <= gv_begda
       AND b~endda     >= gv_begda
       AND b~namzu      = 'A0' "학부
       AND b~titel      = 'A0' "정규생
       AND c~begda     <= gv_begda
       AND c~endda     >= gv_begda
       AND c~sts_cd     = '1000'. "재학

    CONCATENATE gt_stat-rgwin '학년' INTO gt_stat-rgwin.
    MODIFY gt_stat.
  ENDLOOP.

  CHECK gt_stat[] IS NOT INITIAL.
  SORT gt_stat BY rgwin.

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
      WHEN 'RGWIN'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '학년구분'.
        ls_fcat-key = 'X'.
      WHEN 'TOTAL'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '정규재학'.
        ls_fcat-do_sum = 'X'.
      WHEN 'STCNT'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '담기인원'.
        ls_fcat-do_sum = 'X'.
      WHEN 'SMCNT'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '담기과목'.
        ls_fcat-do_sum = 'X'.
      WHEN 'SVCNT'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '담기저장'.
        ls_fcat-do_sum = 'X'.
      WHEN OTHERS.
        ls_fcat-no_out = 'X'.
    ENDCASE.
    MODIFY lt_fieldcat FROM ls_fcat.
  ENDLOOP.

  CONCATENATE `수강신청 담아놓기 (` sy-datum ` ` sy-uzeit ` 기준)`
         INTO lv_str.
  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title       = lv_str
      i_tabname     = 'GT_STAT'
      it_fieldcat   = lt_fieldcat
    TABLES
      t_outtab      = gt_stat
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.

ENDFORM.                    " SET_STATS
*&---------------------------------------------------------------------*
*&      Form  GET_STOBJ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_stobj .

  CLEAR: s_stobj[], s_stobj.

  CHECK p_stp3 NE 'X'.

  IF p_stnum[] IS NOT INITIAL.
    SELECT DISTINCT objid AS low
      INTO CORRESPONDING FIELDS OF TABLE s_stobj
      FROM hrp1000
     WHERE plvar = '01'
       AND otype = 'ST'
       AND langu = '3'
       AND mc_short IN p_stnum.
    LOOP AT s_stobj.
      s_stobj-sign   = 'I'.
      s_stobj-option = 'EQ'.
      MODIFY s_stobj.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " GET_STOBJ
*&---------------------------------------------------------------------*
*&      Form  get_text_0101
*&---------------------------------------------------------------------*
FORM get_text_0101  USING    p_grp
                             p_com
                    CHANGING p_txt.

  "//__ASPN08 2024.02.20 :: SORT 구문 추가
  SORT gt_0101 BY grp_cd com_cd.
  READ TABLE gt_0101 WITH KEY grp_cd = p_grp
                              com_cd = p_com
                     BINARY SEARCH.
  IF sy-subrc IS INITIAL.
    p_txt = gt_0101-com_nm.
  ENDIF.

ENDFORM.                    " GET_TEXT_0101
*&---------------------------------------------------------------------*
*& Form excute_push_message
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM excute_push_message .

  PERFORM set_selected_grid_line(zcms11) TABLES gt_data
                                         USING g_grid 'XFLAG' 'M'.


  DATA: lt_pushlist TYPE TABLE OF zcms_pushlist WITH HEADER LINE.

  LOOP AT gt_data INTO DATA(ls_data) WHERE xflag = 'X'.
    lt_pushlist-rid = ls_data-short.
    APPEND lt_pushlist.
  ENDLOOP.

  CHECK lt_pushlist[] IS NOT INITIAL.

  CALL FUNCTION 'ZCM_SEND_PUSH_WITH_SCREEN'
    EXPORTING
      iv_uname    = sy-uname
      iv_test     = 'X'
    TABLES
      it_pushlist = lt_pushlist[].


ENDFORM.
