*&---------------------------------------------------------------------*
*& Include          MZCMRK990_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data_select
*&---------------------------------------------------------------------*
FORM get_data_select .

  DATA ls_style LIKE LINE OF gt_data-style.

  CLEAR : gt_data[].

  PERFORM get_evob. "개설정보

  CHECK gt_evob[] IS NOT INITIAL.
  SELECT * FROM hrp9551
    INTO TABLE @DATA(lt_9551)
     FOR ALL ENTRIES IN @gt_evob
   WHERE plvar = '01'
     AND otype = 'SE'
     AND objid = @gt_evob-seobjid
     AND begda <= @gv_keydt
     AND endda >= @gv_keydt.
  SORT lt_9551 BY objid.

  SELECT * FROM hrp9550
    INTO TABLE @DATA(lt_9550)
     FOR ALL ENTRIES IN @gt_evob
   WHERE plvar = '01'
     AND otype = 'SE'
     AND objid = @gt_evob-seobjid
     AND begda <= @gv_keydt
     AND endda >= @gv_keydt.
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

  SELECT * FROM dd07t
    INTO TABLE @DATA(lt_dom)
    WHERE domname = 'ZCMK_QT_TP'
      AND ddlanguage = @sy-langu.
  SORT lt_dom BY domvalue_l.

  LOOP AT gt_evob.

    gt_data-o_id = gt_evob-oobjid.
    gt_data-o_stext = gt_evob-ostext.
    gt_data-objid = gt_evob-seobjid.
    gt_data-short = gt_evob-ssshort.
    gt_data-stext = gt_evob-smstext.

    CLEAR ls_style.
    READ TABLE lt_9551 INTO DATA(ls_9551) WITH KEY objid = gt_data-objid BINARY SEARCH.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_9551 TO gt_data.
    ELSE.
      gt_data-set_no = 'X'.

