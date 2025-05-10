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

  CALL METHOD g_grid->set_table_for_first_display
    EXPORTING
      is_layout       = gs_layout
*     IT_TOOLBAR_EXCLUDING = GT_FCODE
      i_save          = 'X' "'A'
      i_default       = 'X'
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
         ff          TYPE lvc_s_fcat,
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

  LOOP AT pt_fieldcat INTO ff.
    CASE 'X'.
      WHEN p_sum.
        CASE ff-fieldname.
          WHEN 'STNUM'.      ff-col_pos = 01. ff-coltext = '학번'.
          WHEN 'STNAM'.      ff-col_pos = 02. ff-coltext = '성명'.
*         WHEN 'STOBJ'.      ff-col_pos = 03. ff-coltext = 'ST'.
          WHEN 'TUI_A'.      ff-col_pos = 04. ff-coltext = '[T]고지서학점'.
*         WHEN 'TUI4A'.      ff-col_pos = 05. ff-coltext = '[T]과목수'.
          WHEN 'ZREAL'.      ff-col_pos = 06. ff-coltext = '납부대상'.
          WHEN 'ZREA1'.      ff-col_pos = 07. ff-coltext = '실납부액'.
          WHEN 'CPT_A'.      ff-col_pos = 08. ff-coltext = '[A]최초학점'.
*         WHEN 'CPT4A'.      ff-col_pos = 09. ff-coltext = '[A]과목수'.
          WHEN 'CPT_B'.      ff-col_pos = 10. ff-coltext = '[B]취소학점'.
*         WHEN 'CPT4B'.      ff-col_pos = 11. ff-coltext = '[B]과목수'.
          WHEN 'CPT_C'.      ff-col_pos = 12. ff-coltext = '[C]현재학점'.
*         WHEN 'CPT4C'.      ff-col_pos = 13. ff-coltext = '[C]과목수'.
          WHEN 'STORL'.      ff-col_pos = 14. ff-coltext = '최종취소일'.
          WHEN 'AMT_B'.      ff-col_pos = 15. ff-coltext = '환불금액'.
          WHEN 'REMRK'.      ff-col_pos = 16. ff-coltext = '점검내역'.
          WHEN OTHERS.       ff-no_out  = gc_set.
        ENDCASE.
      WHEN p_raw.
        CASE ff-fieldname.
*         WHEN 'PERYR'.      ff-col_pos = 01. ff-coltext = '학년도'.
*         WHEN 'PERID'.      ff-col_pos = 02. ff-coltext = '학기'.
          WHEN 'STNUM'.      ff-col_pos = 03. ff-coltext = '학번'.
          WHEN 'STNAM'.      ff-col_pos = 04. ff-coltext = '성명'.
          WHEN 'SMNUM'.      ff-col_pos = 05. ff-coltext = '과목코드'.
          WHEN 'SMNAM'.      ff-col_pos = 06. ff-coltext = '과목명'.
          WHEN 'CPATTEMP'.   ff-col_pos = 07. ff-coltext = '학점'.
          WHEN 'SMSTATUS'.   ff-col_pos = 08. ff-coltext = '상태'.
          WHEN 'STORREASON'. ff-col_pos = 09. ff-coltext = '취소사유'.
          WHEN 'STORDATE'.   ff-col_pos = 10. ff-coltext = '취소일자'.
          WHEN 'STORTIME'.   ff-col_pos = 11. ff-coltext = '취소시간'.
          WHEN 'ERNAM'.      ff-col_pos = 12. ff-coltext = '작업자'.
          WHEN 'BOOKDATE'.   ff-col_pos = 13. ff-coltext = '신청일자'.
          WHEN 'BOOKTIME'.   ff-col_pos = 14. ff-coltext = '신청시간'.

