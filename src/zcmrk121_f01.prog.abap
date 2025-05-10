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
    CASE ls_fcat-fieldname.
      WHEN 'TYPE   '.       ls_fcat-col_pos = 01. ls_fcat-coltext = '타입'.
      WHEN 'MESSAGE'.       ls_fcat-col_pos = 02. ls_fcat-coltext = '메시지'.
      WHEN 'ORGCD'.         ls_fcat-col_pos = 03. ls_fcat-coltext = '소속'.
      WHEN 'ORGCX'.         ls_fcat-col_pos = 04. ls_fcat-coltext = '소속명'.
*     WHEN 'OBJID'.         ls_fcat-col_pos = 05. ls_fcat-coltext = 'ST'.
      WHEN 'SHORT'.         ls_fcat-col_pos = 06. ls_fcat-coltext = '학번'.
      WHEN 'STEXT'.         ls_fcat-col_pos = 07. ls_fcat-coltext = '성명'.
      WHEN 'SC1TX'.         ls_fcat-col_pos = 08. ls_fcat-coltext = '1전공'.
      WHEN 'SC2TX'.         ls_fcat-col_pos = 09. ls_fcat-coltext = '2전공'.
      WHEN 'SC3TX'.         ls_fcat-col_pos = 10. ls_fcat-coltext = '3전공'.
*     WHEN 'SC1ID'.         ls_fcat-col_pos = 11. ls_fcat-coltext = 'SC1'.
*     WHEN 'SC2ID'.         ls_fcat-col_pos = 12. ls_fcat-coltext = 'SC2'.
*     WHEN 'SC3ID'.         ls_fcat-col_pos = 13. ls_fcat-coltext = 'SC3'.
      WHEN 'STSCD'.         ls_fcat-col_pos = 14. ls_fcat-coltext = '학적상태(당시)'.
      WHEN 'STAT2'.         ls_fcat-col_pos = 15. ls_fcat-coltext = '졸업예정'.
      WHEN 'NAMZU'.         ls_fcat-col_pos = 16. ls_fcat-coltext = '학위과정'.
      WHEN 'TITEL'.         ls_fcat-col_pos = 17. ls_fcat-coltext = '학교구분'.
      WHEN 'NATIO'.         ls_fcat-col_pos = 18. ls_fcat-coltext = '국적'.
      WHEN 'PERYR'.         ls_fcat-col_pos = 19. ls_fcat-coltext = '학년도'.
      WHEN 'PERID'.         ls_fcat-col_pos = 20. ls_fcat-coltext = '학기'.
      WHEN 'REGWINDOW'.     ls_fcat-col_pos = 21. ls_fcat-coltext = '수강가능학년'.
      WHEN 'REGSEMSTR'.     ls_fcat-col_pos = 22. ls_fcat-coltext = '수강가능학기'.
      WHEN 'BOOK_CDT'.      ls_fcat-col_pos = 23. ls_fcat-coltext = '수강가능학점'.
      WHEN 'REGI_CDT' .     ls_fcat-col_pos = 24. ls_fcat-coltext = '학점등록신청'.
      WHEN 'BOOK_CNT'.      ls_fcat-col_pos = 25. ls_fcat-coltext = '수강과목'.
      WHEN 'FG_ZEROC'.      ls_fcat-col_pos = 26. ls_fcat-coltext = '(무학점)'.
      WHEN 'FG_TRANS'.      ls_fcat-col_pos = 27. ls_fcat-coltext = '(동등학위)'.
      WHEN 'FG_CU'.         ls_fcat-col_pos = 28. ls_fcat-coltext = '(CU)'.
      WHEN 'FG_CEXCN'.      ls_fcat-col_pos = 29. ls_fcat-coltext = '합산제외'.
      WHEN 'SMOBJID'.       ls_fcat-col_pos = 30. ls_fcat-coltext = 'SM'.
      WHEN 'SMSHORT'.       ls_fcat-col_pos = 31. ls_fcat-coltext = '과목코드'.
      WHEN 'SMSTEXT'.       ls_fcat-col_pos = 32. ls_fcat-coltext = '과목명'.
      WHEN 'CPATTEMP'.      ls_fcat-col_pos = 33. ls_fcat-coltext = '수강신청학점'.
      WHEN 'CUFG'.          ls_fcat-col_pos = 34. ls_fcat-coltext = 'CU과목'.
      WHEN 'SMSTATUS'.      ls_fcat-col_pos = 35. ls_fcat-coltext = '과목상태'.
      WHEN 'SCALEID'.       ls_fcat-col_pos = 36. ls_fcat-coltext = '과목스케일'.
      WHEN 'ALT_SCALEID'.   ls_fcat-col_pos = 37. ls_fcat-coltext = '수강스케일'.
      WHEN 'GRADESCALE'.    ls_fcat-col_pos = 38. ls_fcat-coltext = '평가스케일'.
      WHEN 'GRADESYM'.      ls_fcat-col_pos = 39. ls_fcat-coltext = '기말성적'.
*     WHEN 'GRADE'.         ls_fcat-col_pos = 39. ls_fcat-coltext = '성적등급'.
      WHEN 'EARN_CRD'.      ls_fcat-col_pos = 40. ls_fcat-coltext = '취득누계'.
      WHEN 'CGPA'.          ls_fcat-col_pos = 41. ls_fcat-coltext = '성적집계'.
*     WHEN 'CATEGORY'.      ls_fcat-col_pos = 42. ls_fcat-coltext = '범주'.
      WHEN 'MODREPEATTYPE'. ls_fcat-col_pos = 43. ls_fcat-coltext = '재수강유형'.
      WHEN 'TRANSFERFLAG'.  ls_fcat-col_pos = 44. ls_fcat-coltext = '동등학위'.
      WHEN 'LOCKFLAG'.      ls_fcat-col_pos = 45. ls_fcat-coltext = '변경잠금'.
      WHEN 'AGRNOTRATED'.   ls_fcat-col_pos = 46. ls_fcat-coltext = 'R처리'.
*     WHEN 'BOOKDATE'.      ls_fcat-col_pos = 47. ls_fcat-coltext = '신청일자'.
*     WHEN 'BOOKTIME'.      ls_fcat-col_pos = 48. ls_fcat-coltext = '신청시간'.
      WHEN 'AEDTM'.         ls_fcat-col_pos = 49. ls_fcat-coltext = '처리일자'.
      WHEN 'UNAME'.         ls_fcat-col_pos = 50. ls_fcat-coltext = '처리자'.
*     WHEN 'ID'.            ls_fcat-col_pos = 51. ls_fcat-coltext = 'ID'.
*     WHEN 'AGRID'.         ls_fcat-col_pos = 52. ls_fcat-coltext = 'AGRID'.
*     WHEN 'SOBID'.         ls_fcat-col_pos = 53. ls_fcat-coltext = 'SOBID'.
      WHEN 'OBJID1'.        ls_fcat-col_pos = 54. ls_fcat-coltext = '대체1'.
      WHEN 'OBJID2'.        ls_fcat-col_pos = 55. ls_fcat-coltext = '대체2'.
      WHEN 'OBJID3'.        ls_fcat-col_pos = 56. ls_fcat-coltext = '대체3'.
      WHEN 'OBJID4'.        ls_fcat-col_pos = 57. ls_fcat-coltext = '대체4'.
      WHEN 'OBJID5'.        ls_fcat-col_pos = 58. ls_fcat-coltext = '대체5'.
      WHEN 'P9562'.         ls_fcat-col_pos = 59. ls_fcat-coltext = '재이수처리'.
      WHEN 'PEXCT'.         ls_fcat-col_pos = 60. ls_fcat-coltext = '예외처리'.
      WHEN 'SESSION'.       ls_fcat-col_pos = 61. ls_fcat-coltext = '학기당'.
      WHEN 'MODULE'.        ls_fcat-col_pos = 62. ls_fcat-coltext = '과목당'.
      WHEN '2PERYR'.        ls_fcat-col_pos = 63. ls_fcat-coltext = '최근학년도'.
      WHEN '2PERID'.        ls_fcat-col_pos = 64. ls_fcat-coltext = '최근학기'.
*     WHEN '2PACKNUMBER'.   ls_fcat-col_pos = 65. ls_fcat-coltext = 'SE'.
      WHEN '2SMOBJID'.      ls_fcat-col_pos = 66. ls_fcat-coltext = 'SM'.
      WHEN '2SMSHORT'.      ls_fcat-col_pos = 67. ls_fcat-coltext = '과목코드'.
      WHEN '2SMSTEXT'.      ls_fcat-col_pos = 68. ls_fcat-coltext = '과목명'.
      WHEN '2CPATTEMP'.     ls_fcat-col_pos = 69. ls_fcat-coltext = '학점'.
      WHEN '2GRADESYM'.     ls_fcat-col_pos = 70. ls_fcat-coltext = '기말성적'.
*     WHEN '2GRADE'.        ls_fcat-col_pos = 71. ls_fcat-coltext = '성적등급'.
      WHEN '2GRADESCALE'.   ls_fcat-col_pos = 72. ls_fcat-coltext = '평가스케일'.
      WHEN '2TRANSFERFLAG'. ls_fcat-col_pos = 73. ls_fcat-coltext = '동등학위'.
      WHEN '2AGRNOTRATED'.  ls_fcat-col_pos = 74. ls_fcat-coltext = 'R처리'.
      WHEN 'EMAIL'.         ls_fcat-col_pos = 75. ls_fcat-coltext = '이메일'.
      WHEN 'CELL'.          ls_fcat-col_pos = 76. ls_fcat-coltext = '휴대전화'.
      WHEN OTHERS.          ls_fcat-col_pos = 77. ls_fcat-no_out  = gc_set.
    ENDCASE.

    IF ls_fcat-fieldname = 'ORGCD' OR
       ls_fcat-fieldname = 'ORGCX' OR
       ls_fcat-fieldname = 'OBJID' OR
       ls_fcat-fieldname = 'SHORT' OR
       ls_fcat-fieldname = 'STEXT'.
      ls_fcat-key = 'X'.
    ENDIF.
    IF ls_fcat-fieldname = 'SHORT'    OR
       ls_fcat-fieldname = 'SMOBJID'  OR
       ls_fcat-fieldname = '2SMOBJID' OR
       ls_fcat-fieldname+0(5) = 'OBJID'.
      ls_fcat-hotspot = 'X'.
    ENDIF.
    IF ls_fcat-fieldname+0(1) = '2'  OR
       ls_fcat-fieldname = 'P9562'   OR
       ls_fcat-fieldname = 'PEXCT'   OR
       ls_fcat-fieldname = 'SESSION' OR
       ls_fcat-fieldname = 'MODULE'.
      ls_fcat-emphasize = 'C500'.
    ENDIF.
    IF ls_fcat-fieldname = 'TYPE' OR
       ls_fcat-fieldname = 'MESSAGE'.
      ls_fcat-emphasize = 'C300'.
    ENDIF.
    IF ls_fcat-fieldname = 'REGWINDOW' OR
       ls_fcat-fieldname = 'REGSEMSTR' OR
       ls_fcat-fieldname = 'BOOK_CDT'.
      ls_fcat-emphasize = 'C700'.
    ENDIF.
*    IF ls_fcat-fieldname = 'REGI_CDT' OR
*       ls_fcat-fieldname = 'BOOK_CNT' OR
*       ls_fcat-fieldname = 'FG_TRANS' OR
*       ls_fcat-fieldname = 'FG_CEXCN' OR
*       ls_fcat-fieldname = 'FG_ZEROC'.
*      ls_fcat-emphasize = 'C701'.
*    ENDIF.
    IF ls_fcat-fieldname = 'FG_TRANS' OR
       ls_fcat-fieldname = 'FG_CEXCN' OR
       ls_fcat-fieldname = 'FG_ZEROC'.
      ls_fcat-no_zero = 'X'.
    ENDIF.
    IF ls_fcat-fieldname = 'TRANSFERFLAG'  OR
       ls_fcat-fieldname = 'LOCKFLAG'      OR
       ls_fcat-fieldname = 'AGRNOTRATED'   OR
       ls_fcat-fieldname = '2TRANSFERFLAG' OR
       ls_fcat-fieldname = '2AGRNOTRATED'  OR
       ls_fcat-fieldname = 'P9562' OR
       ls_fcat-fieldname = 'PEXCT' OR
       ls_fcat-fieldname = 'CUFG'.
      ls_fcat-checkbox = 'X'.
    ENDIF.

    MODIFY pt_fieldcat FROM ls_fcat.
  ENDLOOP.

* 값 없는 필드는 자동으로 감추기...
  LOOP AT pt_fieldcat INTO ls_fcat.
    CLEAR: lv_str, lv_chk.
    CONCATENATE 'gt_data-' ls_fcat-fieldname INTO lv_str.
    LOOP AT gt_data.
      ASSIGN (lv_str) TO <fs>.
      IF <fs> IS NOT INITIAL. lv_chk = 'X'. EXIT. ENDIF.
    ENDLOOP.
    IF lv_chk IS INITIAL.
      ls_fcat-no_out = 'X'.
      MODIFY pt_fieldcat FROM ls_fcat.
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
  gs_sort-up        = 'X'.
  gs_sort-spos      = 1.
  gs_sort-fieldname = 'ORGCD'.   APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'ORGCX'.   APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'PERYR'.   APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'PERID'.   APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'SHORT'.   APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'STEXT'.   APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'SMOBJID'. APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'SMSHORT'. APPEND gs_sort TO gt_sort.
  gs_sort-fieldname = 'SMSTEXT'. APPEND gs_sort TO gt_sort.

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
* 사용자의 권한조직 취득
  PERFORM get_user_authorg.
* PFCG 권한
  PERFORM get_userlev.