*      ls_style-fieldname = 'BOOK_KAPZG'.
*      ls_style-style = cl_gui_alv_grid=>mc_style_disabled.
*      INSERT ls_style INTO TABLE gt_data-style.
*      IF gv_grad = abap_true. "대학원
*        ls_style-fieldname = 'BOOK_KAPZ'.
*        ls_style-style = cl_gui_alv_grid=>mc_style_disabled.
*        INSERT ls_style INTO TABLE gt_data-style.
*      ENDIF.
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

    READ TABLE lt_dom INTO DATA(ls_dom) WITH KEY domvalue_l = gt_data-qt_tp BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data-qt_tpt = ls_dom-ddtext.
    ENDIF.

    APPEND gt_data.
    CLEAR gt_data.
  ENDLOOP.

  SORT gt_data BY cflag DESCENDING review DESCENDING short.

  CHECK gv_grad = 'X' OR "대학원
        gv_30000305 = 'X'. "AI·SW대학원

  DATA lv_count TYPE numc5.
  PERFORM create_9551 CHANGING lv_count.

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

  DATA: no_out_undergrad, no_out_grad.
  CASE 'X'.
    WHEN gv_undergrad. "학부
      no_out_undergrad = abap_true.
    WHEN gv_grad. "대학원
      no_out_grad = abap_true.
  ENDCASE.

  LOOP AT go_grid->fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).

    CASE <fs_fcat>-fieldname.
      WHEN 'O_STEXT'.
        <fs_fcat>-reptext = '개설학과'.
      WHEN 'SHORT'.
        <fs_fcat>-reptext = '분반코드'.
      WHEN 'STEXT'.
        <fs_fcat>-reptext = '과목명'.
      WHEN 'BOOK_KAPZ4'.
        <fs_fcat>-reptext = '(학과신청)4학년'.
        <fs_fcat>-no_out = no_out_grad.
        IF p_orgcd = '30000305'. <fs_fcat>-edit = 'X'. ENDIF. "AI·SW대학원
      WHEN 'BOOK_KAPZ3'.
        <fs_fcat>-reptext = '(학과신청)3학년'.
        <fs_fcat>-no_out = no_out_grad.
        IF p_orgcd = '30000305'. <fs_fcat>-edit = 'X'. ENDIF. "AI·SW대학원
      WHEN 'BOOK_KAPZ2'.
        <fs_fcat>-reptext = '(학과신청)2학년'.
        <fs_fcat>-no_out = no_out_grad.
        IF p_orgcd = '30000305'. <fs_fcat>-edit = 'X'. ENDIF. "AI·SW대학원
      WHEN 'BOOK_KAPZ1'.
        <fs_fcat>-reptext = '(학과신청)1학년'.
        <fs_fcat>-no_out = no_out_grad.
        IF p_orgcd = '30000305'. <fs_fcat>-edit = 'X'. ENDIF. "AI·SW대학원
      WHEN 'BOOK_KAPZ'.
        <fs_fcat>-reptext = '대학원 수강가능인원'.
        <fs_fcat>-edit = 'X'.
        <fs_fcat>-no_out = no_out_undergrad.
      WHEN 'BOOK_KAPZG'.
        <fs_fcat>-reptext = '교환학생 수강가능인원'.
        <fs_fcat>-edit = 'X'.
      WHEN 'BOOK_KAPZ4_R'.
        <fs_fcat>-reptext = '4학년 수강가능인원'.
        <fs_fcat>-emphasize = 'C300'.
        <fs_fcat>-no_out = no_out_grad.
        <fs_fcat>-edit = 'X'.
      WHEN 'BOOK_KAPZ3_R'.
        <fs_fcat>-reptext = '3학년 수강가능인원'.
        <fs_fcat>-emphasize = 'C300'.
        <fs_fcat>-no_out = no_out_grad.
        <fs_fcat>-edit = 'X'.
      WHEN 'BOOK_KAPZ2_R'.
        <fs_fcat>-reptext = '2학년 수강가능인원'.
        <fs_fcat>-emphasize = 'C300'.
        <fs_fcat>-no_out = no_out_grad.
        <fs_fcat>-edit = 'X'.
      WHEN 'BOOK_KAPZ1_R'.
        <fs_fcat>-reptext = '1학년 수강가능인원'.
        <fs_fcat>-emphasize = 'C300'.
        <fs_fcat>-no_out = no_out_grad.
        <fs_fcat>-edit = 'X'.
      WHEN 'UG_BOOK_SEQ_TXT'.
        <fs_fcat>-reptext = '학부 학년별 순서'.
        <fs_fcat>-no_out = no_out_grad.
      WHEN 'QT_TPT'.
        <fs_fcat>-reptext = '쿼터풀기 방법'.
        <fs_fcat>-no_out = no_out_grad.
      WHEN 'SET_NO'.
        <fs_fcat>-reptext = '인원 미설정'.
        <fs_fcat>-checkbox = 'X'.
      WHEN 'CU_FG'.
        <fs_fcat>-reptext = 'CU과목'.
        <fs_fcat>-checkbox = 'X'.
      WHEN 'RECOG_FG'.
        <fs_fcat>-reptext = '승인과목'.
        <fs_fcat>-checkbox = 'X'.
      WHEN 'BIGO'.
        <fs_fcat>-reptext = '비고'.
        <fs_fcat>-no_out = no_out_grad.
      WHEN 'REMARK'.
        <fs_fcat>-reptext = '메모'.
        <fs_fcat>-edit = 'X'.
      WHEN 'CFLAG'.
        <fs_fcat>-reptext = '수정'.
        <fs_fcat>-checkbox = 'X'.
      WHEN 'REVIEW'.
        <fs_fcat>-reptext = '변경'.
        <fs_fcat>-checkbox = 'X'.
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
  go_grid->layout->set_stylefname( 'STYLE' ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_sort
*&---------------------------------------------------------------------*
FORM grid_sort .
  go_grid->sort = VALUE #(
                            ( fieldname = 'CFLAG'   down = 'X' ) "수정
                            ( fieldname = 'REVIEW'  down = 'X' ) "변경
*                           ( fieldname = 'O_STEXT' up   = 'X' )
                            ( fieldname = 'SHORT'   up   = 'X' ) "분반코드
*                           ( fieldname = 'STEXT'   up   = 'X' )
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

* 학부전용 execution button
  CHECK gv_undergrad = abap_true. "학부
  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_03
    iv_text   = '쿼터풀기'
    iv_icon   = icon_unlocked ).

  CASE p_perid.
    WHEN '011' OR '021'.
      go_grid->gui_status->add_button(
        iv_button = zcl_falv_dynamic_status=>b_06
        iv_text   = '계절학기 자동 셋팅'
        iv_icon   = icon_complete ).
    WHEN OTHERS.
      go_grid->gui_status->add_button(
        iv_button = zcl_falv_dynamic_status=>b_02
        iv_text   = '학년별 수강인원 자동 셋팅'
        iv_icon   = icon_settings ).
  ENDCASE.
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

    WHEN zcl_falv_dynamic_status=>b_02. "인원 셋팅

      go_grid->get_selected_rows( IMPORTING et_index_rows = gt_rows ).
      IF lines( gt_rows ) IS INITIAL.
        MESSAGE s003 DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.
      CALL SCREEN 200 STARTING AT 5 10.

    WHEN zcl_falv_dynamic_status=>b_03. "쿼터

      go_grid->get_selected_rows( IMPORTING et_index_rows = gt_rows ).
      IF lines( gt_rows ) IS INITIAL.
        MESSAGE s003 DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.
      CALL SCREEN 300 STARTING AT 5 10.


    WHEN zcl_falv_dynamic_status=>b_05. "검토완료
      PERFORM comp_review.

    WHEN zcl_falv_dynamic_status=>b_06. "계절학기
      PERFORM setting_1121.
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
FORM set_ddlb.

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

  DATA lt_vrm  TYPE vrm_values WITH HEADER LINE.