*         WHEN 'ALT_SCALEID'.ff-col_pos = 14. ff-coltext = '스케일'.
*         WHEN 'STOBJ'.      ff-col_pos = 15. ff-coltext = 'ST'.
*         WHEN 'SMOBJ'.      ff-col_pos = 16. ff-coltext = 'SM'.
*         WHEN 'PACKNUMBER'. ff-col_pos = 17. ff-coltext = 'SE'.
*         WHEN 'ID'.         ff-col_pos = 18. ff-coltext = 'ID'.
*         WHEN 'ADATANR'.    ff-col_pos = 19. ff-coltext = 'ADATANR'.
          WHEN OTHERS.       ff-no_out  = gc_set.
        ENDCASE.
    ENDCASE.

    IF ff-fieldname = 'STNUM'.
      ff-hotspot = 'X'.
    ENDIF.

    CASE ff-fieldname.
      WHEN 'STNUM' OR 'STNAM'.
        ff-emphasize = 'C411'.
      WHEN 'SMSTATUS' OR 'STORREASON' OR 'STORDATE' OR 'STORTIME' OR 'ERNAM'.
        ff-emphasize = 'C300'.
      WHEN 'TUI_A' OR 'TUI4A' OR 'ZREAL' OR 'ZREA1'.
        ff-emphasize = 'C500'.
      WHEN 'CPT_A' OR 'CPT4A' OR 'CPT_B' OR 'CPT4B' OR 'STORL' OR
           'CPT_C' OR 'CPT4C' OR 'AMT_B'.
        ff-emphasize = 'C300'.
    ENDCASE.

    CASE ff-fieldname.
      WHEN 'ZREAL' OR 'ZREA1' OR 'AMT_B'.
        ff-cfieldname = 'CURRENCY'.
        ff-currency   = 'KRW'.
    ENDCASE.

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

  CLEAR: gt_sort, gs_sort.

  gs_sort-up        = 'X'.
  gs_sort-spos      = 1.
  gs_sort-fieldname = 'PERYR'. APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'PERID'. APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'STNUM'. APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'STNAM'. APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'SMNUM'. APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'SMNAM'. APPEND gs_sort TO gt_sort.

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
*&      Form  SYNC_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proc_data .
  CALL METHOD g_grid->get_selected_rows
    IMPORTING
      et_index_rows = gt_rows.

  IF NOT gt_rows[] IS INITIAL.
    LOOP AT gt_rows INTO gs_rows.
      READ TABLE gt_data INDEX gs_rows-index.
*      IF gt_data-sync = 'X'.
*        CONTINUE.
*      ENDIF.

*      UPDATE adrp
*         SET name_last  = gt_data-tar_name
*             name_text  = gt_data-tar_name
*             mc_namefir = gt_data-tar_name
*       WHERE persnumber = gt_data-persnumber.
*
*      gt_data-sync = 'X'.
      MODIFY gt_data INDEX gs_rows-index.
    ENDLOOP.

    MESSAGE '처리되었습니다.' TYPE 'S'.
  ENDIF.
ENDFORM.                    " SYNC_DATA
*&---------------------------------------------------------------------*
*&      Form  STR_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_TAR_ST_STEXT  text
*      <--P_gt_data_TAR_NAME  text
*----------------------------------------------------------------------*
FORM str_check  USING    p_str1
                CHANGING p_str2.

  CLEAR p_str2.
  CONDENSE p_str1 NO-GAPS.
  REPLACE ALL OCCURRENCES OF ',' IN p_str1 WITH ''.
  REPLACE ALL OCCURRENCES OF '-' IN p_str1 WITH ''.
  MOVE p_str1 TO p_str2.

ENDFORM.                    " STR_CHECK
*&---------------------------------------------------------------------*
*&      Form  org_f4_entry
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM org_f4_entry.