* 안내문구
  CONCATENATE icon_column_left  ''     INTO sscrfields-functxt_01.
  CONCATENATE icon_column_right ''     INTO sscrfields-functxt_02.
  CONCATENATE icon_system_help '안내'  INTO sscrfields-functxt_03.
  IF gv_userlev <> 'U'.
    CONCATENATE icon_generate '재이수처리' INTO sscrfields-functxt_04.
  ENDIF.
  CONCATENATE icon_pattern_exclude '대상과목' INTO sscrfields-functxt_05.

  t_002 = icon_information && `1단계: 수강생의 재이수, 스케일, 소속제한, 선수과목, 수업시간, 짝홀분반, 휴학수강 등 점검`.
  t_003 = icon_information && `2단계: 재학생의 수강학점 합산, 학점등록 등 점검 (미수강생, 더미과목 포함)`.

*(수강신청학점 초과제외 과목: 2019.03.07
  CLEAR gs_timelimits.
  zcmcl000=>get_timelimits(
    EXPORTING
      iv_o          = p_orgcd
      iv_timelimit  = '0100'
      iv_peryr      = p_peryr
      iv_perid      = p_perid
    IMPORTING
      et_timelimits = DATA(et_timelimits)
  ).
  READ TABLE et_timelimits INDEX 1 INTO DATA(ls_timelimits).
  IF sy-subrc = 0.
    gv_begda = ls_timelimits-ca_lbegda.
    gv_endda = ls_timelimits-ca_lendda.
  ENDIF.

  CLEAR: gt_cexcn[], gt_cexcn.
  gt_cexcn-sign   = 'I'.
  gt_cexcn-option = 'EQ'.
  SELECT objid
    INTO gt_cexcn-low
    FROM hrp9520
   WHERE plvar    = '01'
     AND otype    = 'SM'
     AND begda   <= gv_endda
     AND endda   >= gv_begda
     AND cexc_not = 'X'.
    APPEND gt_cexcn.
  ENDSELECT.
  SORT gt_cexcn BY low.
  DESCRIBE TABLE gt_cexcn LINES gv_count.
  t_004 = icon_warning && `수강학점 합산제외 ` && gv_count && `과목은 상단 "대상과목"에서 확인하세요.`.
*)

* 업데이트일자
  DATA: lv_keyda TYPE datum.
  SELECT MAX( keydate ) INTO lv_keyda FROM zcmta446.
  WRITE lv_keyda TO t_005.
  CONCATENATE icon_information `속도이슈로 학생전공은 ` t_005 ` 04:00 기준데이터 사용 (ZCMTA446)` INTO t_005.

  IF sy-sysid = 'UPS'.
    p_orgcd = '30000304'.
    p_peryr = '2016'.
    p_perid = '020'.
  ENDIF.

ENDFORM.                    " INIT_PROC
*&---------------------------------------------------------------------*
*&      Form  GET_USER_AUTHORG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_user_authorg.

  DATA: lv_profl TYPE profl.
  REFRESH: gt_authobj.

  CALL FUNCTION 'ZCM_USER_AUTHORITY'
    EXPORTING
      im_userid             = sy-uname
*     IM_PROFL              =
    TABLES
      itab_auth             = gt_authobj
    EXCEPTIONS
      no_authority_for_user = 1
      OTHERS                = 2.

  IF sy-subrc NE 0.
    MESSAGE s000 WITH '사용자에게 부여된 권한이 없습니다.'.
    STOP.
  ENDIF.

  SORT gt_authobj BY objid.
  LOOP AT gt_authobj.
    SELECT SINGLE profl INTO lv_profl FROM t77pq
     WHERE profl = gt_authobj-objid.
    IF sy-subrc = 0.
      p_orgcd = lv_profl.
      EXIT.
    ENDIF.
  ENDLOOP.

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
    IF screen-name = 'P_SEL2'.
      IF gv_userlev = 'U'.
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
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .

  CASE 'X'.
    WHEN p_sel1.
      PERFORM get_evob.  "개설과목*
      PERFORM get_smif.  "과목정보1
      PERFORM get_sttg.  "학생대상*
      PERFORM get_stif.  "학생정보*
      PERFORM get_hrpad506.  "재이수
      PERFORM get_acwk.  "이수과목1
      PERFORM set_data.  "세부정보...
      PERFORM chk_dat1.  "재이수탭1
      PERFORM chk_dat2.  "기타점검1
      PERFORM chk_dat3.  "선수과목1
      PERFORM chk_dat4.  "수업시간1
    WHEN p_sel2.
      PERFORM get_evob.  "개설과목*
      PERFORM get_sttg.  "학생대상*
      PERFORM get_stif.  "학생정보*
      PERFORM get_csum.  "학점합계2
      PERFORM set_data.  "세부정보...
      PERFORM chk_dat5.  "수강학점2
  ENDCASE.

  PERFORM set_message. "에러(1->n라인)
  PERFORM set_address. "연락처(에러만)
  PERFORM set_postflr. "필터

  DESCRIBE TABLE gt_data LINES gv_count.
  IF gv_count = 0.
    MESSAGE '점검할 데이터가 없습니다.' TYPE 'S'. STOP.
  ENDIF.

ENDFORM.                    " GET_DATA
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
      iv_adjust    = 30 "1달후...
    IMPORTING
      et_timeinfo  = lt_hrtimeinfo.

  READ TABLE lt_hrtimeinfo INTO ls_timeinfo INDEX 1.
  IF sy-subrc = 0.
    p_peryr = ls_timeinfo-peryr.
    p_perid = ls_timeinfo-perid.
  ENDIF.
  CASE p_perid.
    WHEN '001'. p_perid = '010'.
    WHEN '002'. p_perid = '020'.
  ENDCASE.

ENDFORM.                    " set_current_period
*&---------------------------------------------------------------------*
*&      Form  F4_ORG_CD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f4_org_cd .

  DATA: gt_orgeh TYPE zcms_orgeh_depth OCCURS 0 WITH HEADER LINE.
  DATA: gt_vrm TYPE vrm_values WITH HEADER LINE.

  gt_orgeh-objid = '30000002'. gt_orgeh-tdepth = '1'. APPEND gt_orgeh. "학부
  gt_orgeh-objid = '30000100'. gt_orgeh-tdepth = '1'. APPEND gt_orgeh. "대학원
  gt_orgeh-objid = '30000200'. gt_orgeh-tdepth = '2'. APPEND gt_orgeh. "전문대학원
  gt_orgeh-objid = '30000300'. gt_orgeh-tdepth = '2'. APPEND gt_orgeh. "특수대학원
  gt_orgeh-objid = '30000204'. gt_orgeh-tdepth = '2'. APPEND gt_orgeh. "경영전문대학원(과정)
  gt_orgeh-objid = '30000002'. gt_orgeh-tdepth = '2'. APPEND gt_orgeh. "학사(학부)

  CLEAR: gt_vrm[], gt_vrm.
  CALL FUNCTION 'ZCM_GET_ORGEH_SELECTION'
    EXPORTING
      i_field  = 'P_ORGCD'
    TABLES
      it_orgeh = gt_orgeh
      et_vrm   = gt_vrm.

ENDFORM.                    " F4_ORG_CD
*&---------------------------------------------------------------------*
*&      Form  GET_EVOB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_evob.

  PERFORM set_progbar USING '개설과목'.
  gv_keywd = p_orgcd.

  CLEAR: gt_evob[], gt_evob.
  CALL FUNCTION 'ZCM_GET_COURSE_DETAIL'
    EXPORTING
      i_peryr  = p_peryr
      i_perid  = p_perid
      i_stype  = '1'
      i_kword  = gv_keywd
    TABLES
      e_course = gt_evob.
  SORT gt_evob BY seobjid.

  IF gt_evob[] IS INITIAL.
    MESSAGE '개설과목이 없습니다.' TYPE 'I'. STOP.
  ENDIF.

*----------------------------------------------------------------------*

  CHECK gt_evob[] IS NOT INITIAL.

  PERFORM set_progbar USING '분반일정'.
  CLEAR: gt_1716[], gt_1716.
  SELECT a~objid AS tabnr
         b~beguz
         b~enduz
         b~monday
         b~tuesday
         b~wednesday
         b~thursday
         b~friday
         b~saturday
         b~sunday
    INTO CORRESPONDING FIELDS OF TABLE gt_1716
    FROM hrp1716 AS a INNER JOIN hrt1716 AS b
                         ON b~tabnr = a~tabnr
     FOR ALL ENTRIES IN gt_evob
   WHERE a~plvar = '01'
     AND a~otype = 'E'
     AND a~objid = gt_evob-eobjid.
  SORT gt_1716 BY tabnr.

*----------------------------------------------------------------------*

  PERFORM set_progbar USING '기준일자'.
  READ TABLE gt_evob INDEX 1.
  IF sy-subrc = 0.
    gv_keyda = gt_evob-sebegda.
  ENDIF.

  DATA lt_time TYPE piqtimelimits_tab.
  CALL FUNCTION 'ZCM_GET_TIMELIMITS'
    EXPORTING
      iv_o          = '30000002'
      iv_timelimit  = '0200'
      iv_peryr      = p_peryr
      iv_perid      = p_perid
    IMPORTING
      et_timelimits = lt_time.

  DATA ls_time TYPE piqtimelimits.
  READ TABLE lt_time INTO ls_time INDEX 1.
  IF gv_keyda IS INITIAL. "학부기준
    gv_keyda = ls_time-ca_lbegda.
  ENDIF.

  IF gv_keyda IS INITIAL.
    MESSAGE '기준일자를 확인하세요.' TYPE 'I'. STOP.
  ENDIF.

  gx_keyda = gv_keyda.
  IF p_perid = '010' OR p_perid = '020'.
*   gx_keyda = gv_keyda + ( 7 * 15 ). "15주후(개강후 변동분).
    gx_keyda = ls_time-ca_lendda.
  ENDIF.

*----------------------------------------------------------------------*

  CLEAR: gv_orgcd.
  SELECT SINGLE org
    INTO gv_orgcd
    FROM hrp9500
   WHERE plvar  = '01'
     AND otype  = 'O'
     AND objid  = p_orgcd
     AND begda <= gv_keyda
     AND endda >= gv_keyda.

*----------------------------------------------------------------------*

  PERFORM set_progbar USING '재이수룰'.
  CLEAR: gt_code[], gt_code.
  SELECT *
    INTO TABLE gt_code
    FROM zcmt0101
   WHERE grp_cd    = '506'
     AND com_nm_en = '2007'.
  SORT gt_code BY org_cd short remark.

  CLEAR: gt_rule[], gt_rule.
  LOOP AT gt_code.
    IF gt_rule-orgcd IS NOT INITIAL AND
       gt_rule-orgcd <> gt_code-org_cd.
      PERFORM append_rule.
    ENDIF.
    gt_rule-orgcd = gt_code-org_cd.
    CASE gt_code-short.
      WHEN 'ST'.
        CASE gt_code-remark.
          WHEN '1'. gt_rule-session    = gt_code-map_cd1.
          WHEN '2'. gt_rule-peryr      = gt_code-map_cd1.
          WHEN '3'. gt_rule-method     = gt_code-map_cd1.
        ENDCASE.
      WHEN 'SM'.
        CASE gt_code-remark.
          WHEN '4'. gt_rule-module     = gt_code-map_cd1.
          WHEN '5'. gt_rule-gradesym   = gt_code-map_cd1.
          WHEN '6'. gt_rule-gradescale = gt_code-map_cd1.
        ENDCASE.
    ENDCASE.
  ENDLOOP.
  PERFORM append_rule.
  LOOP AT gt_rule.
    CHECK gt_rule-module <> 99.
    ADD 1 TO gt_rule-module. "재이수2번 허용이면, 3수강까지 이므로...
    MODIFY gt_rule.
  ENDLOOP.

*----------------------------------------------------------------------*

  PERFORM set_progbar USING '수강신청룰'.
  CLEAR: gt_code[], gt_code.
  SELECT *
    INTO TABLE gt_code
    FROM zcmt0101
   WHERE grp_cd    = '509'
     AND com_cd   <> '0000'.
  SORT gt_code BY org_cd map_cd1.
  DELETE ADJACENT DUPLICATES FROM gt_code COMPARING org_cd.
  "경영전문대학원은 주간과정으로 세팅(임시)

  LOOP AT gt_rule.
    READ TABLE gt_code WITH KEY org_cd = gt_rule-orgcd BINARY SEARCH.
    IF sy-subrc = 0.
      gt_rule-regular = gt_code-map_cd3.
      gt_rule-season  = gt_code-short.
    ENDIF.
    MODIFY gt_rule.
  ENDLOOP.
  SORT gt_rule BY orgcd.

*----------------------------------------------------------------------*

  PERFORM set_progbar USING '선수과목/시간중복 허용룰'.
  CLEAR: gt_code[], gt_code.
  SELECT *
    INTO TABLE gt_code
    FROM zcmt0101
   WHERE grp_cd = '002'.
  SORT gt_code BY com_cd.

  LOOP AT gt_rule.
    READ TABLE gt_code WITH KEY com_cd = gt_rule-orgcd BINARY SEARCH.
    IF sy-subrc = 0.
      gt_rule-presubj = gt_code-map_cd1.
      gt_rule-timedup = gt_code-map_cd2.
    ENDIF.
    MODIFY gt_rule.
  ENDLOOP.
  SORT gt_rule BY orgcd.

*----------------------------------------------------------------------*

  PERFORM set_progbar USING '하위학과'.
  CLEAR: gt_stru[], gt_stru.
  CALL FUNCTION 'RHPH_STRUCTURE_READ'
    EXPORTING
      plvar    = '01'
      otype    = 'O'
      objid    = p_orgcd
      wegid    = 'ORGEH'
      begda    = gv_keyda
      endda    = gv_keyda
    TABLES
      stru_tab = gt_stru.
  SORT gt_stru BY objid.

  CLEAR: s_sobid[], s_sobid.
  LOOP AT gt_stru.
    s_sobid-sign   = 'I'.
    s_sobid-option = 'EQ'.
    s_sobid-low    = gt_stru-objid.
    APPEND s_sobid.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_SMIF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_smif .

  PERFORM set_progbar USING '과목정보'.
  CLEAR: gt_1000[], gt_1000.
  SELECT objid short stext
    INTO CORRESPONDING FIELDS OF TABLE gt_1000
    FROM hrp1000
   WHERE plvar  = '01'
     AND otype  = 'SM'
     AND langu  = '3'
     AND begda <= gv_keyda
     AND endda >= gv_keyda.
  SORT gt_1000 BY objid.

