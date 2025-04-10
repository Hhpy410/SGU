*&---------------------------------------------------------------------*
*& Include          MZCMRK_DEMO1_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form EV_user_command
*&---------------------------------------------------------------------*
FORM ev_user_command  USING p_ucomm   po_me TYPE REF TO lcl_alv_grid.

  CASE p_ucomm.
    WHEN zcl_falv_dynamic_status=>b_01. "새로고침
      PERFORM get_data_select.
      PERFORM refresh_alv.

    WHEN zcl_falv_dynamic_status=>b_02. "추가
      PERFORM excute_button_insert.
      PERFORM get_data_select.
      PERFORM refresh_alv.

    WHEN zcl_falv_dynamic_status=>b_03. "변경
      PERFORM excute_button_edit.
      PERFORM get_data_select.
      PERFORM refresh_alv.

    WHEN zcl_falv_dynamic_status=>b_04. "삭제
      PERFORM excute_button_delete.
      PERFORM get_data_select.
      PERFORM refresh_alv.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv_data
*&---------------------------------------------------------------------*
FORM grid_display_alv.

  go_grid ?= lcl_alv_grid=>create( CHANGING ct_table = gt_data[] ).
  go_grid->title_v1 = |{ sy-title } - { lines( gt_data ) } 건|.

  PERFORM grid_field_catalog.
  PERFORM grid_layout.
  PERFORM grid_sort.
  PERFORM grid_gui_status.
  PERFORM grid_toolbar_button.
  PERFORM grid_f4_field.
  PERFORM grid_ddlb.
