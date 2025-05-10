*&---------------------------------------------------------------------*
*& Include          MZCMRK410_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data_select
*&---------------------------------------------------------------------*
FORM get_data_select .


ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv_data
*&---------------------------------------------------------------------*
FORM grid_display_alv.

  go_grid ?= lcl_alv_grid=>create( CHANGING ct_table = gt_data[] ).
  go_grid->title_v1 = |{ TEXT-t01 } - { lines( gt_data ) } 건|.

  PERFORM grid_field_catalog.
  PERFORM grid_layout.
  PERFORM grid_sort.
  PERFORM grid_gui_status.

  go_grid->display( ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_field_catalog
*&---------------------------------------------------------------------*
FORM grid_field_catalog .


  LOOP AT go_grid->fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).

    CASE <fs_fcat>-fieldname.
      WHEN 'TYPE'.
        <fs_fcat>-reptext = '유형'.
        <fs_fcat>-emphasize = 'C300'.
      WHEN 'MESSAGE'.
        <fs_fcat>-reptext = '메세지'.
        <fs_fcat>-emphasize = 'C300'.
      WHEN 'ST_NO'.
        <fs_fcat>-reptext = '학번'.
      WHEN 'ST_NM'.
        <fs_fcat>-reptext = '성명'.
      WHEN 'ST_ID'.
        <fs_fcat>-reptext = 'STID'.
      WHEN 'SE_DETAIL-PERYR'.
        <fs_fcat>-reptext = '학년'.
      WHEN 'SE_DETAIL-PERID'.
        <fs_fcat>-reptext = '학기'.
      WHEN 'SE_DETAIL-ORGCD'.
        <fs_fcat>-reptext = '소속'.
      WHEN 'SE_DETAIL-ORGTXT'.
        <fs_fcat>-reptext = '소속명'.