*----------------------------------------------------------------------*

  PERFORM set_progbar USING '과목관계(선수)'.
  CLEAR: gt_101a[], gt_101a.
  SELECT objid subty sobid
    INTO CORRESPONDING FIELDS OF TABLE gt_101a
    FROM hrp1001
   WHERE plvar  = '01'
     AND otype  = 'SM'
     AND rsign  = 'A'
     AND relat  = '529'
     AND subty  = 'A529' "선수과목
     AND begda <= gv_keyda
     AND endda >= gv_keyda.
  SORT gt_101a BY subty objid sobid.

  PERFORM set_progbar USING '과목관계(대체,선택)'.
  CLEAR: gt_101b[], gt_101b.
  SELECT objid subty sobid
    INTO CORRESPONDING FIELDS OF TABLE gt_101b
    FROM hrp1001
   WHERE plvar  = '01'
     AND otype  = 'SM'
     AND rsign  = 'B'
     AND relat  = '511'
     AND subty  = 'B511' "대체과목
     AND begda <= gv_keyda
     AND endda >= gv_keyda.

  SELECT objid subty sobid
    APPENDING CORRESPONDING FIELDS OF TABLE gt_101b
    FROM hrp1001
   WHERE plvar  = '01'
     AND otype  = 'SM'
     AND rsign  = 'A'
     AND relat  = 'Z30'
     AND subty  = 'AZ30' "선택과목
     AND begda <= gv_keyda
     AND endda >= gv_keyda.
  SORT gt_101b BY subty objid sobid.

*----------------------------------------------------------------------*

  PERFORM set_progbar USING '과목범주'.
  CLEAR: gt_1746[], gt_1746.
  SELECT objid category modrepeattype
    INTO CORRESPONDING FIELDS OF TABLE gt_1746
    FROM hrp1746
   WHERE plvar  = '01'
     AND otype  = 'SM'
     AND begda <= gv_keyda
     AND endda >= gv_keyda.
  SORT gt_1746 BY objid.

*----------------------------------------------------------------------*

  PERFORM set_progbar USING '과목평가'.
  CLEAR: gt_1710[], gt_1710.
  SELECT objid scaleid
    INTO CORRESPONDING FIELDS OF TABLE gt_1710
    FROM hrp1710
   WHERE plvar  = '01'
     AND otype  = 'SM'
     AND begda <= gv_keyda
     AND endda >= gv_keyda.
  SORT gt_1710 BY objid.

*----------------------------------------------------------------------*

  CHECK gt_evob[] IS NOT INITIAL.

  PERFORM set_progbar USING '소속제한'.
  CLEAR: gt_9550[], gt_9550.
  SELECT *
    INTO TABLE gt_9550
    FROM hrp9550
     FOR ALL ENTRIES IN gt_evob
   WHERE plvar    = '01'
     AND otype    = 'SE'
     AND objid    = gt_evob-seobjid
     AND begda    = gv_keyda
     AND apply_fg = 'X'.
  SORT gt_9550 BY objid.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_ACWK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_acwk .

  CHECK gt_stobj[] IS NOT INITIAL.

  PERFORM set_progbar USING '수강신청 내역'.
  CLEAR: gt_data[], gt_data.
  SELECT a~objid "ST
         a~sobid "SM
         a~aedtm
         a~uname
         b~peryr
         b~perid
         b~packnumber "SE
         b~cpattemp
         b~smstatus
         b~alt_scaleid
         b~transferflag
         b~lockflag
         b~bookdate
         b~booktime
         b~id
    INTO CORRESPONDING FIELDS OF TABLE gt_data
    FROM hrp1001 AS a INNER JOIN hrpad506 AS b
                         ON b~adatanr = a~adatanr
   WHERE a~plvar     = '01'
     AND a~otype     = 'ST'
     AND a~objid    IN gt_stobj
     AND a~subty     = 'A506'
     AND b~smstatus IN ('01','02','03').

  DELETE gt_data WHERE peryr > p_peryr. "이후학기 삭제
  DELETE gt_data WHERE peryr = p_peryr AND perid > p_perid.

*(재이수가비지: 2019.10.07 김상현
  PERFORM set_garbage. "순서주의...폐강과목 안뜨네...
*)

  PERFORM set_progbar USING '이수과목 성적'.
  CLEAR: gt_pgen[], gt_pgen.
  IF gt_data[] IS NOT INITIAL.
    SELECT b~agrid
           b~gradesym
           b~grade
           b~gradescale
           b~agrnotrated
           a~modreg_id AS noteid "MODREG_ID 용도로 사용
      INTO CORRESPONDING FIELDS OF TABLE gt_pgen
      FROM piqdbagr_assignm AS a INNER JOIN piqdbagr_gen AS b
                                    ON b~agrid = a~agrid
       FOR ALL ENTRIES IN gt_data
     WHERE a~modreg_id = gt_data-id.
    SORT gt_pgen BY noteid.
  ENDIF.

  PERFORM set_progbar USING '처리자 정보'.
  LOOP AT gt_data.
    gt_data-pernr = gt_data-uname.
    MODIFY gt_data.
  ENDLOOP.
  CLEAR: gt_pa20[], gt_pa20.
  SELECT pernr ename
    INTO CORRESPONDING FIELDS OF TABLE gt_pa20
    FROM pa0001
   WHERE begda <= sy-datum
     AND endda >= sy-datum.
  SORT gt_pa20 BY pernr.

  PERFORM set_progbar USING '수강과목 정리'.
  LOOP AT gt_data.
    gt_data-smobjid = gt_data-sobid. "SM
    CLEAR: gt_data-sobid.
    READ TABLE gt_1000 WITH KEY objid = gt_data-smobjid BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data-smshort = gt_1000-short.
      gt_data-smstext = gt_1000-stext.
    ENDIF.
    READ TABLE gt_pgen WITH KEY noteid = gt_data-id BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data-agrid       = gt_pgen-agrid.
      gt_data-gradesym    = gt_pgen-gradesym.
      gt_data-grade       = gt_pgen-grade.
      gt_data-gradescale  = gt_pgen-gradescale.
      gt_data-agrnotrated = gt_pgen-agrnotrated.
    ENDIF.
    READ TABLE gt_pa20 WITH KEY pernr = gt_data-pernr BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data-uname = gt_data-uname && ` (` && gt_pa20-ename && `)`.
    ENDIF.
    MODIFY gt_data.
  ENDLOOP.

  CLEAR: gt_acwk[], gt_acwk.
  gt_acwk[] = gt_data[].

* 금학기 이수과목(gt_data)
  DELETE gt_data WHERE peryr <> p_peryr OR perid <> p_perid.
* SORT gt_data BY objid peryr perid smobjid.
  SORT gt_data BY packnumber.

* 이전 이수과목(gt_acwk)
  DELETE gt_acwk WHERE peryr > p_peryr.
  DELETE gt_acwk WHERE peryr = p_peryr AND perid >= p_perid.
  SORT gt_acwk BY objid peryr perid smobjid.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_CSUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_csum .

* DATA: lv_cond TYPE string.
  CHECK gt_stobj[] IS NOT INITIAL.

  PERFORM set_progbar USING '수강신청 내역'.
  CLEAR: gt_data[], gt_data.
  SELECT a~objid "ST
         a~sobid "SM
         b~packnumber "SE
         b~cpattemp
         b~smstatus
         b~transferflag
    INTO CORRESPONDING FIELDS OF TABLE gt_data
    FROM hrp1001 AS a INNER JOIN hrpad506 AS b
                         ON b~adatanr = a~adatanr
   WHERE a~plvar  = '01'
     AND a~otype  = 'ST'
     AND a~objid IN gt_stobj
     AND a~subty  = 'A506'
     AND b~peryr  = p_peryr
     AND b~perid  = p_perid
     AND b~smstatus IN ('01','02','03').
  SORT gt_data BY objid sobid.

  PERFORM set_progbar USING '수강학점 합계'.
  CLEAR: gt_sum[], gt_sum.
  LOOP AT gt_data.
    gt_sum-objid = gt_data-objid.
    gt_sum-book_cnt = 1. "과목수(count)
    gt_sum-cpattemp = gt_data-cpattemp. "수강학점(sum)

    IF gt_data-cpattemp = 0.
      gt_sum-fg_zeroc = 1. "무학점(count)
    ENDIF.
    IF gt_data-transferflag = 'X'.
      gt_sum-fg_trans = gt_data-cpattemp. "동등학위(sum)
    ENDIF.
    READ TABLE gt_cexcn WITH KEY low = gt_data-sobid BINARY SEARCH.
    IF sy-subrc = 0.
      CLEAR: gt_sum-cpattemp.
      gt_sum-fg_cexcn = gt_data-cpattemp. "학점제외(sum)
    ENDIF.
    READ TABLE gt_evob
      WITH KEY seobjid = gt_data-packnumber
               cufg = 'X'.
    IF sy-subrc = 0.
      gt_sum-fg_cu = gt_data-cpattemp. "CU과목(sum)
    ENDIF.

    COLLECT gt_sum. CLEAR gt_sum.
  ENDLOOP.
  SORT gt_sum BY objid.

  PERFORM set_progbar USING '미수강생 추가'.
  CLEAR: gt_data[], gt_data.
  LOOP AT gt_sum.
    MOVE-CORRESPONDING gt_sum TO gt_data.
    APPEND gt_data. CLEAR gt_data.
  ENDLOOP.
  LOOP AT gt_stobj.
    READ TABLE gt_sum WITH KEY objid = gt_stobj-low BINARY SEARCH.
    IF sy-subrc <> 0.
      gt_data-objid = gt_stobj-low. "누락분(미수강)추가...
      APPEND gt_data. CLEAR gt_data.
    ENDIF.
  ENDLOOP.