*  SELECT map_cd2, com_nm
*    FROM zcmt0101
*   WHERE grp_cd IN ('100','109')
*    AND map_cd2 IN @lr_org
*    INTO TABLE @lt_vrm.
*  DATA lt_0101 TYPE TABLE OF vrm_value WITH HEADER LINE.
  DATA: BEGIN OF lt_0101 OCCURS 0,
          grp_cd TYPE zcmt0101-grp_cd,
          key    TYPE vrm_value-key,
          text   TYPE vrm_value-text,
        END OF lt_0101.
  CLEAR: lt_0101[], lt_0101.

  " Select and avoid duplicates directly using SELECT DISTINCT
  SELECT DISTINCT grp_cd,
                  map_cd2 AS key,
                  com_nm  AS text
    FROM zcmt0101
   WHERE grp_cd IN ('100', '109')
     AND com_cd <> '0000'
    INTO TABLE @lt_0101.

  LOOP AT lt_0101 INTO DATA(ls_0101) WHERE grp_cd = '109'.
    ls_0101-text = |· { ls_0101-text }|. " String templates for text concatenation
    MODIFY lt_0101 FROM ls_0101 TRANSPORTING text.
  ENDLOOP.
  lt_vrm[] = CORRESPONDING #( lt_0101[] ).

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

  CLEAR lt_vrm[].
  lt_vrm[] = VALUE #( ( text = 1 key = 1  ) ( text = 2 key = 2  ) ( text = 3 key = 3  ) ( text = 4 key = 4  ) ).

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'P_K1'
      values          = lt_vrm[]
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'P_K2'
      values          = lt_vrm[]
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'P_K3'
      values          = lt_vrm[]
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'P_K4'
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
FORM get_datum.

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
  gv_keydt = ls_tili-ca_lbegda.
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
*& Form check_orgcd
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_orgcd.

  CLEAR: gv_undergrad, gv_grad.

  SELECT COUNT(*)
    FROM zcmt0101
   WHERE grp_cd = '109'
     AND map_cd2 = p_orgcd.
  IF sy-subrc = 0 OR p_orgcd = '30000002'.  "학부
    gv_undergrad = abap_true. "학부

  ELSE.
    gv_grad = abap_true. "대학원

  ENDIF.

