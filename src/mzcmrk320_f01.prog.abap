*&---------------------------------------------------------------------*
*& Include          MZCMRK990_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data_select
*&---------------------------------------------------------------------*
FORM get_data_select .

  DATA ls_item TYPE pt9552.

  CLEAR :gt_data[].

  PERFORM get_evob. "개설정보

  CHECK gt_evob[] IS NOT INITIAL.

  SELECT * FROM hrp9552
    INTO TABLE @DATA(lt_9552)
     FOR ALL ENTRIES IN @gt_evob
   WHERE plvar = '01'
     AND otype = 'SE'
     AND objid = @gt_evob-seobjid
     AND begda <= @gv_begda
     AND endda >= @gv_begda.
  SORT lt_9552 BY objid.

  SELECT * FROM hrp9550
    INTO TABLE @DATA(lt_9550)
     FOR ALL ENTRIES IN @gt_evob
   WHERE plvar = '01'
     AND otype = 'SE'
     AND objid = @gt_evob-seobjid
     AND begda <= @gv_begda
     AND endda >= @gv_begda.
  SORT lt_9550 BY objid.

  SELECT se_id, versn, bigo FROM zcmt2381
    INTO TABLE @DATA(lt_2381)
     FOR ALL ENTRIES IN @gt_evob
    WHERE peryr = @p_peryr
      AND perid = @p_perid
      AND se_id = @gt_evob-seobjid
      AND procgb = ''
      AND infty_run = 'X'.
  SORT lt_2381 BY se_id ASCENDING versn DESCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_2381 COMPARING se_id.

  SELECT otype, objid, tabnr FROM hrp1002
    INTO TABLE @DATA(lt_p1002)
   FOR ALL ENTRIES IN @gt_evob
   WHERE plvar = '01'
     AND otype IN ('SM')
     AND objid = @gt_evob-smobjid
     AND subty = '0001'
     AND langu = '3'
     AND begda <= @gv_begda
     AND endda >= @gv_begda.
  IF sy-subrc = 0.
    SELECT tabnr, tabseqnr, tline
      INTO TABLE @DATA(lt_t1002)
      FROM hrt1002
      FOR ALL ENTRIES IN @lt_p1002
     WHERE tabnr = @lt_p1002-tabnr
       AND ( tabseqnr = '000001' OR tabseqnr = '000002' )."두라인
  ENDIF.
  SORT lt_p1002 BY otype objid.
  SORT lt_t1002 BY tabnr tabseqnr.

  IF lt_9552[] IS NOT INITIAL.
    SELECT * FROM hrt9552
      INTO TABLE @DATA(lt_9552_t)
      FOR ALL ENTRIES IN @lt_9552
      WHERE tabnr = @lt_9552-tabnr.
    SORT lt_9552_t BY tabnr book_fg otype objid.
    DELETE lt_9552_t WHERE tabnr IS INITIAL.
    DELETE lt_9552_t WHERE book_fg IS INITIAL.
  ENDIF.

  SELECT * FROM hrp1000
    INTO TABLE gt_1000
    WHERE plvar = '01'
      AND otype IN ('O','SC')
      AND istat = '1'
      AND langu = sy-langu
      AND begda <= gv_begda
      AND endda >= gv_begda.
  SORT gt_1000 BY otype objid.

  LOOP AT gt_evob.

    gt_data-o_id = gt_evob-oobjid.
    gt_data-o_stext = gt_evob-ostext.
    gt_data-objid = gt_evob-seobjid.
    gt_data-short = gt_evob-ssshort.
    gt_data-stext = gt_evob-smstext.
    gt_data-smobjid = gt_evob-smobjid.

    READ TABLE lt_9552 INTO DATA(ls_9552) WITH KEY objid = gt_evob-seobjid BINARY SEARCH.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_9552 TO gt_data.

      READ TABLE lt_9552_t WITH KEY tabnr = ls_9552-tabnr TRANSPORTING NO FIELDS BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_9552_t INTO DATA(ls_9552_t) FROM sy-tabix.
          IF ls_9552_t-tabnr <> ls_9552-tabnr.
            EXIT.
          ENDIF.

          MOVE-CORRESPONDING ls_9552_t TO ls_item.

          APPEND ls_item TO gt_data-item.
          CLEAR ls_item.
        ENDLOOP.
      ENDIF.
    ENDIF.

    READ TABLE lt_9550 INTO DATA(ls_9550) WITH KEY objid = gt_data-objid BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data-cu_fg = ls_9550-cu_fg.
      gt_data-recog_fg = ls_9550-recog_fg.
    ENDIF.

    READ TABLE lt_2381 INTO DATA(ls_2381) WITH KEY se_id = gt_data-objid BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data-bigo = ls_2381-bigo.
    ENDIF.

    READ TABLE lt_p1002 INTO DATA(ls_p1002) WITH KEY otype = 'SM' "비고
                                 objid = gt_data-smobjid
                                 BINARY SEARCH.
    IF sy-subrc = 0.
      READ TABLE lt_t1002 INTO DATA(ls_t1002) WITH KEY tabnr    = ls_p1002-tabnr
                                   tabseqnr = '000001'
                                   BINARY SEARCH.
      IF sy-subrc = 0.
        MOVE ls_t1002-tline TO gt_data-smltext.
      ENDIF.

      READ TABLE lt_t1002 INTO ls_t1002 WITH KEY tabnr    = ls_p1002-tabnr
                                   tabseqnr = '000002'
                                   BINARY SEARCH.
      IF sy-subrc = 0.
        CONCATENATE gt_data-smltext ls_t1002-tline
               INTO gt_data-smltext.
      ENDIF.
    ENDIF.

    APPEND gt_data.
    CLEAR gt_data.
  ENDLOOP.

  PERFORM concatenate_list.

  SORT gt_data BY o_stext short.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv_data