*(초과제외과목(하드코딩 변경함): 2019.03.07
*  IF gt_cexcn[] IS NOT INITIAL.
*    lv_cond = 'a~sobid NOT IN gt_cexcn'.
*  ENDIF.
*)
*  CLEAR: gt_data[], gt_data.
*  SELECT a~objid "ST
*         b~peryr
*         b~perid
*         SUM( b~cpattemp ) AS cpattemp
*    INTO CORRESPONDING FIELDS OF TABLE gt_data
*    FROM hrp1001 AS a INNER JOIN hrpad506 AS b
*                         ON b~adatanr = a~adatanr
*   WHERE a~plvar      = '01'
*     AND a~otype      = 'ST'
*     AND a~objid     IN gt_stobj
*     AND a~subty      = 'A506'
*     AND (lv_cond) "초과제외과목(하드코딩 변경함): 2019.03.07 김상현
*     AND b~peryr      = p_peryr
*     AND b~perid      = p_perid
*     AND b~smstatus  IN ('01','02','03')
**    AND b~transferflag = space "더미과목 누락되므로 조건삭제
*   GROUP BY a~objid b~peryr b~perid.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_STT1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_stt1 .

  PERFORM set_progbar USING '대상학생(학과/수강기준)'.
  CLEAR: gt_sugang[], gt_sugang.
  SELECT b~objid a~packnumber c~sobid
    INTO CORRESPONDING FIELDS OF TABLE gt_sugang
    FROM hrpad506 AS a INNER JOIN hrp1001  AS b
                          ON b~adatanr = a~adatanr
                       INNER JOIN hrp1001 AS c
                          ON c~plvar = b~plvar
                         AND c~otjid = b~otjid
   WHERE a~peryr  = p_peryr
     AND a~perid  = p_perid
     AND a~smstatus IN ('01','02','03')
     AND b~plvar  = '01'
     AND b~otype  = 'ST'
     AND c~subty  = 'A502'
     AND c~begda <= gv_keyda
     AND c~endda >= gv_keyda.
  SORT gt_sugang.
  DELETE ADJACENT DUPLICATES FROM gt_sugang COMPARING ALL FIELDS.

  LOOP AT gt_sugang. "전체수강생...
    READ TABLE gt_evob WITH KEY seobjid = gt_sugang-packnumber BINARY SEARCH.
    IF sy-subrc = 0.
      gt_stobj-sign   = 'I'.
      gt_stobj-option = 'EQ'.
      gt_stobj-low    = gt_sugang-objid. "해당소속 개설과목...
      APPEND gt_stobj. CONTINUE.
    ENDIF.
    READ TABLE gt_stru WITH KEY objid = gt_sugang-sobid BINARY SEARCH.
    IF sy-subrc = 0.
      gt_stobj-sign   = 'I'.
      gt_stobj-option = 'EQ'.
      gt_stobj-low    = gt_sugang-objid. "해당소속 학생...
      APPEND gt_stobj. CONTINUE.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_STT2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_stt2 .

  PERFORM set_progbar USING '대상학생(재학기준)'.
  SELECT a~objid AS low
    INTO CORRESPONDING FIELDS OF TABLE gt_stobj
    FROM hrp9530 AS a INNER JOIN hrp1001 AS b
                         ON b~plvar = a~plvar
                        AND b~otjid = a~otjid
   WHERE a~plvar  = '01'
     AND a~otype  = 'ST'
     AND a~begda <= gx_keyda
     AND a~endda >= gx_keyda
     AND a~sts_cd = '1000' "재학(당시)
     AND b~subty  = 'A502'
     AND b~begda <= gv_keyda
     AND b~endda >= gv_keyda
     AND b~sobid IN s_sobid. "소속학과
  LOOP AT gt_stobj.
    gt_stobj-sign   = 'I'.
    gt_stobj-option = 'EQ'.
    MODIFY gt_stobj.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_STIF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_stif .

  CHECK gt_stobj[] IS NOT INITIAL.

  PERFORM set_progbar USING '학번/성명'.
  CLEAR: gt_stno[], gt_stno.
  SELECT a~objid
         a~short
         a~stext
         b~sts_cd AS stscd "학적상태(당시)
         c~sobid
         d~org AS orgcd
    INTO CORRESPONDING FIELDS OF TABLE gt_stno
    FROM hrp1000 AS a INNER JOIN hrp9530 AS b
                         ON b~plvar = a~plvar
                        AND b~otjid = a~otjid
                      INNER JOIN hrp1001 AS c
                         ON c~plvar = a~plvar
                        AND c~otjid = a~otjid
                      INNER JOIN hrp9500 AS d
                         ON d~plvar = c~plvar
                        AND d~otype = c~sclas
                        AND d~objid = c~sobid
   WHERE a~plvar  = '01'
     AND a~otype  = 'ST'
     AND a~objid IN gt_stobj
     AND a~langu  = '3'
     AND a~begda <= gv_keyda
     AND a~endda >= gv_keyda
     AND b~begda <= gx_keyda
     AND b~endda >= gx_keyda
     AND c~subty  = 'A502'
     AND c~begda <= gv_keyda
     AND c~endda >= gv_keyda
     AND d~begda <= gv_keyda
     AND d~endda >= gv_keyda.
  SORT gt_stno BY objid.

  PERFORM set_progbar USING '학생소속'.
  LOOP AT gt_stno.
    gt_stno-orgeh = gt_stno-sobid.
    CLEAR: gt_stno-sobid.
    CASE gt_stno-orgcd.
      WHEN '0011'. gt_stno-orgcx = '학부'.
      WHEN '0001'. gt_stno-orgcx = '일반'.
      WHEN '0002'. gt_stno-orgcx = '경영'.
      WHEN '0003'. gt_stno-orgcx = '공공'.
      WHEN '0004'. gt_stno-orgcx = '교육'.
      WHEN '0005'. gt_stno-orgcx = '경제'.
      WHEN '0006'. gt_stno-orgcx = '언론'.
      WHEN '0007'. gt_stno-orgcx = '신학'.
      WHEN '0008'. gt_stno-orgcx = '정보'.
      WHEN '0009'. gt_stno-orgcx = '국제'.
      WHEN '0010'. gt_stno-orgcx = '영상'.
      WHEN '0031'. gt_stno-orgcx = '법학'.
      WHEN '0032'. gt_stno-orgcx = '기술'.
    ENDCASE.
    MODIFY gt_stno.
  ENDLOOP.

  PERFORM set_progbar USING '성적집계'.
  CLEAR: gt_9565[], gt_9565.
  SELECT objid earn_crd cgpa
    INTO CORRESPONDING FIELDS OF TABLE gt_9565
    FROM hrp9565
   WHERE plvar    = '01'
     AND otype    = 'ST'
     AND objid   IN gt_stobj
     AND piqperyr = p_peryr
     AND piqperid = p_perid.
  SORT gt_9565 BY objid.

  PERFORM set_progbar USING '개인데이터'.
  CLEAR: gt_1702[], gt_1702.
  SELECT objid namzu titel natio
    INTO CORRESPONDING FIELDS OF TABLE gt_1702
    FROM hrp1702
   WHERE plvar  = '01'
     AND otype  = 'ST'
     AND objid IN gt_stobj
     AND begda <= gx_keyda
     AND endda >= gx_keyda.
  SORT gt_1702 BY objid.

  PERFORM set_progbar USING '입학정보'.
  CLEAR: gt_9710[], gt_9710.
  SELECT objid apply_qual_cd
    INTO CORRESPONDING FIELDS OF TABLE gt_9710
    FROM hrp9710
   WHERE plvar  = '01'
     AND otype  = 'ST'
     AND objid IN gt_stobj
     AND begda <= gv_keyda
     AND endda >= gv_keyda.
  SORT gt_9710 BY objid.

  PERFORM set_progbar USING '수강가능학점'.
  CLEAR: gt_1705[], gt_1705.
  SELECT objid regwindow regsemstr book_cdt
    INTO CORRESPONDING FIELDS OF TABLE gt_1705
    FROM hrp1705
   WHERE plvar  = '01'
     AND otype  = 'ST'
     AND objid IN gt_stobj
     AND begda <= gx_keyda
     AND endda >= gx_keyda.
  SORT gt_1705 BY objid.

  PERFORM set_progbar USING '학점등록신청'.
  CLEAR: gt_2040[], gt_2040.
  SELECT objid status2
    INTO CORRESPONDING FIELDS OF TABLE gt_2040
    FROM zcmt2040
   WHERE peryr = p_peryr
     AND perid = p_perid
     AND objid IN gt_stobj
     AND status2 > 0.
  SORT gt_2040 BY objid.

  PERFORM set_progbar USING '졸업예정자'.
  CLEAR: gt_recs[], gt_recs.
  SELECT objid peryr perid status2
    INTO CORRESPONDING FIELDS OF TABLE gt_recs
    FROM piqdbcmprrecords
   WHERE plvar = '01'
     AND otype = 'ST'.
*    AND objid IN gt_stobj "느림..전체로..
  SORT gt_recs BY objid peryr DESCENDING perid DESCENDING. "최근건
  DELETE ADJACENT DUPLICATES FROM gt_recs COMPARING objid.

*----------------------------------------------------------------------*

* 속도이슈로 백업테이블로 변경: 2020.03.12
  PERFORM set_progbar USING '수강생 전공'.
  CLEAR: gt_majr[], gt_majr.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_majr
    FROM zcmta446
   WHERE stobjid IN gt_stobj.
  SORT gt_majr BY st_objid.

*  DATA: lt_st LIKE zcmsobjid OCCURS 0 WITH HEADER LINE.
*  CLEAR: lt_st[], lt_st.
*  CLEAR: gt_majr[], gt_majr.
*  LOOP AT gt_stobj.
*    lt_st-objid = gt_stobj-low. APPEND lt_st.
*  ENDLOOP.
*  CALL FUNCTION 'ZCM_GET_STUDENT_MAJOR_MULTI'
*    TABLES
*      it_student = lt_st
*      et_major   = gt_majr.
*  SORT gt_majr BY st_objid.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  get_hrpad506
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_hrpad506.

  DATA: lv_key(40), lv_idx TYPE i.
  DATA: lv_perid TYPE piqperid.

  CHECK gt_stobj[] IS NOT INITIAL.

  PERFORM set_progbar USING '재이수 처리내역(전체)'.

  SELECT  a~objid,
          b~peryr AS piqperyr,
          b~perid AS piqperid,
          a~sobid AS sm_id,
          b~reperyr AS repeatyr,
          b~reperid AS repeatid,
          b~resmid AS rep_module,
          b~repeatfg AS no_cnt
      FROM hrp1001 AS a
    INNER JOIN hrpad506 AS b
    ON  a~adatanr = b~adatanr
  WHERE a~plvar = '01'
    AND a~otype = 'ST'
    AND a~istat = '1'
    AND a~objid IN @gt_stobj
    AND a~subty = 'A506'
    AND a~sclas = 'SM'
    AND b~resmid IS NOT INITIAL
    AND b~smstatus IN ('1','2','3')
    INTO TABLE @gt_506_re.
  LOOP AT gt_506_re ASSIGNING FIELD-SYMBOL(<fs_506>).
    CASE <fs_506>-no_cnt.
      WHEN 'X'.
        <fs_506>-no_cnt = ''.
      WHEN OTHERS.
        <fs_506>-no_cnt = 'X'.
    ENDCASE.
  ENDLOOP.
*  gt_506_re[] = CORRESPONDING #( gt_506_re ).

  SORT gt_506_re BY objid peryr perid sm_id.
  DELETE gt_506_re WHERE peryr > p_peryr
                    OR ( peryr = p_peryr AND perid > p_perid ). "이후학기삭제...

  PERFORM set_progbar USING '재이수 처리내역(현재)'.
  CLEAR: gt_506_re_cur[], gt_506_re_cur.
  LOOP AT gt_506_re WHERE peryr = p_peryr AND perid = p_perid. "현재학기만...
    MOVE-CORRESPONDING gt_506_re TO gt_506_re_cur.
    APPEND gt_506_re_cur. CLEAR gt_506_re_cur.
  ENDLOOP.
*)
  SORT gt_506_re_cur BY objid peryr perid sm_id.

  PERFORM set_progbar USING '학기당 재이수횟수'.
  LOOP AT gt_506_re_cur.
    CLEAR: gt_506_re_cur-session. "초기화
    LOOP AT gt_506_re WHERE objid = gt_506_re_cur-objid
                        AND peryr = gt_506_re_cur-peryr
                        AND perid = gt_506_re_cur-perid.
      ADD 1 TO gt_506_re_cur-session. "횟수
    ENDLOOP.
    MODIFY gt_506_re_cur.
  ENDLOOP.

  PERFORM set_progbar USING '과목당 재이수횟수'.
  LOOP AT gt_506_re_cur.
    CLEAR: gt_506_re_cur-module. "초기화
    PERFORM get_smgroup. "->gt_smobj 자신+대체...
    ADD 1 TO gt_506_re_cur-module. "기본값...
    LOOP AT gt_506_re WHERE objid = gt_506_re_cur-objid
                      AND ( sm_id IN gt_smobj OR resmid IN gt_smobj ). "자신+대체...
      ADD 1 TO gt_506_re_cur-module. "횟수
    ENDLOOP.
    MODIFY gt_506_re_cur.
  ENDLOOP.

  CHECK gv_orgcd = '0011'. "학부일때만...

*(재이수횟수관련 로직변경: 2020.08.11 김상현
  PERFORM set_progbar USING '정규합산 재이수횟수(학부)'.
  LOOP AT gt_506_re_cur.
    CLEAR: gt_506_re_cur-total12. "초기화
    LOOP AT gt_506_re WHERE objid = gt_506_re_cur-objid
                      AND ( perid = '010' OR perid = '020' )
                      AND no_cnt <> 'X'. "합산제외...
      ADD 1 TO gt_506_re_cur-total12. "횟수
    ENDLOOP.
    MODIFY gt_506_re_cur.
  ENDLOOP.
*)

*(제이수 유예제도 20-1학기까지만 (통합8회방식 변경)
  CLEAR: gt_yuye[], gt_yuye.
  CHECK p_peryr && p_perid <= '2020010'. "SKIP...

  PERFORM set_progbar USING '직전정규 제적경고(학부)'.
* CLEAR: gt_yuye[], gt_yuye.
  SELECT objid
         piqperyr AS peryr
         piqperid AS perid
         warning_cd
    INTO CORRESPONDING FIELDS OF TABLE gt_yuye
    FROM hrp9565
   WHERE plvar  = '01'
     AND otype  = 'ST'
     AND objid IN gt_stobj
     AND ( piqperyr < p_peryr OR
         ( piqperyr = p_peryr AND piqperid < p_perid ) )
     AND piqperid IN ('010','020').
  SORT gt_yuye BY objid peryr DESCENDING perid DESCENDING.
*(계절학기 신청당시 직전정규 성적완료 없으므로, 이후에 점검시 SKIP 필요
  CLEAR: lv_perid.
  IF p_perid = '011' OR p_perid = '021'.
    lv_perid = p_perid+0(2) && '0'.
    DELETE gt_yuye WHERE peryr = p_peryr AND perid = lv_perid. "직전삭제
  ENDIF.
*)
  DELETE ADJACENT DUPLICATES FROM gt_yuye COMPARING objid.
  DELETE gt_yuye WHERE warning_cd <> '0002'. "제적경고

  PERFORM set_progbar USING '재이수 유예(학부)'.
  CLEAR: lv_perid.
  CASE p_perid. "계절포함변환
    WHEN '001' OR '010' OR '011'. lv_perid = '001'.
    WHEN '002' OR '020' OR '021'. lv_perid = '002'.
  ENDCASE.
  SELECT objid
         piqperyr AS peryr
         piqperid AS perid
    APPENDING CORRESPONDING FIELDS OF TABLE gt_yuye
    FROM hrp9561
   WHERE plvar    = '01'
     AND otype    = 'ST'
     AND objid   IN gt_stobj
     AND piqperyr = p_peryr
     AND piqperid = lv_perid.
  SORT gt_yuye BY objid.
*)

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_data .

  DATA: lv_stat2t TYPE stext.

  PERFORM set_progbar USING '기본정보 확인'.
  LOOP AT gt_data.
    "학생정보
    READ TABLE gt_stno WITH KEY objid = gt_data-objid BINARY SEARCH. "ST
    IF sy-subrc = 0.
      gt_data-short = gt_stno-short.
      gt_data-stext = gt_stno-stext.
      gt_data-stscd = gt_stno-stscd.
      gt_data-orgcd = gt_stno-orgcd.
      gt_data-orgcx = gt_stno-orgcx.
    ENDIF.
    "전공
    READ TABLE gt_majr WITH KEY st_objid = gt_data-objid BINARY SEARCH. "ST
    IF sy-subrc = 0.
      gt_data-sc1tx = gt_majr-sc_short1.
      gt_data-sc2tx = gt_majr-sc_short2.
      gt_data-sc3tx = gt_majr-sc_short3.
      gt_data-sc1id = gt_majr-sc_objid1.
      gt_data-sc2id = gt_majr-sc_objid2.
      gt_data-sc3id = gt_majr-sc_objid3.
    ENDIF.
    "개인정보
    READ TABLE gt_1702 WITH KEY objid = gt_data-objid BINARY SEARCH. "ST
    IF sy-subrc = 0.
      gt_data-namzu = gt_1702-namzu.
      gt_data-titel = gt_1702-titel.
      gt_data-natio = gt_1702-natio.
    ENDIF.
    "입학정보
    READ TABLE gt_9710 WITH KEY objid = gt_data-objid BINARY SEARCH. "ST
    IF sy-subrc = 0.
      gt_data-apply_qual_cd = gt_9710-apply_qual_cd.
    ENDIF.
    "성적집계
    READ TABLE gt_9565 WITH KEY objid = gt_data-objid BINARY SEARCH. "ST
    IF sy-subrc = 0.
      gt_data-earn_crd = gt_9565-earn_crd.
      gt_data-cgpa     = gt_9565-cgpa.
    ENDIF.
    "졸업예정
    READ TABLE gt_recs WITH KEY objid = gt_data-objid BINARY SEARCH. "ST
    IF sy-subrc = 0.
      gt_data-stat2 = gt_recs-peryr+2 && `-` && gt_recs-perid+1(1).
      IF gt_recs-status2 IS NOT INITIAL.
        SELECT SINGLE stat2_text INTO lv_stat2t FROM t7piqcmprstat2t
         WHERE spras = '3' AND status2 = gt_recs-status2.
        IF sy-subrc = 0.
          gt_data-stat2 = gt_data-stat2 && ` (` && lv_stat2t && `)`.
        ENDIF.
      ENDIF.
    ENDIF.
    "대체과목
    LOOP AT gt_101b WHERE subty = 'B511' AND objid = gt_data-smobjid. "SM
      IF gt_data-objid1 IS INITIAL. gt_data-objid1 = gt_101b-sobid. CONTINUE. ENDIF.
      IF gt_data-objid2 IS INITIAL. gt_data-objid2 = gt_101b-sobid. CONTINUE. ENDIF.
      IF gt_data-objid3 IS INITIAL. gt_data-objid3 = gt_101b-sobid. CONTINUE. ENDIF.
      IF gt_data-objid4 IS INITIAL. gt_data-objid4 = gt_101b-sobid. CONTINUE. ENDIF.
      IF gt_data-objid5 IS INITIAL. gt_data-objid5 = gt_101b-sobid. CONTINUE. ENDIF.
    ENDLOOP.
    "카테고리
    READ TABLE gt_1746 WITH KEY objid = gt_data-smobjid BINARY SEARCH. "SM
    IF sy-subrc = 0.
      gt_data-category      = gt_1746-category.
      gt_data-modrepeattype = gt_1746-modrepeattype.
      IF gt_data-modrepeattype <> '0005'. "미적용 아니면 허용으로
        gt_data-modrepeattype = '0001'.
      ENDIF.
      IF gt_data-category = '0030'. "논문(강제미적용)
        gt_data-modrepeattype = '0005'.
      ENDIF.
    ENDIF.
    "과목평가
    READ TABLE gt_1710 WITH KEY objid = gt_data-smobjid BINARY SEARCH. "SM
    IF sy-subrc = 0.
      gt_data-scaleid = gt_1710-scaleid.
    ENDIF.
    "CU과목
    READ TABLE gt_evob WITH KEY seobjid = gt_data-packnumber BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data-cufg = gt_evob-cufg.
    ENDIF.
    "이전 동일과목 찾기
    READ TABLE gt_acwk WITH KEY objid = gt_data-objid BINARY SEARCH. "ST
    IF sy-subrc = 0.
      LOOP AT gt_acwk FROM sy-tabix.
        IF gt_acwk-objid <> gt_data-objid.
          EXIT.
        ENDIF.
        IF gt_acwk-smobjid = gt_data-smobjid. "동일과목
          gt_data-2peryr   = gt_acwk-peryr.
          gt_data-2perid   = gt_acwk-perid.
          gt_data-2smobjid = gt_acwk-smobjid.