*  DATA: lt_zcmt0101 LIKE zcmt0101 OCCURS 0 WITH HEADER LINE.
*  DATA: lt_fields LIKE help_value OCCURS 0 WITH HEADER LINE.
*  DATA: BEGIN OF lt_f4 OCCURS 0,
*        objid  LIKE hrp9580-objid,
*        com_nm LIKE zcmt0101-com_nm,
*        END OF lt_f4.
*  DATA: lv_selectfield LIKE help_info-fieldname,
*        lv_selectvalue LIKE  help_info-fldvalue,
*        lv_idx       LIKE sy-tabix.
**
*  CLEAR: lv_selectvalue,lv_selectfield.
**
*  SELECT * INTO TABLE lt_zcmt0101
*           FROM zcmt0101
*           WHERE grp_cd = '100'.
*
*  SORT lt_zcmt0101 BY remark.
*
*  LOOP AT lt_zcmt0101.
*    lt_f4-objid  = lt_zcmt0101-map_cd2.
*    lt_f4-com_nm = lt_zcmt0101-com_nm.
*    APPEND lt_f4.
*    CLEAR  lt_f4.
*  ENDLOOP.
*  SORT lt_f4.
*
** 화면에서 읽기
*  CLEAR: lt_fields, lt_fields[].
*  lt_fields-tabname    = 'HRP9580'.
*  lt_fields-fieldname  = 'OBJID'.
*  lt_fields-selectflag = 'X'.
*  APPEND lt_fields.
*
*  CLEAR: lt_fields.
*  lt_fields-tabname    = 'ZCMT0101'.
*  lt_fields-fieldname  = 'COM_NM'.
*  lt_fields-selectflag = ' '.
*  APPEND lt_fields.
**
*  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
*    EXPORTING
*      selectfield                  = lv_selectfield
*    IMPORTING
*      ind                          = lv_idx
*      select_value                 = lv_selectvalue
*    TABLES
*      fields                       = lt_fields
*      full_table                   = lt_f4
*    EXCEPTIONS
*      full_table_empty             = 1
*      no_tablestructure_given      = 2
*      no_tablefields_in_dictionary = 3
*      more_then_one_selectfield    = 4
*      no_selectfield               = 5
*      OTHERS                       = 6.
*
*  CHECK NOT lv_idx IS INITIAL.
*  READ TABLE lt_f4 INDEX lv_idx.
**
*  p_orgcd = lt_f4-objid.

ENDFORM.                    " ORG_LIST_ENTRY
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
  PERFORM set_cancel_date.
  PERFORM set_p_strda. "취소일자

  CONCATENATE icon_biw_monitor
              `[1100]수업료 전액 환불/이월기간, `
              `[0330]수강과목 취소기간 `
              `학사력을 확인하세요.`
         INTO t_001.

*  IF sy-sysid = 'UPS'.
*    p_peryr = '2016'.
*    p_perid = '011'.
*  ENDIF.

ENDFORM.                    " INIT_PROC'
*&---------------------------------------------------------------------*
*&      Form  set_cancel_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_cancel_date.

  DATA: lt_times TYPE piqtimelimits_tab,
        ls_times TYPE piqtimelimits.

  CALL FUNCTION 'ZCM_GET_TIMELIMITS'
    EXPORTING
      iv_o          = '30000002'
      iv_timelimit  = '0330' "수강과목 취소기간
      iv_peryr      = p_peryr
      iv_perid      = p_perid
    IMPORTING
      et_timelimits = lt_times.

  READ TABLE lt_times INTO ls_times INDEX 1.
  IF sy-subrc = 0.
    gv_begda = ls_times-ca_lbegda.
    gv_endda = ls_times-ca_lendda.
  ENDIF.

  IF gv_begda IS INITIAL OR gv_endda IS INITIAL.
    MESSAGE '계절학기 수강과목 취소기간 학사력을 입력하세요.' TYPE 'I'.
    STOP.
  ENDIF.

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
  lv_keydate = sy-datum.

  CALL FUNCTION 'ZCM_GET_TIMELIMITS'
    EXPORTING
      iv_o         = '30000002'
      iv_timelimit = '0100'
      iv_keydate   = lv_keydate
    IMPORTING
      et_timeinfo  = lt_hrtimeinfo.

  READ TABLE lt_hrtimeinfo INTO ls_timeinfo INDEX 1.
  IF sy-subrc = 0.
    MOVE ls_timeinfo-peryr TO p_peryr.
    MOVE ls_timeinfo-perid TO p_perid.
  ENDIF.

  CASE p_perid.
    WHEN '010'. p_perid = '011'.
    WHEN '020'. p_perid = '021'.
  ENDCASE.

ENDFORM.                    " set_current_period
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
    IF screen-name = 'P_CANC' OR
       screen-name = 'P_BIGO'.
      IF p_sum = 'X'.
        screen-input = 1.
        MODIFY SCREEN.
      ELSE.
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

  DATA: lv_stordate TYPE datum,
        lv_checksum LIKE hrpad506-cpattemp.

  PERFORM set_range.

  CLEAR: gt_copy[], gt_copy.
  SELECT b~objid AS stobj
         b~sobid
         a~packnumber
         a~peryr
         a~perid
         a~smstatus
         a~storreason
         a~stordate
         a~bookdate
         a~booktime
         a~cpattemp
         a~alt_scaleid
         a~id
         b~adatanr
    INTO CORRESPONDING FIELDS OF TABLE gt_copy
    FROM hrpad506 AS a INNER JOIN hrp1001 AS b
                          ON b~adatanr = a~adatanr
                       INNER JOIN hrp1702 AS c
                          ON c~plvar = b~plvar
                         AND c~otjid = b~otjid
   WHERE a~peryr  = p_peryr
     AND a~perid  = p_perid
     AND a~stordate IN p_strda
     AND b~plvar  = '01'
     AND b~otype  = 'ST'
     AND b~objid IN s_stobj
     AND c~begda <= sy-datum
     AND c~endda >= sy-datum
     AND c~namzu  = 'A0'.


  CASE 'X'.
    WHEN p_sum. "///////////////////////////////////////////////////////