*&---------------------------------------------------------------------*
FORM grid_display_alv.

  go_grid ?= lcl_alv_grid=>create( CHANGING ct_table = gt_data[] ).
  go_grid->title_v1 = |{ TEXT-tit } - { lines( gt_data ) } 건|.

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
      WHEN 'O_STEXT'.
        <fs_fcat>-reptext = '개설학과'.
      WHEN 'SHORT'.
        <fs_fcat>-reptext = '분반코드' .
      WHEN 'STEXT'.
        <fs_fcat>-reptext = '과목명' .
      WHEN 'APPLY_FG'.
        <fs_fcat>-reptext = '소속제한' .
        <fs_fcat>-checkbox = 'X'.
      WHEN 'OBJID_T1'.
        <fs_fcat>-reptext = '전체전공 가능소속' .
        <fs_fcat>-emphasize = 'C410'.
        <fs_fcat>-hotspot = 'X'.
      WHEN 'STEXT_T1'.
        <fs_fcat>-reptext = '전체전공 가능소속명' .
        <fs_fcat>-emphasize = 'C410'.
      WHEN 'OBJID_T2'.
        <fs_fcat>-reptext = '전체전공 불가소속' .
        <fs_fcat>-emphasize = 'C600'.
        <fs_fcat>-hotspot = 'X'.
      WHEN 'STEXT_T2'.
        <fs_fcat>-reptext = '전체전공 불가소속명' .
        <fs_fcat>-emphasize = 'C600'.
      WHEN 'OBJID_T3'.
        <fs_fcat>-reptext = '1전공 가능소속' .
        <fs_fcat>-emphasize = 'C500'.
        <fs_fcat>-hotspot = 'X'.
      WHEN 'STEXT_T3'.
        <fs_fcat>-reptext = '1전공 가능소속명' .
        <fs_fcat>-emphasize = 'C500'.
      WHEN 'OBJID_T4'.
        <fs_fcat>-reptext = '1전공 불가소속' .
        <fs_fcat>-emphasize = 'C710'.
        <fs_fcat>-hotspot = 'X'.
      WHEN 'STEXT_T4'.
        <fs_fcat>-reptext = '1전공 불가소속명' .
        <fs_fcat>-emphasize = 'C710'.
      WHEN 'CU_FG'.
        <fs_fcat>-reptext = 'CU과목' .
        <fs_fcat>-checkbox = 'X'.
      WHEN 'RECOG_FG'.
        <fs_fcat>-reptext = '승인과목' .
        <fs_fcat>-checkbox = 'X'.
      WHEN 'BIGO'.
        <fs_fcat>-reptext = '비고' .
      WHEN 'CFLAG'.
        <fs_fcat>-reptext = '수정' .
        <fs_fcat>-checkbox = 'X'.
      WHEN 'REVIEW'.
        <fs_fcat>-reptext = '변경' .
        <fs_fcat>-checkbox = 'X'.
      WHEN 'SMLTEXT'.
        <fs_fcat>-reptext = '과목설명' .
      WHEN OTHERS.
        <fs_fcat>-no_out = 'X'.
    ENDCASE.

    <fs_fcat>-scrtext_l = <fs_fcat>-scrtext_m = <fs_fcat>-scrtext_s = <fs_fcat>-reptext.
  ENDLOOP.

  go_grid->set_frontend_fieldcatalog( go_grid->fcat ).
  go_grid->set_editable( abap_true ).

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
  go_grid->sort = VALUE #(
                            ( fieldname = 'CFLAG'   down = 'X' )
                            ( fieldname = 'REVIEW'  down = 'X' )
                            ( fieldname = 'O_STEXT' up   = 'X' )
                            ( fieldname = 'SHORT'   up   = 'X' )
                            ( fieldname = 'STEXT'   up   = 'X' )
                         ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_gui_status