* AI·소프트웨어 대학원 - 학부처럼 동작
  IF p_orgcd = '30000305'.
    CLEAR gv_undergrad.
    gv_undergrad = abap_true. "학부
    gv_30000305 = abap_true. "AI·SW대학원

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form grade_seqno
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM grade_seqno .

  DATA(lt_seq) = VALUE ty_namevalueasstring( ( name = '1' value = p_k1 )
                                             ( name = '2' value = p_k2 )
                                             ( name = '3' value = p_k3 )
                                             ( name = '4' value = p_k4 ) ).
  SORT lt_seq BY value name.
  DATA(lt_tmp) = lt_seq[].
  DELETE ADJACENT DUPLICATES FROM lt_tmp COMPARING value.

  LOOP AT lt_tmp INTO DATA(ls_tmp).
    IF sy-tabix <> ls_tmp-value.
      MESSAGE s005 DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
  ENDLOOP.

  DATA lv_cnt TYPE hrp9551-book_kapz.
  FIELD-SYMBOLS <kapz_r> TYPE hrp9551-book_kapz.
  FIELD-SYMBOLS <kapz> TYPE hrp9551-book_kapz.
  DATA lt_txt TYPE TABLE OF stext.
  DATA lv_gt TYPE string.

  LOOP AT gt_rows INTO DATA(ls_row).
    READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<fs>) INDEX ls_row-index.
    CHECK sy-subrc = 0 AND <fs>-set_no = ''.
    <fs>-cflag = 'X'.

    CLEAR lv_cnt.
    DO 4 TIMES.
      LOOP AT lt_seq INTO DATA(ls_seq) WHERE value = sy-index.
        DATA(lv_fld1) = 'BOOK_KAPZ' && ls_seq-name.
        ASSIGN COMPONENT lv_fld1 OF STRUCTURE <fs> TO <kapz_r>.
        CHECK <kapz_r> IS ASSIGNED.
        lv_cnt = lv_cnt + <kapz_r>.
      ENDLOOP.
      LOOP AT lt_seq INTO ls_seq WHERE value = sy-index.
        DATA(lv_fld2) = 'BOOK_KAPZ' && ls_seq-name && `_R`.
        ASSIGN COMPONENT lv_fld2 OF STRUCTURE <fs> TO <kapz>.
        CHECK <kapz> IS ASSIGNED.

        lv_fld1 = 'BOOK_KAPZ' && ls_seq-name.
        ASSIGN COMPONENT lv_fld1 OF STRUCTURE <fs> TO <kapz_r>.
        CHECK <kapz_r> IS ASSIGNED.
        CHECK <kapz_r> IS NOT INITIAL.

        <kapz> = lv_cnt.
      ENDLOOP.
    ENDDO.

*수강순서 텍스트
    CLEAR lt_txt[].
    LOOP AT lt_tmp INTO ls_tmp.
      LOOP AT lt_seq INTO ls_seq WHERE value = ls_tmp-value.
        IF lv_gt IS INITIAL.
          lv_gt = ls_seq-name && `학년`.
        ELSE.
          lv_gt = |{ lv_gt },{ ls_seq-name }학년|.
        ENDIF.
      ENDLOOP.
      APPEND lv_gt TO lt_txt.
      CLEAR lv_gt.
    ENDLOOP.
    CONCATENATE LINES OF lt_txt INTO <fs>-ug_book_seq_txt SEPARATED BY '->'.
  ENDLOOP.

  go_grid->set_frontend_layout( go_grid->lvc_layout ).
  go_grid->soft_refresh( ).

  MESSAGE s006.
  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_QT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM free_qt .


  LOOP AT gt_rows INTO DATA(ls_row).
    READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<fs>) INDEX ls_row-index.
    CHECK sy-subrc = 0 AND <fs>-set_no = ''.

*전체 학년
    <fs>-qt_tp = '10'.
    <fs>-book_kapz1_r = <fs>-book_kapz2_r = <fs>-book_kapz3_r = <fs>-book_kapz4_r =
    ( <fs>-book_kapz1 + <fs>-book_kapz2 + <fs>-book_kapz3 + <fs>-book_kapz4 ).