* 최초학점
      CLEAR: gt_data[], gt_data.
      gt_data[] = gt_copy[].
      DELETE gt_data WHERE smstatus = '04'
                       AND storreason NE gv_storr.
*                      AND stordate NOT BETWEEN gv_begda AND gv_endda.
* ↑날짜조건 모두주석처리

      CLEAR: gt_sumz[], gt_sumz.
      LOOP AT gt_data.
        gt_sumz-stobj = gt_data-stobj.
        gt_sumz-cpt_a = gt_data-cpattemp.
        gt_sumz-cpt4a = 1.
        gt_sumz-cpt_b = 0.
        gt_sumz-cpt_c = 0.
        gt_sumz-amt_b = 0.
        COLLECT gt_sumz.
      ENDLOOP.

* 취소학점
      CLEAR: gt_data[], gt_data.
      gt_data[] = gt_copy[].
      DELETE gt_data WHERE smstatus   NE '04'.
      DELETE gt_data WHERE storreason NE gv_storr.
*     DELETE gt_data WHERE stordate NOT BETWEEN gv_begda AND gv_endda.
* ↑날짜조건 모두주석처리
      SORT gt_data BY stobj stordate.

      LOOP AT gt_data.
        READ TABLE gt_sumz WITH KEY stobj = gt_data-stobj.
        IF sy-subrc = 0.
          ADD gt_data-cpattemp TO gt_sumz-cpt_b.
          ADD 1 TO gt_sumz-cpt4b.
          gt_sumz-storl = gt_data-stordate. "최종취소일
          MODIFY gt_sumz INDEX sy-tabix.
        ENDIF.
      ENDLOOP.

* 현재학점
      CLEAR: gt_data[], gt_data.
      gt_data[] = gt_copy[].
      DELETE gt_data WHERE smstatus = '04'.

      LOOP AT gt_data.
        READ TABLE gt_sumz WITH KEY stobj = gt_data-stobj.
        IF sy-subrc = 0.
          ADD gt_data-cpattemp TO gt_sumz-cpt_c.
          ADD 1 TO gt_sumz-cpt4c.
          MODIFY gt_sumz INDEX sy-tabix.
        ENDIF.
      ENDLOOP.

* 써머리
      CLEAR: gt_data[], gt_data.
      LOOP AT gt_sumz.
        MOVE-CORRESPONDING gt_sumz TO gt_data.
        gt_data-amt_b = gt_data-cpt_b * gv_amtpc. "학점당금액
        lv_checksum = gt_data-cpt_a - gt_data-cpt_b.
        IF lv_checksum NE gt_data-cpt_c.
          CONCATENATE gt_data-remrk `C≠A-B`
                 INTO gt_data-remrk SEPARATED BY space.
        ENDIF.
        READ TABLE gt_tuit WITH KEY objid = gt_data-stobj BINARY SEARCH.
        IF sy-subrc = 0.
          gt_data-tui_a = gt_tuit-cpattemp.
          gt_data-tui4a = gt_tuit-subct.
          gt_data-zreal = gt_tuit-zrealwr.
          gt_data-zrea1 = gt_tuit-zrealwr1.
        ENDIF.
        IF gt_data-tui_a NE gt_data-cpt_a.
          CONCATENATE gt_data-remrk `T≠A`
                 INTO gt_data-remrk SEPARATED BY space.
        ENDIF.
        APPEND gt_data.
        CLEAR  gt_data.
      ENDLOOP.