*      WHEN 'SMOBJID'.
*        <fs_fcat>-reptext = '과목'.
*      WHEN 'SEOBJID'.
*        <fs_fcat>-reptext = '분반'.
      WHEN 'SE_DETAIL-SMSHORT'.
        <fs_fcat>-reptext = '과목'.
      WHEN 'SE_DETAIL-SESHORT'.
        <fs_fcat>-reptext = '분반'.
      WHEN 'SE_DETAIL-SMSTEXT'.
        <fs_fcat>-reptext = '과목명'.
      WHEN 'MAX'.
        <fs_fcat>-reptext = '수강가능학점'.
      WHEN 'SE_DETAIL-CPOPT'.
        <fs_fcat>-reptext = '신청학점'.
        <fs_fcat>-quantity = 'CRH'.
      WHEN 'SE_DETAIL-TIME_PLAC'.
        <fs_fcat>-reptext = '수업시간/강의실'.
      WHEN 'SE_DETAIL-ENAME'.
        <fs_fcat>-reptext = '교수진'.
      WHEN 'SE_DETAIL-BEGDA'.
        <fs_fcat>-reptext = '시작일'.
      WHEN 'SE_DETAIL-ENDDA'.
        <fs_fcat>-reptext = '종료일'.
      WHEN 'REPERYR'.
        <fs_fcat>-reptext = '재이수학년'.
      WHEN 'REPERID'.
        <fs_fcat>-reptext = '재이수학기'.
      WHEN 'RESMID'.
        <fs_fcat>-reptext = '재이수과목'.
      WHEN 'SE_DETAIL-TIME_PLACE'.
        <fs_fcat>-reptext = '시간표/강의실'.
      WHEN 'SE_DETAIL-EOBJID'.
        <fs_fcat>-reptext = '이벤트'.
      WHEN 'SE_DETAIL-OOBJID'.
        <fs_fcat>-reptext = '학과'.
      WHEN 'SE_DETAIL-SCALEID'.
        <fs_fcat>-reptext = '스케일'.
      WHEN 'SE_DETAIL-ID'.
        <fs_fcat>-reptext = '수강신청ID'.
      WHEN OTHERS.
        <fs_fcat>-no_out = 'X'.
    ENDCASE.

    <fs_fcat>-scrtext_l = <fs_fcat>-scrtext_m = <fs_fcat>-scrtext_s = <fs_fcat>-reptext.
  ENDLOOP.

  go_grid->set_frontend_fieldcatalog( go_grid->fcat ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_layout
*&---------------------------------------------------------------------*
FORM grid_layout .

  go_grid->layout->set_cwidth_opt( abap_true ).
  go_grid->layout->set_zebra( abap_true ).
  go_grid->layout->set_sel_mode( 'D' ).
  go_grid->layout->set_no_toolbar( abap_false ).
  go_grid->layout->set_no_rowins( abap_true ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_sort
*&---------------------------------------------------------------------*
FORM grid_sort .
  go_grid->sort = VALUE #( ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_gui_status
*&---------------------------------------------------------------------*
FORM grid_gui_status .

  go_grid->gui_status->fully_dynamic = abap_true.
  go_grid->exclude_functions = go_grid->gui_status->edit_buttons( ).

*  go_grid->gui_status->add_button(
*    iv_button = zcl_falv_dynamic_status=>b_01
*    iv_text   = '1.점검'
*    iv_icon   = icon_check ).

  IF r1 = 'X'.
    go_grid->gui_status->add_button(
      iv_button = zcl_falv_dynamic_status=>b_02
      iv_text   = '일괄신청'
      iv_icon   = icon_create ).
  ENDIF.

  IF r2 = 'X'.
    go_grid->gui_status->add_button(
      iv_button = zcl_falv_dynamic_status=>b_03
      iv_text   = '일괄취소'
      iv_icon   = icon_delete ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EV_data_changed
*&---------------------------------------------------------------------*
FORM ev_data_changed  USING po_data_changed TYPE REF TO cl_alv_changed_data_protocol.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EV_user_command
*&---------------------------------------------------------------------*
FORM ev_user_command  USING p_ucomm   po_me TYPE REF TO lcl_alv_grid.

  CASE p_ucomm.
    WHEN zcl_falv_dynamic_status=>b_01.

    WHEN zcl_falv_dynamic_status=>b_02.
      PERFORM booking_all.

    WHEN zcl_falv_dynamic_status=>b_03.
      PERFORM booking_canc_all.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ev_hotspot_click
*&---------------------------------------------------------------------*
FORM ev_hotspot_click  USING p_row p_fieldname.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ev_top_of_page
*&---------------------------------------------------------------------*
FORM ev_top_of_page  USING    po_dyndoc_id TYPE REF TO cl_dd_document.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EV_ON_F4
*&---------------------------------------------------------------------*
FORM ev_on_f4  USING    p_fieldname  p_fieldvalue  p_row.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_proc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_proc .

* 현재학년도 학기
  PERFORM set_current_period.
* 사용자의 권한조직 취득
  PERFORM get_user_authorg.

*  PERFORM limit_user.

*  PERFORM org_f4_entry.

  CALL FUNCTION 'ZCM_LIST_BOX_PYEAR_PERID'
    EXPORTING
      year_field  = 'P_PERYR'
      perid_field = 'P_PERID'.

  CONCATENATE icon_xxl '양식 내려받기' INTO sscrfields-functxt_01.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_current_period
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_current_period .

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

  READ TABLE lt_hrtimeinfo INTO ls_timeinfo INDEX 1.
  IF sy-subrc = 0.
    MOVE ls_timeinfo-peryr TO p_peryr.
    MOVE ls_timeinfo-perid TO p_perid.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_user_authorg
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_user_authorg .

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
    MESSAGE '사용자에게 부여된 권한이 없습니다.' TYPE 'I'.
    STOP.
  ENDIF.

*{20240208,jjh,경영전문대학원 권한이 있으면 아래 권한이 있는 것
  IF line_exists( gt_authobj[ objid = '30000204' ] ).
    gt_authobj-plvar = '01'.
    gt_authobj-otype = 'O'.
    gt_authobj-begda = sy-datum.
    gt_authobj-endda = '99991231'.

*   경영컨설팅학과
    gt_authobj-objid = '50000252'.
    APPEND gt_authobj.

*   글로벌서비스경영학과
    gt_authobj-objid = '50000254'.
    APPEND gt_authobj.

*   주간MBA
    gt_authobj-objid = '30000205'.
    APPEND gt_authobj.

*   박사MBA
    gt_authobj-objid = '30000206'.
    APPEND gt_authobj.

*   야간MBA
    gt_authobj-objid = '30000207'.
    APPEND gt_authobj.

*   주말MBA
    gt_authobj-objid = '30000208'.
    APPEND gt_authobj.

*   금융MBA
    gt_authobj-objid = '50001401'.
    APPEND gt_authobj.

  ENDIF.
*}

*  SORT gt_authobj BY objid.
*  LOOP AT gt_authobj.
*    SELECT SINGLE profl INTO lv_profl FROM t77pq
*     WHERE profl = gt_authobj-objid.
*    IF sy-subrc = 0.
*      p_orgcd = lv_profl.
*      EXIT.
*    ENDIF.
*  ENDLOOP.

*(관리자 권한: 수강생이 있는 분반 편집 시 [참가자 전송] 화면 무시 기능
  CLEAR gv_nolimit.
  SELECT COUNT(*)
     FROM agr_users
    WHERE uname     = sy-uname
      AND from_dat <= sy-datum
      AND to_dat   >= sy-datum
      AND agr_name IN ('Z_CM_02'). "학사지원팀
  IF sy-dbcnt > 0.
    gv_nolimit = 'X'.
  ENDIF.
*)

  CLEAR gt_agr_users[].
  SELECT * FROM agr_users
    INTO TABLE @gt_agr_users
   WHERE uname = @sy-uname
     AND from_dat <= @sy-datum
     AND to_dat   >= @sy-datum.

  SELECT DISTINCT
         grp_cd,
         map_cd2 AS key,
         com_nm  AS text,
         org_cd
    INTO TABLE @gt_0101
    FROM zcmt0101
    WHERE grp_cd IN ('100', '109').
  SORT gt_0101 BY grp_cd key.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_undergrad_auth
*&---------------------------------------------------------------------*
FORM get_undergrad_auth.

  CLEAR: gt_role[], gt_role.
  CHECK gt_authobj[] IS NOT INITIAL.
  SELECT objid
    INTO TABLE @DATA(lt_oobjid)
    FROM hrp9500
    FOR ALL ENTRIES IN @gt_authobj
   WHERE plvar = '01'
     AND otype = 'O'
     AND objid = @gt_authobj-objid
     AND istat = '1'
     AND begda <= @sy-datum
     AND endda >= @sy-datum
     AND infty = '9500'
     AND org = '0011'. "학부
  CHECK sy-subrc = 0.

  SELECT *
    INTO TABLE @DATA(lt_zcmt2024_role)
    FROM zcmt2024_role.
  CHECK sy-subrc = 0.

  LOOP AT lt_zcmt2024_role INTO DATA(ls_zcmt2024_role)
    WHERE org = '0011'. "학부

    READ TABLE gt_agr_users INTO DATA(ls_agr_users)
      WITH KEY agr_name = ls_zcmt2024_role-agr_name.
    CHECK sy-subrc = 0.

    READ TABLE lt_oobjid INTO DATA(lv_oobjid)
      WITH KEY objid = ls_zcmt2024_role-oobjid.

    CHECK sy-subrc = 0.

    APPEND ls_zcmt2024_role TO gt_role.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_grad_auth
*&---------------------------------------------------------------------*
FORM get_grad_auth.

  CLEAR: gt_role[], gt_role.
  READ TABLE gt_authobj
    WITH KEY objid = p_orgcd.
  CHECK sy-subrc = 0.

  SELECT a~*
    FROM zcmt2024_role AS a
     FOR ALL ENTRIES IN @gt_agr_users
   WHERE a~agr_name = @gt_agr_users-agr_name
     AND a~oobjid = @gt_authobj-objid
     AND a~org <> '0011' "대학원
    INTO TABLE @gt_role.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form limit_user
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM limit_user.

  CLEAR: gt_role[], gt_role.
  IF p_orgcd = '30000002'. "학부
    PERFORM get_undergrad_auth.

  ELSE. "대학원
    PERFORM get_grad_auth.

  ENDIF.

*  SELECT a~* FROM zcmt2024_role AS a
*    INNER JOIN @gt_agr_users AS b
*    ON a~agr_name = b~agr_name
*    INTO TABLE @DATA(lt_role).
*  IF sy-subrc = 0.
  IF gt_role[] IS INITIAL.
    MESSAGE '사용자에게 부여된 권한이 없습니다.' TYPE 'I'.
    STOP.
  ENDIF.

  SORT gt_role BY priority.
  DATA(lv_auth) = gt_role[ 1 ]-auth.

  SELECT SINGLE * FROM zcmt2024_auth
    INTO gs_auth
    WHERE auth = lv_auth.

*  SELECT SINGLE map_cd2
*    INTO @DATA(lv_orgeh)
*    FROM zcmt0101
*   WHERE grp_cd = '100'.
*  IF sy-subrc = 0.
*    p_orgcd = lv_orgeh.
*  ENDIF.

*  ELSE.
*    MESSAGE '사용자에게 부여된 권한이 없습니다.' TYPE 'I'.
*    STOP.
*  ENDIF.

*  SORT gt_authobj BY objid.
*  LOOP AT gt_authobj.
*    SELECT SINGLE profl INTO lv_profl FROM t77pq
*     WHERE profl = gt_authobj-objid.
*    IF sy-subrc = 0.
*      p_orgcd = lv_profl.
*      EXIT.
*    ENDIF.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_check
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_check .

  CASE 'X'.
    WHEN p_type1.

      IF p_ufile IS INITIAL.
        MESSAGE '파일을 선택하세요.' TYPE 'S' DISPLAY LIKE 'E'.
        STOP.
      ENDIF.

      CALL METHOD zcmcl000=>excel_to_itab
        EXPORTING
          iv_local_fpath = p_ufile
        IMPORTING
          ev_error       = DATA(lv_error)
          ev_msg         = DATA(lv_msg)
          ev_filepath    = DATA(lv_file)
        CHANGING
          ct_data        = gt_xls[].

      IF lv_error IS NOT INITIAL.
        MESSAGE lv_msg TYPE 'S' DISPLAY LIKE 'E'.
        STOP.
      ENDIF.

      IF gt_xls[] IS INITIAL.
        MESSAGE '파일을 선택하세요.' TYPE 'S' DISPLAY LIKE 'E'.
        STOP.
      ENDIF.

      LOOP AT gt_xls.
        gt_stse-st_no = gt_xls-st_no.
        gt_stse-se_short = |{ gt_xls-sm_short }-{ gt_xls-se_short }|.
        APPEND gt_stse. CLEAR gt_stse.
      ENDLOOP.

    WHEN p_type2.
      IF p_se IS INITIAL OR p_stnum[] IS INITIAL.
        MESSAGE '분반 또는 학번이 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
        STOP.
      ENDIF.

      CLEAR gt_stse[].
      LOOP AT p_stnum.
        gt_stse-st_no = p_stnum-low.
        gt_stse-se_short = p_se.
        APPEND gt_stse. CLEAR gt_stse.
      ENDLOOP.
  ENDCASE.

  CLEAR gr_stno[].
  gr_stno[] = VALUE #( FOR ls_stse IN gt_stse ( sign = 'I' option = 'EQ' low = ls_stse-st_no ) ).

  CLEAR gt_st1000.
  SELECT objid, short, stext FROM hrp1000
    INTO TABLE @DATA(lt_st)
    FOR ALL ENTRIES IN @gt_stse
    WHERE plvar = '01'
      AND otype = 'ST'
      AND istat = '1'
      AND short = @gt_stse-st_no
      AND langu = '3'
      AND begda <= @gv_keydt
      AND endda >= @gv_keydt.
  gt_st1000 = CORRESPONDING #( lt_st ).
  SORT gt_st1000 BY short.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form org_f4_entry
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM org_f4_entry .
*  CLEAR: gt_vrm[], gt_vrm.
*  DATA lr_org TYPE RANGE OF zcmt0101-map_cd2 WITH HEADER LINE.
*
*  READ TABLE gt_authobj WITH KEY objid = '32000000' TRANSPORTING NO FIELDS.
*  IF sy-subrc <> 0.
*    lr_org[] = CORRESPONDING #( gt_authobj[] MAPPING low = objid ).
*    lr_org-sign = 'I'.
*    lr_org-option = 'EQ'.
*    MODIFY lr_org FROM lr_org TRANSPORTING sign option WHERE sign IS INITIAL .
*  ENDIF.
*
*  SELECT map_cd2, com_nm FROM zcmt0101
*    INTO TABLE @gt_vrm
* WHERE grp_cd = '100'
*   AND com_cd = '0011'
*   AND map_cd2 IN @lr_org
*  ORDER BY remark.
*
*  SELECT map_cd2, com_nm FROM zcmt0101
*    APPENDING TABLE @gt_vrm
* WHERE grp_cd = '109'
*   AND com_cd <> '0000'
*   AND map_cd2 IN @lr_org
*  ORDER BY remark.
*
*  SELECT map_cd2, com_nm FROM zcmt0101
*    APPENDING TABLE @gt_vrm
* WHERE grp_cd = '100'
*   AND com_cd <> '0011'
*   AND map_cd2 IN @lr_org
*  ORDER BY remark.
*
*  CALL FUNCTION 'VRM_SET_VALUES'
*    EXPORTING
*      id              = 'P_ORGCD'
*      values          = gt_vrm[]
*    EXCEPTIONS
*      id_illegal_name = 1
*      OTHERS          = 2.


  SELECT map_cd2, com_nm FROM zcmt0101
    INTO TABLE @gt_vrm
   WHERE grp_cd = '100'
  ORDER BY remark.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'P_ORGCD'
      values          = gt_vrm[]
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_screen .
  LOOP AT SCREEN.

*   엑셀업로드시 활성화
    IF screen-name = 'P_UFILE'. "파일선택
      IF p_type1 = 'X'. "엑셀업로드(라디오버튼)
        screen-input = 1.
        MODIFY SCREEN.
      ELSE.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

*   강제 비활성화
    IF screen-name = 'P_CBO' OR
       screen-name = 'P_STD'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.

*   직접입력시 활성화
    IF screen-name = 'P_SE' OR screen-name = 'P_STNUM-LOW'. "분반 / 학번
      TRANSLATE p_se TO UPPER CASE.
      IF p_type2 = 'X'. "직접입력(라디오버튼)
        screen-input = 1.
        MODIFY SCREEN.
      ELSE.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_file .

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      mask             = ',*.xls,*.xlsx.'
      mode             = 'O'
    IMPORTING
      filename         = p_ufile
    EXCEPTIONS
      inv_winsys       = 1
      no_batch         = 2
      selection_cancel = 3
      selection_error  = 4.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form form_get
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM form_get .
  CALL FUNCTION 'ZCM_MANUAL_PUBLISH'
    EXPORTING
      file_name = 'ZCMRA232'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form screen_ucomm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM screen_ucomm .

  CASE sscrfields-ucomm.
    WHEN 'FC01'.
      PERFORM form_get.
  ENDCASE.

  CASE sy-ucomm.
    WHEN 'UC1'.
      CASE 'X'.
        WHEN p_type1.
          CLEAR: p_stnum, p_stnum[], p_se.
        WHEN p_type2.
          CLEAR: p_ufile.
      ENDCASE.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_COURSE_DETAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_course_detail .
  DATA lr_se TYPE RANGE OF hrobjid.
  DATA lt_msg TYPE TABLE OF string.

  CLEAR:gt_data, gt_data[], gv_check.
  CHECK gt_stse[] IS NOT INITIAL.

  SELECT plvar, otype, objid FROM hrp1000
    INTO TABLE @DATA(lt_se)
    FOR ALL ENTRIES IN @gt_stse
    WHERE plvar = '01'
      AND otype = 'SE'
      AND istat = '1'
      AND short = @gt_stse-se_short
      AND langu = '3'
      AND begda <= @gv_keydt
      AND endda >= @gv_keydt.

  IF lt_se IS NOT INITIAL.
    SORT lt_se BY objid.
    DELETE ADJACENT DUPLICATES FROM lt_se COMPARING ALL FIELDS.
    lr_se = VALUE #( FOR ls_se IN lt_se ( sign = 'I' option = 'EQ' low = ls_se-objid ) ).

    zcmclk100=>get_se_list(
      EXPORTING
        i_peryr   = p_peryr
        i_perid   = p_perid
        it_se     = CONV #( lt_se[] )
      IMPORTING
        et_detail = DATA(lt_detail)
    ).
    SORT lt_detail BY seshort.
  ENDIF.

* 수강가능학점
  IF gt_stlist IS NOT INITIAL.
    SELECT objid, book_cdt, regwindow FROM hrp1705
      FOR ALL ENTRIES IN @gt_stlist
     WHERE plvar  = '01'
       AND otype  = 'ST'
       AND istat = '1'
       AND objid  = @gt_stlist-objid
       AND begda <= @gv_keydt
       AND endda >= @gv_keydt
      INTO TABLE @DATA(lt_cdt).
    SORT lt_cdt BY objid.

    SELECT  a~objid AS st_id,
            a~sobid AS sm_id,
            b~packnumber AS se_id,
            b~id,
            b~peryr,
            b~perid
        FROM hrp1001 AS a
      INNER JOIN hrpad506 AS b
      ON  a~adatanr = b~adatanr
      FOR ALL ENTRIES IN @gt_stlist
    WHERE a~plvar = '01'
      AND a~otype = 'ST'
      AND a~istat = '1'
      AND a~objid  = @gt_stlist-objid
      AND a~subty = 'A506'
      AND a~sclas = 'SM'
      AND b~packnumber IN @lr_se
      AND b~smstatus IN ('1','2','3')
      AND b~peryr = @p_peryr
      AND b~perid = @p_perid
      INTO TABLE @DATA(lt_506).
    SORT lt_506 BY se_id st_id.
  ENDIF.

  LOOP AT gt_stse.

    READ TABLE gt_st1000 INTO DATA(ls_st) WITH KEY short = gt_stse-st_no BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data-st_no = ls_st-short.
      gt_data-st_id = ls_st-objid.
      gt_data-st_nm = ls_st-stext.
      READ TABLE lt_cdt INTO DATA(ls_cdt) WITH KEY objid = gt_data-st_id BINARY SEARCH.
      IF sy-subrc = 0.
        gt_data-max = ls_cdt-book_cdt.
        gt_data-regwindow = ls_cdt-regwindow.
      ENDIF.
    ELSE.
      APPEND '학번(없음)' TO lt_msg.
    ENDIF.

    READ TABLE gt_stlist WITH KEY objid = gt_data-st_id BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      APPEND '권한없음(학번)' TO lt_msg.
    ENDIF.

    READ TABLE lt_detail INTO DATA(ls_detail) WITH KEY seshort = gt_stse-se_short BINARY SEARCH.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_detail TO gt_data-se_detail.
    ELSE.
      APPEND '분반(개설안됨)' TO lt_msg.
    ENDIF.

    READ TABLE lt_506 INTO DATA(ls_506) WITH KEY se_id = gt_data-se_detail-seobjid st_id = gt_data-st_id BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data-se_detail-id = ls_506-id.
    ENDIF.

    CASE 'X'.
      WHEN r1.
        IF gt_data-se_detail-id IS NOT INITIAL.
          APPEND '기수강' TO lt_msg.
        ENDIF.
      WHEN r2.
        IF gt_data-se_detail-id IS INITIAL.
          APPEND '미수강' TO lt_msg.
        ENDIF.
    ENDCASE.

    IF lt_msg IS NOT INITIAL.
      gt_data-type = 'E'.
      CONCATENATE LINES OF lt_msg INTO gt_data-message SEPARATED BY ', '.
    ENDIF.

    APPEND gt_data. CLEAR: gt_data, lt_msg.
  ENDLOOP.

  SORT gt_data BY se_detail-seobjid st_id.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_datum
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_datum .

  zcmcl000=>get_timelimits(
    EXPORTING
      iv_o          = p_orgcd
      iv_timelimit  = '0100'
      iv_peryr      = p_peryr
      iv_perid      = p_perid
    IMPORTING
      et_timelimits = DATA(lt_tili)
  ).

  READ TABLE lt_tili INTO DATA(ls_tili) INDEX 1.
  IF sy-subrc = 0.
    gv_keydt = ls_tili-ca_lbegda.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form booking_all
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM booking_all .

  DATA lt_stlist TYPE TABLE OF hrobject.
  DATA ls_se_detail TYPE zcmsk_course.

  DATA : ls_org         LIKE LINE OF gt_org,
         ls_major       LIKE LINE OF gt_major,
         ls_person      LIKE LINE OF gt_person,
         lt_booked      TYPE zcmsk_course_t,
         lv_booked_cdt  TYPE zcmclk100=>ty_credit-booked,
         lt_acwork      LIKE gt_acwork,
         ls_rebook_info TYPE ci_pad506,
         lv_506_id      TYPE hrpad506-id,
         lv_max         TYPE numc4.

  SORT gt_data BY se_detail-seobjid st_id.

  DATA(lt_temp) = gt_data[].
  DELETE lt_temp WHERE type = 'E'.

  lt_stlist = CORRESPONDING #( lt_temp MAPPING objid = st_id ).
  IF lt_stlist IS INITIAL.
    MESSAGE '처리할 데이터가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  CHECK zcmcl000=>popup_to_confirm( '오류건 제외하고 계속하시겠습니까?' ) IS NOT INITIAL.

  PERFORM get_st_info TABLES lt_stlist.

  LOOP AT lt_temp INTO DATA(ls_temp).

    READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<fs>) WITH KEY se_detail-seobjid = ls_temp-se_detail-seobjid st_id = ls_temp-st_id.

    CLEAR ls_org.
    READ TABLE gt_org INTO ls_org WITH KEY st_id = ls_temp-st_id BINARY SEARCH.
    IF sy-subrc <> 0.
      <fs>-type = 'E'.
      <fs>-message = '학생소속 누락'.
      CONTINUE.
    ENDIF.
    CLEAR ls_major.
    READ TABLE gt_major INTO ls_major WITH KEY st_objid = ls_temp-st_id BINARY SEARCH.
    IF sy-subrc <> 0.
      <fs>-type = 'E'.
      <fs>-message = '학생전공 누락'.
      CONTINUE.
    ENDIF.
    CLEAR ls_person.
    READ TABLE gt_person INTO ls_person WITH KEY objid = ls_temp-st_id BINARY SEARCH.
    IF sy-subrc <> 0.
      <fs>-type = 'E'.
      <fs>-message = '학생기본정보 누락'.
      CONTINUE.
    ENDIF.

    CLEAR lt_acwork.
    lt_acwork = gt_acwork.
    DELETE lt_acwork WHERE objid <> ls_temp-st_id.

    CLEAR ls_se_detail.
    ls_se_detail = ls_temp-se_detail.

    CLEAR lt_booked.
    zcmclk100=>booked_list(
      EXPORTING
        i_stid    = ls_temp-st_id
        i_peryr   = p_peryr
        i_perid   = p_perid
      IMPORTING
        et_detail = lt_booked
    ).
    CLEAR lv_booked_cdt.
    zcmclk100=>booked_credit(
      EXPORTING
        i_orgcd   = ls_org-org_comm
        i_keydt   = gv_keydt
        it_booked = lt_booked
      IMPORTING
        e_booked  = lv_booked_cdt
    ).

    CLEAR lv_max.
    CALL FUNCTION 'ZCM_GET_INITS'
      EXPORTING
        i_peryr = p_peryr
        i_perid = p_perid
        i_objid = ls_temp-st_id
        i_keydt = sy-datum
      IMPORTING
        o_max   = lv_max.
    ls_temp-max = lv_max.

    CLEAR ls_rebook_info.
*수강 가능 여부
    zcmclk100=>check_is_bookable(
      EXPORTING
        i_mode          = gs_auth-auth
        i_stid          = ls_temp-st_id
        i_stno          = ls_temp-st_no
        i_st_regwindow  = ls_temp-regwindow
        i_st_gesch      = ls_person-gesch
        i_st_orgid      = ls_org-org_id
        i_st_orgcd      = ls_org-org_comm
        is_st_major     = ls_major
        it_booked       = lt_booked
        it_acwork       = lt_acwork
        i_max_credit    = ls_temp-max
        i_booked_credit = lv_booked_cdt
        is_booking_info = ls_se_detail
        i_peryr         = p_peryr
        i_perid         = p_perid
        i_keydt         = gv_keydt
      IMPORTING
        es_rebook_info  = ls_rebook_info
        et_msg          = DATA(lt_msg)
    ).

    IF lt_msg IS NOT INITIAL.
      <fs>-type = 'E'.
      <fs>-message = lt_msg[ 1 ]-message.
      CONTINUE.
    ENDIF.

    CLEAR lv_506_id.
**수강신청 함수 실행
    zcmclk100=>booking(
      EXPORTING
        i_stid         = ls_temp-st_id
        i_st_regwindow = ls_temp-regwindow
        i_st_major     = ls_major-sc_objid1
        is_book_data   = ls_se_detail
        is_rebook_info = ls_rebook_info
      IMPORTING
        es_msg         = DATA(ls_msg)
        ev_id          = lv_506_id
    ).
*수강신청 완료
    IF ls_msg IS INITIAL.
      <fs>-type = 'S'.
      <fs>-message = '수강신청 완료'.
      <fs>-reperyr = ls_rebook_info-reperyr.
      <fs>-reperid = ls_rebook_info-reperid.
      <fs>-resmid = ls_rebook_info-resmid.
      <fs>-reid = ls_rebook_info-reid.
      <fs>-se_detail-id = lv_506_id.
    ELSE.
      <fs>-type = 'E'.
      <fs>-message = ls_msg-message.
    ENDIF.

  ENDLOOP.

  go_grid->soft_refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ST_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_st_info TABLES pt_stlist TYPE hrobject_tab.

*소속
  CLEAR gt_org.
  zcmcl000=>get_st_orgcd(
    EXPORTING
      it_stobj = pt_stlist[]
    IMPORTING
      et_storg = DATA(lt_org)
  ).
  gt_org = lt_org.

*개인정보
  CLEAR gt_person.
  zcmcl000=>get_st_person(
    EXPORTING
      it_stobj    = pt_stlist[]
    IMPORTING
      et_stperson = DATA(lt_stperson)
  ).
  gt_person = lt_stperson.

*전공
  CLEAR gt_major.
  zcmcl000=>get_st_major(
    EXPORTING
      it_stobj   = pt_stlist[]
      iv_keydate = gv_keydt
    IMPORTING
      et_stmajor = DATA(lt_major)
  ).
  gt_major = lt_major.

*성적
  CLEAR gt_acwork.
  zcmcl000=>get_aw_acwork(
    EXPORTING
      it_stobj  = pt_stlist[]
    IMPORTING
      et_acwork = DATA(lt_acwork)
  ).

  gt_acwork = lt_acwork.

  DELETE gt_acwork WHERE awotype <> 'SM'.
  DELETE gt_acwork WHERE peryr > p_peryr.
  DELETE gt_acwork WHERE peryr = p_peryr
                     AND perid >= p_perid.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form booking_canc_all
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM booking_canc_all .

  DATA ls_booked TYPE zcmsk_course.

  SORT gt_data BY se_detail-seobjid st_id.

  DATA(lt_temp) = gt_data[].
  DELETE lt_temp WHERE type = 'E'.

  IF lt_temp IS INITIAL.
    MESSAGE '처리할 데이터가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  CHECK zcmcl000=>popup_to_confirm( '오류건 제외하고 계속하시겠습니까?' ) IS NOT INITIAL.

  LOOP AT lt_temp INTO DATA(ls_temp).

    READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<fs>) WITH KEY se_detail-seobjid = ls_temp-se_detail-seobjid st_id = ls_temp-st_id.

    MOVE-CORRESPONDING ls_temp-se_detail TO ls_booked.

    SELECT  a~objid AS st_id, a~sobid AS sm_id, b~packnumber AS se_id,
            b~peryr, b~perid, b~id, b~smstatus
        FROM hrp1001 AS a
   INNER JOIN hrpad506 AS b
      ON  a~adatanr = b~adatanr
    WHERE a~plvar = '01'
      AND a~otype = 'ST'
      AND a~objid = @ls_temp-st_id
      AND a~istat = '1'
      AND a~subty = 'A506'
      AND a~sclas = 'SM'
      AND b~packnumber = @ls_booked-seobjid
      AND b~peryr = @p_peryr
      AND b~perid = @p_perid
      AND b~smstatus IN ('1','2','3')
      INTO TABLE @DATA(lt_506).
    SORT lt_506 BY se_id.
    READ TABLE lt_506 INTO DATA(ls_506) WITH KEY se_id = ls_booked-seobjid.
    CHECK sy-subrc = 0.

    ls_booked-id = ls_506-id.

    zcmclk100=>booking_canc(
      EXPORTING
        i_stid    = ls_temp-st_id
        is_booked = ls_booked
      IMPORTING
        es_msg    = DATA(ls_msg)
    ).

*수강신청 완료
    IF ls_msg IS INITIAL.
      <fs>-type = 'S'.
      <fs>-message = '수강취소 완료'.
      <fs>-se_detail-id = ''.
    ELSE.
      <fs>-type = 'E'.
      <fs>-message = ls_msg-message.
    ENDIF.
  ENDLOOP.

  go_grid->soft_refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_st_auth
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_st_auth .

*  DATA lt_ststatus TYPE RANGE OF char04 .

*  lt_ststatus = VALUE #( ( sign = 'I' option = 'EQ' low = '1000' ) ).
  DATA(lt_org) = VALUE hrobject_t( ( plvar = '01' otype = 'O' objid = p_orgcd ) ).

  zcmcl000=>get_st_list(
    EXPORTING
      it_object   = lt_org
      ir_stno     = gr_stno
*     ir_sts_cd   = lt_ststatus
      iv_major_fg = ''
      iv_titel    = ''  " 빈값일 경우 모두
      iv_keydate  = gv_keydt
    IMPORTING
      et_stlist   = gt_stlist[]
  ).

  SORT gt_stlist BY objid.


ENDFORM.