*         EXIT. "마지막까지 찾기...
        ENDIF.
      ENDLOOP.
    ENDIF.
    "이전 대체과목 찾기
    IF   gt_data-2smobjid IS     INITIAL AND "동일과목 못찾고
       ( gt_data-objid1   IS NOT INITIAL OR  "대체과목 있으면
         gt_data-objid2   IS NOT INITIAL OR
         gt_data-objid3   IS NOT INITIAL OR
         gt_data-objid4   IS NOT INITIAL OR
         gt_data-objid5   IS NOT INITIAL ).
      READ TABLE gt_acwk WITH KEY objid = gt_data-objid BINARY SEARCH. "ST
      IF sy-subrc = 0.
        LOOP AT gt_acwk FROM sy-tabix.
          IF gt_acwk-objid <> gt_data-objid.
            EXIT.
          ENDIF.
          IF gt_acwk-smobjid = gt_data-objid1 OR "대체과목
             gt_acwk-smobjid = gt_data-objid2 OR
             gt_acwk-smobjid = gt_data-objid3 OR
             gt_acwk-smobjid = gt_data-objid4 OR
             gt_acwk-smobjid = gt_data-objid5.
            gt_data-2peryr   = gt_acwk-peryr.
            gt_data-2perid   = gt_acwk-perid.
            gt_data-2smobjid = gt_acwk-smobjid.
*           EXIT. "마지막까지 찾기...
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
    PERFORM get_prevsym. "이전과목 정보...

    MODIFY gt_data.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  APPEND_RULE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_rule .

  IF gt_rule-session = 0. gt_rule-session = 99. ENDIF.
  IF gt_rule-module  = 0. gt_rule-module  = 99. ENDIF.
  CASE gt_rule-gradesym.
    WHEN 'A+'.
      gt_rule-notallow1 = ''.
    WHEN 'A0'.
      gt_rule-notallow1 = 'A+'.
    WHEN 'A-'.
      gt_rule-notallow1 = 'A+A0'.
    WHEN 'B+'.
      gt_rule-notallow1 = 'A+A0A-'.
    WHEN 'B0'.
      gt_rule-notallow1 = 'A+A0A-B+'.
    WHEN 'B-'.
      gt_rule-notallow1 = 'A+A0A-B+B0'.
    WHEN 'C+'.
      gt_rule-notallow1 = 'A+A0A-B+B0B-'.
    WHEN 'C0'.
      gt_rule-notallow1 = 'A+A0A-B+B0B-C+'.
    WHEN 'C-'.
      gt_rule-notallow1 = 'A+A0A-B+B0B-C+C0'.
    WHEN 'D+'.
      gt_rule-notallow1 = 'A+A0A-B+B0B-C+C0C-'.
    WHEN 'D0'.
      gt_rule-notallow1 = 'A+A0A-B+B0B-C+C0C-D+'.
    WHEN 'D-'.
      gt_rule-notallow1 = 'A+A0A-B+B0B-C+C0C-D+D0'.
    WHEN 'F'.
      gt_rule-notallow1 = 'A+A0A-B+B0B-C+C0C-D+D0D-'.
  ENDCASE.
  IF gt_rule-gradescale = 'KRR2'.
    gt_rule-notallow2 = 'A+A0'.
  ENDIF.
  APPEND gt_rule.
  CLEAR  gt_rule.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_message USING p_type p_message.

* 'S'는 Bapi stack에 쌓지 않음...
  CLEAR: gs_bapiret2.
  CASE p_type.
    WHEN 'E'.
      gs_bapiret2-number = 100.
    WHEN 'W'.
      gs_bapiret2-number = 200.
    WHEN 'S'.
      gs_bapiret2-number = 300.
  ENDCASE.
  gs_bapiret2-type = p_type.
  gs_bapiret2-message = p_message.
  APPEND gs_bapiret2 TO gt_data-bapiret2.
  SORT gt_data-bapiret2 BY number type message.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_MESSAGE2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_message2 USING p_type p_message.

* 'S'는 Bapi stack에 쌓지 않음...
  CLEAR: gs_bapiret2.
  CASE p_type.
    WHEN 'E'.
      gs_bapiret2-number = 100.
    WHEN 'W'.
      gs_bapiret2-number = 200.
    WHEN 'S'.
      gs_bapiret2-number = 300.
  ENDCASE.
  gs_bapiret2-type = p_type.
  gs_bapiret2-message = p_message.
  APPEND gs_bapiret2 TO gt_copy-bapiret2.       "/////
  SORT gt_copy-bapiret2 BY number type message. "/////

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
  DATA: lv_seark TYPE seark.

  READ TABLE gt_data INDEX p_row.
  CASE p_column.
    WHEN 'SHORT'.
      CHECK gt_data-objid IS NOT INITIAL.
      PERFORM call_transaction_piqst00(zcmsubpool)
        USING gt_data-objid.
    WHEN 'SMOBJID'.
      lv_seark = gt_data-smobjid.
    WHEN '2SMOBJID'.
      lv_seark = gt_data-2smobjid.
    WHEN 'OBJID1'.
      lv_seark = gt_data-objid1.
    WHEN 'OBJID2'.
      lv_seark = gt_data-objid2.
    WHEN 'OBJID3'.
      lv_seark = gt_data-objid3.
    WHEN 'OBJID4'.
      lv_seark = gt_data-objid4.
    WHEN 'OBJID5'.
      lv_seark = gt_data-objid5.
  ENDCASE.

  CHECK lv_seark IS NOT INITIAL.
  CHECK lv_seark <> '00000000'.

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
*&      Form  ASSIGN_GRID_EVENT_HANDLERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM assign_grid_event_handlers.
* GRID Event receiver object 선언.
  CREATE OBJECT g_event_receiver_grid.
* Hotspot Click
  SET HANDLER g_event_receiver_grid->handle_hotspot_click
                                     FOR g_grid.
ENDFORM.                    " ASSIGN_GRID_EVENT_HANDLERS
*&---------------------------------------------------------------------*
*&      Form  GET_PREVSYM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_prevsym .

  CHECK gt_data-2smobjid IS NOT INITIAL.

  READ TABLE gt_acwk WITH KEY objid   = gt_data-objid "ST
                              peryr   = gt_data-2peryr
                              perid   = gt_data-2perid
                              smobjid = gt_data-2smobjid
                              BINARY SEARCH.
  IF sy-subrc = 0.
    gt_data-2smshort      = gt_acwk-smshort.
    gt_data-2smstext      = gt_acwk-smstext.
    gt_data-2cpattemp     = gt_acwk-cpattemp.
    gt_data-2gradesym     = gt_acwk-gradesym.
    gt_data-2grade        = gt_acwk-grade.
    gt_data-2gradescale   = gt_acwk-gradescale.
    gt_data-2transferflag = gt_acwk-transferflag.
    gt_data-2agrnotrated  = gt_acwk-agrnotrated.
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
FORM set_prev_period.

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
FORM set_next_period.

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
*&      Form  SET_PROGBAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_progbar USING p_msg.

  DATA: lv_msg TYPE string.
  CONCATENATE `[ ` p_msg ` ] 항목을 조회중입니다.` INTO lv_msg.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = lv_msg
    EXCEPTIONS
      OTHERS = 0.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_HIGHER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_higher .

* 수강신청룰 METHOD='H'인 대학원의 이전과목 인정건
  READ TABLE gt_506_re_cur
    WITH KEY objid = gt_data-objid "ST
             peryr = gt_data-2peryr
             perid = gt_data-2perid
             sm_id = gt_data-2smobjid
             BINARY SEARCH.
  IF sy-subrc = 0.
    READ TABLE gt_506_re_cur
      WITH KEY objid = gt_data-objid "ST
               reperyr = gt_data-peryr
               reperid = gt_data-perid
               sm_id = gt_data-smobjid. "BINARY SEARCH.
    IF sy-subrc = 0.
      PERFORM add_message USING 'W' '【재이수】 과거성적 인정'. "높은성적 재이수용도...
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHK_DAT1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chk_dat1 .

  PERFORM set_progbar USING '재이수 처리점검'.
  LOOP AT gt_data.
    "수강신청룰
    READ TABLE gt_rule WITH KEY orgcd = gt_data-orgcd BINARY SEARCH.
    IF sy-subrc = 0.
*----------------------------------------------------------------------*
      "재이수 점검
      READ TABLE gt_506_re_cur
        WITH KEY objid = gt_data-objid "ST
                 peryr = gt_data-peryr
                 perid = gt_data-perid
                 sm_id = gt_data-smobjid BINARY SEARCH.
***** 재이수 기처리
      IF sy-subrc = 0.
        gt_data-retake = 'X'.
        IF gt_data-modrepeattype = '0005'.
          PERFORM add_message USING 'E' '【재이수】 미대상 처리'.
        ELSE.
          IF gt_data-2peryr = gt_506_re_cur-reperyr AND
             gt_data-2perid = gt_506_re_cur-reperid AND
             gt_data-2smobjid = gt_506_re_cur-resmid.
            IF gt_rule-notallow1 CS gt_data-2gradesym AND gt_data-2gradesym IS NOT INITIAL.
              gv_msg = '【재이수】 수강불가 성적(' && gt_data-2gradesym && ') 신청/처리'.
              PERFORM add_message USING 'E' gv_msg.
            ELSE.
*             PERFORM add_message USING 'S' ''. "정상(재이수)
            ENDIF.
          ELSE.
            gt_data-pexct = 'X'.
            gt_data-2peryr = gt_506_re_cur-reperyr.
            gt_data-2perid = gt_506_re_cur-reperid.
            gt_data-2smobjid = gt_506_re_cur-resmid.
            PERFORM get_prevsym. "이전과목 정보...
            PERFORM add_message USING 'W' '【재이수】 처리된 이전과목 다름'.
          ENDIF.
        ENDIF.
        IF gt_data-alt_scaleid <> gt_rule-gradescale AND
           gt_data-alt_scaleid <> 'KRNP' AND
           gt_data-alt_scaleid <> 'KRSU'.
          gv_msg = '【재이수】 수강스케일(' && gt_data-alt_scaleid && ') 확인'.
          PERFORM add_message USING 'W' gv_msg.
        ENDIF.
        IF gt_rule-notallow2 CS gt_data-gradesym AND gt_data-gradesym IS NOT INITIAL.
          gv_msg = '【재이수】 성적(' && gt_data-gradesym && ') 초과부여'.
          PERFORM add_message USING 'E' gv_msg.
        ENDIF.
        IF gt_rule-method = 'H' AND gt_data-grade < gt_data-2grade AND
           gt_data-gradesym IS NOT INITIAL AND gt_data-2gradesym IS NOT INITIAL.
          gv_msg = '【재이수】 성적(' && gt_data-2gradesym && '→' && gt_data-gradesym && ') 낮아짐'.
          PERFORM add_message USING 'E' gv_msg.
        ENDIF.
        IF gt_rule-method = 'F' AND gt_data-grade < gt_data-2grade AND
           gt_data-gradesym IS NOT INITIAL AND gt_data-2gradesym IS NOT INITIAL.
          gv_msg = '【재이수】 성적 낮아짐'.
          PERFORM add_message USING 'W' gv_msg.
        ENDIF.
        IF gt_data-cpattemp <> gt_data-2cpattemp.
          PERFORM add_message USING 'W' '【재이수】 학점 다름'.
        ENDIF.
        IF gt_data-2transferflag = 'X'.
          PERFORM add_message USING 'W' '【재이수】 인정과목 재수강'.
        ENDIF.
        IF gt_data-cgpa IS INITIAL AND gt_data-2agrnotrated = 'X'.
          PERFORM add_message USING 'W' '【재이수】 관련없음(R) 재수강'.
        ENDIF.