* 삭제옵션
      IF p_canc = 'X'.
        DELETE gt_data WHERE cpt_b IS INITIAL.
      ENDIF.
      IF p_bigo = 'X'.
        DELETE gt_data WHERE remrk IS INITIAL.
      ENDIF.

    WHEN p_raw. "///////////////////////////////////////////////////////

      CLEAR: gt_data[], gt_data.
      gt_data[] = gt_copy[].
      DELETE gt_data WHERE smstatus NE '04'.

      DELETE gt_data WHERE stordate BETWEEN p_strda-low AND p_strda-high.
*      DELETE gt_data WHERE storreason NE gv_storr.
*     DELETE gt_data WHERE stordate < gv_begda.
*     DELETE gt_data WHERE stordate > gv_endda.
* ↑날짜조건 모두주석처리

      LOOP AT gt_data.
        gt_data-smobj = gt_data-sobid.
        READ TABLE gt_course WITH KEY seobjid = gt_data-packnumber
                                      BINARY SEARCH.
        IF sy-subrc = 0.
          CONCATENATE gt_course-smshort '-'
                      gt_course-seshort INTO gt_data-smnum.
          gt_data-smnam = gt_course-smstext.
        ENDIF.

        lv_stordate = gt_data-stordate. "취소일자/시간
        SELECT b~key_date b~key_time UP TO 1 ROWS "시간추정치
          INTO (gt_data-stordate, gt_data-stortime)
          FROM piqproc_awcd AS a INNER JOIN piqproc_dh AS b
                                    ON b~docid = a~docid
         WHERE a~modreg_id = gt_data-id
         ORDER BY b~key_date DESCENDING
                  b~key_time DESCENDING.
        ENDSELECT.
        IF lv_stordate <> gt_data-stordate. "취소일자 다르면 시간삭제
          CLEAR: gt_data-stortime.
        ENDIF.
        MODIFY gt_data.
      ENDLOOP.

  ENDCASE.

* 최종데이터
  LOOP AT gt_data.
    PERFORM get_object USING 'ST' gt_data-stobj
                    CHANGING gt_data-stnum gt_data-stnam.
    MODIFY gt_data.
  ENDLOOP.

* 카운트
  DESCRIBE TABLE gt_data LINES gv_count.

  IF gt_data[] IS INITIAL.
    MESSAGE s001 WITH '조회된 데이터가 없습니다.'.
    STOP.
  ENDIF.

ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_EVOB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_evob .

  IF p_perid NE '011' AND p_perid NE '021'.
    MESSAGE '계절학기 전용프로그램 입니다.' TYPE 'I'.
    STOP.
  ENDIF.

  DATA: lt_times TYPE piqtimelimits_tab,
        ls_times TYPE piqtimelimits.

  CALL FUNCTION 'ZCM_GET_TIMELIMITS'
    EXPORTING
      iv_o          = '30000002'
      iv_timelimit  = '0330' "수강과목 취소기간
      iv_peryr      = p_peryr
      iv_perid      = p_perid
    IMPORTING
      et_timelimits = lt_times.

  READ TABLE lt_times INTO ls_times INDEX 1.
  IF sy-subrc = 0.
    gv_begda = ls_times-ca_lbegda.
    gv_endda = ls_times-ca_lendda.
  ENDIF.

  IF gv_begda IS INITIAL OR gv_endda IS INITIAL.
    MESSAGE '계절학기 수강과목 취소기간 학사력을 입력하세요.' TYPE 'I'.
    STOP.
  ENDIF.

  CLEAR: gt_course[], gt_course.
  CALL FUNCTION 'ZCM_GET_COURSE_DETAIL' "학부/대학원
    EXPORTING
      i_peryr  = p_peryr
      i_perid  = p_perid
*     i_stype  = '1'
*     i_kword  = '30000002'
    TABLES
      e_course = gt_course.

  SORT gt_course BY seobjid.

ENDFORM.                    " GET_EVOB
*&---------------------------------------------------------------------*
*&      Form  GET_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0908   text
*      -->P_GT_DATA_ST  text
*      <--P_GT_DATA_STNAM  text
*----------------------------------------------------------------------*
FORM get_object  USING    p_otype
                          p_objid
                 CHANGING p_short
                          p_stext.

  SELECT SINGLE short stext
    INTO (p_short, p_stext)
    FROM hrp1000
   WHERE plvar = '01'
     AND otype = p_otype
     AND objid = p_objid
     AND langu = '3'
     AND endda = '99991231'.

