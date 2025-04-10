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
*  PERFORM DATA_GRID_SCREEN_CONTROL .
  DATA: ls_variant TYPE disvariant.
  CLEAR: ls_variant.
  ls_variant-report = sy-repid.

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
    CASE ls_fcat-fieldname.
      WHEN 'TYPE'.         ls_fcat-col_pos = 01. ls_fcat-coltext = '타입'.
      WHEN 'MESSAGE'.      ls_fcat-col_pos = 02. ls_fcat-coltext = '점검내역'.
*     WHEN 'OBJID'.        ls_fcat-col_pos = 03. ls_fcat-coltext = 'ST'.
      WHEN 'SHORT'.        ls_fcat-col_pos = 04. ls_fcat-coltext = '학번'.
      WHEN 'STEXT'.        ls_fcat-col_pos = 05. ls_fcat-coltext = '성명'.
*     WHEN 'SC_OBJID1'.    ls_fcat-col_pos = 06. ls_fcat-coltext = 'SC1'.
*     WHEN 'SC_SHORT1'.    ls_fcat-col_pos = 07. ls_fcat-coltext = '1전공'.
*     WHEN 'O_OBJID'.      ls_fcat-col_pos = 08. ls_fcat-coltext = 'O'.
*     WHEN 'STS_CD'.       ls_fcat-col_pos = 09. ls_fcat-coltext = '학적상태'.
      WHEN 'STS_CDT'.      ls_fcat-col_pos = 10. ls_fcat-coltext = '학적상태'.
*     WHEN 'BEGDA'.        ls_fcat-col_pos = 11. ls_fcat-coltext = '변동일자'.
*     WHEN 'NATIO'.        ls_fcat-col_pos = 12. ls_fcat-coltext = '국적'.
      WHEN 'READMIT'.      ls_fcat-col_pos = 13. ls_fcat-coltext = '재입학'.
      WHEN 'REGWINDOW'.    ls_fcat-col_pos = 14. ls_fcat-coltext = '수강학년'.
      WHEN 'REGSEMSTR'.    ls_fcat-col_pos = 15. ls_fcat-coltext = '수강학기'.
      WHEN 'BOOK_CDT'.     ls_fcat-col_pos = 16. ls_fcat-coltext = '수강학점'.
      WHEN 'RX_NOW'.       ls_fcat-col_pos = 17. ls_fcat-coltext = '금학기'.
      WHEN 'RC_TOTAL'.     ls_fcat-col_pos = 18. ls_fcat-coltext = '전체(ABC)'.
      WHEN 'RC_S1020'.     ls_fcat-col_pos = 19. ls_fcat-coltext = '정규(A)'.
      WHEN 'RC_S1121'.     ls_fcat-col_pos = 20. ls_fcat-coltext = '계절(B)'.
      WHEN 'RC_NOCNT'.     ls_fcat-col_pos = 21. ls_fcat-coltext = '제외(C)'.
      WHEN 'CC_EXPIRED'.   ls_fcat-col_pos = 22. ls_fcat-coltext = '만료(A≥8)'.
      WHEN 'CC_EXCEED'.    ls_fcat-col_pos = 23. ls_fcat-coltext = '초과(A-8)'.
      WHEN 'CC_REMAIN'.    ls_fcat-col_pos = 24. ls_fcat-coltext = '잔여(8-A)'.
      WHEN 'CC_RECOMMEND'. ls_fcat-col_pos = 25. ls_fcat-coltext = '보장(9-A)'.
      WHEN 'CC_UPDATE'.    ls_fcat-col_pos = 26. ls_fcat-coltext = '조정(*)'.
      WHEN 'P01'.          ls_fcat-col_pos = 27. ls_fcat-coltext = '01'.
      WHEN 'P02'.          ls_fcat-col_pos = 28. ls_fcat-coltext = '02'.
      WHEN 'P03'.          ls_fcat-col_pos = 29. ls_fcat-coltext = '03'.
      WHEN 'P04'.          ls_fcat-col_pos = 30. ls_fcat-coltext = '04'.
      WHEN 'P05'.          ls_fcat-col_pos = 31. ls_fcat-coltext = '05'.
      WHEN 'P06'.          ls_fcat-col_pos = 32. ls_fcat-coltext = '06'.
      WHEN 'P07'.          ls_fcat-col_pos = 33. ls_fcat-coltext = '07'.
      WHEN 'P08'.          ls_fcat-col_pos = 34. ls_fcat-coltext = '08'.
      WHEN 'P09'.          ls_fcat-col_pos = 35. ls_fcat-coltext = '09'.
      WHEN 'P10'.          ls_fcat-col_pos = 36. ls_fcat-coltext = '10'.
      WHEN 'P11'.          ls_fcat-col_pos = 37. ls_fcat-coltext = '11'.
      WHEN 'P12'.          ls_fcat-col_pos = 38. ls_fcat-coltext = '12'.
      WHEN 'P13'.          ls_fcat-col_pos = 39. ls_fcat-coltext = '13'.
      WHEN 'P14'.          ls_fcat-col_pos = 40. ls_fcat-coltext = '14'.
      WHEN 'P15'.          ls_fcat-col_pos = 41. ls_fcat-coltext = '15'.
      WHEN 'P16'.          ls_fcat-col_pos = 42. ls_fcat-coltext = '16'.
      WHEN 'P17'.          ls_fcat-col_pos = 43. ls_fcat-coltext = '17'.
      WHEN 'P18'.          ls_fcat-col_pos = 44. ls_fcat-coltext = '18'.
      WHEN 'P19'.          ls_fcat-col_pos = 45. ls_fcat-coltext = '19'.
      WHEN 'P20'.          ls_fcat-col_pos = 46. ls_fcat-coltext = '20'.
*     WHEN 'ADATANR'.      ls_fcat-col_pos = 47. ls_fcat-coltext = 'ADATANR'.
*     WHEN 'TABSEQNR'.     ls_fcat-col_pos = 48. ls_fcat-coltext = 'TABSEQNR'.
      WHEN 'SEQNO'.        ls_fcat-col_pos = 49. ls_fcat-coltext = '전체연번'.
      WHEN 'SEQNO2'.       ls_fcat-col_pos = 50. ls_fcat-coltext = '조정연번'.
*      WHEN 'NO_CNT'.       ls_fcat-col_pos = 51. ls_fcat-coltext = '제외'.
      WHEN 'REPEATFG'.       ls_fcat-col_pos = 51. ls_fcat-coltext = '재이수 확정여부'.
      WHEN 'PIQPERYR'.     ls_fcat-col_pos = 52. ls_fcat-coltext = '학년도'.
      WHEN 'PIQPERID'.     ls_fcat-col_pos = 53. ls_fcat-coltext = '학기'.
      WHEN 'SM_ID'.        ls_fcat-col_pos = 54. ls_fcat-coltext = 'SM'.
      WHEN 'SM_IDT'.       ls_fcat-col_pos = 55. ls_fcat-coltext = '과목코드'.
      WHEN 'SM_IDX'.       ls_fcat-col_pos = 56. ls_fcat-coltext = '과목명'.
      WHEN 'REPERYR'.      ls_fcat-col_pos = 57. ls_fcat-coltext = '과거학년도'.
      WHEN 'REPERID'.      ls_fcat-col_pos = 58. ls_fcat-coltext = '과거학기'.
      WHEN 'RESMID'.       ls_fcat-col_pos = 59. ls_fcat-coltext = '과거SM'.
      WHEN 'REP_MODULET'.  ls_fcat-col_pos = 60. ls_fcat-coltext = '과거코드'.
      WHEN 'REP_MODULEX'.  ls_fcat-col_pos = 61. ls_fcat-coltext = '과거과목명'.