*&---------------------------------------------------------------------*
FORM grid_gui_status .

  go_grid->gui_status->fully_dynamic = abap_true.
  go_grid->exclude_functions = go_grid->gui_status->edit_buttons( ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_01
    iv_text   = '저장'
    iv_icon   = icon_system_save ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_02
    iv_text   = '엑셀 업로드'
    iv_icon   = icon_xls ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_04
    iv_text   = '전체전공 가능'
    iv_icon   = icon_led_green ).
  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_05
    iv_text   = '전체전공 가능'
    iv_icon   = icon_delete ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_06
    iv_text   = '전체전공 불가'
    iv_icon   = icon_led_red ).
  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_07
    iv_text   = '전체전공 불가'
    iv_icon   = icon_delete ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_08
    iv_text   = '1전공 가능'
    iv_icon   = icon_led_green ).
  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_09
    iv_text   = '1전공 가능'
    iv_icon   = icon_delete ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_10
    iv_text   = '1전공 불가'
    iv_icon   = icon_led_red ).
  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_11
    iv_text   = '1전공 불가'
    iv_icon   = icon_delete ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_12
    iv_text   = '모든 변경사항 확인'
    iv_icon   = icon_complete ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EV_data_changed
*&---------------------------------------------------------------------*
FORM ev_data_changed  USING po_data_changed TYPE REF TO cl_alv_changed_data_protocol.


  LOOP AT po_data_changed->mt_mod_cells INTO DATA(ls_mod).
    READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<fs>) INDEX ls_mod-row_id.
    CHECK sy-subrc = 0.
    <fs>-cflag = 'X'.
  ENDLOOP.

  go_grid->set_frontend_layout( go_grid->lvc_layout ).
  go_grid->soft_refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EV_user_command
*&---------------------------------------------------------------------*
FORM ev_user_command  USING p_ucomm   po_me TYPE REF TO lcl_alv_grid.

  CASE p_ucomm.
    WHEN zcl_falv_dynamic_status=>b_01. "저장
      PERFORM save_data.

    WHEN zcl_falv_dynamic_status=>b_02. "엑셀 업로드
      PERFORM set_uplo_limit.

    WHEN zcl_falv_dynamic_status=>b_04. "전체전공 가능 추가
      PERFORM add_org_multi USING '1'.

    WHEN zcl_falv_dynamic_status=>b_05. "전체전공 가능 삭제
      PERFORM del_org_multi USING '1'.

    WHEN zcl_falv_dynamic_status=>b_06. "전체전공 불가 추가
      PERFORM add_org_multi USING '2'.

    WHEN zcl_falv_dynamic_status=>b_07. "전체전공 불가 삭제
      PERFORM del_org_multi USING '2'.

    WHEN zcl_falv_dynamic_status=>b_08. "1전공 가능 추가
      PERFORM add_org_multi USING '3'.

    WHEN zcl_falv_dynamic_status=>b_09. "1전공 가능 삭제
      PERFORM del_org_multi USING '3'.

    WHEN zcl_falv_dynamic_status=>b_10. "1전공 불가 추가
      PERFORM add_org_multi USING '4'.

    WHEN zcl_falv_dynamic_status=>b_11. "1전공 불가 삭제
      PERFORM del_org_multi USING '4'.

    WHEN zcl_falv_dynamic_status=>b_12. "모든 변경사항 확인
      PERFORM comp_review.

    WHEN zcl_falv_dynamic_status=>b_31. "추가 팝업
      PERFORM add_org.
    WHEN zcl_falv_dynamic_status=>b_32. "삭제 팝업
      PERFORM del_org.

    WHEN 'CONTINUE'.
      CASE po_me.
        WHEN go_item.
          PERFORM item_to_header.
          LEAVE TO SCREEN 0.

        WHEN go_xls.
          PERFORM save_xls_data.
        WHEN OTHERS.
      ENDCASE.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ev_hotspot_click
*&---------------------------------------------------------------------*
FORM ev_hotspot_click  USING p_row p_fieldname.

  DATA ls_item LIKE gt_item.

  CLEAR: gt_item[], gt_rows[], gv_book_fg.

  CLEAR gt_data.
  READ TABLE gt_data INDEX p_row.
  CHECK sy-subrc = 0.

  gt_rows = VALUE #( ( index = p_row ) ).