ENDFORM.                    " GET_OBJECT
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
    WHEN 'STNUM' .
      PERFORM call_transaction_piqst00(zcmsubpool)
        USING gt_data-stobj.
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

*  LOOP AT p_data_changed->mt_good_cells INTO gs_mod_cells.
*    gt_data-edit = 'X'.
*    MODIFY gt_data INDEX gs_mod_cells-row_id
*                   TRANSPORTING (gs_mod_cells-fieldname) edit.
*  ENDLOOP.

ENDFORM.                    " GRID_DATA_CHANGED
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
* Data changed
  SET HANDLER g_event_receiver_grid->handle_data_changed
                                     FOR g_grid.
* Hotspot Click
  SET HANDLER g_event_receiver_grid->handle_hotspot_click
                                     FOR g_grid .
  CALL METHOD g_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 0.

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
*&      Form  GET_TUIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_tuit .

  CLEAR: gt_tuit[], gt_tuit.
  SELECT *
    INTO TABLE gt_tuit
    FROM hrp9580
   WHERE plvar  = '01'
     AND otype  = 'ST'
     AND zperyr = p_peryr
     AND zperid = p_perid
     AND zstatus IN ('1','3'). "삭제,취소제외
  SORT gt_tuit BY objid zperyr zperid.

* 학점당금액
  SELECT SINGLE b~kbetr
    INTO gv_amtpc
    FROM a501 AS a INNER JOIN konp AS b
                      ON b~knumh = a~knumh
   WHERE a~kappl = 'CM'
     AND a~kschl = 'Z005'
     AND cmperyr = p_peryr
     AND cmperid = p_perid
     AND cmstcat = '1100'.

ENDFORM.                    " GET_TUIT
*&---------------------------------------------------------------------*
*&      Form  SET_RANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_range .

  IF p_stnum[] IS NOT INITIAL.
    s_stobj-sign = 'I'.
    s_stobj-option = 'EQ'.
    SELECT objid
      INTO s_stobj-low
      FROM hrp1000
     WHERE plvar  = '01'
       AND otype  = 'ST'
       AND begda <= sy-datum
       AND endda >= sy-datum
       AND short IN p_stnum
       AND langu  = '3'.
      APPEND s_stobj.
    ENDSELECT.
  ENDIF.

ENDFORM.                    " SET_RANGE
*&---------------------------------------------------------------------*
*& Form set_p_strda
*&---------------------------------------------------------------------*
*& set STORDATE in hrpad506 table using p_peryr and p_perid parameter
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_p_strda.

  CHECK p_peryr IS NOT INITIAL AND
        p_perid IS NOT INITIAL.

  CLEAR: p_strda[], p_strda.
  p_strda-sign = 'I'.
  p_strda-option = 'BT'.

  DATA lr_time TYPE RANGE OF piqtimelimit.
  lr_time = VALUE #( sign = 'I' option = 'EQ' ( low = '0300' ) ( low = '0310' ) ( low = '0320' ) ).

  CLEAR p_strda. "취소일자
  SELECT b~begda, b~endda
*    INTO (@p_strda-low, @p_strda-high)
    INTO TABLE @DATA(lt_strda)
    FROM hrp1750 AS a
   INNER JOIN hrt1750 AS b
           ON b~tabnr = a~tabnr
   WHERE a~plvar  = '01'
     AND a~otype  = 'CA'
     AND a~objid  = '20000000'    "학부
     AND a~istat  = 1
     AND a~infty  = '1750'
     AND a~peryr  = @p_peryr
     AND b~perid  = @p_perid
     AND b~timelimit IN @lr_time.

  SORT lt_strda BY endda DESCENDING begda DESCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_strda COMPARING endda begda.
  SORT lt_strda BY endda DESCENDING.
  READ TABLE lt_strda INTO DATA(ls_strda) INDEX 1.
  IF sy-subrc = 0.
    p_strda-low = ls_strda-begda + 1. "최종 수강신청 익일
    p_strda-high = p_strda-low + 30.  "최종 수강신청 익일 + 30일(한달)
  ENDIF.

  IF p_strda-low IS INITIAL OR p_strda-high IS INITIAL.
    p_strda-low = gv_begda. "수강취소기간(0330) 시작일
    p_strda-high = gv_endda. "수강취소기간(0330) 종료일

  ENDIF.

  APPEND p_strda.

ENDFORM.