*신청한 학년
    IF p_r2 IS NOT INITIAL.
      IF <fs>-book_kapz1 IS INITIAL.
        CLEAR <fs>-book_kapz1_r.
      ENDIF.
      IF <fs>-book_kapz2 IS INITIAL.
        CLEAR <fs>-book_kapz2_r.
      ENDIF.
      IF <fs>-book_kapz3 IS INITIAL.
        CLEAR <fs>-book_kapz3_r.
      ENDIF.
      IF <fs>-book_kapz4 IS INITIAL.
        CLEAR <fs>-book_kapz4_r.
      ENDIF.
      <fs>-qt_tp = '20'.
    ENDIF.

    SELECT SINGLE ddtext FROM dd07t
      INTO <fs>-qt_tpt
      WHERE domname = 'ZCMK_QT_TP'
        AND ddlanguage = sy-langu
        AND domvalue_l = <fs>-qt_tp.

    <fs>-cflag = 'X'.
  ENDLOOP.

  go_grid->set_frontend_layout( go_grid->lvc_layout ).
  go_grid->soft_refresh( ).

  MESSAGE s006.
  LEAVE TO SCREEN 0.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_data .

  go_grid->check_changed_data( ).

  READ TABLE gt_data WITH KEY cflag = 'X' TRANSPORTING NO FIELDS.
  IF sy-subrc <> 0.
    MESSAGE s004 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  CHECK zcmcl000=>popup_to_confirm( '저장하시겠습니까?' ) IS NOT INITIAL.

  LOOP AT gt_data INTO DATA(ls_data) WHERE cflag = 'X'.
    CHECK ls_data-set_no = ''.

    IF gv_30000305 = abap_true. "정보통신대학원
      UPDATE hrp9551
         SET aedtm = sy-datum
             uname = sy-uname
             book_kapz4 = ls_data-book_kapz4
             book_kapz3 = ls_data-book_kapz3
             book_kapz2 = ls_data-book_kapz2
             book_kapz1 = ls_data-book_kapz1
             book_kapz4_r = ls_data-book_kapz4_r
             book_kapz3_r = ls_data-book_kapz3_r
             book_kapz2_r = ls_data-book_kapz2_r
             book_kapz1_r = ls_data-book_kapz1_r
             remark = ls_data-remark
             review = ''
       WHERE plvar = '01'
         AND otype = 'SE'
         AND objid = ls_data-objid
         AND begda = ls_data-begda
         AND endda = ls_data-endda
         AND istat = '1'.

    ELSEIF gv_grad = abap_true. "대학원
      UPDATE hrp9551
         SET aedtm = sy-datum
             uname = sy-uname
             book_kapz    = ls_data-book_kapz
             remark = ls_data-remark
             review = ''
       WHERE plvar = '01'
         AND otype = 'SE'
         AND objid = ls_data-objid
         AND begda = ls_data-begda
         AND endda = ls_data-endda
         AND istat = '1'.

    ELSEIF gv_undergrad = abap_true. "학부
      UPDATE hrp9551
         SET aedtm = sy-datum
             uname = sy-uname
             book_kapzg   = ls_data-book_kapzg
             book_kapz4_r = ls_data-book_kapz4_r
             book_kapz3_r = ls_data-book_kapz3_r
             book_kapz2_r = ls_data-book_kapz2_r
             book_kapz1_r = ls_data-book_kapz1_r
             ug_book_seq_txt = ls_data-ug_book_seq_txt
             qt_tp  = ls_data-qt_tp
             remark = ls_data-remark
             review = ''
       WHERE plvar = '01'
         AND otype = 'SE'
         AND objid = ls_data-objid
         AND begda = ls_data-begda
         AND endda = ls_data-endda
         AND istat = '1'.

    ENDIF.

  ENDLOOP.

  MESSAGE s011.
  COMMIT WORK.

  PERFORM get_data_select.

  go_grid->set_frontend_layout( go_grid->lvc_layout ).
  go_grid->soft_refresh( ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form comp_review
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM comp_review .

  DATA ls_p9551 TYPE p9551.

  go_grid->get_selected_rows( IMPORTING et_index_rows = gt_rows ).
  IF lines( gt_rows ) IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  CHECK zcmcl000=>popup_to_confirm( '검토 완료하시겠습니까?' ) IS NOT INITIAL.

  LOOP AT gt_rows INTO DATA(ls_row).
    READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<fs>) INDEX ls_row-index.
    CHECK sy-subrc = 0.

    CLEAR: ls_p9551.
    SELECT SINGLE * FROM hrp9551
      INTO CORRESPONDING FIELDS OF ls_p9551
      WHERE plvar = '01'
        AND otype = 'SE'
        AND objid = <fs>-objid
        AND istat = '1'
        AND begda <= gv_keydt
        AND endda >= gv_keydt
        AND review = 'X'.
    IF sy-subrc = 0.
      UPDATE hrp9551 SET review = ''
                   WHERE plvar = ls_p9551-plvar
                     AND otype = ls_p9551-otype
                     AND objid = ls_p9551-objid
                     AND istat = ls_p9551-istat
                     AND begda = ls_p9551-begda
                     AND endda = ls_p9551-endda.
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
*&---------------------------------------------------------------------*
*& Form setting_1121
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM setting_1121 .

  go_grid->get_selected_rows( IMPORTING et_index_rows = gt_rows ).
  IF lines( gt_rows ) IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  CHECK zcmcl000=>popup_to_confirm( '셋팅하시겠습니까?' ) IS NOT INITIAL.

  LOOP AT gt_rows INTO DATA(ls_row).
    READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<fs>) INDEX ls_row-index.
    CHECK sy-subrc = 0 AND <fs>-set_no = ''.

    <fs>-book_kapz1_r = <fs>-book_kapz1.
    <fs>-book_kapz2_r = <fs>-book_kapz2.
    <fs>-book_kapz3_r = <fs>-book_kapz3.
    <fs>-book_kapz4_r = <fs>-book_kapz4.

    <fs>-cflag = 'X'.
  ENDLOOP.

  go_grid->set_frontend_layout( go_grid->lvc_layout ).
  go_grid->soft_refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_9551
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_9551 CHANGING pv_count.

  TRY.
      DATA(lr_log) = NEW cl_bal_logobj( i_max_msg_memory = 99999 ).
    CATCH cx_bal_exception INTO DATA(lx_bal).
      " Handle the exception (logging, raising, or displaying a message)
      MESSAGE lx_bal->get_text( ) TYPE 'E'.
  ENDTRY.

  CLEAR pv_count.
  LOOP AT gt_data INTO DATA(ls_data) WHERE set_no = 'X'.

    ADD 1 TO pv_count.
    CLEAR gv_err.
    PERFORM create_infty_9551 USING ls_data CHANGING lr_log.

    CHECK gv_err IS INITIAL.
    CLEAR gt_data-set_no.
    MODIFY gt_data.

  ENDLOOP.

  CHECK pv_count > 0.
  lr_log->display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_infty_9551
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_DATA
*&      <-- LR_LOG
*&---------------------------------------------------------------------*
FORM create_infty_9551 USING    ps_data LIKE gt_data
                       CHANGING po_log TYPE REF TO cl_bal_logobj.

  DATA ls_p9551 TYPE p9551.
  CLEAR ls_p9551.

  SELECT SINGLE *
    FROM hrp9550
   WHERE plvar = '01'
     AND otype = 'SE'
     AND objid = @ps_data-objid
     AND istat = '1'
     AND begda <= @gv_endda
     AND endda >= @gv_begda
    INTO @DATA(ls_9550).
  IF ls_9550 IS NOT INITIAL AND
     ls_9550-book_kapz IS NOT INITIAL.

    ls_p9551-book_kapz = ls_9550-book_kapz.

  ENDIF.

  ls_p9551-plvar = '01'.
  ls_p9551-otype = 'SE'.
  ls_p9551-objid = ps_data-objid.
  ls_p9551-istat = '1'.
  ls_p9551-begda = gv_begda.
  ls_p9551-endda = gv_endda.
  ls_p9551-infty = '9551'.
  ls_p9551-aedtm = sy-datum.
  ls_p9551-uname = sy-uname.

  " 시간제약 1번일 경우 자동으로 생성하거나 기간을 짜름...
  zcmcl000=>hriq_modify_infty(
    EXPORTING
      iv_mode  = 'I'
      is_pnnnn = ls_p9551
    IMPORTING
      ev_error = gv_err
      ev_msg   = DATA(lv_msg)
  ).

  TRY.
      IF gv_err IS INITIAL.
        po_log->add_statustext( |{ ps_data-stext }[{ ps_data-short }] - { lv_msg } | ).
      ELSE.
        po_log->add_errortext( |{ ps_data-stext }[{ ps_data-short }] - { lv_msg }| ).
      ENDIF.
    CATCH cx_bal_exception INTO DATA(lx_bal).
      " Handle the exception (log it, display a message, etc.)
      MESSAGE lx_bal->get_text( ) TYPE 'E'.
  ENDTRY.

ENDFORM.