*  PERFORM grid_top_of_page.

  go_grid->display( ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_init
*&---------------------------------------------------------------------*
FORM set_init .

  DATA: ls_obj TYPE hrobject.

  CLEAR: ls_obj.
  ls_obj-plvar = '01'.
  ls_obj-otype = 'O'.
  ls_obj-objid = p_torg.

  "학년도 학기 시작일 종료일
  CALL FUNCTION 'ZCM_GET_CA_YEARSESSION'
    EXPORTING
      is_object                = ls_obj
      iv_keydate               = sy-datum
      iv_filter_date           = sy-datum
      iv_regsession            = 'X'
      iv_timelimit             = '0100'
    IMPORTING
      ev_peryr                 = p_peryr
      ev_perid                 = p_perid
      ev_begda                 = gv_begda
      ev_endda                 = gv_endda
    EXCEPTIONS
      no_start_object_imported = 1
      customizing_incomplete   = 2
      invalid_ca_object        = 3
      no_eval_path             = 4
      relative_timelimit_error = 5
      more_than_one_record     = 6
      no_data_found            = 7
      internal_error           = 8
      OTHERS                   = 9.

  CLEAR: gt_orgs[], gt_orgs.
  CALL FUNCTION 'HRIQ_STRUC_GET'
    EXPORTING
      act_otype      = 'O'
      act_objid      = p_torg
      act_wegid      = 'ORGEH'
      act_plvar      = '01'
      act_begda      = gv_begda
      act_endda      = gv_endda
    TABLES
      result_objec   = gt_orgs[]
    EXCEPTIONS
      no_plvar_found = 1
      no_entry_found = 2
      internal_error = 3
      OTHERS         = 4.

  p_1oobj = p_torg.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_select
*&---------------------------------------------------------------------*
FORM get_data_select .

  CLEAR gt_data[].

  PERFORM get_selist TABLES gt_selist_temp.

  "- ZCMTK210에 존재하는 분반만 조회
  IF gt_selist_temp[] IS NOT INITIAL.
    SELECT se_id AS objid
      FROM zcmtk210 INTO CORRESPONDING FIELDS OF TABLE gt_selist
      FOR ALL ENTRIES IN gt_selist_temp
      WHERE peryr = p_peryr
        AND perid = p_perid
        AND se_id = gt_selist_temp-objid
        AND delay_begda IN s_dat.
    gs_selist-plvar = '01'.
    gs_selist-otype = 'SE'.
    MODIFY gt_selist FROM gs_selist TRANSPORTING plvar otype WHERE plvar = ''.
  ENDIF.

  PERFORM get_courseinfo.

  CHECK gt_course[] IS NOT INITIAL.

  DATA: lv_fstxt(20).
  DATA: lv_seq(2).
  DATA: lv_pernr(20).
  FIELD-SYMBOLS <pernr> TYPE any.
  FIELD-SYMBOLS <sname> TYPE any.

  SELECT * FROM zcmtk210 INTO TABLE @DATA(lt_210)
    WHERE peryr = @p_peryr
      AND perid = @p_perid.
  SORT lt_210 BY se_id.

  LOOP AT lt_210 INTO DATA(ls_210).
    CLEAR gt_data.

    READ TABLE gt_course INTO DATA(ls_course) WITH KEY seobjid = ls_210-se_id.

    CHECK sy-subrc EQ 0.

    gt_data = CORRESPONDING #( ls_course ).
    MOVE-CORRESPONDING ls_210 TO gt_data.
    gt_data-stobjid      = ls_210-st_id.
    gt_data-seats_remain = ls_course-kapz1 - ls_course-bookcnt.
    gt_data-delay_begda = ls_210-delay_begda.
    gt_data-delay_begtm = ls_210-delay_begtm.

    "교수 조합
    CLEAR lv_seq.
    DO 10 TIMES.
      ADD 1 TO lv_seq.

      lv_fstxt = 'PERNR' && lv_seq.
      ASSIGN COMPONENT lv_fstxt OF STRUCTURE ls_course TO <pernr>.
      IF sy-subrc EQ 0 AND <pernr> IS NOT INITIAL.
        WRITE <pernr> TO lv_pernr NO-ZERO.
        CONDENSE lv_pernr.
        IF gt_data-lec_pernr IS INITIAL.
          gt_data-lec_pernr = lv_pernr.
        ELSE.
          CONCATENATE gt_data-lec_pernr lv_pernr INTO gt_data-lec_pernr SEPARATED BY ','.
        ENDIF.
      ENDIF.

      lv_fstxt = 'SNAME' && lv_seq.
      ASSIGN COMPONENT lv_fstxt OF STRUCTURE ls_course TO <sname>.
      IF sy-subrc EQ 0 AND <sname> IS NOT INITIAL.
        IF gt_data-lec_name IS INITIAL.
          gt_data-lec_name = <sname>.
        ELSE.
          CONCATENATE gt_data-lec_name <sname> INTO gt_data-lec_name SEPARATED BY ','.
        ENDIF.
      ENDIF.
    ENDDO.

    APPEND gt_data.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_field_catalog
*&---------------------------------------------------------------------*
FORM grid_field_catalog .

  LOOP AT go_grid->fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).

    CASE <fs_fcat>-fieldname.
      WHEN 'PERYR'.
        <fs_fcat>-reptext = '학년도'.
      WHEN 'PERID'.
        <fs_fcat>-reptext = '학기' .
        <fs_fcat>-convexit = 'PERI2'.
