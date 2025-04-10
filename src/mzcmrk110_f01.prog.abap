*&---------------------------------------------------------------------*
*& Include          MZCMRK990_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data_select
*&---------------------------------------------------------------------*
FORM get_data_select .

  DATA lt_txt TYPE TABLE OF string.

  CLEAR : gt_data[].

  SELECT * FROM hrp9566
    INTO TABLE @DATA(lt_9566)
    WHERE plvar = '01'
      AND otype = 'O'
      AND objid IN @s_objid
      AND istat = '1'.
  CHECK lt_9566[] IS NOT INITIAL.

  SELECT * FROM hrt9566
    INTO TABLE @DATA(lt_t9566)
    FOR ALL ENTRIES IN @lt_9566
    WHERE tabnr = @lt_9566-tabnr.
  SORT lt_t9566 BY tabnr possb_oid.

  SELECT * FROM hrp1000
    INTO TABLE @DATA(lt_1000)
    FOR ALL ENTRIES IN @lt_9566
    WHERE plvar = '01'
      AND otype = 'O'
      AND objid = @lt_9566-objid
      AND istat = '1'
      AND begda <= @sy-datum
      AND endda >= @sy-datum
      AND langu = @sy-langu.
  SORT lt_1000 BY objid.

  IF lt_t9566 IS NOT INITIAL.
    SELECT * FROM hrp1000
      APPENDING TABLE @lt_1000
      FOR ALL ENTRIES IN @lt_t9566
      WHERE plvar = '01'
        AND otype = 'O'
        AND objid = @lt_t9566-possb_oid
        AND istat = '1'
        AND begda <= @sy-datum
        AND endda >= @sy-datum
        AND langu = @sy-langu.
    SORT lt_1000 BY objid.
  ENDIF.

  SELECT * FROM dd07t
    INTO TABLE @DATA(lt_dom)
    WHERE domname IN ('ZCMK_RE_GRD_PRC','')
      AND ddlanguage = @sy-langu.
  SORT lt_dom BY domname domvalue_l.

  SELECT * FROM t7piqscalet
    INTO TABLE @DATA(lt_scl)
    WHERE langu = @sy-langu.
  SORT lt_scl BY scaleid.

  LOOP AT lt_9566 INTO DATA(ls_9566).
    MOVE-CORRESPONDING ls_9566 TO gt_data.

    READ TABLE lt_1000 INTO DATA(ls_1000) WITH KEY objid = gt_data-objid BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data-o_stext = ls_1000-stext.
    ENDIF.

    READ TABLE lt_scl INTO DATA(ls_scl) WITH KEY scaleid = gt_data-re_scale BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data-re_scalet = ls_scl-text.
    ENDIF.

    READ TABLE lt_dom INTO DATA(ls_dom) WITH KEY domname = 'ZCMK_RE_GRD_PRC' domvalue_l = gt_data-re_grd_prc BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data-re_grd_prct = ls_dom-ddtext.
    ENDIF.

    READ TABLE lt_t9566 WITH KEY tabnr = ls_9566-tabnr BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      LOOP AT lt_t9566 INTO DATA(ls_t9566) FROM sy-tabix.
        IF ls_t9566-tabnr <> ls_9566-tabnr.
          EXIT.
        ENDIF.

        READ TABLE lt_1000 INTO ls_1000 WITH KEY objid = ls_t9566-possb_oid BINARY SEARCH.
        IF sy-subrc = 0.
          APPEND |[{ ls_t9566-possb_oid }]{ ls_1000-stext }| TO lt_txt.
        ENDIF.

      ENDLOOP.
    ENDIF.

    CONCATENATE LINES OF lt_txt INTO gt_data-possb SEPARATED BY `, `.

    APPEND gt_data.
    CLEAR: gt_data, lt_txt.
  ENDLOOP.


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
      WHEN 'OBJID'.
        <fs_fcat>-reptext = '소속'.
      WHEN 'O_STEXT'.
        <fs_fcat>-reptext = '소속명' .
      WHEN 'BEGDA'.
        <fs_fcat>-reptext = '시작일' .
      WHEN 'ENDDA'.
        <fs_fcat>-reptext = '종료일' .
      WHEN 'ST_GRD'.
        <fs_fcat>-reptext = '재이수 대상 성적' .
      WHEN 'RE_SCALE'.
        <fs_fcat>-reptext = '재이수 과목 성적 스케일' .
      WHEN 'RE_SCALET'.
        <fs_fcat>-reptext = '재이수 과목 성적 스케일' .
      WHEN 'RE_MAX_GRD'.
        <fs_fcat>-reptext = '재이수 과목 최대가능 성적' .
      WHEN 'RE_PER_SM_CNT'.
        <fs_fcat>-reptext = '학기당 재이수 과목수' .
      WHEN 'RE_TOT_CNT'.
        <fs_fcat>-reptext = '총 재이수 가능횟수' .
      WHEN 'RE_SAME_SM_CNT'.
        <fs_fcat>-reptext = '동일과목의 재이수 횟수' .
      WHEN 'RE_GRD_PRC'.
        <fs_fcat>-reptext = '성적처리' .
      WHEN 'RE_GRD_PRCT'.
        <fs_fcat>-reptext = '성적처리' .
*      WHEN 'REMARK'.
*        <fs_fcat>-reptext = '비고' .
      WHEN 'PRECD'.
        <fs_fcat>-reptext = '선수과목 체크여부' .
        <fs_fcat>-checkbox = 'X'.
      WHEN 'OVERL'.
        <fs_fcat>-reptext = '시간중복 체크여부' .
        <fs_fcat>-checkbox = 'X'.
      WHEN 'POSSB'.
        <fs_fcat>-reptext = '수강가능 소속' .
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
  go_grid->sort = VALUE #(  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_gui_status
*&---------------------------------------------------------------------*
FORM grid_gui_status .

  go_grid->gui_status->fully_dynamic = abap_true.
  go_grid->exclude_functions = go_grid->gui_status->edit_buttons( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EV_data_changed
*&---------------------------------------------------------------------*
FORM ev_data_changed  USING po_data_changed TYPE REF TO cl_alv_changed_data_protocol.

*  go_grid->set_frontend_layout( go_grid->lvc_layout ).
*  go_grid->soft_refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EV_user_command
*&---------------------------------------------------------------------*
FORM ev_user_command  USING p_ucomm   po_me TYPE REF TO lcl_alv_grid.

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
*& Form f4_O_ID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_o_id .
  DATA : f4_objec   LIKE objec.

  CALL FUNCTION 'RH_OBJID_REQUEST'
    EXPORTING
      plvar           = '01'
      otype           = 'O'
      dynpro_repid    = sy-repid
      dynpro_dynnr    = sy-dynnr
    IMPORTING
      sel_object      = f4_objec
    EXCEPTIONS
      cancelled       = 1
      wrong_condition = 2
      nothing_found   = 3
      illegal_mode    = 4
      internal_error  = 5
      OTHERS          = 6.

  IF sy-subrc = 0.
    MOVE f4_objec-realo TO s_objid-low.
  ENDIF.

ENDFORM.