*  ASSIGN COMPONENT p_fieldname OF STRUCTURE ls_data TO FIELD-SYMBOL(<fs_obj>).
*  CHECK sy-subrc = 0.
*  CHECK <fs_obj> IS NOT INITIAL.

  IF p_fieldname(7) = 'OBJID_T'.
    gv_book_fg = p_fieldname+7(1).
  ENDIF.

  SELECT SINGLE ddtext FROM dd07t
    INTO @DATA(lv_ft)
    WHERE domvalue_l = @gv_book_fg
      AND domname = 'ZCMK_BOOK_FG'
      AND ddlanguage = @sy-langu.

  CHECK gv_book_fg IS NOT INITIAL.

  LOOP AT gt_data-item INTO DATA(ls_data_item) WHERE book_fg = gv_book_fg.
    MOVE-CORRESPONDING ls_data_item TO ls_item.

    READ TABLE gt_1000 INTO DATA(ls_1000) WITH KEY otype = ls_item-otype
                                                   objid = ls_item-objid
                                                   BINARY SEARCH.
    IF sy-subrc = 0.
      ls_item-stext = ls_1000-stext.
    ENDIF.
    APPEND ls_item TO gt_item.
    CLEAR ls_item.
  ENDLOOP.
  IF gt_item[] IS INITIAL AND gt_data-item IS NOT INITIAL.
    MESSAGE '이미 셋팅되었습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  go_item ?= lcl_alv_grid=>create( EXPORTING i_popup  = abap_true
                                   CHANGING  ct_table = gt_item[] ).

  LOOP AT go_item->fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).
    CASE <fs_fcat>-fieldname.
      WHEN 'OTYPE'.
        <fs_fcat>-reptext = 'OTYPE'.
        <fs_fcat>-outputlen = 5.
      WHEN 'OBJID'.
        <fs_fcat>-reptext = '소속'.
        <fs_fcat>-outputlen = 10.
      WHEN 'STEXT'.
        <fs_fcat>-reptext = '소속명'.
        <fs_fcat>-outputlen = 28.
      WHEN OTHERS.
        <fs_fcat>-no_out = 'X'.
    ENDCASE.

    <fs_fcat>-scrtext_l = <fs_fcat>-scrtext_m = <fs_fcat>-scrtext_s = <fs_fcat>-reptext.
  ENDLOOP.

  go_item->set_frontend_fieldcatalog( go_item->fcat ).
  go_item->layout->set_sel_mode( 'D' ).
  go_item->layout->set_grid_title( |{ gt_data-short } - { lv_ft }| ).
  go_item->title_v1 = |{ gt_data-short } - { lv_ft }|.
  go_item->add_button( EXPORTING iv_function = zcl_falv_dynamic_status=>b_31
                                 iv_icon     = icon_insert_row
                                 iv_text     = '추가' ).
  go_item->add_button( EXPORTING iv_function = zcl_falv_dynamic_status=>b_32
                                 iv_icon     = icon_delete_row
                                 iv_text     = '삭제' ).
  go_item->display(
    EXPORTING
      iv_start_row    = 5
      iv_start_column = 5
      iv_end_row      = 20
      iv_end_column   = 50 ).




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
*& Form grid_top_of_page
*&---------------------------------------------------------------------*
FORM grid_top_of_page .

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

  PERFORM get_user_authorg.
  PERFORM set_current_period.
  PERFORM set_ddlb.

  CONCATENATE icon_xls '양식 내려받기' INTO sscrfields-functxt_01.
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

  CHECK NOT lt_hrtimeinfo[] IS INITIAL.

  LOOP AT lt_hrtimeinfo INTO ls_timeinfo.
    p_peryr = ls_timeinfo-peryr.
    p_perid = ls_timeinfo-perid.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_ddlb
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_ddlb .

  DATA lt_vrm  TYPE vrm_values WITH HEADER LINE.
  DATA lr_org TYPE RANGE OF zcmt0101-map_cd2 WITH HEADER LINE.

* 정규학기만
  CALL FUNCTION 'ZCM_LIST_BOX_PYEAR_PERID'
    EXPORTING
      year_field  = 'P_PERYR'
      perid_field = 'P_PERID'.

  READ TABLE gt_authobj WITH KEY objid = '32000000' TRANSPORTING NO FIELDS.
  IF sy-subrc <> 0.
    lr_org[] = CORRESPONDING #( gt_authobj[] MAPPING low = objid ).
    lr_org-sign = 'I'.
    lr_org-option = 'EQ'.
    MODIFY lr_org FROM lr_org TRANSPORTING sign option WHERE sign IS INITIAL .
  ENDIF.

  SELECT map_cd2, com_nm
    FROM zcmt0101
   WHERE grp_cd IN ('100','109')
    AND map_cd2 IN @lr_org
    INTO TABLE @lt_vrm.

  SORT lt_vrm.
  DELETE ADJACENT DUPLICATES FROM lt_vrm COMPARING ALL FIELDS.

  READ TABLE lt_vrm INDEX 1.
  IF sy-subrc = 0.
    p_orgcd = lt_vrm-key.
  ENDIF.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'P_ORGCD'
      values          = lt_vrm[]
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.


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

  CALL FUNCTION 'ZCM_USER_AUTHORITY'
    EXPORTING
      im_userid             = sy-uname
    TABLES
      itab_auth             = gt_authobj[]
    EXCEPTIONS
      no_authority_for_user = 1
      OTHERS                = 2.

  IF sy-subrc <> 0.
    MESSAGE ID   sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    STOP.
  ENDIF.

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
  CHECK sy-subrc = 0.