*(재이수횟수관련 로직변경: 2020.08.11 김상현
        IF gt_rule-orgcd = '0011' AND p_peryr && p_perid >= '2020020'.
          gt_data-total12 = gt_506_re_cur-total12.
          IF p_perid = '010' OR p_perid = '020'. "정규학기만
            IF gt_data-total12 > 8.
              gv_msg = '【재이수】 정규합산 허용횟수(' && gt_data-total12  && '/8회) 초과'.
              PERFORM add_message USING 'E' gv_msg. "필수과목 F성적은 +1허용(수동)
            ENDIF.
          ENDIF.
        ELSE.
*((((기존로직...
          IF gt_rule-orgcd = '0011'. "유예/제적경고
            READ TABLE gt_yuye WITH KEY objid = gt_data-objid BINARY SEARCH. "ST
            IF sy-subrc = 0.
              ADD 1 TO gt_rule-session. "유예/제적경고자 +1허용(자동)
            ENDIF.
          ENDIF.
          gt_data-session = gt_506_re_cur-session.
          IF gt_rule-session < gt_data-session.
            gv_msg = '【재이수】 학기당 허용횟수(' && gt_data-session && '/' && gt_rule-session && '회) 초과'.
            PERFORM add_message USING 'E' gv_msg.
          ENDIF.
          gt_data-module = gt_506_re_cur-module.
          IF gt_rule-module  < gt_data-module.
            gv_msg = '【재이수】 과목당 허용횟수(' && gt_data-module && '/' && gt_rule-module  && '수강) 초과'.
            PERFORM add_message USING 'E' gv_msg. "필수과목 F성적은 +1허용(수동)
          ENDIF.
*))))
        ENDIF.
*)
***** 재이수 미처리
      ELSE.
        IF gt_data-modrepeattype = '0005'.
*         PERFORM add_message USING 'S' ''. "정상(초수강)
        ELSE.
          IF gt_data-2smobjid IS NOT INITIAL.
            IF gt_rule-notallow1 CS gt_data-2gradesym AND gt_data-2gradesym IS NOT INITIAL.
              gv_msg = '【재이수】 수강불가 성적(' && gt_data-2gradesym && ') 신청'.
              PERFORM add_message USING 'E' gv_msg.
            ELSE.
              PERFORM add_message USING 'E' '【재이수】 처리 누락'.
            ENDIF.
          ELSE.
*           PERFORM add_message USING 'S' ''. "정상(초수강)
          ENDIF.
        ENDIF.
        PERFORM get_higher. "이전과목 인정건
        IF gt_data-transferflag IS INITIAL AND "이전아님
           gt_data-scaleid <> gt_data-alt_scaleid.
*         gv_msg = '【수강조건】 수강스케일(' && gt_data-alt_scaleid && ') 다름'.
          PERFORM add_message USING 'W' '【수강조건】 수강스케일 다름'. "gv_msg.
        ENDIF.
        IF gt_data-transferflag IS INITIAL AND "이전아님
           gt_data-scaleid <> gt_data-gradescale AND
           gt_data-gradescale IS NOT INITIAL.
*         gv_msg = '【수강조건】 평가스케일(' && gt_data-gradescale  && ') 다름'.
          PERFORM add_message USING 'W' '【수강조건】 평가스케일 다름'. "gv_msg.
        ENDIF.
      ENDIF.
*----------------------------------------------------------------------*
    ELSE.
      PERFORM add_message USING 'E' 'Rule not found'.
    ENDIF.
    MODIFY gt_data.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHK_DAT2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chk_dat2 .

  DATA: lv_len TYPE i, lv_chr TYPE c. "학번마지막
  DATA: lt_scadd TYPE TABLE OF swhactor WITH HEADER LINE, "하위소속(add)
        lt_sctot TYPE TABLE OF swhactor WITH HEADER LINE. "하위소속(tot)
  DATA: lv_error TYPE c. "소속제한오류

  PERFORM set_progbar USING '기타 수강점검'.
  LOOP AT gt_data.
    READ TABLE gt_evob WITH KEY seobjid = gt_data-packnumber BINARY SEARCH.
    IF sy-subrc = 0.
      IF gt_evob-orgcd <> gt_data-orgcd.
        PERFORM add_message USING 'W' '【수강조건】 타학과소속 수강생'.
      ENDIF.
      IF gt_evob-oddevfg IS NOT INITIAL.
        IF gt_data-short IS NOT INITIAL.
          lv_len = strlen( gt_data-short ) - 1.
          lv_chr = gt_data-short+lv_len.
          IF gt_evob-oddevfg NS lv_chr.
            PERFORM add_message USING 'E' '【수강조건】 짝홀반 선택오류'.
          ENDIF.
        ELSE.
          PERFORM add_message USING 'W' '【수강조건】 학번 확인불가'.
        ENDIF.
      ENDIF.
      IF gt_evob-intstfg = 'X'. "ZCM_GET_RELEVAL_EXCEPT 참고...
        IF gt_data-natio = 'KR' AND "내국인
           gt_data-apply_qual_cd <> '6082' AND "새터민아님
           gt_data-apply_qual_cd <> '7040'.
          PERFORM add_message USING 'E' '【수강조건】 국제학생(새터민) 전용'.
        ENDIF.
      ENDIF.
    ELSE.
      IF gv_orgcd = gt_data-orgcd. "본학과소속생일때만...
        PERFORM add_message USING 'W' '【수강조건】 타소속과목 수강생'.
      ENDIF.
    ENDIF.
*(변경잠금: 2019.09.09
    IF gt_data-lockflag = 'X'.
      PERFORM add_message USING 'E' '【수강조건】 과목 변경잠금'.
    ENDIF.
*)
    IF gt_data-perid = '010' OR gt_data-perid = '020'.
      IF gt_data-stscd <> '1000' AND gt_data-stscd <> '4000'.
        PERFORM add_message USING 'W' '【수강조건】 재학/수료외 수강생'.
      ENDIF.
    ELSE.
      IF gt_data-stscd <> '1000' AND gt_data-stscd <> '2000' AND gt_data-stscd <> '4000'.
        PERFORM add_message USING 'W' '【수강조건】 재학/휴학/수료외 수강생'.
      ENDIF.
    ENDIF.
    IF gt_data-alt_scaleid IS INITIAL.
      PERFORM add_message USING 'W' '【수강조건】 수강스케일 누락'.
*(추가함: 2019.08.21 김상현
    ELSE.
      IF gt_data-alt_scaleid <> gt_data-scaleid AND
         gt_data-alt_scaleid <> 'KRR2'.
        PERFORM add_message USING 'W' '【수강조건】 수강스케일 다름'.
      ENDIF.
*)
    ENDIF.
    MODIFY gt_data.
  ENDLOOP.

*----------------------------------------------------------------------*

  DEFINE get_orgunit.
    IF gt_9550-book_fg&1 IS NOT INITIAL.
      CLEAR: lt_scadd[], lt_scadd.
      CALL FUNCTION 'HRIQ_STRUC_GET'
        EXPORTING
          act_otype      = 'O'
          act_objid      = gt_9550-book_org&1
          act_wegid      = 'O-SC'
          act_plvar      = '01'
          act_begda      = gv_keyda
          act_endda      = gv_keyda
          act_tdepth     = 0
        TABLES
          result_tab     = lt_scadd
        EXCEPTIONS
          no_plvar_found = 1
          no_entry_found = 2
          internal_error = 3
          OTHERS         = 4.
      APPEND LINES OF lt_scadd TO lt_sctot.
    ENDIF.
  END-OF-DEFINITION.

  PERFORM set_progbar USING '소속제한 점검'.
  LOOP AT gt_9550. "제한과목만
    CLEAR: lt_sctot[], lt_sctot.
    get_orgunit: 01,02,03,04,05,06,07,08,09,10,11,12,13,14,15.

    DELETE lt_sctot WHERE otype NE 'SC'.
    SORT lt_sctot BY objid.
    DELETE ADJACENT DUPLICATES FROM lt_sctot COMPARING objid.
    CHECK lt_sctot[] IS NOT INITIAL.

* 같은 분반은 같은 수강구분을 넣는다는 전제하에 진행....
    READ TABLE gt_data WITH KEY packnumber = gt_9550-objid BINARY SEARCH.
    IF sy-subrc = 0.
      LOOP AT gt_data FROM sy-tabix.
        IF gt_data-packnumber <> gt_9550-objid.
          EXIT.
        ENDIF.
        CASE gt_9550-book_fg01.
          WHEN '1'. "1  가능(전체전공)
            lv_error = 'X'.
            LOOP AT lt_sctot.
              IF gt_data-sc1id = lt_sctot-objid OR
                 gt_data-sc2id = lt_sctot-objid OR
                 gt_data-sc3id = lt_sctot-objid.
                CLEAR: lv_error. "OK
                EXIT.
              ENDIF.
            ENDLOOP.
            IF lv_error = 'X'.
              PERFORM add_message USING 'E' '【수강조건】 소속제한 가능(A) 위반'.
            ENDIF.
          WHEN '3'. "3  가능(1전공)
            lv_error = 'X'.
            LOOP AT lt_sctot.
              IF gt_data-sc1id = lt_sctot-objid.
                CLEAR: lv_error. "OK
                EXIT.
              ENDIF.
            ENDLOOP.
            IF lv_error = 'X'.
              PERFORM add_message USING 'E' '【수강조건】 소속제한 가능(1) 위반'.
            ENDIF.
          WHEN '2'. "2  불가(전체전공)
            CLEAR: lv_error.
            LOOP AT lt_sctot.
              IF gt_data-sc1id = lt_sctot-objid OR
                 gt_data-sc2id = lt_sctot-objid OR
                 gt_data-sc3id = lt_sctot-objid.
                lv_error = 'X'. "ERROR
                EXIT.
              ENDIF.
            ENDLOOP.
            IF lv_error = 'X'.
              PERFORM add_message USING 'E' '【수강조건】 소속제한 불가(A) 위반'.
            ENDIF.
          WHEN '4'. "4  불가(1전공)
            CLEAR: lv_error.
            LOOP AT lt_sctot.
              IF gt_data-sc1id = lt_sctot-objid.
                lv_error = 'X'. "ERROR
                EXIT.
              ENDIF.
            ENDLOOP.
            IF lv_error = 'X'.
              PERFORM add_message USING 'E' '【수강조건】 소속제한 불가(1) 위반'.
            ENDIF.
        ENDCASE.
        MODIFY gt_data.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHK_DAT3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chk_dat3 .

  DATA: lv_error TYPE c. "수강가능여부

*(gt_acwk[]의 활용순서에 주의하세요.
  DELETE gt_acwk WHERE smstatus <> '02'. "완료(성공)만 인정
  DELETE gt_acwk WHERE agrnotrated = 'X'. "관련없음 삭제
  SORT gt_acwk BY objid smobjid. "소트
*)

  PERFORM set_progbar USING '선수과목 미이수점검'.
  LOOP AT gt_data.
    "수강신청룰
    READ TABLE gt_rule WITH KEY orgcd = gt_data-orgcd BINARY SEARCH.
    IF sy-subrc = 0.
      CHECK gt_rule-presubj = 'X'.
*     CHECK gt_data-short+0(1) <> 'G'. "교환학생 SKIP
*----------------------------------------------------------------------*
      CLEAR: lv_error.
      LOOP AT gt_101a WHERE subty = 'A529' AND objid = gt_data-smobjid. "SM(선수과목)
        READ TABLE gt_acwk WITH KEY objid   = gt_data-objid "ST
                                    smobjid = gt_101a-sobid
                                    BINARY SEARCH.
        IF sy-subrc <> 0. "이수과목에 없으면 ERROR
          lv_error = 'X'.
          LOOP AT gt_101b WHERE ( subty = 'B511' OR subty = 'AZ30' ) AND objid = gt_101a-sobid. "SM(대체/선택과목)
            READ TABLE gt_acwk WITH KEY objid   = gt_data-objid "ST
                                        smobjid = gt_101b-sobid
                                        BINARY SEARCH.
            IF sy-subrc = 0. "단, 대체/선택과목에 있으면 PASS
              CLEAR: lv_error.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF lv_error = 'X'. EXIT. ENDIF. "더이상 볼필요없음
        ENDIF.
      ENDLOOP.
      IF lv_error = 'X'.
        PERFORM add_message USING 'E' '【수강조건】 선수과목 미이수'.
      ENDIF.