*     WHEN 'CON_GRD'.      ls_fcat-col_pos = 62. ls_fcat-coltext = '과거성적'. "미사용
*     WHEN 'CREDIT'.       ls_fcat-col_pos = 63. ls_fcat-coltext = '과거학점'. "미사용
*     WHEN 'REPEAT_NUM'.   ls_fcat-col_pos = 64. ls_fcat-coltext = '과목횟수'. "미사용
*     WHEN 'REPEAT_CD'.    ls_fcat-col_pos = 65. ls_fcat-coltext = '처리구분'. "미사용
*     WHEN 'DELAY_FG'.     ls_fcat-col_pos = 66. ls_fcat-coltext = '유예구분'. "미사용
      WHEN 'ERDAT'.        ls_fcat-col_pos = 67. ls_fcat-coltext = '조정일자'.
      WHEN 'ERTIM'.        ls_fcat-col_pos = 68. ls_fcat-coltext = '조정시간'.
      WHEN OTHERS.        ls_fcat-col_pos = 69. ls_fcat-no_out  = gc_set.
    ENDCASE.

    CLEAR: ls_fcat-key.
    IF ls_fcat-fieldname = 'TYPE' OR
       ls_fcat-fieldname = 'MESSAGE'.
      ls_fcat-emphasize = 'C300'.
    ENDIF.
    IF ls_fcat-fieldname = 'SHORT' OR
      ls_fcat-fieldname = 'SM_ID' OR
      ls_fcat-fieldname = 'REP_MODULE'.
      ls_fcat-hotspot = 'X'.
    ENDIF.
    IF ls_fcat-fieldname CP 'RC_*' OR
       ls_fcat-fieldname CP 'SEQNO*' OR
       ls_fcat-fieldname = 'REPEATFG'.
      ls_fcat-emphasize = 'C700'.
      ls_fcat-no_zero = 'X'.
    ENDIF.
    IF ls_fcat-fieldname CP 'CC_*'.
      ls_fcat-emphasize = 'C500'.
      ls_fcat-no_zero = 'X'.
    ENDIF.
    IF ls_fcat-fieldname = 'CC_UPDATE'.
      ls_fcat-do_sum = 'X'.
    ENDIF.
    IF ls_fcat-fieldname = 'ERTIM'.
      ls_fcat-no_zero = 'X'.
    ENDIF.
    IF ls_fcat-fieldname = 'CC_EXPIRED'  OR
       ls_fcat-fieldname = 'READMIT'  OR
       ls_fcat-fieldname = 'REPEATFG'.
      ls_fcat-checkbox = 'X'.
    ENDIF.
    IF ls_fcat-fieldname = 'REGWINDOW'  OR
       ls_fcat-fieldname = 'REGSEMSTR'  OR
       ls_fcat-fieldname = 'BOOK_CDT'.
      IF p_sel1 = 'X'.
        ls_fcat-no_out = 'X'.
      ENDIF.
    ENDIF.
    IF ls_fcat-fieldname = 'REPEATFG'.
      IF p_sel2 = 'X'.
        ls_fcat-no_out = 'X'.
      ENDIF.
    ENDIF.
    MODIFY pt_fieldcat FROM ls_fcat.
  ENDLOOP.

* 값 없는 필드는 자동으로 감추기...
  LOOP AT pt_fieldcat INTO ls_fcat.

    CHECK ls_fcat-fieldname <> 'TYPE'    AND
          ls_fcat-fieldname <> 'MESSAGE' AND
          ls_fcat-fieldname <> 'REPEATFG'.

    CLEAR: lv_str, lv_chk.
    CONCATENATE 'gt_data-' ls_fcat-fieldname INTO lv_str.
    LOOP AT gt_data.
      UNASSIGN <fs>.
      ASSIGN (lv_str) TO <fs>.
      IF <fs> IS ASSIGNED AND <fs> IS NOT INITIAL.
        lv_chk = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF lv_chk IS INITIAL.
      ls_fcat-no_out = 'X'.
    ENDIF.
    MODIFY pt_fieldcat FROM ls_fcat.
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

  CLEAR: gt_sort, gs_sort.
  gs_sort-up        = 'X'.
  gs_sort-spos      = 1.

  IF p_sel2 = 'X'.
    gs_sort-fieldname = 'TYPE'.     APPEND gs_sort TO gt_sort.
    gs_sort-fieldname = 'MESSAGE'.  APPEND gs_sort TO gt_sort.
  ENDIF.

  gs_sort-fieldname = 'SHORT'.     APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'STEXT'.     APPEND gs_sort TO gt_sort.
* gs_sort-fieldname = 'SC_SHORT1'. APPEND gs_sort TO gt_sort.
* gs_sort-fieldname = 'STS_CDT'.   APPEND gs_sort TO gt_sort.
* gs_sort-fieldname = 'BEGDA'.     APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'SEQNO'.     APPEND gs_sort TO gt_sort.

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

* 사용자의 권한조직 취득
*  PERFORM get_user_authorg.

  t_001 = icon_warning     && `기준일자에 "재학/휴학"인 학생이 조회대상`.
  t_002 = icon_warning     && `수강신청 대상학기 "ZCMRA250"을 먼저 세팅해야 함`.
  t_003 = icon_information && `[학칙개정] 정규학기 통산 8회까지 재이수 가능, 계절학기 제외 (2020.06.05)`.
  t_004 = icon_information && `9학기 이상은 매학기 "재이수 가능횟수" 1회연장 가능`.
  t_005 = icon_information && `8학기 이하는 학기수에 기반한 "초기세팅"만 가능`.

*  CONCATENATE icon_column_left  '' INTO sscrfields-functxt_01.
*  CONCATENATE icon_column_right '' INTO sscrfields-functxt_02.

  t_011 = `[재이수 가능횟수 강제추가]`.
  t_012 = icon_checked && `재이수 가능횟수 강제추가는 과거 정규학기부터 해야 함`.
  t_013 = icon_checked && `강제추가는 계절학기 과목에는 할 수 없음`.

  IF sy-sysid = 'UPS'.
    p_stnum-sign   = 'I'.
    p_stnum-option = 'CP'.
    p_stnum-low    = '2011*'.
    APPEND p_stnum.

    p_peryr = '2020'.
    p_perid = '020'.
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
    IF screen-name = 'P_KEYDA' OR
       screen-name = 'P_PERYR' OR
       screen-name = 'P_PERID'.
      screen-input = 0.
      MODIFY SCREEN.
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

  PERFORM chk_input.  "입력조건(필터)
  PERFORM get_stid12. "재적대상
  PERFORM get_adinfo. "추가정보
  PERFORM get_resubj. "재이수/실제이수내역
  PERFORM set_table.  "화면구성
  PERFORM set_cdata.  "상세내역
  PERFORM chk_error.  "점검내역(필터)

  DESCRIBE TABLE gt_data LINES gv_tot.
  IF gv_tot = 0.
    MESSAGE '조회된 데이터가 없습니다.' TYPE 'I'. STOP.
  ENDIF.

ENDFORM.                    " GET_DATA
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

* Data changed
* SET HANDLER g_event_receiver_grid->handle_data_changed FOR g_grid.

* Hotspot Click
  SET HANDLER g_event_receiver_grid->handle_hotspot_click FOR g_grid .

*  CALL METHOD g_grid->set_ready_for_input
*    EXPORTING
*      i_ready_for_input = 0.

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
*  CALL METHOD g_grid->register_edit_event
*    EXPORTING
*      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

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
  DATA: lv_otype TYPE otype.
  DATA: lv_seark TYPE seark.

  READ TABLE gt_data INDEX p_row.
  CASE p_column .
    WHEN 'SHORT'.
      PERFORM call_transaction_piqst00(zcmsubpool)
        USING gt_data-objid.

    WHEN 'SM_ID' OR 'REP_MODULE'.
      IF p_column = 'SM_ID'.
        lv_seark = gt_data-sm_id.
      ELSE.
        lv_seark = gt_data-resmid.
      ENDIF.

      CLEAR: bdcdata[], bdcdata.
      PERFORM bdc_dynpro USING 'SAPMH5A0'    '5000'.
      PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
      PERFORM bdc_field  USING 'PPHDR-PLVAR' '01'.
      PERFORM bdc_field  USING 'PPHDR-OTYPE' 'SM'.
      PERFORM bdc_field  USING 'PM0D1-SEARK' lv_seark.
      PERFORM bdc_dynpro USING 'SAPMH5A0'    '5000'.
      PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
      PERFORM bdc_field  USING 'PM0D1-TIMR6' 'X'.
      PERFORM bdc_field  USING 'PPHDR-BEGDA' '1800.01.01'.
      PERFORM bdc_field  USING 'PPHDR-ENDDA' '9999.12.31'.
      PERFORM bdc_dynpro USING 'SAPMH5A0'    '5000'.
      PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.

      session_name = sy-index.
      CALL FUNCTION 'ABAP4_CALL_TRANSACTION'
*        STARTING NEW TASK session_name
        DESTINATION 'NONE'
        EXPORTING
          tcode                   = 'PP01'
          skip_screen             = ' '
          mode_val                = 'E'
          update_val              = 'S'
        TABLES
          using_tab               = bdcdata
        EXCEPTIONS
          call_transaction_denied = 1
          tcode_invalid           = 2.

  ENDCASE.