*    IF ls_tili-ca_lbegda =< sy-datum AND ls_tili-ca_lendda >= sy-datum.
*      gv_keydt = sy-datum.
*    ELSEIF ls_tili-ca_lendda < sy-datum.
*    gv_keydt = ls_tili-ca_lendda.
*    ELSEIF ls_tili-ca_lbegda > sy-datum.
*      gv_keydt = ls_tili-ca_lbegda.
*    ENDIF.
  gv_begda = ls_tili-ca_lbegda.
  gv_endda = ls_tili-ca_lendda.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_evob
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_evob .


  DATA: lt_evob TYPE zcmscourse OCCURS 0 WITH HEADER LINE.
  DATA: lv_keywd TYPE stext.

  CLEAR: gt_evob[], gt_evob, lt_evob[], lt_evob.
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

  IF s_sesht[] IS NOT INITIAL.
    DELETE gt_evob WHERE ssshort NOT IN s_sesht[].
  ENDIF.
  IF s_smsht[] IS NOT INITIAL.
    DELETE gt_evob WHERE smshort NOT IN s_smsht[].
  ENDIF.

  SORT gt_evob BY seobjid.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_data
*&---------------------------------------------------------------------*
FORM save_data .


  go_grid->check_changed_data( ).

  READ TABLE gt_data WITH KEY cflag = 'X' TRANSPORTING NO FIELDS.
  IF sy-subrc <> 0.
    MESSAGE s004 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  CHECK zcmcl000=>popup_to_confirm( '저장하시겠습니까?' ) IS NOT INITIAL.

  DATA(lr_log) = NEW cl_bal_logobj( i_max_msg_memory = 99999 ).

  LOOP AT gt_data INTO DATA(ls_data) WHERE cflag = 'X'.

    PERFORM save_infty_9552 USING ls_data CHANGING lr_log.

  ENDLOOP.

  lr_log->display( ).

  PERFORM get_data_select.

  go_grid->set_frontend_layout( go_grid->lvc_layout ).
  go_grid->soft_refresh( ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_objid_list
*&---------------------------------------------------------------------*
FORM set_objid_list  TABLES   pt_ot1
                              pt_st1
                     USING    p_otype
                              p_objid.

  APPEND |[{ p_otype }]{ p_objid }| TO pt_ot1.

  READ TABLE gt_1000 INTO DATA(ls_1000) WITH KEY otype = p_otype
                                                 objid = p_objid
                                                 BINARY SEARCH.
  IF sy-subrc = 0.
    APPEND ls_1000-stext TO pt_st1.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_ORG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM add_org .

  PERFORM orgcd_request.

  go_item->set_frontend_layout( go_item->lvc_layout ).
  go_item->soft_refresh( ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form orgcd_request
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM orgcd_request .

  DATA lt_objec TYPE TABLE OF objec.

  CLEAR lt_objec[].
  CALL FUNCTION 'ZCMK_ORGEH_REQUEST'
    EXPORTING
      iv_keydt  = gv_begda
      iv_expand = p_orgcd
    TABLES
      et_orgeh  = lt_objec.

  LOOP AT lt_objec INTO DATA(ls_objec).
    READ TABLE gt_item WITH KEY otype = ls_objec-otype objid = ls_objec-objid.
    CHECK sy-subrc <> 0.
    CLEAR gt_item.
    MOVE-CORRESPONDING ls_objec TO gt_item.

    gt_item-book_fg = gv_book_fg.

    APPEND gt_item.
    CLEAR gt_item.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form del_org
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM del_org .

  DATA lt_rows LIKE gt_rows.

  go_item->get_selected_rows( IMPORTING et_index_rows = lt_rows ).
  IF lines( lt_rows ) IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  CHECK zcmcl000=>popup_to_confirm( '삭제하시겠습니까?' ) IS NOT INITIAL.

  LOOP AT lt_rows INTO DATA(ls_row).
    READ TABLE gt_item ASSIGNING FIELD-SYMBOL(<fs>) INDEX ls_row-index.
    CHECK sy-subrc = 0.

    <fs>-del = 'X'.
  ENDLOOP.

  DELETE gt_item WHERE del = 'X'.

  go_item->set_frontend_layout( go_item->lvc_layout ).
  go_item->soft_refresh( ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form item_to_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM item_to_header .
  DATA ls_data_item TYPE pt9552.

  LOOP AT gt_rows INTO DATA(ls_row).
    READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<fs>) INDEX ls_row-index.
    CHECK sy-subrc = 0.

    <fs>-cflag = 'X'.
    CLEAR <fs>-item.
*    DELETE <fs>-item WHERE book_fg = gv_book_fg.

    LOOP AT gt_item INTO DATA(ls_item).

      READ TABLE <fs>-item WITH KEY book_fg = ls_item-book_fg
                                    otype = ls_item-otype
                                    objid = ls_item-objid
                                    TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        <fs>-apply_fg = 'X'.
        MOVE-CORRESPONDING ls_item TO ls_data_item.
        APPEND ls_data_item TO <fs>-item.
        CLEAR ls_item.
      ENDIF.
    ENDLOOP.

  ENDLOOP.

  PERFORM concatenate_list.

  go_grid->set_frontend_layout( go_grid->lvc_layout ).
  go_grid->soft_refresh( ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONCATENATE_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM concatenate_list .

  DATA : lt_ot1 TYPE TABLE OF stext,
         lt_st1 TYPE TABLE OF stext,
         lt_ot2 TYPE TABLE OF stext,
         lt_st2 TYPE TABLE OF stext,
         lt_ot3 TYPE TABLE OF stext,
         lt_st3 TYPE TABLE OF stext,
         lt_ot4 TYPE TABLE OF stext,
         lt_st4 TYPE TABLE OF stext.

  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs>).
    IF <fs>-item[] IS INITIAL.
      CLEAR : <fs>-objid_t1, <fs>-stext_t1,
              <fs>-objid_t2, <fs>-stext_t2,
              <fs>-objid_t3, <fs>-stext_t3,
              <fs>-objid_t4, <fs>-stext_t4.
      CONTINUE.
    ENDIF.

    LOOP AT <fs>-item INTO DATA(ls_data_item).
      CASE ls_data_item-book_fg.
        WHEN '1'.
          PERFORM set_objid_list TABLES lt_ot1 lt_st1
                                 USING ls_data_item-otype ls_data_item-objid.
        WHEN '2'.
          PERFORM set_objid_list TABLES lt_ot2 lt_st2
                                 USING ls_data_item-otype ls_data_item-objid.
        WHEN '3'.
          PERFORM set_objid_list TABLES lt_ot3 lt_st3
                                 USING ls_data_item-otype ls_data_item-objid.
        WHEN '4'.
          PERFORM set_objid_list TABLES lt_ot4 lt_st4
                                 USING ls_data_item-otype ls_data_item-objid.
      ENDCASE.
    ENDLOOP.

    CONCATENATE LINES OF lt_ot1 INTO <fs>-objid_t1 SEPARATED BY gc_separator.
    CONCATENATE LINES OF lt_st1 INTO <fs>-stext_t1 SEPARATED BY gc_separator.
    CONCATENATE LINES OF lt_ot2 INTO <fs>-objid_t2 SEPARATED BY gc_separator.
    CONCATENATE LINES OF lt_st2 INTO <fs>-stext_t2 SEPARATED BY gc_separator.
    CONCATENATE LINES OF lt_ot3 INTO <fs>-objid_t3 SEPARATED BY gc_separator.
    CONCATENATE LINES OF lt_st3 INTO <fs>-stext_t3 SEPARATED BY gc_separator.
    CONCATENATE LINES OF lt_ot4 INTO <fs>-objid_t4 SEPARATED BY gc_separator.
    CONCATENATE LINES OF lt_st4 INTO <fs>-stext_t4 SEPARATED BY gc_separator.

    CLEAR: lt_ot1,lt_st1,
           lt_ot2,lt_st2,
           lt_ot3,lt_st3,
           lt_ot4,lt_st4.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_org_multi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM add_org_multi  USING    p_flag.

  go_grid->get_selected_rows( IMPORTING et_index_rows = gt_rows ).
  IF lines( gt_rows ) IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  CLEAR: gt_item[], gv_book_fg.
  gv_book_fg = p_flag.

  PERFORM orgcd_request.
  CHECK gt_item[] IS NOT INITIAL.
  PERFORM item_to_header.

  MESSAGE s006.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form del_org_multi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM del_org_multi  USING    p_flag.

  go_grid->get_selected_rows( IMPORTING et_index_rows = gt_rows ).
  IF lines( gt_rows ) IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  CHECK zcmcl000=>popup_to_confirm( '삭제하시겠습니까?' ) IS NOT INITIAL.

  LOOP AT gt_rows INTO DATA(ls_row).
    READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<fs>) INDEX ls_row-index.
    CHECK sy-subrc = 0.

    IF <fs>-item[] IS NOT INITIAL.
      <fs>-cflag = 'X'.
      DELETE <fs>-item WHERE book_fg = p_flag.
      DATA(lv_del) = 'X'.
    ENDIF.

  ENDLOOP.

  IF lv_del IS INITIAL.
    MESSAGE s009 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  PERFORM concatenate_list.
  MESSAGE s006.

  go_grid->set_frontend_layout( go_grid->lvc_layout ).
  go_grid->soft_refresh( ).


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
      file_name = 'ZCMRK320'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_uplo_limit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_uplo_limit .

  DATA: BEGIN OF lt_form OCCURS 0,
          short(12),
          book_fg(1),
          otype(2),
          o_id(8),
        END OF lt_form.

  DATA: lv_filename TYPE rlgrap-filename,
        lv_row_data TYPE truxs_t_text_data.
  DATA lt_msg TYPE TABLE OF stext.

  CLEAR gt_xls[].

  CALL METHOD zcmcl000=>excel_to_itab
    IMPORTING
      ev_error = DATA(lv_error)
      ev_msg   = DATA(ev_msg)
    CHANGING
      ct_data  = lt_form[].

  IF lv_error IS NOT INITIAL.
    MESSAGE s001 WITH ev_msg DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  DELETE lt_form WHERE short IS INITIAL.
  CHECK lt_form[] IS NOT INITIAL.

  SELECT * FROM hrp1000
    INTO TABLE @DATA(lt_se)
    FOR ALL ENTRIES IN @lt_form
    WHERE plvar = '01'
      AND otype = 'SE'
      AND short = @lt_form-short
      AND istat = '1'
      AND langu = @sy-langu
      AND begda <= @sy-datum
      AND endda >= @sy-datum.
  SORT lt_se BY short.

  SELECT * FROM dd07t
    INTO TABLE @DATA(lt_dom)
    WHERE domname = 'ZCMK_BOOK_FG'
      AND ddlanguage = @sy-langu.
  SORT lt_dom BY domvalue_l.

  LOOP AT lt_form.
    MOVE-CORRESPONDING lt_form TO gt_xls.

    READ TABLE lt_dom INTO DATA(ls_dom) WITH KEY domvalue_l = gt_xls-book_fg BINARY SEARCH.
    IF sy-subrc <> 0.
      APPEND '수강구분 오류' TO lt_msg.
    ENDIF.

    IF gt_xls-otype = 'SC' OR gt_xls-otype = 'O'.
    ELSE.
      APPEND '오브젝트유형 오류' TO lt_msg.
    ENDIF.

    READ TABLE lt_se INTO DATA(ls_se) WITH KEY short = gt_xls-short BINARY SEARCH.
    IF sy-subrc = 0.
      gt_xls-objid = ls_se-objid.
      gt_xls-stext = ls_se-stext.
    ELSE.
      APPEND '분반코드 오류' TO lt_msg.
    ENDIF.

    READ TABLE gt_1000 INTO DATA(ls_1000) WITH KEY otype = gt_xls-otype objid = gt_xls-o_id BINARY SEARCH.
    IF sy-subrc = 0.
      gt_xls-o_stext = ls_1000-stext.
    ELSE.
      APPEND '소속코드 오류' TO lt_msg.
    ENDIF.

    IF lt_msg IS NOT INITIAL.
      CONCATENATE LINES OF lt_msg INTO gt_xls-msg SEPARATED BY ','.
      gt_xls-type = 'E'.
    ENDIF.

    gt_xls-apply_fg = 'X'.

    APPEND gt_xls.
    CLEAR: gt_xls, lt_msg.
  ENDLOOP.


  PERFORM grid_display_xls.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_display_xls
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM grid_display_xls .

  SORT gt_xls BY objid book_fg otype o_id.

  go_xls ?= lcl_alv_grid=>create( EXPORTING i_popup  = abap_true
                                  CHANGING  ct_table = gt_xls[] ).

  LOOP AT go_xls->fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).
    CASE <fs_fcat>-fieldname.
      WHEN 'TYPE'.
        <fs_fcat>-reptext = 'Type'.
        <fs_fcat>-outputlen = 5.
      WHEN 'MSG'.
        <fs_fcat>-reptext = '비고'.
        <fs_fcat>-outputlen = 10.
      WHEN 'OBJID'.
        <fs_fcat>-reptext = '분반ID'.
        <fs_fcat>-outputlen = 10.
      WHEN 'SHORT'.
        <fs_fcat>-reptext = '분반코드'.
        <fs_fcat>-outputlen = 10.
      WHEN 'STEXT'.
        <fs_fcat>-reptext = '분반명'.
        <fs_fcat>-outputlen = 25.
      WHEN 'BOOK_FG'.
        <fs_fcat>-reptext = '수강가능구분'.
        <fs_fcat>-outputlen = 10.
      WHEN 'OTYPE'.
        <fs_fcat>-reptext = '오브젝트유형'.
        <fs_fcat>-outputlen = 10.
      WHEN 'O_ID'.
        <fs_fcat>-reptext = '소속'.
        <fs_fcat>-outputlen = 10.
      WHEN 'O_STEXT'.
        <fs_fcat>-reptext = '소속명'.
        <fs_fcat>-outputlen = 25.
      WHEN OTHERS.
        <fs_fcat>-no_out = 'X'.
    ENDCASE.

    <fs_fcat>-scrtext_l = <fs_fcat>-scrtext_m = <fs_fcat>-scrtext_s = <fs_fcat>-reptext.
  ENDLOOP.

  go_xls->title_v1 = |{ TEXT-ti2 } - { lines( gt_xls ) } 건|.
  go_xls->set_frontend_fieldcatalog( go_xls->fcat ).
  go_xls->layout->set_zebra( abap_true ).

  go_xls->display(
    EXPORTING
      iv_start_row    = 1
      iv_start_column = 5
      iv_end_row      = 40
      iv_end_column   = 120 ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_INFTY_9552
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_DATA
*&---------------------------------------------------------------------*
FORM save_infty_9552  USING    ps_data LIKE gt_data
                      CHANGING po_log TYPE REF TO cl_bal_logobj.

  DATA ls_p9552 TYPE p9552.
  DATA lt_p9552 TYPE TABLE OF pt9552.
  DATA lv_mode.

  CLEAR: ls_p9552, lv_mode, lt_p9552[].
  SELECT SINGLE * FROM hrp9552
    INTO CORRESPONDING FIELDS OF ls_p9552
    WHERE plvar = '01'
      AND otype = 'SE'
      AND objid = ps_data-objid
      AND istat = '1'
      AND begda <= gv_begda
      AND endda >= gv_begda.
  IF sy-subrc = 0.
    lv_mode = 'U'.
  ELSE.
    lv_mode = 'I'.

    ls_p9552-plvar = '01'.
    ls_p9552-otype = 'SE'.
    ls_p9552-istat = '1'.
    ls_p9552-infty = '9552'.
    ls_p9552-objid = ps_data-objid.
    ls_p9552-begda = gv_begda.
    ls_p9552-endda = gv_endda.
  ENDIF.
  ls_p9552-apply_fg = ps_data-apply_fg.
  ls_p9552-review = ''.

  lt_p9552[] = ps_data-item[].

  zcmcl000=>hriq_modify_infty(
    EXPORTING
      iv_mode   = lv_mode
      is_pnnnn  = ls_p9552
      it_ptnnnn = lt_p9552
    IMPORTING
      ev_error  = DATA(lv_err)
      ev_msg    = DATA(lv_msg)
  ).

  IF lv_err IS INITIAL.
    po_log->add_statustext( |{ ps_data-stext }[{ ps_data-short }] - { lv_msg } | ).
  ELSE.
    po_log->add_errortext( |{ ps_data-stext }[{ ps_data-short }] - { lv_msg }| ).
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_XLS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_xls_data .

  DATA lt_temp LIKE TABLE OF gt_data WITH HEADER LINE.
  DATA ls_item TYPE pt9552.

  READ TABLE gt_xls WITH KEY type = 'E' TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    DATA(lv_msg) = '에러데이터를 제외하고 저장하시겠습니까?'.
  ELSE.
    lv_msg = '저장하시겠습니까?'.
  ENDIF.

  CHECK zcmcl000=>popup_to_confirm( lv_msg ) IS NOT INITIAL.

  DELETE gt_xls WHERE type = 'E'.
  SORT gt_xls BY objid book_fg otype o_id.

*Sort 필수
  LOOP AT gt_xls INTO DATA(ls_xls) GROUP BY ( objid = ls_xls-objid )
                                   ASSIGNING FIELD-SYMBOL(<fg>).

    LOOP AT GROUP <fg> ASSIGNING FIELD-SYMBOL(<fs>).
      ls_item-book_fg = <fs>-book_fg.
      ls_item-otype = <fs>-otype.
      ls_item-objid = <fs>-o_id.
      APPEND ls_item TO lt_temp-item.
      CLEAR ls_item.
    ENDLOOP.

    lt_temp-objid = <fs>-objid.
    lt_temp-short = <fs>-short.
    lt_temp-stext = <fs>-stext.
    lt_temp-apply_fg = <fs>-apply_fg.
    APPEND lt_temp.
    CLEAR lt_temp.
  ENDLOOP.
  CHECK lt_temp[] IS NOT INITIAL.

  DATA(lr_log) = NEW cl_bal_logobj( i_max_msg_memory = 99999 ).

  LOOP AT lt_temp INTO DATA(ls_data).
    PERFORM save_infty_9552 USING ls_data CHANGING lr_log.
  ENDLOOP.

  lr_log->display( ).

  PERFORM get_data_select.

  go_grid->set_frontend_layout( go_grid->lvc_layout ).
  go_grid->soft_refresh( ).

  LEAVE TO SCREEN 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form COMP_REVIEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM comp_review .

  DATA ls_p9552 TYPE p9552.

  CHECK zcmcl000=>popup_to_confirm( '모든 변경사항 확인 완료하시겠습니까?' ) IS NOT INITIAL.

  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs>) WHERE review = 'X'.

    CLEAR: ls_p9552.
    SELECT SINGLE * FROM hrp9552
      INTO CORRESPONDING FIELDS OF ls_p9552
      WHERE plvar = '01'
        AND otype = 'SE'
        AND objid = <fs>-objid
        AND istat = '1'
        AND begda <= gv_begda
        AND endda >= gv_begda
        AND review = 'X'.
    IF sy-subrc = 0.
      UPDATE hrp9552 SET review = ''
                   WHERE plvar = ls_p9552-plvar
                     AND otype = ls_p9552-otype
                     AND objid = ls_p9552-objid
                     AND istat = ls_p9552-istat
                     AND begda = ls_p9552-begda
                     AND endda = ls_p9552-endda.
      DATA(lv_set) = 'X'.
    ENDIF.
  ENDLOOP.
  IF lv_set IS INITIAL.
    MESSAGE s009 DISPLAY LIKE 'E'. RETURN.
  ENDIF.

  COMMIT WORK.
  MESSAGE s011.

  PERFORM get_data_select.

  go_grid->soft_refresh( ).


ENDFORM.