*      WHEN 'O_ID'.
*        <fs_fcat>-reptext = '단과대학' .
*      WHEN 'O_STEXT'.
*        <fs_fcat>-reptext = '단과대학명' .
      WHEN 'OOBJID'.
        <fs_fcat>-reptext = '주관학과' .
      WHEN 'OSTEXT'.
        <fs_fcat>-reptext = '주관학과명' .
      WHEN 'SESTEXT'.
        <fs_fcat>-reptext = '분반' .
      WHEN 'SMOBJID'.
        <fs_fcat>-reptext = '과목' .
      WHEN 'SEOBJID'.
        <fs_fcat>-reptext = 'seobjid' .
      WHEN 'SMSTEXT'.
        <fs_fcat>-reptext = '과목명(국문)' .
      WHEN 'LEC_PERNR'.
        <fs_fcat>-reptext = '교수사번' .
      WHEN 'LEC_NAME'.
        <fs_fcat>-reptext = '교수명' .
      WHEN 'BOOKCNT'.
        <fs_fcat>-reptext = '수강인원' .
      WHEN 'SEATS_REMAIN'.
        <fs_fcat>-reptext = '여석' .
      WHEN 'DELAY_BEGDA'.
        <fs_fcat>-reptext = '잠금해제일자' .
        <fs_fcat>-emphasize = 'C300' .
      WHEN 'DELAY_BEGTM'.
        <fs_fcat>-reptext = '잠금해제시간' .
        <fs_fcat>-emphasize = 'C300' .
      WHEN 'ERNAM'.
        <fs_fcat>-reptext = '생성자' .
      WHEN 'ERDAT'.
        <fs_fcat>-reptext = '생성일'.
      WHEN 'ERTIM'.
        <fs_fcat>-reptext = '생성시간'.
      WHEN 'AENAM'.
        <fs_fcat>-reptext = '변경자'.
      WHEN 'AEDAT'.
        <fs_fcat>-reptext = '변경일자'.
      WHEN 'AETIM'.
        <fs_fcat>-reptext = '변경시간'.
    ENDCASE.

    <fs_fcat>-scrtext_l = <fs_fcat>-scrtext_m =
                                <fs_fcat>-scrtext_s = <fs_fcat>-reptext.
  ENDLOOP.

  go_grid->set_frontend_fieldcatalog( go_grid->fcat ).
  go_grid->set_editable( abap_true ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_layout
*&---------------------------------------------------------------------*
FORM grid_layout .

  go_grid->layout->set_cwidth_opt( 'A' ).
  go_grid->layout->set_zebra( abap_true ).
  go_grid->layout->set_sel_mode( 'D' ).
  go_grid->layout->set_no_toolbar( abap_false ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_sort
*&---------------------------------------------------------------------*
FORM grid_sort .
*  go_grid->sort = VALUE #(
*                   ( fieldname = 'CARRID' up = abap_true subtot = abap_true )
*                   ( fieldname = 'CONNID' up = abap_true subtot = abap_true ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_gui_status
*&---------------------------------------------------------------------*
FORM grid_gui_status .

  go_grid->gui_status->fully_dynamic = abap_true.
  go_grid->exclude_functions = go_grid->gui_status->edit_buttons( ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_01
    iv_text   = '새로고침'
    iv_icon   = icon_refresh ).

*  go_grid->gui_status->add_button(
*    iv_button = zcl_falv_dynamic_status=>b_02
*    iv_text   = '추가'
*    iv_icon   = icon_insert_row ).
*
*  go_grid->gui_status->add_button(
*    iv_button = zcl_falv_dynamic_status=>b_03
*    iv_text   = '지연시간 변경'
*    iv_icon   = icon_change ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_04
    iv_text   = '잠금해제'
    iv_icon   = icon_cancel ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form grid_toolbar_button
*&---------------------------------------------------------------------*
FORM grid_toolbar_button .
*  go_grid->add_button(
*    iv_function = zcl_falv_dynamic_status=>b_02
*    iv_icon     = icon_activate
*    iv_text     = 'TEST' ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_DETAIL
*&---------------------------------------------------------------------*
FORM call_detail .

*  SELECT * FROM sflight
*    INTO CORRESPONDING FIELDS OF TABLE gt_data2
*    WHERE currency = 'USD'.
*
*  DATA(lo_grid2) = lcl_alv_grid=>create(
*    EXPORTING
*      i_popup  = abap_true
*    CHANGING
*      ct_table = gt_data2[]
*  ).
*
*  lo_grid2->display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_f4_field
*&---------------------------------------------------------------------*
FORM grid_f4_field .

  go_grid->register_f4_for_fields( VALUE #(
          ( fieldname = 'CONNID' register = 'X' getbefore = 'X' )
  ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_ddlb
*&---------------------------------------------------------------------*
FORM grid_ddlb .
  DATA: lt_listbox TYPE lvc_t_dral.

  SELECT 1 AS handle, planetype AS int_value, planetype AS value FROM saplane
    INTO TABLE @lt_listbox
    WHERE producer = 'BOE'.

  CALL METHOD go_grid->set_drop_down_table
    EXPORTING
      it_drop_down_alias = lt_listbox.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EV_data_changed
*&---------------------------------------------------------------------*
FORM ev_data_changed  USING po_data_changed TYPE REF TO cl_alv_changed_data_protocol.

*  LOOP AT po_data_changed->mt_mod_cells INTO DATA(ls_mod).
*    CASE ls_mod-fieldname.
*      WHEN 'CARRID'.
*        READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<fs>) INDEX ls_mod-row_id.
*        CHECK sy-subrc = 0.
*        <fs>-carrid = ls_mod-value.
*        CLEAR <fs>-carrname.
*        SELECT SINGLE carrname FROM scarr
*          INTO <fs>-carrname
*          WHERE carrid = <fs>-carrid.
*      WHEN 'CONNID'.
*      WHEN OTHERS.
*    ENDCASE.
*  ENDLOOP.

  PERFORM refresh_alv.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ev_hotspot_click
*&---------------------------------------------------------------------*
FORM ev_hotspot_click  USING p_row p_fieldname.

  MESSAGE p_fieldname TYPE 'S'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ev_top_of_page
*&---------------------------------------------------------------------*
FORM ev_top_of_page  USING  po_dyndoc_id   TYPE REF TO cl_dd_document.
  DATA: lv_text TYPE sdydo_text_element.

  CALL METHOD po_dyndoc_id->initialize_document.

  SELECT SINGLE stext FROM hrp1000 INTO lv_text
    WHERE otype = 'O'
      AND objid = p_torg
      AND begda <= p_datum
      AND endda >= p_datum.
  lv_text = |▶대학구분: { lv_text }|.
  PERFORM add_header_text(zcms11) USING po_dyndoc_id lv_text ''.
  CALL METHOD po_dyndoc_id->new_line( ).

  SELECT SINGLE perit FROM t7piqperiodt INTO lv_text
    WHERE spras = sy-langu
      AND perid = p_perid.
  lv_text = |▶학년도학기: { p_peryr }-{ lv_text }|.
  PERFORM add_header_text(zcms11) USING po_dyndoc_id lv_text ''.
  CALL METHOD po_dyndoc_id->new_line( ).

  lv_text = |▶기준일자: { p_datum DATE = USER }|.
  PERFORM add_header_text(zcms11) USING po_dyndoc_id lv_text ''.
  CALL METHOD po_dyndoc_id->new_line( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EV_ON_F4
*&---------------------------------------------------------------------*
FORM ev_on_f4  USING    p_fieldname  p_fieldvalue  p_row.

  DATA lt_return TYPE TABLE OF ddshretval.

  CASE p_fieldname.
    WHEN 'CONNID'.
*      SELECT carrid, connid, cityfrom, cityto FROM spfli
*        INTO TABLE @DATA(lt_spfli).
*
*      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*        EXPORTING
*          retfield        = 'CONNID'
*          dynpprog        = sy-cprog
*          dynpnr          = sy-dynnr
*          value_org       = 'S'
*        TABLES
*          value_tab       = lt_spfli
*          return_tab      = lt_return
*        EXCEPTIONS
*          parameter_error = 1
*          no_values_found = 2
*          OTHERS          = 3.
*      CHECK lt_return IS NOT INITIAL.
*      READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<fs>) INDEX p_row.
*      CHECK sy-subrc = 0.
*      <fs>-connid = lt_return[ 1 ]-fieldval.

    WHEN OTHERS.
  ENDCASE.

  go_grid->soft_refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_top_of_page
*&---------------------------------------------------------------------*
FORM grid_top_of_page .

  go_grid->top_of_page_height = 100.
  go_grid->show_top_of_page( ).

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
  DATA: ls_obj TYPE hrobject.

  CLEAR: ls_obj.
  ls_obj-plvar = '01'.
  ls_obj-otype = 'O'.
  ls_obj-objid = p_torg.

  "기본 학사력
  CALL FUNCTION 'ZCM_GET_CA_TIMELIMIT'
    EXPORTING
      is_object                = ls_obj
      iv_filter_peryr          = p_peryr
      iv_filter_perid          = p_perid
      iv_timelimit             = '0100'
    IMPORTING
      ev_begda                 = gv_begda
      ev_endda                 = gv_endda
    EXCEPTIONS
      no_start_object_imported = 1
      customizing_incomplete   = 2
      invalid_ca_object        = 3
      no_eval_path             = 4
      relative_timelimit_error = 5
      no_data_found            = 6
      internal_error           = 7
      OTHERS                   = 8.

  IF gv_begda =< sy-datum AND gv_endda >= sy-datum.
    p_datum = sy-datum.
  ELSEIF gv_endda < sy-datum.
    p_datum = gv_endda.
  ELSEIF gv_begda > sy-datum.
    p_datum = gv_begda.
  ENDIF.

  IF p_peryr IS NOT INITIAL AND p_perid IS NOT INITIAL.
    p_datum = gv_begda.
  ELSE.
    p_datum = sy-datum.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_modify_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_modify_screen .

  LOOP AT SCREEN.
    CASE screen-name.
      WHEN  'P_1TXT' OR 'P_DATUM'.
        screen-input = 0.

      WHEN OTHERS.

    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_value_request_sm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM get_value_request_sm USING    p_reffd.
  DATA: ls_sel    LIKE objec.
  CLEAR : ls_sel.

  CALL FUNCTION 'HRIQ_OBJID_REQUEST'
    EXPORTING
      plvar           = '01'
      otype           = 'SM'     "'O'
      seark_begda     = p_datum
      seark_endda     = p_datum
      win_title       = '교과목조회'
    IMPORTING
      sel_object      = ls_sel
    EXCEPTIONS
      cancelled       = 1
      wrong_condition = 2
      nothing_found   = 3
      illegal_mode    = 4
      internal_error  = 5
      OTHERS          = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF p_reffd = 'ID'.
      s_smsht-low = ls_sel-short.
    ELSEIF p_reffd = 'TX'.
      p_smtx = ls_sel-stext.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  F4_PERYR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_peryr INPUT.
  PERFORM get_request_for_f4_peryr(zcms11) USING  gs_s100-peryr
                                                  p_torg.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'S100'.
  SET TITLEBAR 'TITLE' WITH TEXT-t10.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_PERID  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_perid INPUT.
  PERFORM get_request_for_f4_perid(zcms11) USING  gs_s100-perid
                                                  '1'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_100 INPUT.

  CASE ok_code.
    WHEN 'SAVE'.
      CLEAR ok_code.
      PERFORM run_data_save.

    WHEN 'CANCEL'.
      CLEAR: ok_code, gs_s100.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
      CLEAR ok_code.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_SE_SHORT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_se_short INPUT.

  PERFORM get_value_request_se(zcms11) USING gs_s100-seshort p_datum.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form run_data_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM run_data_save .

  IF gs_s100-peryr IS INITIAL.
    MESSAGE i010 WITH '학년도'.  EXIT.
  ELSEIF gs_s100-perid IS INITIAL.
    MESSAGE i010 WITH '학기'.    EXIT.
  ELSEIF gs_s100-seshort IS INITIAL.
    MESSAGE i010 WITH '분반'.    EXIT.
  ELSEIF gs_s100-delay_begda IS INITIAL.
    MESSAGE i010 WITH '잠금해제일자'. EXIT.
  ELSEIF gs_s100-delay_begtm IS INITIAL.
    MESSAGE i010 WITH '잠금해제시간'. EXIT.
  ELSEIF gs_s100-delay_begda < sy-datum.
    MESSAGE '과거시간을 잠금해제시간으로 설정할 수 없습니다.' TYPE 'I'. EXIT.
  ELSEIF gs_s100-delay_begda = sy-datum AND gs_s100-delay_begtm <= sy-uzeit.
    MESSAGE '과거시간을 잠금해제시간으로 설정할 수 없습니다.' TYPE 'I'. EXIT.
  ENDIF.

  DATA ls_zcmtk210 TYPE zcmtk210.

  SELECT SINGLE objid FROM hrp1000 INTO ls_zcmtk210-se_id
    WHERE plvar = '01'
      AND otype = 'SE'
      AND istat = '1'
      AND begda <= gv_endda
      AND endda >= gv_begda
      AND short = gs_s100-seshort.

  IF sy-subrc NE 0.
    MESSAGE '정확한 분반번호가 아닙니다.' TYPE 'I'. EXIT.
  ELSE.
    PERFORM get_smid_from_seid(zcms11) USING ls_zcmtk210-se_id gv_begda
                                    CHANGING ls_zcmtk210-sm_id.
  ENDIF.

  ls_zcmtk210-peryr    = gs_s100-peryr.
  ls_zcmtk210-perid    = gs_s100-perid.
  ls_zcmtk210-delay_begda = gs_s100-delay_begda.
  ls_zcmtk210-delay_begtm = gs_s100-delay_begtm.
  ls_zcmtk210-ernam    = sy-uname.
  ls_zcmtk210-erdat    = sy-datum.
  ls_zcmtk210-ertim    = sy-uzeit.
  ls_zcmtk210-aenam    = sy-uname.
  ls_zcmtk210-aedat    = sy-datum.
  ls_zcmtk210-aetim    = sy-uzeit.

  MODIFY zcmtk210 FROM ls_zcmtk210 .
  IF sy-subrc EQ 0.
    COMMIT WORK.

    CALL FUNCTION 'ZCM_BACKUP_ZCMTK210'
      EXPORTING
        is_data  = ls_zcmtk210
        iv_keydt = gv_begda
        iv_mode  = 'I'.

    MESSAGE i011.

    PERFORM get_data_select.
    LEAVE TO SCREEN 0.

  ELSE.
    ROLLBACK WORK.
    MESSAGE i012.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_selist
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SELIST_TEMP
*&---------------------------------------------------------------------*
FORM get_selist TABLES pt_selist STRUCTURE hrobject.

  DATA: lt_result TYPE objec   OCCURS 0 WITH HEADER LINE.
  DATA: lt_1000   TYPE hrp1000 OCCURS 0 WITH HEADER LINE.
  DATA: lv_smtext TYPE char40.
  DATA: r_smid    TYPE RANGE OF sobid   WITH HEADER LINE.
  DATA: lt_smlist TYPE hrobject_t,
        ls_smlist TYPE hrobject.

  DATA lt_selist TYPE hrobject_t.

  CLEAR pt_selist[].

*-학과
  CLEAR: lt_result[], lt_result.
  CALL FUNCTION 'HRIQ_STRUC_GET'
    EXPORTING
      act_otype      = 'O'
      act_objid      = p_1oobj
      act_wegid      = 'ORGEH'
      act_plvar      = '01'
      act_begda      = gv_begda
      act_endda      = gv_endda
    TABLES
      result_objec   = lt_result[]
    EXCEPTIONS
      no_plvar_found = 1
      no_entry_found = 2
      internal_error = 3
      OTHERS         = 4.

  CHECK lt_result[] IS NOT INITIAL.

*- 교과목명 /교과목번호
  IF p_smtx IS NOT INITIAL OR
     s_smsht[] IS NOT INITIAL.

    LOOP AT s_smsht.
      TRANSLATE s_smsht-low TO UPPER CASE."소문자를 대문자로 변경
      MODIFY s_smsht.
      CLEAR: s_smsht.
    ENDLOOP.

    CONCATENATE '%' p_smtx '%' INTO lv_smtext.
    CONDENSE lv_smtext NO-GAPS.

    CLEAR: lt_1000[], lt_1000.
    SELECT *
      FROM hrp1000
      INTO TABLE lt_1000[]
     WHERE plvar  = '01'
       AND otype  = 'SM'
       AND begda <= gv_begda
       AND endda >= gv_begda
       AND short IN s_smsht
       AND stext LIKE lv_smtext.
    SORT lt_1000 BY objid.

    IF sy-subrc <> 0.
      MESSAGE i001(zcmmsg) WITH '정확하게 입력하세요.'.
      STOP.
    ENDIF.

    DELETE ADJACENT DUPLICATES FROM lt_1000.

    CLEAR: r_smid[], r_smid.
    LOOP AT lt_1000.
      r_smid-sign   = 'I'.
      r_smid-option = 'EQ'.
      r_smid-low    = lt_1000-objid.
      APPEND r_smid. CLEAR: r_smid.
    ENDLOOP.
  ENDIF.


*- 이수구분 / 프로그램 유형
  CLEAR: lt_smlist, ls_smlist.
  SELECT b~plvar
         b~otype
         b~objid
  FROM hrp1001 AS a
  JOIN hrp1738 AS b
    ON a~plvar = b~plvar
   AND a~sclas = b~otype
   AND a~sobid = b~objid
  INTO TABLE  lt_smlist
   FOR ALL ENTRIES IN lt_result
 WHERE a~plvar      =  '01'
   AND a~otype      =  'O'
   AND a~objid      =  lt_result-objid
   AND a~istat      =  '1'
   AND a~begda     <=   gv_begda
   AND a~endda     >=   gv_begda
   AND a~subty      =  'A501'
   AND a~sclas      =  'SM'
   AND a~sobid     IN  r_smid

   AND b~plvar      =  '01'
   AND b~otype      =  'SM'
   AND b~istat      =  '1'
   AND b~begda     <=   gv_begda
   AND b~endda     >=   gv_begda.
*
*-중복삭제
  SORT lt_smlist BY objid.
  DELETE ADJACENT DUPLICATES FROM lt_smlist.

  CHECK lt_smlist IS NOT INITIAL.

  SELECT a~plvar
         a~otype
         a~objid
    FROM hrp1000 AS a
    JOIN hrp1001 AS b
      ON b~sobid = a~objid
    INTO TABLE pt_selist
     FOR ALL ENTRIES IN lt_smlist
   WHERE a~plvar  = '01'
     AND a~otype  = 'SE'
     AND a~short IN s_sest
     AND a~begda <= gv_begda
     AND a~endda >= gv_begda

     AND b~plvar  = '01'
     AND b~otype  = 'SM'
     AND b~objid  = lt_smlist-objid
     AND b~begda <= gv_begda
     AND b~endda >= gv_begda
     AND b~subty  = 'B514'
     AND b~sclas  = 'SE'.
*  ENDIF.

*-중복삭제
  SORT pt_selist BY objid.
  DELETE ADJACENT DUPLICATES FROM pt_selist.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_courseinfo
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_courseinfo .


  DATA: lt_keywd TYPE TABLE OF zcmrange_s_keywd WITH HEADER LINE.

  CHECK gt_selist[] IS NOT INITIAL.

  LOOP AT gt_selist INTO DATA(ls_selist).
    lt_keywd-sign = 'I'.
    lt_keywd-option = 'EQ'.
    lt_keywd-low = ls_selist-objid.
    APPEND lt_keywd.
  ENDLOOP.

  CALL FUNCTION 'ZCM_GET_COURSE_DETAIL_N'
    EXPORTING
      i_peryr  = p_peryr
      i_perid  = p_perid
      i_stype  = '7'
*     I_KWORD  =
*     I_AGRT   =
    TABLES
      e_course = gt_course[]
      e_keywd  = lt_keywd[].


ENDFORM.
*&---------------------------------------------------------------------*
*& Form excute_button_insert
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM excute_button_insert .
  CLEAR gs_s100.
  gs_s100-peryr = p_peryr.
  gs_s100-perid = p_perid.
  gs_s100-delay_begda = sy-datum.
  CALL SCREEN 100 STARTING AT 5 5 .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form excute_button_edit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM excute_button_edit .

  go_grid->set_alv_selected(
    EXPORTING
      iv_flag = 'XFLAG'
      iv_mode = 'M'
    CHANGING
      ct_data = gt_data[]
  ).


  CLEAR gs_s200.
  gs_s200-delay_begda = sy-datum.
  CALL SCREEN 200 STARTING AT 5 5.

  CHECK gs_s200-delay_begtm IS NOT INITIAL AND gs_s200-delay_begda IS NOT INITIAL .

  PERFORM data_popup_to_confirm_yn(zcms0)  USING gv_answer
                                       '변경 확인'
                                       '수강신청 잠금해제시간을 변경 하시겠습니까?'
                                       ''.
  CHECK gv_answer = 'J'.

  DATA ls_zcmtk210 TYPE zcmtk210.
  DATA lv_subrc TYPE sy-subrc.
  DATA lv_tabix TYPE sy-tabix.

  LOOP AT gt_data WHERE xflag = 'X'.
    lv_tabix = sy-tabix.
    CLEAR ls_zcmtk210.
    SELECT SINGLE * FROM zcmtk210 INTO ls_zcmtk210
      WHERE peryr = gt_data-peryr
        AND perid = gt_data-perid
        AND sm_id = gt_data-smobjid
        AND se_id = gt_data-seobjid.
    IF sy-subrc EQ 0.
      gt_data-delay_begda = gs_s200-delay_begda.
      gt_data-delay_begtm = gs_s200-delay_begtm.
      UPDATE zcmtk210 SET delay_begda = gt_data-delay_begda
                         delay_begtm = gt_data-delay_begtm
                         aenam = sy-uname
                         aedat = sy-datum
                         aetim = sy-uzeit
                   WHERE peryr = gt_data-peryr
                     AND perid = gt_data-perid
                     AND sm_id = gt_data-smobjid
                     AND se_id = gt_data-seobjid.
      IF sy-subrc EQ 0.
        COMMIT WORK.
        CALL FUNCTION 'ZCM_BACKUP_ZCMTK210'
          EXPORTING
            is_data  = ls_zcmtk210
            iv_keydt = gv_begda
            iv_mode  = 'C'.

        MODIFY gt_data INDEX lv_tabix
          TRANSPORTING delay_begda delay_begtm.

      ELSE.
        ROLLBACK WORK.
        lv_subrc = sy-subrc.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lv_subrc NE 0.
    MESSAGE '지연시간 변경중 오류 발생했습니다!!!!!!!!!!!!!' TYPE 'I'.
  ELSE.
    MESSAGE '지연시간 변경 완료했습니다' TYPE 'I'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form excute_button_delete
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM excute_button_delete .

  go_grid->set_alv_selected(
    EXPORTING
      iv_flag = 'XFLAG'
      iv_mode = 'M'
    CHANGING
      ct_data = gt_data[]
  ).

  PERFORM data_popup_to_confirm_yn(zcms0)  USING gv_answer
                                       '삭제 확인'
                                       '수강신청 지연 정보를 삭제하시겠습니까?'
                                       ''.

  CHECK gv_answer = 'J'.

  DATA ls_zcmtk210 TYPE zcmtk210.
  DATA lv_subrc TYPE sy-subrc.

  LOOP AT gt_data WHERE xflag = 'X'.
    CLEAR ls_zcmtk210.
    SELECT SINGLE * FROM zcmtk210 INTO ls_zcmtk210
      WHERE peryr = gt_data-peryr
        AND perid = gt_data-perid
        AND se_id = gt_data-seobjid
        AND st_id = gt_data-stobjid
        AND tmstp = gt_data-tmstp.

    IF sy-subrc EQ 0.
      DELETE zcmtk210 FROM ls_zcmtk210.
      IF sy-subrc EQ 0.
        COMMIT WORK.
        CALL FUNCTION 'ZCM_BACKUP_ZCMTK210'
          EXPORTING
            is_data  = ls_zcmtk210
            iv_keydt = gv_begda
            iv_mode  = 'D'.
      ELSE.
        lv_subrc = sy-subrc.
        EXIT.
        ROLLBACK WORK.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lv_subrc EQ 0.
    MESSAGE i014.
  ELSE.
    MESSAGE i015.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'S100'.
  SET TITLEBAR 'TITLE' WITH TEXT-t20.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_CURSOR_FIELD OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_cursor_field OUTPUT.
  SET CURSOR FIELD 'GS_S200-DELAY_BEGTM'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_200 INPUT.

  CASE ok_code.
    WHEN 'SAVE'.
      IF gs_s200-delay_begtm IS INITIAL.
        MESSAGE '잠금해제시간을 입력하세요' TYPE 'I'.
      ELSEIF gs_s200-delay_begda < sy-datum.
        MESSAGE '과거시간을 잠금해제시간으로 설정할 수 없습니다.' TYPE 'I'. EXIT.
      ELSEIF gs_s200-delay_begda = sy-datum AND gs_s200-delay_begtm < sy-uzeit.
        MESSAGE '과거시간을 잠금해제시간으로 설정할 수 없습니다.' TYPE 'I'. EXIT.
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.

    WHEN 'CANCEL'.
      CLEAR gs_s200.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form refresh_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_alv .

  go_grid->set_frontend_layout( go_grid->lvc_layout ).
  go_grid->soft_refresh( ).

ENDFORM.