ENDFORM.                    " DISPLAY_HOTSPOT_CLICK
*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  IF fval <> '/'. "nodata.
    CLEAR bdcdata.
    bdcdata-fnam = fnam.
    bdcdata-fval = fval.
    APPEND bdcdata.
  ENDIF.
ENDFORM.                    "BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  GRID_DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*      -->P_E_ONF4  text
*----------------------------------------------------------------------*
*FORM grid_data_changed
*        USING p_data_changed  TYPE REF TO cl_alv_changed_data_protocol
*              p_onf4          TYPE any.
*
*  LOOP AT p_data_changed->mt_good_cells INTO gs_mod_cells.
*    gt_data-edit = 'X'.
*    MODIFY gt_data INDEX gs_mod_cells-row_id
*                   TRANSPORTING (gs_mod_cells-fieldname) edit.
*  ENDLOOP.
*  PERFORM refresh_grid.
*
*ENDFORM.                    " GRID_DATA_CHANGED
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
        ls_timeinfo   TYPE zcms023.

  CALL FUNCTION 'ZCM_GET_TIMELIMITS'
    EXPORTING
      iv_o         = '30000002'
      iv_timelimit = '0100'
      iv_keydate   = sy-datum
      iv_adjust    = 90 "3달미리...
    IMPORTING
      et_timeinfo  = lt_hrtimeinfo.

  READ TABLE lt_hrtimeinfo INTO ls_timeinfo INDEX 1.
  IF sy-subrc = 0.
    MOVE ls_timeinfo-peryr TO p_peryr.
    MOVE ls_timeinfo-perid TO p_perid.
  ENDIF.

  CASE p_perid.
    WHEN '001' OR '011'. p_perid = '010'.
    WHEN '002' OR '021'. p_perid = '020'.
  ENDCASE.

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
  CALL FUNCTION 'ZCM_LIST_BOX_PYEAR_PERID2'
    EXPORTING
      year_field  = 'P_PERYR'
      perid_field = 'P_PERID'.

ENDFORM.                    " SET_PERID_BASIC
*&---------------------------------------------------------------------*
*&      Form  GET_KEYDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_keydate  USING v_peryr v_perid.

  DATA : lt_time TYPE piqtimelimits_tab,
         ls_time TYPE piqtimelimits.
  CLEAR: gv_begda, gv_endda.

  CALL FUNCTION 'ZCM_GET_TIMELIMITS'
    EXPORTING
      iv_o          = '30000002'
      iv_timelimit  = '0100'
      iv_peryr      = v_peryr
      iv_perid      = v_perid
    IMPORTING
      et_timelimits = lt_time.

  READ TABLE lt_time INTO ls_time INDEX 1.
  IF sy-subrc = 0.
    gv_begda = ls_time-ca_lbegda.
    gv_endda = ls_time-ca_lendda.
  ENDIF.

ENDFORM.                    " GET_KEYDATE
*&---------------------------------------------------------------------*
*&      Form  GET_STS_CDT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_sts_cdt.
  CASE gt_data-sts_cd.
    WHEN '1000'. gt_data-sts_cdt = '재학'.
    WHEN '2000'. gt_data-sts_cdt = '휴학'.
    WHEN '3000'. gt_data-sts_cdt = '제적'.
    WHEN '4000'. gt_data-sts_cdt = '수료'.
    WHEN '5000'. gt_data-sts_cdt = '졸업'.
    WHEN '6000'. gt_data-sts_cdt = '입학취소'.
  ENDCASE.
ENDFORM.                    " GET_STS_CDT
*&---------------------------------------------------------------------*
*&      Form  SET_PREV_PERIOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_prev_period .
*  CASE p_perid.
*    WHEN '010'. p_perid = '020'. p_peryr = p_peryr - 1.
*    WHEN '020'. p_perid = '010'.
*  ENDCASE.
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
*  CASE p_perid.
*    WHEN '010'. p_perid = '020'.
*    WHEN '020'. p_perid = '010'. p_peryr = p_peryr + 1.
*  ENDCASE.
ENDFORM.                    " SET_NEXT_PERIOD
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_selected_rows .

  CLEAR: gt_rows[], gt_rows.
  CALL METHOD g_grid->get_selected_rows
    IMPORTING
      et_index_rows = gt_rows.

ENDFORM.                    " GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  CHK_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chk_input .

  PERFORM set_progbar USING '입력조건'.

  CLEAR: p_stobj[], p_stobj.
  IF p_stnum[] IS NOT INITIAL.
    SELECT stobjid
      INTO p_stobj-low
      FROM cmacbpst
     WHERE student12 IN p_stnum.
      p_stobj-sign   = 'I'.
      p_stobj-option = 'EQ'.
      APPEND p_stobj.
    ENDSELECT.
    IF p_stobj[] IS INITIAL.
      MESSAGE '해당학번이 존재하지 않습니다.' TYPE 'S'. STOP.
    ENDIF.
  ENDIF.
  SORT p_stobj.
  DELETE ADJACENT DUPLICATES FROM p_stobj COMPARING low.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_PROGBAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_progbar USING p_txt.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = p_txt
    EXCEPTIONS
      OTHERS = 0.
ENDFORM.                    " SET_PROGBAR
*&---------------------------------------------------------------------*
*&      Form  SET_PROGCNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_progcnt.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = gv_cnt && ` / ` && gv_sel
    EXCEPTIONS
      OTHERS = 0.
ENDFORM.                    " SET_PROGCNT
*&---------------------------------------------------------------------*
*&      Form  GET_STID12
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_stid12 .

  PERFORM set_progbar USING '대상선택'.
  CLEAR: gt_data[], gt_data.
  SELECT a~objid a~sts_cd a~begda b~natio
    INTO CORRESPONDING FIELDS OF TABLE gt_data
    FROM hrp9530 AS a INNER JOIN hrp1702 AS b
                         ON b~plvar = a~plvar
                        AND b~otjid = a~otjid
   WHERE a~plvar   = '01'
     AND a~otype   = 'ST'
     AND a~objid  IN p_stobj "학번(필터)
     AND a~begda  <= p_keyda
     AND a~endda  >= p_keyda
     AND a~sts_cd IN ('1000','2000')
     AND b~begda  <= p_keyda
     AND b~endda  >= p_keyda
     AND b~namzu   = 'A0'    "학부생
     AND b~titel   = 'A0'.   "정규생
  SORT gt_data BY objid.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_P9562
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_resubj .

  CHECK gt_data[] IS NOT INITIAL.

  PERFORM set_progbar USING '재이수내역'.
  CLEAR: gt_copy[], gt_copy.
*--------------------------------------------------------------------*
*  SELECT *
*    INTO CORRESPONDING FIELDS OF TABLE gt_copy
*    FROM hrp9562 AS a INNER JOIN zcmt9562 AS b
*                         ON b~adatanr = a~adatanr
*     FOR ALL ENTRIES IN gt_data
*   WHERE a~plvar = '01'
*     AND a~otype = 'ST'
*     AND a~objid = gt_data-objid.
*  SORT gt_copy BY objid piqperyr piqperid sm_id.

  " AD506 버전으로 바꿈..
  SELECT b~objid AS st_id,
         b~sclas AS sm_otype,
         b~sobid AS sm_sobid,
         b~adatanr,
         a~smstatus,
         a~peryr AS piqperyr,
         a~perid AS piqperid,
         a~packnumber AS se_id,
         a~reperyr,
         a~reperid,
         a~resmid,
         a~reid,
         a~repeatfg,
         a~regwindow
    FROM hrpad506 AS a
   INNER JOIN hrp1001 AS b ON a~adatanr = b~adatanr
     FOR ALL ENTRIES IN @gt_data
   WHERE a~resmid IS NOT INITIAL
     AND a~smstatus IN ('01','02','03')
     AND b~plvar = '01'
     AND b~otype = 'ST'
     AND b~objid = @gt_data-objid
     AND b~subty = 'A506'
     AND b~sclas = 'SM'
     INTO TABLE @DATA(lt_resubj).

  LOOP AT lt_resubj ASSIGNING FIELD-SYMBOL(<fs_resubj>).
    gt_copy-objid     = <fs_resubj>-st_id.
    gt_copy-piqperyr  = <fs_resubj>-piqperyr.
    gt_copy-piqperid  = <fs_resubj>-piqperid.
    gt_copy-sm_id     = <fs_resubj>-sm_sobid.
    gt_copy-reperyr   = <fs_resubj>-reperyr.
    gt_copy-reperid   = <fs_resubj>-reperid.
    gt_copy-resmid    = <fs_resubj>-resmid.
    gt_copy-reid      = <fs_resubj>-reid.
    gt_copy-repeatfg  = <fs_resubj>-repeatfg.
    APPEND gt_copy. CLEAR gt_copy.
  ENDLOOP.

  SORT gt_copy BY objid piqperyr piqperid sm_id.