*----------------------------------------------------------------------*
    ELSE.
      PERFORM add_message USING 'E' 'Rule not found'.
    ENDIF.
    MODIFY gt_data.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHK_DAT4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chk_dat4 .

  PERFORM set_progbar USING '학생별 수업시간표'.
  CLEAR: gt_time[], gt_time.
  LOOP AT gt_data.
    READ TABLE gt_evob WITH KEY seobjid = gt_data-packnumber BINARY SEARCH. "SE
    IF sy-subrc = 0.
      READ TABLE gt_1716 WITH KEY tabnr = gt_evob-eobjid BINARY SEARCH. "E
      IF sy-subrc = 0.
        LOOP AT gt_1716 FROM sy-tabix.
          IF gt_1716-tabnr <> gt_evob-eobjid. EXIT. ENDIF.
          MOVE-CORRESPONDING gt_1716 TO gt_time.
          gt_time-objid      = gt_data-objid.
          gt_time-packnumber = gt_data-packnumber.
          APPEND gt_time.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDLOOP.
  SORT gt_time BY objid packnumber.

  PERFORM set_progbar USING '수업시간 중복점검'.
  CLEAR: gt_dupl[], gt_dupl.
  gt_dupl[] = gt_time[].
  SORT gt_dupl BY objid packnumber timedup.

  LOOP AT gt_time.
    CHECK NOT ( gt_time-sunday = 'X' AND gt_time-beguz+0(2) = '00' ). "일요일 제외
    READ TABLE gt_dupl WITH KEY objid = gt_time-objid BINARY SEARCH. "ST
    IF sy-subrc = 0.
      LOOP AT gt_dupl FROM sy-tabix.
        IF gt_dupl-objid     <> gt_time-objid.      EXIT.     ENDIF. "동일학생
        IF gt_dupl-packnumber = gt_time-packnumber. CONTINUE. ENDIF. "다른과목
        IF ( gt_dupl-monday    = 'X' AND gt_time-monday    = 'X' ) OR
           ( gt_dupl-tuesday   = 'X' AND gt_time-tuesday   = 'X' ) OR
           ( gt_dupl-wednesday = 'X' AND gt_time-wednesday = 'X' ) OR
           ( gt_dupl-thursday  = 'X' AND gt_time-thursday  = 'X' ) OR
           ( gt_dupl-friday    = 'X' AND gt_time-friday    = 'X' ) OR
           ( gt_dupl-saturday  = 'X' AND gt_time-saturday  = 'X' ) OR
           ( gt_dupl-sunday    = 'X' AND gt_time-sunday    = 'X' ).
          IF gt_dupl-beguz < gt_time-enduz AND
             gt_dupl-enduz > gt_time-beguz.
            gt_time-timedup = 'X'.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
    MODIFY gt_time.
  ENDLOOP.
  SORT gt_time BY objid packnumber timedup. "timedup 추가함: 시간2type일때 read못하는 문제

  LOOP AT gt_data.
    "수강신청룰
    READ TABLE gt_rule WITH KEY orgcd = gt_data-orgcd BINARY SEARCH.
    IF sy-subrc = 0.
      CHECK gt_rule-timedup = 'X'.
*----------------------------------------------------------------------*
      READ TABLE gt_time WITH KEY objid      = gt_data-objid      "ST
                                  packnumber = gt_data-packnumber "SE
                                  timedup    = 'X'
                                  BINARY SEARCH.
      IF sy-subrc = 0.
*        IF gt_time-timedup = 'X'.
        PERFORM add_message USING 'E' '【수강조건】 수업시간 중복'.
*        ENDIF.
      ENDIF.
*----------------------------------------------------------------------*
    ELSE.
      PERFORM add_message USING 'E' 'Rule not found'.
    ENDIF.
    MODIFY gt_data.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHK_DAT5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chk_dat5 .

  DATA: lv_msg TYPE string.

  LOOP AT gt_data.
    "수강신청룰
    READ TABLE gt_rule WITH KEY orgcd = gt_data-orgcd BINARY SEARCH.
    IF sy-subrc = 0.
*----------------------------------------------------------------------*
      CASE gt_data-orgcd.
        WHEN '0011' OR '0008' OR '0003'. "학부/정통대/공대원
          READ TABLE gt_1705 WITH KEY objid = gt_data-objid BINARY SEARCH. "ST
          IF sy-subrc = 0.
            gt_data-regwindow = gt_1705-regwindow.
            gt_data-regsemstr = gt_1705-regsemstr.
            gt_data-book_cdt  = gt_1705-book_cdt.
          ENDIF.
        WHEN OTHERS.
          CASE p_perid.
            WHEN '010' OR '020'.
              gt_data-book_cdt = gt_rule-regular. "정규학기
            WHEN '011' OR '021'.
              gt_data-book_cdt = gt_rule-season.  "계절학기
          ENDCASE.
      ENDCASE.
*(학점등록(학부):2019.09.03
      READ TABLE gt_2040 WITH KEY objid = gt_data-objid BINARY SEARCH. "ST
      IF sy-subrc = 0.
        gt_data-regi_cdt = gt_2040-status2. "학점등록신청(학부)...
        IF gt_data-regi_cdt NOT BETWEEN 1 AND 9.
          PERFORM add_message USING 'E' '【학점등록】 신청학점범위(1-9) 오류'.
        ENDIF.
        IF ( gt_data-regi_cdt BETWEEN 1 AND 3 AND gt_data-book_cdt <> 3 ) OR
           ( gt_data-regi_cdt BETWEEN 4 AND 6 AND gt_data-book_cdt <> 6 ) OR
           ( gt_data-regi_cdt BETWEEN 7 AND 9 AND gt_data-book_cdt <> 9 ).
          PERFORM add_message USING 'E' '【학점등록】 수강가능학점(구간) 다름'.
        ENDIF.
        IF gt_data-book_cdt < gt_data-cpattemp.
          PERFORM add_message USING 'E' '【학점등록】 수강가능학점(구간) 초과'.
        ENDIF.
        IF ( gt_data-book_cdt BETWEEN 4 AND 6 AND gt_data-cpattemp <= 3 ) OR
           ( gt_data-book_cdt BETWEEN 7 AND 9 AND gt_data-cpattemp <= 6 ).
          PERFORM add_message USING 'W' '【학점등록】 수강가능학점(구간) 미만'.
        ENDIF.
*)
      ELSE.
        IF gt_data-book_cdt IS INITIAL.
          PERFORM add_message USING 'E' '【수강학점】 수강가능학점 누락'.
        ELSEIF gt_data-book_cdt < gt_data-cpattemp.
          PERFORM add_message USING 'E' '【수강학점】 수강가능학점 초과'.
        ENDIF.
        IF p_perid = '010' OR p_perid = '020'. "정규학기
          IF gt_data-book_cnt = 0.
            PERFORM add_message USING 'E' '【수강학점】 정규학기 미수강(재학)'.
          ELSE.
            IF gt_data-orgcd = '0011' OR gt_data-orgcd = '0031'. "학부, 법학전문대학원(20220329)
              IF gt_data-cpattemp < 9.
                IF gt_data-cpattemp = 0.
                  PERFORM add_message USING 'W' '【수강학점】 정규학기 9학점 미만(무학점)'.
                ELSE.
                  PERFORM add_message USING 'W' '【수강학점】 정규학기 9학점 미만'.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF gt_data-fg_cu > 6.
        PERFORM add_message USING 'E' '【CU수강학점】 수강가능학점(6학점) 초과'.
      ENDIF.



*----------------------------------------------------------------------*
    ELSE.
      PERFORM add_message USING 'E' 'Rule not found'.
    ENDIF.
    MODIFY gt_data.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_file.

  DATA: filepath LIKE sapb-sappfad.
  DATA: filename TYPE string.
  DATA: ls_fcat TYPE lvc_s_fcat,
        lv_fld  TYPE string,
        lv_val  TYPE string.
  FIELD-SYMBOLS <fs> TYPE any.
  DATA: lv_bgcol(6).

  CONCATENATE '수강신청점검(' p_orgcd ')_' sy-datum+2 '_' sy-uzeit '.xls' INTO filename.
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
    t USING `<tr bgcolor="#F2E1AF">`.

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
*(색상
      lv_bgcol = 'EEF9FD'.
      CASE ls_fcat-fieldname.
        WHEN 'ORGCD' OR 'ORGCX' OR 'SHORT' OR 'STEXT'
          OR 'SC1TX' OR 'SC2TX' OR 'SC3TX'
          OR 'STSCD' OR 'STAT2'.  lv_bgcol = '9ACCEE'.
        WHEN 'TYPE' OR 'MESSAGE'.
          lv_bgcol = 'FEFEB8'.
      ENDCASE.
      IF ls_fcat-fieldname+0(1) = '2'  OR
         ls_fcat-fieldname = 'P9562'   OR
         ls_fcat-fieldname = 'PEXCT'   OR
         ls_fcat-fieldname = 'SESSION' OR
         ls_fcat-fieldname = 'MODULE'.
        lv_bgcol = 'CEF8AE'.
      ENDIF.
*)
      CLEAR: lv_fld.
      CONCATENATE 'gt_data-' ls_fcat-fieldname INTO lv_fld.
      ASSIGN (lv_fld) TO <fs>.
      lv_val = <fs>.
      CONDENSE lv_val.
      TRANSLATE lv_val USING `"〃`.
      CONCATENATE `<td bgcolor="#` lv_bgcol `">` lv_val `</td>`
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
*&      Form  SHOW_PIC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_pic .

  repid = sy-repid.
  IF docking IS INITIAL .
    CREATE OBJECT docking
      EXPORTING
        repid                       = repid
        dynnr                       = sy-dynnr
        side                        = cl_gui_docking_container=>dock_at_right
        extension                   = '272'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT picture_control_1 EXPORTING parent = docking.

    CHECK sy-subrc = 0.
    CALL METHOD picture_control_1->set_3d_border
      EXPORTING
        border = 0.

    CALL FUNCTION 'DP_PUBLISH_WWW_URL'
      EXPORTING
        objid    = 'ZCMRA121'
        lifetime = 'T'
      IMPORTING
        url      = url
      EXCEPTIONS
        OTHERS   = 1.

* Load the picture by using the url generated by the data provider.
    IF sy-subrc = 0.
      CALL METHOD picture_control_1->load_picture_from_url_async
        EXPORTING
          url = url.
    ENDIF.
  ENDIF .

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORM_GET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM form_get .
  CALL FUNCTION 'ZCM_MANUAL_PUBLISH'
    EXPORTING
      file_name = 'ZCMRA121'.
ENDFORM.                    " FORM_GET
*&---------------------------------------------------------------------*
*&      Form  GET_STATS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_stats.

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
  SORT gt_stat BY message count DESCENDING.

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
      WHEN 'TYPE'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '타입'.
        ls_fcat-key = 'X'.
      WHEN 'MESSAGE'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '비고(더블클릭->필터적용)'.
        ls_fcat-outputlen = 48.
        ls_fcat-do_sum = 'X'.
      WHEN 'COUNT'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '갯수'.
        ls_fcat-outputlen = 7.
        ls_fcat-do_sum = 'X'.
      WHEN OTHERS.
        ls_fcat-no_out = 'X'.
    ENDCASE.
    MODIFY lt_fieldcat FROM ls_fcat.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title       = '에러/경고 통계'
      i_tabname     = 'GT_STAT'
      it_fieldcat   = lt_fieldcat
    IMPORTING
      es_selfield   = lv_selec
    TABLES
      t_outtab      = gt_stat
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.

  DATA lt_filt_old TYPE lvc_t_filt.
  CLEAR lt_filt_old.
  lt_filt_old = gt_filt.
  IF lv_selec-fieldname = 'COUNT'.
    MESSAGE '통계(필터) 비고를 더블클릭 하세요.' TYPE 'I'.
    gt_filt = lt_filt_old.
    EXIT.
  ENDIF.