*--------------------------------------------------------------------*


  CHECK p_sel1 = 'X'.
  CHECK gt_copy[] IS NOT INITIAL.

  PERFORM set_progbar USING '실제이수(좌측)'.
  LOOP AT gt_copy. gt_copy-sobid = gt_copy-sm_id. MODIFY gt_copy. ENDLOOP.
  CLEAR: gt_ad506[], gt_ad506.
  SELECT a~objid b~peryr b~perid a~sobid b~packnumber
    INTO TABLE gt_ad506
    FROM hrp1001 AS a INNER JOIN hrpad506 AS b
                         ON b~adatanr = a~adatanr
     FOR ALL ENTRIES IN gt_copy
   WHERE a~plvar = '01'
     AND a~otype = 'ST'
     AND a~objid = gt_copy-objid "ST
     AND a~subty = 'A506'
     AND a~sobid = gt_copy-sobid "SM
     AND b~smstatus IN ('01','02','03') "취소아님
     AND b~peryr = gt_copy-piqperyr
     AND b~perid = gt_copy-piqperid.

  PERFORM set_progbar USING '실제이수(우측)'.
  LOOP AT gt_copy. gt_copy-sobid = gt_copy-resmid. MODIFY gt_copy. ENDLOOP.

*//__13.11.2024 09:38:20__EDIT__//
  SELECT a~objid b~peryr b~perid a~sobid b~packnumber
    APPENDING TABLE gt_ad506
    FROM hrp1001 AS a INNER JOIN hrpad506 AS b
                         ON b~adatanr = a~adatanr
     FOR ALL ENTRIES IN gt_copy
   WHERE a~plvar = '01'
     AND a~otype = 'ST'
     AND a~objid = gt_copy-objid "ST
     AND a~subty = 'A506'
     AND a~sobid = gt_copy-sobid "SM
     AND b~smstatus IN ('01','02','03') "취소아님
     AND b~peryr = gt_copy-reperyr
     AND b~perid = gt_copy-reperid.


  SORT gt_ad506 BY objid peryr perid smobj.
  DELETE ADJACENT DUPLICATES FROM gt_ad506 COMPARING ALL FIELDS.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_table .

  DATA: lv_objid  TYPE hrobjid, "ST
        lv_seqno  TYPE i,       "전체연번
        lv_seqno2 TYPE i.       "조정연번

  PERFORM set_progbar USING '화면구성'.
  CASE 'X'.
    WHEN p_sel1. "재이수내역 조회
      LOOP AT gt_copy.
* 연번
        IF lv_objid <> gt_copy-objid. CLEAR: lv_seqno, lv_seqno2. ENDIF.
        ADD 1 TO lv_seqno. "전체연번(+1)
        IF gt_copy-repeatfg = 'X'.
          ADD 1 TO lv_seqno2. "조정연번(+1)
        ENDIF.
        gt_copy-seqno  = lv_seqno.
        gt_copy-seqno2 = lv_seqno2.
* 학생정보
        READ TABLE gt_data WITH KEY objid = gt_copy-objid BINARY SEARCH.
        IF sy-subrc = 0.
          gt_copy-sts_cd = gt_data-sts_cd.
          gt_copy-begda  = gt_data-begda.
          gt_copy-natio  = gt_data-natio.
        ENDIF.
* 변경로그
        READ TABLE gt_ta261 WITH KEY objid    = gt_copy-objid
                                     piqperyr = gt_copy-piqperyr
                                     piqperid = gt_copy-piqperid
                                     sm_id    = gt_copy-sm_id
                                     BINARY SEARCH.
        IF sy-subrc = 0.
          gt_copy-peryr = gt_ta261-peryr.
          gt_copy-perid = gt_ta261-perid.
          gt_copy-erdat = gt_ta261-erdat.
          gt_copy-ertim = gt_ta261-ertim.
        ENDIF.

        lv_objid = gt_copy-objid. "직전ST
        MODIFY gt_copy. CLEAR gt_copy.
      ENDLOOP.
      CLEAR: gt_data[], gt_data.
      gt_data[] = gt_copy[]. "스와핑...
      CLEAR: gt_copy[], gt_copy.

    WHEN p_sel2. "재이수횟수 점검
      LOOP AT gt_data.
* 재이수정보
        READ TABLE gt_copy WITH KEY objid = gt_data-objid BINARY SEARCH.
        IF sy-subrc = 0.
          LOOP AT gt_copy FROM sy-tabix.
            IF gt_copy-objid <> gt_data-objid. EXIT. ENDIF. "/////
            IF gt_copy-repeatfg = ''.
              ADD 1 TO gt_data-rc_nocnt. "제외(+1)
            ELSE.
              CASE gt_copy-piqperid.
                WHEN '010' OR '020'. ADD 1 TO gt_data-rc_s1020. "정규(+1)
                WHEN OTHERS.         ADD 1 TO gt_data-rc_s1121. "계절(+1)
              ENDCASE.
            ENDIF.
            ADD 1 TO gt_data-rc_total. "전체(+1)
*(금학기추가
            IF gt_copy-piqperyr = p_peryr AND
               gt_copy-piqperid = p_perid.
              ADD 1 TO gt_data-rx_now. "금학기(+1)옵션
            ENDIF.
*)
          ENDLOOP.
        ENDIF.

* 변경로그
        READ TABLE gt_ta261 WITH KEY objid = gt_data-objid BINARY SEARCH.
        IF sy-subrc = 0.
          gt_data-peryr = gt_ta261-peryr.
          gt_data-perid = gt_ta261-perid.
          gt_data-erdat = gt_ta261-erdat.
          gt_data-ertim = gt_ta261-ertim.
        ENDIF.

        MODIFY gt_data. CLEAR gt_data.
      ENDLOOP.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_CDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_cdata .

  PERFORM set_progbar USING '상세내역'.
  LOOP AT gt_data.
* 학생정보
    READ TABLE gt_1000 WITH KEY objid = gt_data-objid BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data-short = gt_1000-short.
      gt_data-stext = gt_1000-stext.
    ENDIF.

* 수강학기
    READ TABLE gt_1705 WITH KEY objid = gt_data-objid BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data-regwindow = gt_1705-regwindow.
      gt_data-regsemstr = gt_1705-regsemstr.
      gt_data-book_cdt  = gt_1705-book_cdt.
      IF gt_data-regsemstr IS INITIAL.
        gt_data-regsemstr = '01'. "PRD에 있으면 안됨...
      ENDIF.
    ENDIF.

* 재입학여부
    READ TABLE gt_9530 WITH KEY objid = gt_data-objid BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data-readmit = 'X'.
    ENDIF.

* 학적상태
    CASE gt_data-sts_cd.
      WHEN '1000'. gt_data-sts_cdt = '재학'.
      WHEN '2000'. gt_data-sts_cdt = '휴학'.
    ENDCASE.

* 전공정보
*    READ TABLE gt_majr WITH KEY st_objid = gt_data-objid BINARY SEARCH.
*    IF sy-subrc = 0.
*      gt_data-sc_objid1 = gt_majr-sc_objid1.
*      gt_data-sc_short1 = gt_majr-sc_short1.
*      gt_data-o_objid   = gt_majr-o_objid.
*    ENDIF.

* 과목정보
    PERFORM get_smstext USING gt_data-piqperyr
                              gt_data-piqperid
                              gt_data-sm_id
                     CHANGING gt_data-sm_idt
                              gt_data-sm_idx.
    PERFORM get_smstext USING gt_data-reperyr
                              gt_data-reperid
                              gt_data-resmid
                     CHANGING gt_data-rep_modulet
                              gt_data-rep_modulex.

    MODIFY gt_data. CLEAR gt_data.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_message USING p_typ p_msg.
  IF gt_data-type IS INITIAL.
    gt_data-type    = p_typ.
    gt_data-message = p_msg.
  ELSE.
    IF p_typ = 'E'.
      gt_data-type = p_typ.
    ENDIF.
    gt_data-message = gt_data-message && `, ` && p_msg.
  ENDIF.
  REPLACE '】,' IN gt_data-message WITH '】'. "/////
ENDFORM.
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
        lv_selec    TYPE slis_selfield.
  DATA: lv_idx TYPE numc2.

  CLEAR: gt_stats[], gt_stats.
  LOOP AT gt_data.
    IF gt_data-regsemstr IS INITIAL.
      gt_data-regsemstr = '01'. "PRD에 있으면 안됨...
    ENDIF.
    gt_stats-regsemstr = gt_data-regsemstr.
    CASE gt_data-cc_remain.
      WHEN 0. gt_stats-r0 = 1.
      WHEN 1. gt_stats-r1 = 1.
      WHEN 2. gt_stats-r2 = 1.
      WHEN 3. gt_stats-r3 = 1.
      WHEN 4. gt_stats-r4 = 1.
      WHEN 5. gt_stats-r5 = 1.
      WHEN 6. gt_stats-r6 = 1.
      WHEN 7. gt_stats-r7 = 1.
      WHEN 8. gt_stats-r8 = 1.
    ENDCASE.
    gt_stats-rt = 1.
    COLLECT gt_stats.
    CLEAR   gt_stats.
  ENDLOOP.

*(빈학기 채우기[01-18]: 2020.08.10 김상현
  CLEAR: lv_idx.
  DO 18 TIMES.
    ADD 1 TO lv_idx.
    READ TABLE gt_stats WITH KEY regsemstr = lv_idx.
    IF sy-subrc <> 0.
      CLEAR gt_stats.
      gt_stats-regsemstr = lv_idx.
      APPEND gt_stats.
    ENDIF.
  ENDDO.
*)

  CHECK gt_stats[] IS NOT INITIAL.
  SORT gt_stats BY regsemstr DESCENDING.

  CLEAR: lt_fieldcat[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'GT_STATS'
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
      WHEN 'REGSEMSTR'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '학기'.
        ls_fcat-outputlen = 5.
        ls_fcat-key = 'X'.
      WHEN 'R0'.
        ls_fcat-reptext_ddic = '만료'.
        ls_fcat-outputlen = 6.
        ls_fcat-do_sum = 'X'.
        ls_fcat-no_zero = 'X'.
      WHEN 'R1'.
        ls_fcat-reptext_ddic = '1회'.
        ls_fcat-outputlen = 6.
        ls_fcat-do_sum = 'X'.
        ls_fcat-no_zero = 'X'.
      WHEN 'R2'.
        ls_fcat-reptext_ddic = '2회'.
        ls_fcat-outputlen = 6.
        ls_fcat-do_sum = 'X'.
        ls_fcat-no_zero = 'X'.
      WHEN 'R3'.
        ls_fcat-reptext_ddic = '3회'.
        ls_fcat-outputlen = 6.
        ls_fcat-do_sum = 'X'.
        ls_fcat-no_zero = 'X'.
      WHEN 'R4'.
        ls_fcat-reptext_ddic = '4회'.
        ls_fcat-outputlen = 6.
        ls_fcat-do_sum = 'X'.
        ls_fcat-no_zero = 'X'.
      WHEN 'R5'.
        ls_fcat-reptext_ddic = '5회'.
        ls_fcat-outputlen = 6.
        ls_fcat-do_sum = 'X'.
        ls_fcat-no_zero = 'X'.
      WHEN 'R6'.
        ls_fcat-reptext_ddic = '6회'.
        ls_fcat-outputlen = 7.
        ls_fcat-do_sum = 'X'.
        ls_fcat-no_zero = 'X'.
      WHEN 'R7'.
        ls_fcat-reptext_ddic = '7회'.
        ls_fcat-outputlen = 7.
        ls_fcat-do_sum = 'X'.
        ls_fcat-no_zero = 'X'.
      WHEN 'R8'.
        ls_fcat-reptext_ddic = '8회'.
        ls_fcat-outputlen = 7.
        ls_fcat-do_sum = 'X'.
        ls_fcat-no_zero = 'X'.
      WHEN 'RT'.
        ls_fcat-reptext_ddic = '소계'.
        ls_fcat-outputlen = 8.
        ls_fcat-do_sum = 'X'.
        ls_fcat-no_zero = 'X'.
        ls_fcat-emphasize = 'C300'.
      WHEN OTHERS.
        ls_fcat-no_out = 'X'.
    ENDCASE.
    MODIFY lt_fieldcat FROM ls_fcat.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title       = '수강학기별 잔여횟수 통계'
      i_tabname     = 'GT_STATS'
      it_fieldcat   = lt_fieldcat
    IMPORTING
      es_selfield   = lv_selec
    TABLES
      t_outtab      = gt_stats
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.

* 필터설정(단수)
*  CLEAR: gt_filt[], gs_filt.
*  IF lv_selec IS NOT INITIAL.
*    CHECK lv_selec-fieldname = 'TYPE' OR
*          lv_selec-fieldname = 'MESSAGE'.
*    gs_filt-fieldname = lv_selec-fieldname.
*    gs_filt-sign      = 'I'.
*    gs_filt-option    = 'EQ'.
*    gs_filt-low       = lv_selec-value.
*    APPEND gs_filt TO gt_filt.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_STATS2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_stats2 .

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        ls_fcat     TYPE slis_fieldcat_alv,
        lv_selec    TYPE slis_selfield.

  CLEAR: gt_stats2[], gt_stats2.
  LOOP AT gt_data.
    MOVE-CORRESPONDING gt_data TO gt_stats2.
    IF gt_data-erdat IS INITIAL.
      ADD 1 TO gt_stats2-cnt1. "미연장
    ELSE.
      ADD 1 TO gt_stats2-cnt2. "연장완료
    ENDIF.
    gt_stats2-count = 1.
    COLLECT gt_stats2.
    CLEAR   gt_stats2.
  ENDLOOP.

  CHECK gt_stats2[] IS NOT INITIAL.
  SORT gt_stats2.

  CLEAR: lt_fieldcat[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'GT_STATS2'
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
      WHEN 'TYPE'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '타입'.
        ls_fcat-outputlen = 6.
        ls_fcat-key = 'X'.
      WHEN 'MESSAGE'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '비고'.
        ls_fcat-outputlen = 30.
        ls_fcat-do_sum = 'X'.
      WHEN 'CNT1'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '미연장'.
        ls_fcat-outputlen = 10.
        ls_fcat-do_sum = 'X'.
      WHEN 'CNT2'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '연장완료'.
        ls_fcat-outputlen = 10.
        ls_fcat-do_sum = 'X'.
      WHEN 'COUNT'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '소계'.
        ls_fcat-outputlen = 10.
        ls_fcat-do_sum = 'X'.
        ls_fcat-emphasize = 'C300'.
      WHEN OTHERS.
        ls_fcat-no_out = 'X'.
    ENDCASE.
    MODIFY lt_fieldcat FROM ls_fcat.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title       = '점검내역 통계'
      i_tabname     = 'GT_STATS2'
      it_fieldcat   = lt_fieldcat
    IMPORTING
      es_selfield   = lv_selec
    TABLES
      t_outtab      = gt_stats2
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.

* 필터설정(단수)
*  CLEAR: gt_filt[], gs_filt.
*  IF lv_selec IS NOT INITIAL.
*    CHECK lv_selec-fieldname = 'TYPE' OR
*          lv_selec-fieldname = 'MESSAGE'.
*    gs_filt-fieldname = lv_selec-fieldname.
*    gs_filt-sign      = 'I'.
*    gs_filt-option    = 'EQ'.
*    gs_filt-low       = lv_selec-value.
*    APPEND gs_filt TO gt_filt.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_ADINFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_adinfo .

  PERFORM set_progbar USING '변경로그'.
  CLEAR: gt_ta261[], gt_ta261.
  SELECT * INTO TABLE gt_ta261 FROM zcmta261.
  IF p_sel1 = 'X'.
    SORT gt_ta261 BY objid piqperyr piqperid sm_id.
  ELSE.
    SORT gt_ta261 BY objid ASCENDING erdat DESCENDING ertim DESCENDING.
  ENDIF.

  CHECK gt_data[] IS NOT INITIAL. "//////////

*  PERFORM set_progbar USING '전공정보'.
*  CLEAR: gt_stob[], gt_stob.
*  LOOP AT gt_data.
*    gt_stob-objid = gt_data-objid. APPEND gt_stob.
*  ENDLOOP.
*  DELETE ADJACENT DUPLICATES FROM gt_stob COMPARING objid.
*  CLEAR: gt_majr[], gt_majr.
*  CALL FUNCTION 'ZCM_GET_STUDENT_MAJOR_MULTI'
*    EXPORTING
*      i_langu    = '3'
*    TABLES
*      it_student = gt_stob
*      et_major   = gt_majr.
*  SORT gt_majr BY st_objid.

  PERFORM set_progbar USING '학번/성명'.
  CLEAR: gt_1000[], gt_1000.
  SELECT objid short stext
    INTO CORRESPONDING FIELDS OF TABLE gt_1000
    FROM hrp1000
     FOR ALL ENTRIES IN gt_data
   WHERE plvar  = '01'
     AND otype  = 'ST'
     AND objid  = gt_data-objid
     AND langu  = '3'
     AND begda <= p_keyda "sy-datum
     AND endda >= p_keyda."sy-datum.
  SORT gt_1000 BY objid.

  PERFORM set_progbar USING '수강학년'.
  CLEAR: gt_1705[], gt_1705.
  SELECT objid regwindow book_cdt regsemstr
    INTO CORRESPONDING FIELDS OF TABLE gt_1705
    FROM hrp1705
     FOR ALL ENTRIES IN gt_data
   WHERE plvar  = '01'
     AND otype  = 'ST'
     AND objid  = gt_data-objid
     AND begda <= p_keyda "sy-datum
     AND endda >= p_keyda."sy-datum.
  SORT gt_1705 BY objid.

  PERFORM set_progbar USING '재입학'.
  CLEAR: gt_9530[], gt_9530.
  SELECT objid begda sts_cd sts_chng_cd
    INTO CORRESPONDING FIELDS OF TABLE gt_9530
    FROM hrp9530
     FOR ALL ENTRIES IN gt_data
   WHERE plvar  = '01'
     AND otype  = 'ST'
     AND objid  = gt_data-objid
     AND sts_cd = '1000'
     AND sts_chng_cd = '1300'. "재입학
  SORT gt_9530 BY objid.

  CHECK p_sel1 = 'X'. "//////////

  PERFORM set_progbar USING '과목코드'.
  CLEAR: mt_1000[], mt_1000.
  SELECT objid begda short stext
    INTO CORRESPONDING FIELDS OF TABLE mt_1000
    FROM hrp1000
   WHERE plvar  = '01'
     AND otype  = 'SM'
     AND langu  = '3'.
*    AND begda <= sy-datum
*    AND endda >= sy-datum.
  SORT mt_1000 BY objid begda.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_confirm USING p_msg.
  CLEAR: gv_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      textline1      = p_msg
      titel          = '확인'
      cancel_display = ' '
    IMPORTING
      answer         = gv_answer.
  IF gv_answer NE 'J'. "실행확인
    MESSAGE '실행이 중단되었습니다.' TYPE 'E'. EXIT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHK_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chk_error .

  DATA: lv_regsemstr TYPE i,
        lv_recommend TYPE i,
        lv_msg(100)  TYPE c.

  DATA lv_re_tot_cnt TYPE hrp9566-re_tot_cnt.

  CLEAR lv_re_tot_cnt.

*--------------------------------------------------------------------*
  "총 재이수 가능횟수
  SELECT SINGLE re_tot_cnt INTO lv_re_tot_cnt
         FROM hrp9566
         WHERE plvar = '01'
         AND   otype = 'O'
         AND   objid = '30000002'  " 학부
         AND   begda <= p_keyda
         AND   endda >= p_keyda.
  IF sy-subrc <> 0.
    lv_re_tot_cnt = 8.
  ENDIF.
*--------------------------------------------------------------------*

  PERFORM set_progbar USING '점검내역'.
  LOOP AT gt_data.

    CASE 'X'.
*----------------------------------------------------------------------*
      WHEN p_sel1. "재이수내역 조회
*        ADD 1 TO gv_cnt.
*        PERFORM set_progcnt.
        CLEAR: lv_msg.

* 실제이수(좌측)
        READ TABLE gt_ad506 WITH KEY objid = gt_data-objid
                                     peryr = gt_data-piqperyr
                                     perid = gt_data-piqperid
                                     smobj = gt_data-sm_id BINARY SEARCH.
        IF sy-subrc <> 0.
          lv_msg = `, 수강취소(좌측)`.
        ENDIF.

* 실제이수(우측)
        READ TABLE gt_ad506 WITH KEY objid = gt_data-objid
                                     peryr = gt_data-reperyr
                                     perid = gt_data-reperid
                                     smobj = gt_data-resmid BINARY SEARCH.
        IF sy-subrc <> 0.
          lv_msg = `, 수강취소(우측)`.
        ENDIF.

        IF lv_msg IS NOT INITIAL.
          lv_msg = `【과목없음】 ` && lv_msg+2.
          PERFORM set_message USING 'E' lv_msg.
        ENDIF.

*----------------------------------------------------------------------*
      WHEN p_sel2. "재이수횟수 점검
* 수강학기
        lv_regsemstr = gt_data-regsemstr. "(이수완료+1개념)

* 잔여횟수(실제)
*        gt_data-cc_remain = 8 - gt_data-rc_s1020. "(-)가능
        gt_data-cc_remain = lv_re_tot_cnt - gt_data-rc_s1020. "(-)가능
        PERFORM set_cutzero USING gt_data-cc_remain.

* 초과횟수
        gt_data-cc_exceed = gt_data-rc_s1020 - lv_re_tot_cnt. "(-)가능
        PERFORM set_cutzero USING gt_data-cc_exceed.

* 만료자
        IF gt_data-cc_remain = 0.
          gt_data-cc_expired = 'X'. "만료
          IF lv_regsemstr <= lv_re_tot_cnt. "8학기이하자 초기세팅 1회만...
*(오픈시에만 가능(20-2초기세팅)
*           lv_msg = `【사용만료】 ` && lv_regsemstr && `학기 (초기세팅)`.
*           PERFORM set_message USING 'R' lv_msg.
*           gt_data-cc_recommend = 9 - lv_regsemstr. "(-)없음
*On<->Off
            lv_msg = `【사용만료】 ` && lv_regsemstr && `학기 (연장불가)`.
            PERFORM set_message USING 'E' lv_msg.
            gt_data-cc_recommend = 0.
*)
          ELSE. "9학기이상자 매학기 1회부여...
            IF ( gt_data-peryr <> p_peryr OR gt_data-perid <> p_perid ) "AND->OR: 2021.08.19 김상현
               AND gt_data-rx_now = 0. "gv_processed <> 'X'. "2021.09.02 금학기없으면...
              PERFORM set_message USING 'R' `【사용만료】 9이상 (+1회가능)`.
              gt_data-cc_recommend = 1.
            ELSE.
              PERFORM set_message USING 'E' `【사용만료】 9이상 (연장불가)`.
              gt_data-cc_recommend = 0.
            ENDIF.
          ENDIF.
          IF gt_data-cc_recommend > 0. "추가함
            gt_data-cc_update = gt_data-cc_exceed + gt_data-cc_recommend. "조정대상(*)
          ENDIF.

* 만료아님
        ELSE.
          lv_recommend = 9 - lv_regsemstr. "(-)가능
          PERFORM set_cutzero USING lv_recommend.

          IF lv_recommend > gt_data-cc_remain.
*(오픈시에만 가능(20-2초기세팅)
*           lv_msg = `【학기초과】 ` && lv_regsemstr && `학기 (초기세팅)`.
*           PERFORM set_message USING 'R' lv_msg.
*           gt_data-cc_recommend = lv_recommend.
*On<->Off
            lv_msg = `【학기초과】 ` && lv_regsemstr && `학기 (연장불가)`.
            PERFORM set_message USING 'E' lv_msg.
*           gt_data-cc_recommend = lv_recommend. "재입학은 해줘야되나...★★★★★
*)
            IF gt_data-cc_recommend > 0. "추가함
              gt_data-cc_update = gt_data-cc_recommend - gt_data-cc_remain. "조정대상(*)
            ENDIF.
          ENDIF.

        ENDIF.

* 연장완료
*        IF gt_data-erdat IS NOT INITIAL.
*          WRITE gt_data-erdat USING EDIT MASK '____.__.__' TO lv_msg.
*          lv_msg = `【연장완료】 ` && lv_msg && ` 처리`.
*          PERFORM set_message USING 'S' lv_msg.
*        ENDIF.

*----------------------------------------------------------------------*
    ENDCASE.

    MODIFY gt_data. CLEAR gt_data.
  ENDLOOP.

* 점검대상만 조회(완료건은 포함)
  IF p_exp = 'X'.
    DELETE gt_data WHERE type IS INITIAL AND erdat IS INITIAL.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_XMARK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_xmark.

  DATA: lv_msg(100) TYPE c.
  DATA: lv_cnt TYPE i. "성공(로컬)

  CLEAR: gt_rows[], gv_sel, gv_cnt. "성공(전체)
  CALL METHOD g_grid->get_selected_rows
    IMPORTING
      et_index_rows = gt_rows.
  DESCRIBE TABLE gt_rows LINES gv_sel.

  IF gv_sel = 0.
    MESSAGE '라인(n)을 선택하세요.' TYPE 'E'.
  ENDIF.

  lv_msg = p_peryr && `-` && p_perid && ` 재이수 가능횟수를 연장하시겠습니까? [조정(*)수 만큼 업데이트]`.
  PERFORM set_confirm USING lv_msg.

  CLEAR: gv_sel.
  LOOP AT gt_rows INTO gs_rows.
    READ TABLE gt_data INDEX gs_rows-index.
    CHECK sy-subrc = 0.
    CHECK gt_data-type = 'R'. "대상만.
    PERFORM set_progcnt.
*----------------------------------------------------------------------*
    CLEAR: gt_data-type, gt_data-message.
    ADD 1 TO gv_sel. "학생수

* 재이수내역
    PERFORM get_t9562.

    CLEAR: lv_cnt.
    LOOP AT gt_zbooked.
      UPDATE hrpad506 SET repeatfg = '' WHERE id = gt_zbooked-id.

      CASE sy-dbcnt.
        WHEN 0. "변경없음
          PERFORM set_message USING 'E' '업데이트 실패(DC=0)'.
        WHEN 1. "정상
          COMMIT WORK.
          PERFORM set_ulog. "업데이트로그...
          ADD 1 TO gv_cnt. "성공(전체)
          ADD 1 TO lv_cnt. "성공(로컬)
        WHEN OTHERS. "비정상...
          ROLLBACK WORK.
          lv_msg = `업데이트 실패(DC=` && sy-dbcnt && `)`.
          PERFORM set_message USING 'E' lv_msg.
      ENDCASE.
    ENDLOOP.

* 결과확인
    IF sy-subrc = 0.
      IF gt_data-cc_update = lv_cnt.
        lv_msg = `업데이트 성공(` && lv_cnt && `건)`.
        PERFORM set_message USING 'S' lv_msg.
      ELSE.
        lv_msg = `업데이트 경고(` && gt_data-cc_update && `≠` && lv_cnt && `건)`.
        PERFORM set_message USING 'W' lv_msg.
      ENDIF.
    ELSE.
      PERFORM set_message USING 'E' '업데이트 실패(PK)'.
    ENDIF.
*----------------------------------------------------------------------*
    MODIFY gt_data INDEX gs_rows-index.
    CLEAR  gt_data.
  ENDLOOP.

* 최종메시지
  IF gv_cnt > 0.
    MESSAGE `업데이트 결과(` && gv_cnt && `건 / ` && gv_sel && `명) 반영됨` TYPE 'I'.
  ELSE.
    MESSAGE '업데이트 실패(변경없음)' TYPE 'I'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_XMARK2
*&---------------------------------------------------------------------*
* 강제연장
*----------------------------------------------------------------------*
FORM set_xmark2.

  DATA: lv_msg(100) TYPE c.
  DATA: lv_cnt TYPE i. "성공(로컬)

  CLEAR: gt_rows[], gv_sel, gv_cnt. "성공(전체)
  CALL METHOD g_grid->get_selected_rows
    IMPORTING
      et_index_rows = gt_rows.
  DESCRIBE TABLE gt_rows LINES gv_sel.

  IF gv_sel IS INITIAL OR
     gv_sel = 0 OR
     gv_sel > 1.
    MESSAGE '한 줄을 선택하세요.' TYPE 'E'.
  ENDIF.

  lv_msg = p_peryr && `-` && p_perid && ` 재이수 가능 횟수를 강제 추가 하시겠습니까?(학칙 기준무시)`.
  PERFORM set_confirm USING lv_msg.

  CLEAR: gv_sel.
  READ TABLE gt_rows INTO gs_rows INDEX 1.
  CHECK gs_rows IS NOT INITIAL.
  READ TABLE gt_data INDEX gs_rows-index.
  CHECK sy-subrc = 0.

* validation
  IF gt_data-piqperid = 011 OR gt_data-piqperid = 021.
    PERFORM set_message USING 'E' '[실패]계절학기 과목은 재이수 가능 횟수에 포함되지 않습니다.'.
    MODIFY gt_data INDEX gs_rows-index.
    EXIT.
  ENDIF.

  DATA lv_err(1).
  CLEAR lv_err.
  IF gt_data-type = 'E'.
    lv_err = 'X'.
    IF gt_data-message CP '*[사용만료]*' OR
       gt_data-message CP '*[학기초과]*'.
      CLEAR lv_err.
    ENDIF.
  ENDIF.
  IF lv_err IS NOT INITIAL.
    PERFORM set_message USING 'E' '재이수 가능 횟수를 증가할 수 없습니다.'.
    MODIFY gt_data INDEX gs_rows-index.
    EXIT.
  ENDIF.

*--------------------------------------------------------------------*
*//__13.11.2024 13:52:49__재이수 부분__//
  DATA ls_zbooked TYPE zv_piqmodbooked2.
  CLEAR ls_zbooked.
*  SELECT SINGLE *
*   INTO CORRESPONDING FIELDS OF ls_9562
*   FROM hrp9562 AS a INNER JOIN zcmt9562 AS b
*                        ON b~adatanr = a~adatanr
*  WHERE a~plvar = '01'
*    AND a~otype = 'ST'
*    AND a~objid = gt_data-objid "ST
*    AND b~adatanr  = gt_data-adatanr
*    AND b~tabseqnr = gt_data-tabseqnr
*    AND b~piqperyr = gt_data-piqperyr
*    AND b~piqperid = gt_data-piqperid
*    AND b~sm_id    = gt_data-sm_id
*    AND b~repeatyr = gt_data-repeatyr
*    AND b~repeatid = gt_data-repeatid
*    AND b~rep_module = gt_data-rep_module
*    AND b~no_cnt <> 'X'.
*  IF sy-subrc <> 0 OR ls_9562 IS INITIAL.
*    PERFORM set_message USING 'E' '재이수 가능 횟수를 증가할 수 없습니다.'.
*    MODIFY gt_data INDEX gs_rows-index.
*    EXIT.
*  ENDIF.

  SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_zbooked
         FROM zv_piqmodbooked2
         WHERE otype    = 'SM'
         AND   objid    = gt_data-sm_id
         AND   plvar    = '01'
         AND   sclas    = 'ST'
         AND   sobid    = gt_data-objid "ST
         AND   peryr    = gt_data-piqperyr
         AND   reperyr  = gt_data-reperyr
         AND   reperid  = gt_data-reperid
         AND   resmid   = gt_data-resmid
         AND   repeatfg = 'X'.

  IF sy-subrc <> 0 OR ls_zbooked IS INITIAL.
    PERFORM set_message USING 'E' '재이수 가능 횟수를 증가할 수 없습니다.'.
    MODIFY gt_data INDEX gs_rows-index.
    EXIT.
  ENDIF.
*--------------------------------------------------------------------*

*(validatiaon
  CHECK lv_err IS INITIAL.
  PERFORM chk_oldest_exception USING    ls_zbooked
                               CHANGING lv_err.
  IF lv_err IS NOT INITIAL.
    PERFORM set_message USING 'E' '과거 정규학기부터 조정이 가능합니다.'.
    MODIFY gt_data INDEX gs_rows-index.
    EXIT.
  ENDIF.
*)

*  ls_9562-no_cnt = 'X'.
*  MODIFY zcmt9562 FROM ls_9562. "업데이트

  ls_zbooked-repeatfg = ''.
  UPDATE hrpad506 SET repeatfg = ls_zbooked-repeatfg WHERE id = ls_zbooked-id.

  CLEAR: gt_data-type, gt_data-message.
  CASE sy-dbcnt.
    WHEN 0. "변경없음
      PERFORM set_message USING 'E' '업데이트 실패(DC=0)'.
    WHEN 1. "정상
      COMMIT WORK.
      PERFORM set_force_log USING ls_zbooked. "업데이트로그...
      PERFORM set_message USING 'S' '업데이트 성공'.
      " 재이수 부분 수정
      gt_data-repeatfg = ls_zbooked-repeatfg.

      lv_msg = ` 재이수횟수 점검(1:1)에서 실제 횟수가 늘어났는지 반드시 확인하세요.`.
      PERFORM set_confirm USING lv_msg.

    WHEN OTHERS. "비정상...
      ROLLBACK WORK.
      lv_msg = `업데이트 실패(DC=` && sy-dbcnt && `)`.
      PERFORM set_message USING 'E' lv_msg.
  ENDCASE.
  MODIFY gt_data INDEX gs_rows-index.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_T9562
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_t9562.

  DATA: lv_cnt TYPE i.
  CLEAR: gt_t9562[], gt_t9562.
  CLEAR: gt_zbooked[], gt_zbooked.

  CHECK gt_data-cc_update > 0. "매우중요/////

*--------------------------------------------------------------------*
*  SELECT *
*    INTO CORRESPONDING FIELDS OF TABLE gt_t9562
*    FROM hrp9562 AS a INNER JOIN zcmt9562 AS b
*                         ON b~adatanr = a~adatanr
*   WHERE a~plvar = '01'
*     AND a~otype = 'ST'
*     AND a~objid = gt_data-objid "ST
*     AND b~piqperid IN ('010','020') "정규학기
*     AND b~no_cnt <> 'X'.
*  SORT gt_t9562 ASCENDING BY piqperyr piqperid sm_id.
*
** 연번->업데이트대상
*  LOOP AT gt_t9562.
*    ADD 1 TO lv_cnt.
*    gt_t9562-credit = lv_cnt. "연번(CREDIT필드 활용)
*    MODIFY gt_t9562.
*  ENDLOOP.

* 삭제되지 않은 레코드는 모두 NO_CNT 업데이트됨
*  DELETE gt_t9562 WHERE credit > gt_data-cc_update. "이후삭제
*--------------------------------------------------------------------*
  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zbooked
           FROM zv_piqmodbooked2
           WHERE plvar = '01'
           AND   sobid = gt_data-objid
           AND   perid IN ('010','020') "정규학기
           AND   repeatfg = 'X'. " 재이수 확정

  SORT gt_zbooked ASCENDING BY peryr perid objid.

* 연번->업데이트대상
  LOOP AT gt_zbooked.
    ADD 1 TO lv_cnt.
    gt_zbooked-seqnr = lv_cnt. "연번(CREDIT필드 활용)
    MODIFY gt_zbooked. CLEAR gt_zbooked.
  ENDLOOP.

*  삭제되지 않은 레코드는 모두 no_cnt 업데이트됨
  DELETE gt_zbooked WHERE seqnr > gt_data-cc_update. "이후삭제

*--------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_ULOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_ulog.

*  CLEAR: gs_ta261.
*  SELECT SINGLE *
*    INTO gs_ta261
*    FROM zcmta261
*   WHERE objid    = gt_data-objid "ST
*     AND piqperyr = gt_t9562-piqperyr
*     AND piqperid = gt_t9562-piqperid
*     AND sm_id    = gt_t9562-sm_id.
*  IF sy-subrc = 0.
*    gs_ta261-aenam = sy-uname.
*    gs_ta261-aedat = sy-datum.
*    gs_ta261-aetim = sy-uzeit.
*  ELSE.
*    MOVE-CORRESPONDING gt_t9562 TO gs_ta261.
*    gs_ta261-objid = gt_data-objid.
*    gs_ta261-peryr = p_peryr. "참고(수강학년도)
*    gs_ta261-perid = p_perid. "참고(수강학기)
*    gs_ta261-ernam = sy-uname.
*    gs_ta261-erdat = sy-datum.
*    gs_ta261-ertim = sy-uzeit.
*  ENDIF.
*  gs_ta261-no_cnt = 'X'.
*  MODIFY zcmta261 FROM gs_ta261.

  CLEAR: gs_ta261.

  gs_ta261-piqperyr  = gt_zbooked-peryr.
  gs_ta261-piqperid  = gt_zbooked-perid.
  gs_ta261-sm_id     = gt_zbooked-objid.
  IF gt_zbooked-repeatfg = 'X'.
    gs_ta261-no_cnt    = ''.
  ELSE.
    gs_ta261-no_cnt    = 'X'.
  ENDIF.
  gs_ta261-adatanr   = gt_zbooked-adatanr.
  gs_ta261-tabseqnr  = ''.
  gs_ta261-objid  = gt_data-objid.
  gs_ta261-peryr  = p_peryr. "참고(수강학년도)
  gs_ta261-perid  = p_perid. "참고(수강학기)
  gs_ta261-no_cnt = 'X'.
  gs_ta261-ernam  = sy-uname.
  gs_ta261-erdat  = sy-datum.
  gs_ta261-ertim  = sy-uzeit.
  MODIFY zcmta261 FROM gs_ta261.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_ULOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_force_log USING ps_zbooked TYPE zv_piqmodbooked2.

  DATA ls_zcmta261 TYPE zcmta261.
  CLEAR ls_zcmta261.
*  MOVE-CORRESPONDING ps_9562 TO ls_zcmta261.

  gs_ta261-piqperyr  = ps_zbooked-peryr.
  gs_ta261-piqperid  = ps_zbooked-perid.
  gs_ta261-sm_id     = ps_zbooked-objid.
  IF ps_zbooked-repeatfg = 'X'.
    gs_ta261-no_cnt    = ''.
  ELSE.
    gs_ta261-no_cnt    = 'X'.
  ENDIF.

  ls_zcmta261-objid  = ps_zbooked-sobid.
  ls_zcmta261-peryr  = p_peryr. "참고(수강학년도)
  ls_zcmta261-perid  = p_perid. "참고(수강학기)
  ls_zcmta261-no_cnt = 'X'.
  ls_zcmta261-force  = 'X'.
  ls_zcmta261-ernam  = sy-uname.
  ls_zcmta261-erdat  = sy-datum.
  ls_zcmta261-ertim  = sy-uzeit.
  MODIFY zcmta261 FROM ls_zcmta261.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_SMSTEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_smstext USING p_year p_sess p_id CHANGING p_tx p_ltx.

  CHECK p_year IS NOT INITIAL.
  CHECK p_sess IS NOT INITIAL.
  CHECK p_id   IS NOT INITIAL.

  DATA: lv_keyda TYPE datum.
  CASE p_sess. "별로 좋아하는 방법은 아니지만... 이해해!
    WHEN '010'. lv_keyda = p_year && '0401'.
    WHEN '011'. lv_keyda = p_year && '0630'.
    WHEN '020'. lv_keyda = p_year && '1001'.
    WHEN '021'. lv_keyda = p_year && '1231'.
  ENDCASE.

  READ TABLE mt_1000 WITH KEY objid = p_id BINARY SEARCH.
  IF sy-subrc = 0.
    LOOP AT mt_1000 FROM sy-tabix.
      IF mt_1000-objid <> p_id. EXIT. ENDIF.
      IF mt_1000-begda > lv_keyda. EXIT. ENDIF.
      p_tx  = mt_1000-short.
      p_ltx = mt_1000-stext.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_CUTZERO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_cutzero USING p_val.
  IF p_val < 0.
    CLEAR p_val.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_PROCESSED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_processed .

* 심플하게 RX_NOW 필드를 활용: 2021.09.02 김상현
* why?여러 대상자중 1명만 처리하고 나중에 하려는 경우 처리불가
*
** 금학기 처리자 존재여부
** 9학기이상 만료자를 중복처리(+1,+1)하면 안되므로: 2020.08.24 김상현
** ex) 대상 만료자 +1회처리 후, 수강신청 끝나면 다른 만료자가 나오는데
**     이 학생들을 +1하면 안되므로...
**
**  CLEAR: gv_processed.
**  CHECK p_sel2 = 'X'.
**
**  LOOP AT gt_data WHERE regsemstr BETWEEN '09' AND '99' "9학기이상
**                    AND peryr = p_peryr  "처리학년도
**                    AND perid = p_perid. "처리학기
**    gv_processed = 'X'.
**    EXIT.
**  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHK_OLDEST_EXCEPTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM chk_oldest_exception USING    ps_zbooked TYPE zv_piqmodbooked2
                           CHANGING pv_err.

  CHECK pv_err IS INITIAL.

*//__13.11.2024 13:54:08__재이수 부분__//

  DATA lv_piqperyr TYPE zcmt9562-piqperyr.

  CLEAR lv_piqperyr.

  SELECT MIN( peryr )
    INTO lv_piqperyr
    FROM zv_piqmodbooked2
   WHERE adatanr = ps_zbooked-adatanr
     AND perid NOT IN ( '011', '021' )
     AND repeatfg = 'X'.

  IF sy-subrc = 0.
    IF lv_piqperyr <> ps_zbooked-peryr.
*     oldest 정규학기가 아님
      pv_err = 'X'.
    ENDIF.

  ELSE.
    pv_err = 'X'.

  ENDIF.

ENDFORM.