* 필터설정
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
*&      Form  SET_CEXCN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_cexcn .

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        ls_fcat     TYPE slis_fieldcat_alv,
        lv_selec    TYPE slis_selfield.
  DATA: lv_cnt TYPE i.

  CHECK gt_cexcn[] IS NOT INITIAL.

  CLEAR: gt_stat2[], gt_stat2.
  SELECT short stext
    INTO CORRESPONDING FIELDS OF TABLE gt_stat2
    FROM hrp1000
   WHERE plvar  = '01'
     AND otype  = 'SM'
     AND objid IN gt_cexcn
     AND langu  = '3'
     AND begda <= sy-datum "gv_keyda
     AND endda >= sy-datum."gv_keyda.
  SORT gt_stat2 BY short.

  LOOP AT gt_stat2.
    ADD 1 TO lv_cnt.
    gt_stat2-seqnr = lv_cnt.
    MODIFY gt_stat2.
  ENDLOOP.

  CHECK gt_stat2[] IS NOT INITIAL.

  CLEAR: lt_fieldcat[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'GT_STAT2'
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
      WHEN 'SEQNR'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '순번'.
        ls_fcat-key = 'X'.
        ls_fcat-outputlen = 4.
      WHEN 'SHORT'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '과목코드'.
        ls_fcat-key = 'X'.
        ls_fcat-outputlen = 8.
      WHEN 'STEXT'.
        ls_fcat-seltext_l =
        ls_fcat-seltext_m =
        ls_fcat-seltext_s =
        ls_fcat-reptext_ddic = '과목명'.
        ls_fcat-outputlen = 40.
      WHEN OTHERS.
        ls_fcat-no_out = 'X'.
    ENDCASE.
    MODIFY lt_fieldcat FROM ls_fcat.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title       = '수강학점 합산제외 대상과목'
      i_tabname     = 'GT_STAT2'
      it_fieldcat   = lt_fieldcat
    IMPORTING
      es_selfield   = lv_selec
    TABLES
      t_outtab      = gt_stat2
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_message .

*  DATA: lv_cnt TYPE i.

* 'E','W'내역 gt_data(1)->gt_copy(1)
  CLEAR: gt_copy[], gt_copy.
  LOOP AT gt_data.
    CHECK gt_data-bapiret2[] IS NOT INITIAL.
    MOVE-CORRESPONDING gt_data TO gt_copy.
    APPEND gt_copy.
    DELETE gt_data.
  ENDLOOP.

  IF p_error = 'X'. "에러만...
    CLEAR: gt_data[], gt_data.
  ENDIF.

* 'E','W'내역 gt_copy(1)->gt_data(n)
  LOOP AT gt_copy.
    CHECK gt_copy-bapiret2[] IS NOT INITIAL.
    MOVE-CORRESPONDING gt_copy TO gt_data.
    LOOP AT gt_copy-bapiret2[] INTO gs_bapiret2.
      MOVE-CORRESPONDING gs_bapiret2 TO gt_data.
      APPEND gt_data.
    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_USERLEV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_userlev .

  CLEAR: gv_userlev. "A:관리자,R:학사지원팀,G:대학원행정팀,U:학부행정팀

  SELECT COUNT(*)
    FROM agr_users
   WHERE uname     = sy-uname
     AND from_dat <= sy-datum
     AND to_dat   >= sy-datum
     AND agr_name = 'Z_IT_ADMIN'. "정보통신원
  IF sy-dbcnt > 0.
    gv_userlev = 'A'.
    EXIT.
  ENDIF.

  SELECT COUNT(*)
    FROM agr_users
   WHERE uname     = sy-uname
     AND from_dat <= sy-datum
     AND to_dat   >= sy-datum
     AND agr_name = 'Z_CM_02'. "학사지원팀
  IF sy-dbcnt > 0.
    gv_userlev = 'R'.
    EXIT.
  ENDIF.

  SELECT COUNT(*)
    FROM agr_users
   WHERE uname     = sy-uname
     AND from_dat <= sy-datum
     AND to_dat   >= sy-datum
     AND agr_name LIKE 'Z_CM_07%'. "대학원행정팀
  IF sy-dbcnt > 0.
    gv_userlev = 'G'.
    EXIT.
  ENDIF.

  SELECT COUNT(*)
    FROM agr_users
   WHERE uname     = sy-uname
     AND from_dat <= sy-datum
     AND to_dat   >= sy-datum
     AND agr_name LIKE 'Z_CM_06%'. "학부행정팀
  IF sy-dbcnt > 0.
    gv_userlev = 'U'.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_POSTFLR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_postflr .

  IF p_titel = 'X'.
    DELETE gt_data WHERE titel <> 'A0'. "비정규생 삭제
  ENDIF.

*  IF sy-mandt = '100'.
*    DELETE gt_data WHERE stscd = '5000'. "졸업삭제
*  ENDIF.

* 재이수가비지 외 삭제...: 2019.10.07 김상현
  DELETE gt_data WHERE smstatus = '04' AND message <> gv_garbage.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_ADDRESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_address .

  CHECK gt_copy[] IS NOT INITIAL. "에러대상자만...

  PERFORM set_progbar USING '학생 연락처/이메일'.
  CLEAR: gt_addr[], gt_addr.
  LOOP AT gt_copy.
    gt_addr-objid = gt_copy-objid.
    APPEND gt_addr.
  ENDLOOP.
  SORT gt_addr BY objid.
  DELETE ADJACENT DUPLICATES FROM gt_addr COMPARING objid.

  CALL FUNCTION 'ZCM_STUDENT_EMAIL_CELL'
    EXPORTING
      i_gubun    = 'XXDEFAULT'
    TABLES
      t_zcms0640 = gt_addr.

  LOOP AT gt_data.
    READ TABLE gt_addr WITH KEY objid = gt_data-objid BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data-email = gt_addr-email.
      gt_data-cell  = gt_addr-cell.
    ENDIF.
    MODIFY gt_data.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_GARBAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_garbage.

  gv_garbage = '【재이수】 재이수과목 취소됨(가비지)'.

  SORT gt_data BY objid peryr perid sobid.
  CLEAR: gt_copy[], gt_copy.
  LOOP AT gt_506_re_cur.
    READ TABLE gt_data WITH KEY objid = gt_506_re_cur-objid
                                peryr = gt_506_re_cur-peryr
                                perid = gt_506_re_cur-perid
                                sobid = gt_506_re_cur-sm_id BINARY SEARCH. "SM
    IF sy-subrc <> 0. "취소된 과목이면...
      CLEAR: gt_copy.
      gt_copy-objid    = gt_506_re_cur-objid.
      gt_copy-peryr    = gt_506_re_cur-peryr.
      gt_copy-perid    = gt_506_re_cur-perid.
      gt_copy-sobid    = gt_506_re_cur-sm_id. "SM
      gt_copy-smstatus = '04'. "취소과목...
      PERFORM add_message2 USING 'E' gv_garbage.
      APPEND gt_copy.
    ENDIF.
  ENDLOOP.
  APPEND LINES OF gt_copy TO gt_data.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_SMGROUP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_smgroup .

  CLEAR: gt_smobj[], gt_smobj.
  gt_smobj-sign   = 'I'.
  gt_smobj-option = 'EQ'.
  gt_smobj-low    = gt_506_re-sm_id.
  APPEND gt_smobj. "자신(필수)

  LOOP AT gt_101b WHERE subty = 'B511' AND objid = gt_506_re-sm_id.
    gt_smobj-low = gt_101b-sobid.
    APPEND gt_smobj. "대체(옵션)
  ENDLOOP.

  SORT gt_smobj BY low.
  DELETE ADJACENT DUPLICATES FROM gt_smobj COMPARING low. "중복제거

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_STTG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_sttg .

  PERFORM set_progbar USING '대상학생(학번기준)'.
  CLEAR: gt_stobj[], gt_stobj.
  IF p_stnum[] IS NOT INITIAL.
    SELECT stobjid
      INTO gt_stobj-low
      FROM cmacbpst
     WHERE student12 IN p_stnum. "학번
      gt_stobj-sign   ='I'.
      gt_stobj-option = 'EQ'.
      APPEND gt_stobj.
    ENDSELECT.
  ELSE.
    IF p_sel1 = 'X' OR p_perid = '011' OR p_perid = '021'. "계절학기 포함
      PERFORM get_stt1.  "대상학생(학과/수강기준)
    ELSE.
      PERFORM get_stt2.  "대상학생(재학기준)
    ENDIF.
  ENDIF.

  SORT gt_stobj.
  DELETE ADJACENT DUPLICATES FROM gt_stobj COMPARING low.

  IF gt_stobj[] IS INITIAL.
    MESSAGE '대상학생이 없습니다.' TYPE 'I'. STOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  cancel_course
*&---------------------------------------------------------------------*
* 수강취소, ZCMRA235, 일괄 수강취소 이용
*----------------------------------------------------------------------*
FORM cancel_course.

  CHECK gt_data[] IS NOT INITIAL.

  CLEAR gt_rows.
  CALL METHOD g_grid->get_selected_rows
    IMPORTING
      et_index_rows = gt_rows.

  IF gt_rows[] IS INITIAL.
    MESSAGE '처리할 라인을 선택하세요.' TYPE 'E'. "복수선택
  ENDIF.

  IF go_cancel_course_model IS NOT BOUND.
    CREATE OBJECT go_cancel_course_model.
  ENDIF.
  go_cancel_course_model->cancel( ).

ENDFORM.

*{   INSERT         DEVK989929                                        1
*&---------------------------------------------------------------------*
*& Form CALL_PUSH_POPUP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_push_popup .
  CLEAR gt_rows.
  CALL METHOD g_grid->get_selected_rows
    IMPORTING
      et_index_rows = gt_rows.

  IF gt_rows[] IS INITIAL.
    MESSAGE '처리할 라인을 선택하세요.' TYPE 'E'. "복수선택
  ENDIF.

  CLEAR: zxit0010, gv_username.
  CALL SCREEN '0200' STARTING AT 20 5.

ENDFORM.
*}   INSERT
*&---------------------------------------------------------------------*
*& Form check_input_sms
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_CHK
*&---------------------------------------------------------------------*
FORM check_input_sms  USING    p_chk.
  CLEAR p_chk.

  IF zxit0010-userid IS INITIAL .
    MESSAGE '전송부서를 입력하세요' TYPE 'S' .
    p_chk = 'E' .
    RETURN .
  ENDIF .

  IF zxit0010-subject IS INITIAL .
    MESSAGE '전송제목을 입력하세요' TYPE 'S' .
    p_chk = 'E' .
    RETURN .
  ENDIF .

  IF zxit0010-name IS INITIAL .
    MESSAGE '전송자명을 입력하세요' TYPE 'S' .
    p_chk = 'E' .
    RETURN .
  ENDIF .

  IF zxit0010-content IS INITIAL .
    MESSAGE '메시지내용을 입력하세요' TYPE 'S' .
    p_chk = 'E' .
    RETURN .
  ENDIF .

  IF zxit0010-callback_no IS INITIAL .
    MESSAGE '회신번호를 입력하세요' TYPE 'S' .
    p_chk = 'E' .
    RETURN .
  ELSE .
    PERFORM telno_numerchk USING zxit0010-callback_no
                                 p_chk .
    IF p_chk = 'E' .
      MESSAGE '회신번호는 숫자로만 입력되어야 합니다.' TYPE 'S' .
      RETURN .
    ENDIF .
  ENDIF .

  IF zxit0010-indate  IS INITIAL .
    MESSAGE '전송일자를 입력하세요' TYPE 'S' .
    p_chk = 'E' .
    RETURN .
  ENDIF .

  IF zxit0010-intime  IS INITIAL .
    MESSAGE '전송시간을 입력하세요' TYPE 'S' .
    p_chk = 'E' .
    RETURN .
  ENDIF .


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  TELNO_NUMERCHK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZXIT0010_PHONE  text
*      -->P_L_CHK  text
*----------------------------------------------------------------------*
FORM telno_numerchk  USING    p_number
                              p_chk.
  DATA: l_number_in      LIKE sph_call-no_dialed,
        l_number_out     LIKE sph_call-no_dialed,
        allowed_char(39) VALUE '0123456789',
        l_char_len       TYPE i,
        l_num_len        TYPE i,
        l_pos            TYPE i,
        l_cnt            TYPE i.

  CLEAR : p_chk .

  l_cnt = 1 .

  MOVE p_number TO l_number_in.
  CLEAR l_number_out.
  CONDENSE l_number_in NO-GAPS.
  TRANSLATE l_number_in TO UPPER CASE.                   "#EC TRANSLANG
  IF l_number_in CN allowed_char.
    l_num_len = strlen( l_number_in ).
    l_pos = 0.
    WHILE l_pos < l_num_len.
      l_char_len = charlen( l_number_in+l_pos ).
      IF l_number_in+l_pos(l_char_len) CO allowed_char.
      ELSE .
        p_chk = 'E' .
        RETURN .
      ENDIF.
      ADD l_char_len TO l_pos.
    ENDWHILE.
  ENDIF.
ENDFORM.                    " TELNO_NUMERCHK
*&---------------------------------------------------------------------*
*&      Form  CHECK_PROC_CONTINUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_Z_ANSWER  text
*----------------------------------------------------------------------*
FORM check_proc_continue USING $msg     TYPE string
                               $answer.

  DATA: l_defaultoption, l_textline1(70),  l_textline2(70).

  CLEAR: $answer.

  l_defaultoption = 'N'.
  l_textline1     = $msg. "'진행 하시겠습니까?'.

  PERFORM popup_to_confirm(zcmsubpool)
    USING l_defaultoption l_textline1 l_textline2 z_return.

  CHECK z_return  EQ 'J'.    "Yes
  $answer = 'X'.
ENDFORM.                    " CHECK_PROC_CONTINUE
*&---------------------------------------------------------------------*
*& Form send_sms_proc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM send_sms_proc .

  DATA: BEGIN OF lt_push OCCURS 0,
          objid LIKE hrp1000-objid,
          short LIKE hrp1000-short,
          stext LIKE hrp1000-stext,
          email LIKE zcms0640-email,
          cell  LIKE zcms0640-cell,
        END OF lt_push.

  DATA: l_jobtype     TYPE char1,
        l_retcode     TYPE char1,
        l_msg         TYPE char255,
        l_phone       TYPE char20,
        l_callback_no TYPE char20,
        l_rid         TYPE bname.

  DATA(lr_log) = NEW cl_bal_logobj( ).

  LOOP AT gt_rows INTO DATA(ls_row).
    READ TABLE gt_data INDEX ls_row-index.
    CHECK sy-subrc = 0.
    MOVE-CORRESPONDING gt_data TO lt_push.
    COLLECT lt_push.
    CLEAR lt_push.
  ENDLOOP.

  CHECK lt_push[] IS NOT INITIAL.

  l_jobtype = '1'.
  l_callback_no = zxit0010-callback_no.
  LOOP AT lt_push.
    IF lt_push-cell IS INITIAL.
      lr_log->add_errortext( |{ lt_push-stext }[{ lt_push-short }] - 핸드폰번호누락자 | ).
      CONTINUE.
    ENDIF.
    IF lt_push-cell+0(2) <> '01'.
      lr_log->add_errortext( |{ lt_push-stext }[{ lt_push-short }] - 핸드폰번호이상자 | ).
      CONTINUE.
    ENDIF.

    l_phone = lt_push-cell.
    l_rid = lt_push-short.

    CLEAR: l_retcode, l_msg.
    CALL FUNCTION 'ZXI_PUSH_SMS'
      EXPORTING
        i_jobtype     = l_jobtype
        i_userid      = zxit0010-userid
        i_phone       = l_phone
        i_subject     = zxit0010-subject
        i_name        = zxit0010-name
        i_content     = zxit0010-content
        i_callback_no = l_callback_no
        i_rev_date    = zxit0010-indate
        i_rev_time    = zxit0010-intime
        i_rid         = l_rid "PUSH(신규)
      IMPORTING
        e_retcode     = l_retcode
        e_msg         = l_msg.

    IF l_retcode = 'Y'.
      lr_log->add_statustext( |{ lt_push-stext }[{ lt_push-short }] - PUSH 전송 성공!! | ).
    ELSE.
      lr_log->add_errortext( |{ lt_push-stext }[{ lt_push-short }] - { l_msg }| ).
    ENDIF.

  ENDLOOP.


  lr_log->display( ).

  LEAVE TO SCREEN 0.
ENDFORM.
