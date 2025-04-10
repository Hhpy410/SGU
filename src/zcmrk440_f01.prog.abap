*&---------------------------------------------------------------------*
*& Include          ZCMR1050_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form button_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ME
*&      --> ES_COL_ID
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM button_click   USING    po_grid TYPE REF TO lcl_falv
                            ps_col_id TYPE lvc_s_col
                            ps_row_no TYPE lvc_s_roid.


  IF po_grid = g_grid1.
    READ TABLE gt_data1 INDEX ps_row_no-row_id ASSIGNING FIELD-SYMBOL(<fs_data1>).
    CHECK sy-subrc = 0.

    CASE ps_col_id-fieldname.
      WHEN 'BTN_PASSN'.
*        PERFORM call_attach_file USING <fs_data1>-file_objid1.

      WHEN 'BTN_VISA'.
*        PERFORM call_attach_file USING <fs_data1>-file_objid2.

      WHEN OTHERS.

    ENDCASE.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_data_changed
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ME
*&      --> ER_DATA_CHANGED
*&      --> E_ONF4
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM grid_data_changed  USING    po_grid TYPE REF TO lcl_falv
                                 po_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                 p_e_onf4
                                 p_e_ucomm.

  DATA : ls_celltab   TYPE lvc_s_styl.
  DATA : lt_celltab   TYPE lvc_t_styl.
  DATA : ls_mod_cells TYPE lvc_s_modi.
  DATA : lv_index     TYPE c.

  FIELD-SYMBOLS : <fs_modi>  TYPE any.
  FIELD-SYMBOLS : <fs_value>  TYPE any.

  CASE po_grid.
    WHEN g_grid1.
      LOOP AT po_data_changed->mt_mod_cells INTO ls_mod_cells.

        READ TABLE gt_data1 ASSIGNING FIELD-SYMBOL(<fs_line>) INDEX ls_mod_cells-row_id.
        IF sy-subrc = 0.
          "체인지 필드 변경
          UNASSIGN <fs_value>.
          ASSIGN COMPONENT 'CHANGE_FG' OF STRUCTURE <fs_line> TO <fs_value>.
          IF <fs_value> IS ASSIGNED.
            <fs_value> = 'X'.
          ENDIF.

        ENDIF.

      ENDLOOP.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_select
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data_select .

  CLEAR : gt_data1, gt_data1[].

  CASE 'X'.
    WHEN p_r01.
      " 재이수 처리
      PERFORM _get_data_proc01.

    WHEN p_r02.
      " 재이수 대체처리
      PERFORM _get_data_proc02.

    WHEN OTHERS.
  ENDCASE.


ENDFORM.


*&---------------------------------------------------------------------*
*& Form create_single_falv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*


FORM create_single_falv  USING    pv_tabnm pv_assign_seq.


  DATA lv_seq TYPE i.

  DATA lv_tabnm(20).
  DATA lv_tabnm_tb(20).

  FIELD-SYMBOLS <fs_tab> TYPE STANDARD TABLE.

  lv_seq = pv_assign_seq.

  PERFORM get_ref_splitter_object USING  lv_seq.

  " 각 Contrainer 구성 object
  PERFORM get_ref_cont_object USING  lv_seq.

  CHECK <fs_grid> IS ASSIGNED.

  " TAB NAME & ITAB NAME Assign
  lv_tabnm    = pv_tabnm.
  lv_tabnm_tb = |{ pv_tabnm }[]|.

  ASSIGN (lv_tabnm_tb) TO <fs_tab>.
  IF <fs_tab> IS NOT ASSIGNED.
    MESSAGE e001 WITH 'Internal Table Assign Error!!'.
    EXIT.
  ENDIF.


  IF <fs_splitter> IS INITIAL.
    <fs_splitter> = NEW cl_gui_splitter_container( columns = 1
                                                    rows    = 1
                                                    parent = NEW cl_gui_docking_container(   style     = cl_gui_control=>ws_child
                                                                                             repid     = sy-cprog                          "현재 프로그램 ID
                                                                                             dynnr     = sy-dynnr                          "현재 화면번호
                                                                                             side      = 1 "CONTAINER POS
                                                                                             lifetime  = cl_gui_control=>lifetime_imode
                                                                                             extension = 3000 )  ).

    <fs_grid> ?= zcl_falv=>create( EXPORTING i_subclass = cl_abap_classdescr=>describe_by_name( p_name = gc_falv )
                                             i_handle   = CONV slis_handl( lv_seq )
                                             i_parent   = <fs_splitter>->get_container( row = 1 column = 1 )
                                   CHANGING  ct_table   = <fs_tab> ).

    CHECK  <fs_grid> IS BOUND.
    PERFORM create_grid_object USING <fs_grid> lv_tabnm lv_seq.

  ELSE.
    IF <fs_grid> IS ASSIGNED.
** Layout
*      PERFORM set_layout USING <fs_grid> lv_tabnm. " 스타일은 재설정 해야 함.

      <fs_grid>->soft_refresh( ).
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_ref_splitter_object
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_SEQ
*&---------------------------------------------------------------------*
FORM get_ref_splitter_object   USING    pv_seq.

  DATA lv_splitter_nm(30).

  lv_splitter_nm      = |{ gc_g_splitter }{ pv_seq }|.

  UNASSIGN :  <fs_splitter>.
  ASSIGN (lv_splitter_nm)      TO <fs_splitter>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_ref_cont_object
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_SEQ
*&---------------------------------------------------------------------*
FORM get_ref_cont_object  USING    pv_seq.

  DATA lv_grid_nm(30).

  lv_grid_nm      = |{ gc_g_grid }{ pv_seq }|.

  UNASSIGN :  <fs_grid>.
  ASSIGN (lv_grid_nm)      TO <fs_grid>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_grid_object
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_GRID>
*&      --> LV_TABNM
*&      --> LV_SEQ
*&---------------------------------------------------------------------*
FORM create_grid_object  USING    po_grid TYPE REF TO lcl_falv
                                  pv_tabnm
                                  pv_seq.

* show_top_of_page
  PERFORM show_top_of_page    USING po_grid pv_tabnm.

* Field_Catalog Define
  PERFORM set_fieldcatalog    USING po_grid pv_tabnm.

* Exclude
  PERFORM make_exclude_code   USING po_grid pv_tabnm.

* Layout
  PERFORM set_layout USING po_grid pv_tabnm.

* Toolbar button
  PERFORM set_toolbar USING po_grid pv_tabnm.

* Dropdown
  PERFORM create_dropdown USING po_grid pv_tabnm .

* F4
  PERFORM set_f4 USING po_grid pv_tabnm.

* variant
  PERFORM set_variant USING po_grid pv_tabnm pv_seq.

* Layout
  PERFORM set_sort USING po_grid pv_tabnm.


  po_grid->display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form show_top_of_page
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_GRID
*&      --> PV_TABNM
*&---------------------------------------------------------------------*
FORM show_top_of_page USING    po_grid TYPE REF TO lcl_falv
                                pv_tabnm.


  CASE pv_tabnm.
    WHEN 'GT_DATA1'.
*      po_grid->top_of_page_height = 100. "absolute size
*      po_grid->show_top_of_page( ).


    WHEN 'GT_DATA2'.

    WHEN 'GT_DATA3'.

    WHEN 'GT_DATA4'.

    WHEN OTHERS.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcatalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_GRID
*&      --> PV_TABNM
*&---------------------------------------------------------------------*
FORM set_fieldcatalog USING  po_grid TYPE REF TO lcl_falv  pv_tabnm.

  FIELD-SYMBOLS : <fs_fcat> LIKE LINE OF   po_grid->fcat.


  CASE pv_tabnm.
    WHEN 'GT_DATA1' .
      LOOP AT po_grid->fcat ASSIGNING <fs_fcat>.

        IF <fs_fcat>-outputlen >= 30.
          <fs_fcat>-outputlen = 20.
        ENDIF.

        IF <fs_fcat>-outputlen <= 5.
          <fs_fcat>-outputlen = 5.
        ENDIF.

        CASE <fs_fcat>-fieldname.
          WHEN 'CHANGE_FG' OR 'EXEC_FG' OR 'ADATANR' OR 'AGRID' OR 'REAGRID' .
            <fs_fcat>-no_out = 'X'.

          WHEN 'TARGET_FG'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '처리대상' .
            <fs_fcat>-checkbox = 'X'.

          WHEN 'MSGTY'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '처리결과' .

          WHEN 'MSGTX'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '처리결과 메시지' .

          WHEN 'ORGCD'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '소속구분' .

          WHEN 'ORGCD_T'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '소속구분명' .

          WHEN 'O_OBJID'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '학과' .


          WHEN 'O_OBJID'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '학과ID' .

          WHEN 'O_SHORT'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '학과명' .

          WHEN 'ST_NO'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '학번' .
            <fs_fcat>-hotspot = 'X'.

          WHEN 'ST_NM'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '성명' .

          WHEN 'STS_CD'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '학적상태' .
            <fs_fcat>-outputlen = 5.

          WHEN 'STS_CD_T'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '학적상태명' .
            <fs_fcat>-outputlen = 8.

          WHEN 'SM_ID'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '과목ID' .


          WHEN 'SM_SHORT'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '과목코드' .

          WHEN 'SM_STEXT'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '과목명' .

          WHEN 'SMSTATUS'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '상태' .

          WHEN 'SMSTATUS_T'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '상태명' .

          WHEN 'MODREG_ID'.
            <fs_fcat>-no_out = 'X'.

          WHEN 'CPATTEMPFU'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '신청 학점' .
            <fs_fcat>-quantity = 'CRH'.

          WHEN 'CPEARNEDFU'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '취득 학점' .
            <fs_fcat>-quantity = 'CRH'.

          WHEN 'REPEATFG'.
            <fs_fcat>-checkbox = 'X'.

          WHEN 'REPERYR'.
            <fs_fcat>-emphasize = 'C300'.
          WHEN 'REPERID'.
            <fs_fcat>-emphasize = 'C300'.
          WHEN 'RESMID'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '재수강 과목ID' .
            <fs_fcat>-emphasize = 'C300'.

          WHEN 'RESM_SHORT'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '재수강 과목코드' .
            <fs_fcat>-emphasize = 'C300'.
          WHEN 'RESM_STEXT'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '재수강 과목명' .
            <fs_fcat>-emphasize = 'C300'.
          WHEN 'RESMSTATUS'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '과거 상태' .
            <fs_fcat>-emphasize = 'C300'.
          WHEN 'RESMSTATUS_T'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '과거 상태명' .
            <fs_fcat>-emphasize = 'C300'.
          WHEN 'REID'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '과거 수강신청ID' .
            <fs_fcat>-emphasize = 'C300'.

          WHEN 'REPEXCEPT'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '대체처리(예외)' .
            <fs_fcat>-checkbox = 'X'.
            <fs_fcat>-emphasize = 'C300'.
          WHEN 'RE_GRADESYM'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '과거 성적' .
            <fs_fcat>-emphasize = 'C300'.
          WHEN 'RE_CPEARNEDFU'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '과거 학점' .
            <fs_fcat>-quantity = 'CRH'.
            <fs_fcat>-emphasize = 'C300'.
          WHEN OTHERS.

        ENDCASE.


      ENDLOOP.


    WHEN 'GT_DATA3'.

    WHEN OTHERS.
  ENDCASE.

  po_grid->set_frontend_fieldcatalog( po_grid->fcat ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_exclude_code
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_GRID
*&      --> PV_TABNM
*&---------------------------------------------------------------------*
FORM make_exclude_code   USING  po_grid TYPE REF TO lcl_falv  pv_tabnm.


  po_grid->exclude_functions  = po_grid->gui_status->edit_buttons( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_GRID
*&      --> PV_TABNM
*&---------------------------------------------------------------------*
FORM set_layout   USING  po_grid TYPE REF TO lcl_falv  pv_tabnm.

  DATA lv_row_id TYPE lvc_s_roid-row_id.

*  po_grid->set_editable( iv_modify = abap_true ).

  CASE pv_tabnm.
    WHEN 'GT_DATA1'.
      po_grid->layout->set_sel_mode( iv_value = 'D' ).
*      po_grid->layout->set_grid_title( 'FALV1 TITLE' ).
      IF p_r02 IS NOT INITIAL.
        po_grid->layout->set_info_fname( 'ROW_COLOR' ).
      ENDIF.
*      po_grid->layout->set_ctab_fname( 'CELL_COLOR' ).
      po_grid->layout->set_cwidth_opt( iv_value = abap_true ).
      po_grid->layout->set_stylefname( 'STYLES' ).
      po_grid->layout->set_zebra( abap_false ).

      LOOP AT gt_data1.
        po_grid->set_cell_button(
          EXPORTING
            iv_fieldname = 'BTN_STD'
            iv_row       = sy-tabix
        ).
      ENDLOOP.

    WHEN 'GT_DATA2'.
      po_grid->layout->set_sel_mode( iv_value = 'D' ).
      po_grid->layout->set_cwidth_opt( iv_value = abap_false ).
      po_grid->layout->set_zebra( abap_false ).

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_GRID
*&      --> PV_TABNM
*&---------------------------------------------------------------------*
FORM set_toolbar  USING    po_grid TYPE REF TO lcl_falv
                           pv_tabnm.

*    po_grid->add_button(
*        EXPORTING
*        iv_function  = 'BALV1'
*        iv_text      = 'ALV1 버튼'
*        iv_icon      = icon_abc
*        ).

  CASE pv_tabnm.
    WHEN 'GT_DATA1'.
*      po_grid->add_button(
*          EXPORTING
*          iv_function  = 'BALV1'
*          iv_text      = 'SetStyle 버튼'
*          iv_icon      = icon_abc
*          ).

    WHEN 'GT_DATA2'.
*      po_grid->add_button(
*          EXPORTING
*          iv_function  = 'BALV2'
*          iv_text      = 'Add Line 버튼'
*          iv_icon      = icon_finite
*          ).

    WHEN 'GT_DATA3'.

    WHEN 'GT_DATA4'.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_dropdown
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_GRID
*&      --> PV_TABNM
*&---------------------------------------------------------------------*
FORM create_dropdown   USING    po_grid TYPE REF TO lcl_falv
                               pv_tabnm.

  DATA: lt_listbox TYPE lvc_t_dral.

*  SELECT 1 AS handle, planetype AS int_value, planetype AS value FROM saplane
*    INTO TABLE @lt_listbox
*    WHERE producer = 'BOE'.

  CASE pv_tabnm.
    WHEN 'GT_DATA1'.

    WHEN 'GT_DATA2'.
*      po_grid->column( 'PLANETYPE' )->set_edit( iv_value = abap_true )->set_drdn_hndl(
*        EXPORTING
*          iv_value             = 1
*          it_drop_down_alias   = lt_listbox
*      ).

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_GRID
*&      --> PV_TABNM
*&---------------------------------------------------------------------*
FORM set_f4   USING    po_grid TYPE REF TO lcl_falv
                      pv_tabnm.


*    po_grid->column( 'OTYPE' )->set_edit( iv_value = abap_true ).
*    po_grid->register_f4_for_fields( VALUE #( (  fieldname = 'OTYPE' register = 'X' getbefore = 'X' ) ) ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_variant
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_GRID
*&      --> PV_TABNM
*&      --> PV_SEQ
*&---------------------------------------------------------------------*
FORM set_variant  USING    po_grid TYPE REF TO lcl_falv
                           pv_tabnm
                           pv_seq.

  DATA ls_variant TYPE disvariant.

  ls_variant-username = sy-uname.
  ls_variant-report   = sy-repid.
  ls_variant-handle   = pv_seq.

  po_grid->set_variant(
    EXPORTING
      is_variant = ls_variant                 " Layout Variant (External Use)
  ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form download_zip
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM download_zip .
  DATA: lt_selrows TYPE lvc_t_roid,
        ls_selrows TYPE lvc_s_roid.
  DATA: lv_lines   TYPE numc5.

  DATA lv_tline TYPE sytabix.

  CONSTANTS lc_file_path(30) VALUE 'C:\(서강대)국제학생 첨부파일'.

*--------------------------------------------------------------------*
*//___ # 10.09.2024 16:15:54 # 라인 선택 __//
*--------------------------------------------------------------------*
  CALL METHOD g_grid1->get_selected_rows
    IMPORTING
      et_row_no = lt_selrows.

  CLEAR: lv_lines.
  DESCRIBE TABLE lt_selrows LINES lv_lines.

  IF lv_lines < 1.
    MESSAGE s010(zcm11) DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*--------------------------------------------------------------------*
*//___ # 10.09.2024 16:16:08 # 실행할 라인 체크 __//
*--------------------------------------------------------------------*
*  LOOP AT lt_selrows INTO ls_selrows.
*    READ TABLE gt_data1 INDEX ls_selrows-row_id ASSIGNING FIELD-SYMBOL(<fs_data1>).
*    IF sy-subrc = 0.
*      IF <fs_data1>-file_objid1 IS INITIAL AND <fs_data1>-file_objid2 IS INITIAL.
*
*      ELSE.
*        <fs_data1>-exec_fg = 'X'." 실행할 라인..
*        ADD 1 TO lv_tline.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
*
*  IF line_exists( gt_data1[ exec_fg = 'X' ] ).
*
*  ELSE.
*    " 처리 실행할 라인 없을 경우...
*    MESSAGE s013(zcm11) DISPLAY LIKE 'E'.
*    EXIT.
*  ENDIF.
*

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_request_for_f4_org
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_1OOBJ
*&---------------------------------------------------------------------*
FORM get_request_for_f4_org USING    pv_1oobj.


  DATA: lt_vrmlist TYPE TABLE OF vrm_value WITH HEADER LINE.
  DATA lv_tabix TYPE i.

  CLEAR: lt_vrmlist[], lt_vrmlist.

  LOOP AT gt_orgcd_list ASSIGNING FIELD-SYMBOL(<fs_orgcd_list>).
    lt_vrmlist-key  = <fs_orgcd_list>-name.
    lt_vrmlist-text = <fs_orgcd_list>-value.
    APPEND lt_vrmlist.
  ENDLOOP.
  SORT lt_vrmlist.
  DELETE ADJACENT DUPLICATES FROM lt_vrmlist COMPARING ALL FIELDS.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'P_1OOBJ'
      values = lt_vrmlist[].

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
    IF screen-group1 = 'DAT'.
      screen-active = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

*  CASE p_1oobj.
*    WHEN gc_org204."경영전문대학원
*      LOOP AT SCREEN.
*        IF screen-group1 = 'O2'.
*          screen-active = 1 .
*        ENDIF.
*        MODIFY SCREEN.
*      ENDLOOP.
*
*    WHEN OTHERS.
**      CLEAR p_2oobj.
*      LOOP AT SCREEN.
*        IF screen-group1 = 'O2'.
*          screen-active = 0 .
*        ENDIF.
*        MODIFY SCREEN.
*      ENDLOOP.
*
*  ENDCASE.

  CASE 'X'.
    WHEN p_r01.


    WHEN p_r02.
      LOOP AT SCREEN.
        IF screen-group1 = 'PER'.
          screen-active = 0 .
        ENDIF.
        IF screen-group1 = 'C1'.
          screen-input = 0 .
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN OTHERS.
  ENDCASE.

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

  CLEAR gs_timelimits.
  zcmcl000=>get_timelimits(
    EXPORTING
      iv_o          = p_1oobj                " 소속 오브젝트 ID
      iv_timelimit  = '0100'           " 시한
      iv_peryr      = p_peryr                 " 학년도
      iv_perid      = p_perid                 " 학기
    IMPORTING
      et_timelimits = DATA(et_timelimits)
  ).
  READ TABLE et_timelimits INDEX 1 INTO gs_timelimits.
  IF sy-subrc = 0.
    p_datum  = gs_timelimits-ca_lbegda.
    gv_begda = gs_timelimits-ca_lbegda.
    gv_endda = gs_timelimits-ca_lendda.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM initialization .

*--------------------------------------------------------------------*
* # 26.08.2024 15:30:23 # 기준일
*--------------------------------------------------------------------*

  zcmcl000=>get_timelimits(
    EXPORTING
      iv_o          = '30000002'                " 소속 오브젝트 ID
      iv_timelimit  = '0100'           " 시한
      iv_keydate    = sy-datum
    IMPORTING
      et_timelimits = DATA(et_timelimits)
  ).

  LOOP AT et_timelimits ASSIGNING FIELD-SYMBOL(<fs_time>) WHERE ca_lbegda <= sy-datum AND ca_lendda >= sy-datum.
    IF <fs_time>-ca_perid = '001' OR <fs_time>-ca_perid = '002'.
      " 큰학기 제외.
    ELSE.
      gs_timelimits = CORRESPONDING #( <fs_time> ).
      EXIT.
    ENDIF.
  ENDLOOP.

  p_peryr  = gs_timelimits-ca_peryr.
  p_perid  = gs_timelimits-ca_perid.
  p_datum  = gs_timelimits-ca_lbegda.
  gv_begda = gs_timelimits-ca_lbegda.
  gv_endda = gs_timelimits-ca_lendda.

  gv_begda = sy-datum.
  gv_endda = sy-datum.

*--------------------------------------------------------------------*
* # 26.08.2024 15:30:08 # 사용자권한
*--------------------------------------------------------------------*
  DATA lv_admin_fg(1).
  IF sy-sysid = 'DEV'.
    IF sy-uname CS 'ASPN' OR sy-uname CS 'SIT'.
      lv_admin_fg = 'X'.
    ENDIF.
  ENDIF.
  zcmcl000=>get_user_authorg(
    EXPORTING
      iv_uname      = sy-uname         " 사용자 이름
      iv_admin_fg   = lv_admin_fg                 " 일반 표시
      iv_vrm_all    = 'X'
    IMPORTING
      ev_orgeh      = DATA(ev_orgeh)
      et_auth_root  = gt_auth_root[]                  " 권한 뷰
      et_auth_struc = gt_auth_object[]                 " 권한 ROOT ->ORG -> SC 레벨
      et_vrmlist    = gt_orgcd_list[]
      ev_error      = DATA(ev_error)                 " ERROR FLAG
      ev_msg        = DATA(ev_msg)                 " Message
  ).

  DELETE gt_orgcd_list WHERE name = '32000000'.

  READ TABLE gt_orgcd_list WITH KEY selected = 'X' ASSIGNING FIELD-SYMBOL(<fs_orgcd_list>).
  IF sy-subrc = 0.
    p_1oobj = <fs_orgcd_list>-name.
  ELSE.
    READ TABLE gt_orgcd_list INDEX 1 ASSIGNING <fs_orgcd_list>.
    IF sy-subrc = 0.
      p_1oobj = <fs_orgcd_list>-name.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_comm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data_comm .

  CLEAR gv_error.

  SELECT * INTO TABLE gt_hrp1000
           FROM hrp1000
           WHERE plvar = '01'
           AND   otype = 'O'
           AND   begda <= p_datum
           AND   endda >= p_datum
           AND   langu = '3'.

  SORT gt_hrp1000 BY otype objid .

*--------------------------------------------------------------------*
*//__07.10.2024 09:54:09__조건유형__//
  SELECT * INTO TABLE gt_t7piqsmstatt
           FROM t7piqsmstatt
           WHERE spras = sy-langu.

  SORT gt_t7piqsmstatt BY smstatus.

*--------------------------------------------------------------------*
*//__07.10.2024 09:54:01__공통코드__//
  RANGES lr_grp_cd FOR zcmt0101-grp_cd.

  lr_grp_cd[] = VALUE #( sign = 'I' option = 'EQ' ( low = '100' )   ).

  zcmcl000=>get_comm_cd( EXPORTING ir_grp_cd = lr_grp_cd[] IMPORTING et_zcmt0101 = gt_zcmt0101[] ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_button
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_DATA1
*&---------------------------------------------------------------------*
FORM add_button  USING    ps_data LIKE gt_data1
                          pv_fieldname.

  DATA ls_style TYPE lvc_s_styl.

  ls_style-fieldname = pv_fieldname.
  ls_style-style     = cl_gui_alv_grid=>mc_style_button.

  INSERT  ls_style INTO TABLE ps_data-styles.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_attach_fiel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_DATA1>_FILE_OBJID1
*&---------------------------------------------------------------------*
FORM call_attach_file  USING pv_object_id.
*
*  CHECK pv_object_id IS NOT INITIAL.
*
*  SELECT SINGLE * INTO @DATA(ls_toa01)
*         FROM toa01
*         WHERE object_id = @pv_object_id
*         AND   ar_object = 'ZCMFILE'.
*
*  CHECK sy-subrc = 0.
*
*  CALL METHOD zcl_fi_comm=>read_document_in_cr
*    EXPORTING
*      im_key       = ls_toa01-object_id
*      im_object    = ls_toa01-sap_object
*      im_arobj     = ls_toa01-ar_object
*      im_archiv_id = ls_toa01-archiv_id             " Content Repository Identification
*    IMPORTING
*      ex_subrc     = DATA(ex_subrc)
*      ex_uri       = DATA(ex_uri)                 " SAP 아카이브링크: 절대 URI의 data element
*      ex_ftype     = DATA(ex_ftype).
*
*  CHECK ex_uri IS NOT INITIAL.
*
*  zcmcl000=>call_local_browser(
*    EXPORTING
*      iv_url = CONV string( ex_uri )
*  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ST_ATTACH_FILE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_DATA1>
*&      --> P_
*&      <-- LV_ZIP_CONTENT
*&---------------------------------------------------------------------*
FORM get_st_attach_file  USING    ps_data LIKE gt_data1
                                  pv_gubun
                         CHANGING cv_file_contents TYPE xstring.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_GRID
*&      --> PV_TABNM
*&---------------------------------------------------------------------*
FORM set_sort USING po_grid TYPE REF TO lcl_falv
                    pv_tabnm.

  IF pv_tabnm = 'GT_DATA1'.

    po_grid->sort = VALUE #( ( fieldname = 'ST_NO' down = 'X' ) "학번
                             ( fieldname = 'PERYR' down = 'X' ) "학년도
                             ( fieldname = 'PERID' down = 'X' ) "학기
                            ).
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form del_scfeecat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM del_data .

*--------------------------------------------------------------------*
*//___ # 재이수 삭제 : 재이수 삭제 하시겠습니까 ?
*                      재이수 삭제는 한건씩만 가능
*                      확정인것만 삭제가능 __//
*--------------------------------------------------------------------*

  DATA: lt_selrows TYPE lvc_t_roid,
        ls_selrows TYPE lvc_s_roid.

  DATA lv_tline TYPE sytabix.

  DATA lv_status_tx(100).
  DATA: lv_lines   TYPE seqnr.

  DATA ls_msg         TYPE bapiret2.
  DATA ls_rebook_info TYPE pad506.

  CLEAR: gt_log[], gt_log.
*--------------------------------------------------------------------*
*//___ # 04.09.2024 13:18:44 # 라인 선택 및 체크 __//
*--------------------------------------------------------------------*

  CALL METHOD g_grid1->get_selected_rows
    IMPORTING
      et_row_no = lt_selrows.

  CLEAR lv_lines.
  DESCRIBE TABLE lt_selrows LINES lv_lines.

  IF lv_lines IS INITIAL.
    MESSAGE s010(zcm11) DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  LOOP AT lt_selrows INTO ls_selrows.
    READ TABLE gt_data1 INDEX ls_selrows-row_id ASSIGNING FIELD-SYMBOL(<fs_data1>).
    IF sy-subrc = 0.
      IF <fs_data1>-repeatfg = 'X'. " 재이수 확정
        <fs_data1>-exec_fg = 'X'." 실행할 라인..
        ADD 1 TO lv_tline.
      ENDIF.
    ENDIF.
  ENDLOOP.

  READ TABLE gt_data1 WITH KEY exec_fg = 'X' TRANSPORTING NO FIELDS.
  IF sy-subrc <> 0.
    MESSAGE s013(zcm11) DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  CHECK zcmcl000=>popup_to_confirm(
        text1 = '재이수 삭제처리 하시겠습니까?'
        text2 = ''
        ) IS NOT INITIAL.

  DATA ls_ci506 TYPE ci_pad506.

  LOOP AT gt_data1 ASSIGNING <fs_data1> WHERE exec_fg = 'X'.

    ADD 1 TO lv_lines.

    lv_status_tx = |{ lv_lines }-{ <fs_data1>-st_no } { <fs_data1>-st_nm }/{ <fs_data1>-sm_short }|.
    PERFORM display_status(zcms0) USING '' lv_status_tx.

*//__15.11.2024 13:48:35__학기 기준일__//
    zcmcl000=>get_timelimits(
      EXPORTING
        iv_o          = p_1oobj                " 소속 오브젝트 ID
        iv_timelimit  = '0100'           " 시한
        iv_peryr      = <fs_data1>-peryr                 " 학년도
        iv_perid      = <fs_data1>-perid                 " 학기
      IMPORTING
        et_timelimits = DATA(et_timelimits)
    ).
    READ TABLE et_timelimits INDEX 1 INTO DATA(ls_timelimits).

*//__15.11.2024 14:08:27__과목 스케일__//
    SELECT SINGLE * INTO @DATA(ls_hrp1710)
           FROM hrp1710
           WHERE plvar = '01'
           AND   otype = 'SM'
           AND   objid = @<fs_data1>-sm_id
           AND   begda <= @ls_timelimits-ca_lbegda
           AND   endda >= @ls_timelimits-ca_lbegda.

*//__15.11.2024 14:08:36__취소시 스케일은 과목 스케일 , 기타 CLEAR__//
    CLEAR ls_ci506.
    UPDATE hrpad506 SET alt_scaleid  = ls_hrp1710-scaleid
                        reperyr      = ls_ci506-reperyr
                        reperid      = ls_ci506-reperid
                        resmid       = ls_ci506-resmid
                        reid         = ls_ci506-reid
                        repeatfg     = ls_ci506-repeatfg
                        repexcept    = ls_ci506-repexcept
                        booktype     = 'SAPGUI'
                        hostname     = sy-host
                        aenam        = sy-uname
                        aedat        = sy-datum
                        aetim        = sy-uzeit
                 WHERE  id           = <fs_data1>-modreg_id.
    IF sy-subrc = 0.
      ls_msg-type    = 'S'.
      ls_msg-message = '재이수 삭제처리 완료'.

      ls_rebook_info = CORRESPONDING #( <fs_data1> ).
      PERFORM set_log USING lv_lines <fs_data1> ls_msg ls_rebook_info 'D'.
    ELSE.
      gt_log-code1 = <fs_data1>-st_no.
      gt_log-code2 = <fs_data1>-sm_short.
      gt_log-logtx = '처리 실패!'.
      APPEND gt_log.
    ENDIF.

  ENDLOOP.

  IF gt_log[] IS INITIAL.
    MESSAGE s011.
  ELSE.
    PERFORM popup_log_display.
  ENDIF.

  PERFORM get_data_select.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form popup_log_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM popup_log_display .
  CHECK gt_log[] IS NOT INITIAL.

  DATA(lr_log) = NEW cl_bal_logobj( i_max_msg_memory = 9999 ).

  LOOP AT gt_log  .
    lr_log->add_errortext( |{ gt_log-code1 }-{ gt_log-code2 }-{ gt_log-logtx }| ).
  ENDLOOP.

  lr_log->display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM add_data .

*  gv_mode = 'C'.
*
*  CLEAR gv_kschl.
*
*  gv_speryr    = 1900.
*  gv_eperyr    = 9999.
*  gv_feecal_fg = 'X'.  " 등록금 계산항목 여부 디폴트,  장학 등
*
*  CALL SCREEN 200 STARTING AT 5 5 .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_defautl_2oobj_val
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_default_2oobj_val .

*  CLEAR p_2oobj.
*
*  CASE p_1oobj.
*    WHEN gc_org204."경영전문대학원
*      IF p_2oobj IS INITIAL.
*        LOOP AT gt_auth_object ASSIGNING FIELD-SYMBOL(<fs_auth_object>) WHERE orgcd = p_1oobj.
*          IF <fs_auth_object>-dept_cd = p_1oobj.
*
*          ELSE.
*            p_2oobj = <fs_auth_object>-dept_cd.
*            EXIT.
*          ENDIF.
*        ENDLOOP.
*      ENDIF.
*
*    WHEN OTHERS.
*
*  ENDCASE .

ENDFORM.

*&---------------------------------------------------------------------*
*& Form EDIT_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM edit_data .
*  DATA: lt_selrows TYPE lvc_t_roid,
*        ls_selrows TYPE lvc_s_roid.
*
*  DATA lv_tline TYPE sytabix.
*
*  DATA lv_status_tx(100).
*  DATA: lv_lines   TYPE seqnr.
*
*
*  CLEAR: gt_log[], gt_log.
**--------------------------------------------------------------------*
**//___ # 04.09.2024 13:18:44 # 라인 선택 및 체크 __//
**--------------------------------------------------------------------*
*
*  CALL METHOD g_grid1->get_selected_rows
*    IMPORTING
*      et_row_no = lt_selrows.
*
*  CLEAR: lv_lines.
*  DESCRIBE TABLE lt_selrows LINES lv_lines.
*
*  IF lv_lines <> 1.
*    MESSAGE s009(zcm11) DISPLAY LIKE 'E'.
*    RETURN.
*  ENDIF.
*
*  LOOP AT lt_selrows INTO ls_selrows.
*    READ TABLE gt_data1 INDEX ls_selrows-row_id ASSIGNING FIELD-SYMBOL(<fs_data1>).
*    IF sy-subrc = 0.
*
*      gv_mode      = 'M'.
*      gv_kschl     = <fs_data1>-kschl.
*      gv_speryr    = <fs_data1>-speryr.
*      gv_eperyr    = <fs_data1>-eperyr.
*      gv_feecal_fg = <fs_data1>-feecal_fg.
*
*      CALL SCREEN 200 STARTING AT 5 5 .
*
*    ENDIF.
*  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_repeat_sm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM proc_repeat_sm .
*--------------------------------------------------------------------*
*//___ # 처리대상만 재이수 처리, 라인 선택 필요 없음 __//
*--------------------------------------------------------------------*

  DATA lt_stlist TYPE TABLE OF hrobject WITH HEADER LINE.

  DATA: lt_selrows TYPE lvc_t_roid,
        ls_selrows TYPE lvc_s_roid.

  DATA lv_tline TYPE sytabix.

  DATA lv_status_tx(100).
  DATA: lv_lines   TYPE seqnr.


  CLEAR: gt_log[], gt_log.

  CHECK zcmcl000=>popup_to_confirm(
        text1 = ' 재이수 처리하시겠습니까?'
        text2 = '(일괄처리)재이수 처리대상'
        ) IS NOT INITIAL.

  CLEAR lv_lines.

  LOOP AT gt_data1 ASSIGNING FIELD-SYMBOL(<fs_data1>) WHERE target_fg = 'X'.
    CLEAR : lt_stlist, lt_stlist[].

    ADD 1 TO lv_lines.

    lv_status_tx = |{ lv_lines }-{ <fs_data1>-st_no } { <fs_data1>-st_nm }/{ <fs_data1>-sm_short }|.
    PERFORM display_status(zcms0) USING '' lv_status_tx.

*//__14.11.2024 15:32:47__학생 과목 이수정보__//
    lt_stlist-plvar = '01'.
    lt_stlist-otype = 'ST'.
    lt_stlist-objid = <fs_data1>-st_id.
    APPEND lt_stlist.
    zcmcl000=>get_aw_acwork(
      EXPORTING
        it_stobj  = lt_stlist[]
      IMPORTING
        et_acwork = DATA(et_acwork)
    ).

*   temp
    DATA(lv_max_period) = p_peryr && p_perid.
    LOOP AT et_acwork INTO DATA(es_acwork).
      DATA(lv_period) = es_acwork-peryr && es_acwork-perid.
      CHECK lv_period > lv_max_period.
      DELETE et_acwork INDEX sy-tabix.

    ENDLOOP.

    zcmclk100=>check_sm_rebook_admin(
      EXPORTING
        i_stid         = <fs_data1>-st_id
        i_smid         = <fs_data1>-sm_id
        i_book_id      = <fs_data1>-modreg_id
        i_keydt        = p_datum
        i_peryr        = p_peryr
        i_perid        = p_perid
        i_oid          = <fs_data1>-orgcd
        it_acwork      = et_acwork[]
      IMPORTING
        es_msg         = DATA(es_msg)
        es_rebook_info = DATA(es_rebook_info)
    ).
    IF es_rebook_info IS NOT INITIAL.
      UPDATE hrpad506 SET alt_scaleid  = es_rebook_info-alt_scaleid
                          reperyr      = es_rebook_info-reperyr
                          reperid      = es_rebook_info-reperid
                          resmid       = es_rebook_info-resmid
                          reid         = es_rebook_info-reid
                          repeatfg     = es_rebook_info-repeatfg
                          booktype     = 'SAPGUI'
                          hostname     = sy-host
                          smobjid      = <fs_data1>-sm_id
                          stobjid      = <fs_data1>-st_id
                          aenam        = sy-uname
                          aedat        = sy-datum
                          aetim        = sy-uzeit
                   WHERE  id           = <fs_data1>-modreg_id.
      IF sy-subrc = 0.
        es_msg-type    = 'S'.
        es_msg-message = '재이수 처리 완료'.
        PERFORM set_log USING lv_lines <fs_data1> es_msg es_rebook_info 'RE01'.
      ELSE.
        gt_log-code1 = <fs_data1>-st_no.
        gt_log-code2 = <fs_data1>-sm_short.
        gt_log-logtx = '처리 실패!'.
        APPEND gt_log.
      ENDIF.
    ELSE.
      gt_log-code1 = <fs_data1>-st_no.
      gt_log-code2 = <fs_data1>-sm_short.
      gt_log-logtx = es_msg-message.
      APPEND gt_log.
    ENDIF.
  ENDLOOP.

  IF gt_log[] IS INITIAL.
    MESSAGE s011.
  ELSE.
    PERFORM popup_log_display.
  ENDIF.

  PERFORM get_data_select.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_repsts_sm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM proc_repsts_sm .

*--------------------------------------------------------------------*
*//___# 재이수 대체처리 : 재이수 rule 지켜야 됨, 강제처리 __//
*--------------------------------------------------------------------*

  DATA: lt_selrows TYPE lvc_t_roid,
        ls_selrows TYPE lvc_s_roid.

  DATA lv_tline TYPE sytabix.

  DATA lv_status_tx(100).
  DATA: lv_lines   TYPE seqnr.

  DATA lt_stlist TYPE TABLE OF hrobject WITH HEADER LINE.

  CLEAR: lt_stlist[], lt_stlist.
  CLEAR: gt_log[], gt_log.
**--------------------------------------------------------------------*
**//___ # 04.09.2024 13:18:44 # 라인 선택 및 체크 __//
**--------------------------------------------------------------------*

  CALL METHOD g_grid1->get_selected_rows
    IMPORTING
      et_row_no = lt_selrows.

  CLEAR: lv_lines.
  DESCRIBE TABLE lt_selrows LINES lv_lines.

  IF lv_lines = 2.

  ELSE.
    MESSAGE s001 WITH '처리 실행 할 두개 라인을 선택하세요.' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  LOOP AT lt_selrows INTO ls_selrows.
    READ TABLE gt_data1 INDEX ls_selrows-row_id ASSIGNING FIELD-SYMBOL(<fs_data1>).
    IF sy-subrc = 0.
      IF gs_maxper-peryr = <fs_data1>-peryr AND gs_maxper-perid = <fs_data1>-perid.
        IF <fs_data1>-resmid IS INITIAL.
          IF <fs_data1>-smstatus < 4. "01: 수강신청됨, 02: 완료(성공), 03: 완료(실패)
            <fs_data1>-proc_gb = 'R'. " 처리할 라인...
          ELSE.
            gt_log-code1 = <fs_data1>-st_no.
            gt_log-code2 = <fs_data1>-sm_short.
            gt_log-logtx = '처리 라인 - 수강상태(01)만 처리 가능합니다.'.
            APPEND gt_log.
            CONTINUE.
          ENDIF.
        ELSE.
          gt_log-code1 = <fs_data1>-st_no.
          gt_log-code2 = <fs_data1>-sm_short.
          gt_log-logtx = '처리 라인 - 재이수 내역이 존재합니다.'.
          APPEND gt_log.
          CONTINUE.
        ENDIF.
      ELSE.
        IF <fs_data1>-smstatus = '02' OR <fs_data1>-smstatus = '03'. " 완료
          <fs_data1>-proc_gb = 'S'. " 참조할 과거 라인...
        ELSE.
          gt_log-code1 = <fs_data1>-st_no.
          gt_log-code2 = <fs_data1>-sm_short.
          gt_log-logtx = '과거 라인 - 수강상태(02,03)만 처리 가능합니다.'.
          APPEND gt_log.
          CONTINUE.
        ENDIF.
      ENDIF.

      <fs_data1>-exec_fg = 'X'." 실행할 라인..
      ADD 1 TO lv_tline.

    ENDIF.
  ENDLOOP.

  PERFORM popup_log_display.

*--------------------------------------------------------------------*
*//___ # 15.11.2024 13:31:18 # 체크 __//
*--------------------------------------------------------------------*
  READ TABLE gt_data1 WITH KEY exec_fg = 'X' TRANSPORTING NO FIELDS.
  IF sy-subrc <> 0.
    MESSAGE s013(zcm11) DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  READ TABLE gt_data1 WITH KEY proc_gb = 'R' TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.

  ELSE.
    MESSAGE s001 WITH '재이수 대체처리 할 내역이 없습니다.' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  READ TABLE gt_data1 WITH KEY proc_gb = 'S' TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.

  ELSE.
    MESSAGE s001 WITH '재이수 대체처리 참조 할 과거내역이 없습니다.' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*--------------------------------------------------------------------*
*//___ # 15.11.2024 13:31:12 # 처리 __//
*--------------------------------------------------------------------*

  CHECK zcmcl000=>popup_to_confirm(
        text1 = '재이수 대체처리 하시겠습니까?'
        text2 = ''
        ) IS NOT INITIAL.

  DATA ls_ci506 TYPE ci_pad506.

  READ TABLE gt_data1 WITH KEY exec_fg = 'X' proc_gb = 'R' ASSIGNING <fs_data1>.
  IF sy-subrc = 0.

*//__15.11.2024 13:34:34__모든 이수내역 불러옴.__//
    CLEAR : lt_stlist, lt_stlist[].
    lt_stlist-plvar = '01'.
    lt_stlist-otype = 'ST'.
    lt_stlist-objid = <fs_data1>-st_id.
    APPEND lt_stlist.
    zcmcl000=>get_aw_acwork(
      EXPORTING
        it_stobj  = lt_stlist[]
      IMPORTING
        et_acwork = DATA(et_acwork)
    ).

*//__15.11.2024 13:48:35__학기 기준일__//
    zcmcl000=>get_timelimits(
      EXPORTING
        iv_o          = p_1oobj                " 소속 오브젝트 ID
        iv_timelimit  = '0100'           " 시한
        iv_peryr      = <fs_data1>-peryr                 " 학년도
        iv_perid      = <fs_data1>-perid                 " 학기
      IMPORTING
        et_timelimits = DATA(et_timelimits)
    ).
    READ TABLE et_timelimits INDEX 1 INTO DATA(ls_timelimits).

    READ TABLE gt_data1 WITH KEY exec_fg = 'X' proc_gb = 'S' INTO DATA(ls_data_s).

*//__15.11.2024 13:34:45__재이수 체크__//
    zcmclk100=>check_sm_rebook_admin(
      EXPORTING
        i_stid         = <fs_data1>-st_id
        i_smid         = <fs_data1>-sm_id
        i_book_id      = <fs_data1>-modreg_id
        i_keydt        = ls_timelimits-ca_lbegda
        i_peryr        = <fs_data1>-peryr
        i_perid        = <fs_data1>-perid
        i_oid          = <fs_data1>-orgcd
        it_acwork      = et_acwork[]
        i_book_re_id   = ls_data_s-modreg_id
      IMPORTING
        es_msg         = DATA(es_msg)
        es_rebook_info = DATA(es_rebook_info)
    ).

    IF es_rebook_info IS NOT INITIAL.
      es_rebook_info-repexcept = 'X'.
      UPDATE hrpad506 SET alt_scaleid  = es_rebook_info-alt_scaleid
                          reperyr      = es_rebook_info-reperyr
                          reperid      = es_rebook_info-reperid
                          resmid       = es_rebook_info-resmid
                          reid         = es_rebook_info-reid
                          repeatfg     = es_rebook_info-repeatfg
                          repexcept    = es_rebook_info-repexcept      " 재이수 대체처리
                          booktype     = 'SAPGUI'
                          hostname     = sy-host
                          smobjid      = <fs_data1>-sm_id
                          stobjid      = <fs_data1>-st_id
                          aenam        = sy-uname
                          aedat        = sy-datum
                          aetim        = sy-uzeit
                   WHERE  id           = <fs_data1>-modreg_id.
      IF sy-subrc = 0.
        es_msg-type    = 'S'.
        es_msg-message = '재이수 대체처리 완료'.
        PERFORM set_log USING lv_lines <fs_data1> es_msg es_rebook_info 'RE02'.
      ELSE.
        gt_log-code1 = <fs_data1>-st_no.
        gt_log-code2 = <fs_data1>-sm_short.
        gt_log-logtx = '처리 실패!'.
        APPEND gt_log.
      ENDIF.
    ELSE.
      gt_log-code1 = <fs_data1>-st_no.
      gt_log-code2 = <fs_data1>-sm_short.
      gt_log-logtx = es_msg-message.
      APPEND gt_log.
    ENDIF.

  ENDIF.

  IF gt_log[] IS INITIAL.
    MESSAGE s011.
  ELSE.
    PERFORM popup_log_display.
  ENDIF.

  PERFORM get_data_select.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form _get_data_proc01
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM _get_data_proc01 .

*//__14.11.2024 15:00:36__GET ST LIST__//
  PERFORM get_st_list.

*//__15.11.2024 12:46:35__과목 정보__//
  PERFORM get_st_smbook.

*//__15.11.2024 12:46:42__학생 기타정보__//
  PERFORM get_st_info.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form _get_data_proc02
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM _get_data_proc02 .

*--------------------------------------------------------------------*
*//___ # 15.11.2024 12:47:24 # 학번 체크 __//
*--------------------------------------------------------------------*
  IF s_stno12[] IS INITIAL.
    gv_error = 'X'.
    MESSAGE s001 WITH '학번을 입력 필수입니다.' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*//__15.11.2024 15:25:59__GET 학생 리스트__//
  PERFORM get_st_list.

  IF gt_stlist[] IS INITIAL.
    gv_error = 'X'.
    MESSAGE s001 WITH '정확한 대상자가 없습니다.' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  DESCRIBE TABLE gt_stlist.
  IF sy-tfill > 1.
    gv_error = 'X'.
    MESSAGE s001 WITH '학생 한명만 입력하세요.' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*//__15.11.2024 12:46:35__과목 정보__//
  PERFORM get_st_smbook_sts.

*//__15.11.2024 12:46:42__학생 기타정보__//
  PERFORM get_st_info.

*//__15.11.2024 13:07:39__SET LINE COLOR__//
  PERFORM set_line_color.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ST_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_st_list .

  DATA lt_object   TYPE TABLE OF hrobject .
  DATA lt_ststatus TYPE RANGE OF char04 .
  DATA lv_orgid    TYPE hrobjid.

  CLEAR : gt_stlist, gt_stlist[].

*--------------------------------------------------------------------*
*//___ # 21.10.2024 12:46:01 # 대상자 불러오기 __//
*--------------------------------------------------------------------*
  PERFORM display_status(zcms0) USING '' '대상자 조회 중...'.

  " 소속
  lt_object = VALUE #( ( plvar = '01' otype = 'O' objid = p_1oobj ) ).

  " 재학/휴학
  lt_ststatus = VALUE #( sign = 'I' option = 'EQ' ( low = '1000' ) ( low = '2000' ) ( low = '3000' ) ( low = '4000' ) ).

  zcmcl000=>get_st_list(
    EXPORTING
      it_object   = lt_object
      ir_stno     = s_stno12[]
      ir_sts_cd   = lt_ststatus[]
      iv_major_fg = ''
      iv_keydate  = gv_begda
    IMPORTING
      et_stlist   = gt_stlist[]
  ).


  SORT gt_stlist BY objid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_st_smbook
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_st_smbook .

  DATA lt_stlist      TYPE TABLE OF hrobject WITH HEADER LINE.
  DATA lt_hrsobid     TYPE TABLE OF hrsobid WITH HEADER LINE.
  DATA lt_smobj       TYPE TABLE OF hrp1000       WITH HEADER LINE.

  CHECK gt_stlist[] IS NOT INITIAL.

  PERFORM display_status(zcms0) USING '' '수강정보 조회 중...'.

*//__14.11.2024 15:33:03__해당 학기 학생 수강 신청 내역__//
  lt_hrsobid[] = CORRESPONDING #( gt_stlist[] MAPPING sobid = objid ).

  SELECT * INTO TABLE @DATA(lt_smbook)
           FROM zv_piqmodbooked2
           FOR ALL ENTRIES IN @lt_hrsobid[]
           WHERE plvar    = '01'
           AND   sclas    = 'ST'
           AND   sobid    = @lt_hrsobid-sobid
           AND   smstatus <= 3 "1:수강신청, 2:완료, 3:완료(실패)
           AND   peryr    = @p_peryr
           AND   perid    = @p_perid.

  SORT lt_smbook BY sobid.

  CHECK lt_smbook[] IS NOT INITIAL.


  LOOP AT lt_smbook ASSIGNING FIELD-SYMBOL(<fs_smbook_st>).
    lt_stlist-plvar = '01'.
    lt_stlist-otype = 'ST'.
    lt_stlist-objid = <fs_smbook_st>-sobid.
    APPEND lt_stlist.
  ENDLOOP.
  SORT lt_stlist.
  DELETE ADJACENT DUPLICATES FROM lt_stlist COMPARING ALL FIELDS.


*//__14.11.2024 15:32:37__학생 소속구분__//
  zcmcl000=>get_st_orgcd(
    EXPORTING
      it_stobj   = lt_stlist[]
      iv_keydate = p_datum      " 기준 일자
    IMPORTING
      et_storg   = DATA(et_storg)
  ).

  PERFORM display_status(zcms0) USING '' '학생 이수정보 조회 중...'.

*//__14.11.2024 15:32:47__학생 과목 이수정보__//
  zcmcl000=>get_aw_acwork(
    EXPORTING
      it_stobj  = lt_stlist[]
    IMPORTING
      et_acwork = DATA(et_acwork)
  ).

* temp
  DATA(lv_max_period) = p_peryr && p_perid.
  LOOP AT et_acwork INTO DATA(es_acwork).
    DATA(lv_period) = es_acwork-peryr && es_acwork-perid.
    CHECK lv_period > lv_max_period.
    DELETE et_acwork INDEX sy-tabix.

  ENDLOOP.

*//__14.11.2024 15:46:19__GET SM TEXT__//
  SELECT * INTO TABLE lt_smobj
           FROM hrp1000
           FOR ALL ENTRIES IN lt_smbook
           WHERE plvar = '01'
           AND   otype = 'SM'
           AND   objid = lt_smbook-objid
           AND   begda <= p_datum
           AND   endda >= p_datum
           AND   langu = '3'.

  SELECT * APPENDING TABLE lt_smobj
           FROM hrp1000
           FOR ALL ENTRIES IN lt_smbook
           WHERE plvar = '01'
           AND   otype = 'SM'
           AND   objid = lt_smbook-resmid
           AND   begda <= p_datum
           AND   endda >= p_datum
           AND   langu = '3'.

  SORT lt_smobj BY objid .

  PERFORM display_status(zcms0) USING '' '재이수 정보 체크 중...'.


  LOOP AT lt_smbook ASSIGNING FIELD-SYMBOL(<fs_smbook>).
    gt_data1-st_id    = <fs_smbook>-sobid.
    READ TABLE et_storg WITH KEY st_id = gt_data1-st_id ASSIGNING FIELD-SYMBOL(<fs_storg>) BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data1-orgcd   = <fs_storg>-org_id.
      gt_data1-orgcd_t = <fs_storg>-org_nm.
    ENDIF.
    gt_data1-repeatfg  = <fs_smbook>-repeatfg.
    gt_data1-peryr     = <fs_smbook>-peryr.
    gt_data1-perid     = <fs_smbook>-perid.
    gt_data1-sm_id     = <fs_smbook>-objid.
    gt_data1-smstatus  = <fs_smbook>-smstatus.
    gt_data1-modreg_id = <fs_smbook>-id.
    gt_data1-alt_scaleid = <fs_smbook>-alt_scaleid.
    gt_data1-reperyr   = <fs_smbook>-reperyr.
    gt_data1-reperid   = <fs_smbook>-reperid.
    gt_data1-resmid    = <fs_smbook>-resmid.
    gt_data1-reid      = <fs_smbook>-reid.
    gt_data1-repexcept = <fs_smbook>-repexcept.
    gt_data1-adatanr   = <fs_smbook>-adatanr.

    READ TABLE et_acwork WITH KEY modreg_id = gt_data1-modreg_id ASSIGNING FIELD-SYMBOL(<fs_acwork>).
    IF sy-subrc = 0.
      gt_data1-agrid      = <fs_acwork>-agrid.
      gt_data1-gradesym   = <fs_acwork>-gradesym.
      gt_data1-cpattempfu = <fs_acwork>-cpattemp.
      IF <fs_acwork>-agrid IS NOT INITIAL.
        gt_data1-cpearnedfu = <fs_acwork>-cpgained.
      ENDIF.
    ENDIF.

    READ TABLE et_acwork WITH KEY modreg_id = gt_data1-reid ASSIGNING FIELD-SYMBOL(<fs_acwork_re>).
    IF sy-subrc = 0.
      gt_data1-reagrid       = <fs_acwork_re>-agrid.
      gt_data1-re_gradesym   = <fs_acwork_re>-gradesym.
      gt_data1-re_cpearnedfu = <fs_acwork_re>-cpgained.
      gt_data1-resmstatus    = <fs_acwork_re>-smstatus.
    ENDIF.

    READ TABLE lt_smobj WITH KEY objid = gt_data1-sm_id BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data1-sm_short = lt_smobj-short.
      gt_data1-sm_stext = lt_smobj-stext.
    ENDIF.
    READ TABLE lt_smobj WITH KEY objid = gt_data1-resmid BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data1-resm_short = lt_smobj-short.
      gt_data1-resm_stext = lt_smobj-stext.
    ENDIF.

    DATA(lt_acwork_tmp) = et_acwork[].

    DELETE lt_acwork_tmp WHERE objid <>  gt_data1-st_id.

    " 재이수 대상 체크
    IF gt_data1-resmid IS INITIAL.
      zcmclk100=>check_sm_rebook_admin(
        EXPORTING
          i_stid         = gt_data1-st_id
          i_smid         = gt_data1-sm_id
          i_book_id      = gt_data1-modreg_id
          i_keydt        = p_datum
          i_peryr        = p_peryr
          i_perid        = p_perid
          i_oid          = gt_data1-orgcd
          it_acwork      = lt_acwork_tmp[]
        IMPORTING
          es_msg         = DATA(es_msg)
          es_rebook_info = DATA(es_rebook_info)
      ).

      IF  es_msg IS NOT INITIAL.
        gt_data1-target_fg = ''.   " 처리대상 아님.
        gt_data1-msgty = es_msg-type.
        gt_data1-msgtx = es_msg-message.
      ELSE.
        IF es_rebook_info IS NOT INITIAL.
          gt_data1-target_fg = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.

*선수과목 체크
    CLEAR es_msg.
    zcmclk100=>check_precedence(
      EXPORTING
        i_target_sm = gt_data1-sm_id
        i_keydt     = p_datum
        i_oid       = gt_data1-orgcd
        it_acwork   = lt_acwork_tmp[]
      IMPORTING
        es_msg      = es_msg ).
    IF  es_msg IS NOT INITIAL.
      gt_data1-msgty = es_msg-type.
      gt_data1-msgtx = es_msg-message.
    ENDIF.

    APPEND gt_data1. CLEAR gt_data1.
  ENDLOOP.

  IF p_chk01 IS NOT INITIAL.
    DELETE gt_data1 WHERE target_fg IS INITIAL.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_st_info
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_st_info .

  DATA lt_stlist TYPE TABLE OF hrobject WITH HEADER LINE.

  CHECK gt_data1[] IS NOT INITIAL.

  PERFORM display_status(zcms0) USING '' '학생정보 조회 중...'.

  LOOP AT gt_data1.
    lt_stlist-plvar = '01'.
    lt_stlist-otype = 'ST'.
    lt_stlist-objid = gt_data1-st_id.
    APPEND lt_stlist.
  ENDLOOP.
  SORT lt_stlist.
  DELETE ADJACENT DUPLICATES FROM lt_stlist COMPARING ALL FIELDS.

*--------------------------------------------------------------------*
*//___ # 22.10.2024 09:32:43 # GET ST CMACBPST __//
*--------------------------------------------------------------------*
  zcmcl000=>get_st_cmacbpst(
    EXPORTING
      it_stobj    = lt_stlist[]
      iv_keydate  = gv_begda        " 일자
    IMPORTING
      et_cmacbpst = DATA(et_cmacbpst)
  ).

*--------------------------------------------------------------------*
*//__01.11.2024 13:13:58__학적상태__//
*--------------------------------------------------------------------*
  zcmcl000=>get_st_status(
    EXPORTING
      it_stobj    = lt_stlist[]
      iv_keydate  = gv_begda
    IMPORTING
      et_ststatus = DATA(et_ststatus)
  ).

*--------------------------------------------------------------------*
*//___ # 22.10.2024 09:33:06 # GET MAJOR __//
*--------------------------------------------------------------------*
  zcmcl000=>get_st_major(
    EXPORTING
      it_stobj   = lt_stlist[]
      iv_keydate = gv_begda        " 일자
    IMPORTING
      et_stmajor = DATA(et_stmajor)
  ).

*//__14.11.2024 16:27:41__수강신청 WINDOW__//
  SELECT * INTO TABLE @DATA(lt_hrp1705)
           FROM hrp1705
           FOR ALL ENTRIES IN @lt_stlist[]
           WHERE plvar = '01'
           AND   otype = 'ST'
           AND   objid = @lt_stlist-objid
           AND   begda <= @gv_begda
           AND   endda >= @gv_begda.

  SORT lt_hrp1705 BY objid.

*--------------------------------------------------------------------*
*//___ # 15.11.2024 15:12:05 # 처리로그 __//
*--------------------------------------------------------------------*
  SELECT * INTO TABLE @DATA(lt_log)
           FROM zcmt2024_rep
           FOR ALL ENTRIES IN @gt_data1
           WHERE id = @gt_data1-modreg_id
*           AND   repgb IN ('RE01','RE02')
           AND   msgty = 'S'.

  SORT lt_log BY id
                 datum DESCENDING
                 uzeit DESCENDING.

*--------------------------------------------------------------------*
*//___ # 14.11.2024 15:37:38 # 기타 내역 정리 __//
*--------------------------------------------------------------------*

  LOOP AT gt_data1 ASSIGNING FIELD-SYMBOL(<fs_data1>).
    READ TABLE et_cmacbpst WITH KEY st_id = <fs_data1>-st_id  ASSIGNING FIELD-SYMBOL(<fs_cmacbpst>) BINARY SEARCH.
    IF sy-subrc = 0.
      <fs_data1>-st_no = <fs_cmacbpst>-st_no.
      <fs_data1>-st_nm = <fs_cmacbpst>-st_nm.
    ENDIF.
    READ TABLE et_stmajor WITH KEY st_objid = <fs_data1>-st_id ASSIGNING FIELD-SYMBOL(<fs_major>) BINARY SEARCH.
    IF sy-subrc = 0.
      <fs_data1>-o_objid   = <fs_major>-o_objid.
      <fs_data1>-o_short   = <fs_major>-o_short.
*      gt_data1-sc_objid  = <fs_major>-sc_objid1.
**      gt_data1-sc_stext  = <fs_major>-sc_stext1.
*      gt_data1-sc_stext  = <fs_major>-sc_short1.
    ENDIF.
    READ TABLE et_ststatus WITH KEY objid = <fs_data1>-st_id ASSIGNING FIELD-SYMBOL(<fs_ststatus>) BINARY SEARCH.
    IF sy-subrc = 0.
      <fs_data1>-sts_cd        = <fs_ststatus>-sts_cd.
      <fs_data1>-sts_cd_t      = <fs_ststatus>-sts_cd_t.
    ENDIF.
    READ TABLE lt_hrp1705 WITH KEY objid = <fs_data1>-st_id ASSIGNING FIELD-SYMBOL(<fs_hrp1705>) BINARY SEARCH.
    IF sy-subrc = 0.
      <fs_data1>-regwindow = <fs_hrp1705>-regwindow.
    ENDIF.

    READ TABLE gt_t7piqsmstatt WITH KEY smstatus = <fs_data1>-smstatus BINARY SEARCH.
    IF sy-subrc = 0.
      <fs_data1>-smstatus_t = gt_t7piqsmstatt-smstatust.
    ENDIF.
    READ TABLE gt_t7piqsmstatt WITH KEY smstatus = <fs_data1>-resmstatus BINARY SEARCH.
    IF sy-subrc = 0.
      <fs_data1>-resmstatus_t = gt_t7piqsmstatt-smstatust.
    ENDIF.

    " 최근 처리한 로그내역을 보여줌...
    READ TABLE lt_log WITH KEY id = <fs_data1>-modreg_id ASSIGNING FIELD-SYMBOL(<fs_log>) BINARY SEARCH.
    IF sy-subrc = 0.
      <fs_data1>-msgty = <fs_log>-msgty.
      <fs_data1>-msgtx = <fs_log>-msgtx.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_st_repast
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_st_repast .

**        re_gradesym   LIKE piqdbagr_gen-gradesym,   "성적기호
**        re_cpearnedfu LIKE piqdbagr_foll_up-cpearnedfu, "취득학점
*
*  CHECK gt_data1[] IS NOT INITIAL.
*
*  SELECT * INTO TABLE @DATA(lt_smbook_re)
*           FROM zv_piqmodbooked2
*           FOR ALL ENTRIES IN @gt_data1[]
*           WHERE id    = @gt_data1-reid.
*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_st_smbook_sts
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_st_smbook_sts .

  DATA lt_stlist      TYPE TABLE OF hrobject WITH HEADER LINE.
  DATA lt_hrsobid     TYPE TABLE OF hrsobid WITH HEADER LINE.
  DATA lt_smobj       TYPE TABLE OF hrp1000       WITH HEADER LINE.

  CHECK gt_stlist[] IS NOT INITIAL.

  PERFORM display_status(zcms0) USING '' '수강정보 조회 중...'.

*//__14.11.2024 15:33:03__해당 학기 학생 수강 신청 내역__//
  lt_hrsobid[] = CORRESPONDING #( gt_stlist[] MAPPING sobid = objid ).

  SELECT * INTO TABLE @DATA(lt_smbook)
           FROM zv_piqmodbooked2
           FOR ALL ENTRIES IN @lt_hrsobid[]
           WHERE plvar    = '01'
           AND   sclas    = 'ST'
           AND   sobid    = @lt_hrsobid-sobid.

  SORT lt_smbook BY sobid.

  CHECK lt_smbook[] IS NOT INITIAL.


  LOOP AT lt_smbook ASSIGNING FIELD-SYMBOL(<fs_smbook_st>).
    lt_stlist-plvar = '01'.
    lt_stlist-otype = 'ST'.
    lt_stlist-objid = <fs_smbook_st>-sobid.
    APPEND lt_stlist.
  ENDLOOP.
  SORT lt_stlist.
  DELETE ADJACENT DUPLICATES FROM lt_stlist COMPARING ALL FIELDS.


*//__14.11.2024 15:32:37__학생 소속구분__//
  zcmcl000=>get_st_orgcd(
    EXPORTING
      it_stobj   = lt_stlist[]
      iv_keydate = p_datum      " 기준 일자
    IMPORTING
      et_storg   = DATA(et_storg)
  ).

  PERFORM display_status(zcms0) USING '' '학생 이수정보 조회 중...'.


*//__14.11.2024 15:32:47__학생 과목 이수정보__//
  zcmcl000=>get_aw_acwork(
    EXPORTING
      it_stobj  = lt_stlist[]
    IMPORTING
      et_acwork = DATA(et_acwork)
  ).

*//__14.11.2024 15:46:19__GET SM TEXT__//
  SELECT * INTO TABLE lt_smobj
           FROM hrp1000
           FOR ALL ENTRIES IN lt_smbook
           WHERE plvar = '01'
           AND   otype = 'SM'
           AND   objid = lt_smbook-objid
           AND   langu = '3'.

  SELECT * APPENDING TABLE lt_smobj
           FROM hrp1000
           FOR ALL ENTRIES IN lt_smbook
           WHERE plvar = '01'
           AND   otype = 'SM'
           AND   objid = lt_smbook-resmid
           AND   langu = '3'.

  SORT lt_smobj BY objid begda endda.


  LOOP AT lt_smbook ASSIGNING FIELD-SYMBOL(<fs_smbook>).
    gt_data1-st_id    = <fs_smbook>-sobid.
    READ TABLE et_storg WITH KEY st_id = gt_data1-st_id ASSIGNING FIELD-SYMBOL(<fs_storg>) BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data1-orgcd   = <fs_storg>-org_id.
      gt_data1-orgcd_t = <fs_storg>-org_nm.
    ENDIF.
    gt_data1-repeatfg  = <fs_smbook>-repeatfg.
    gt_data1-peryr     = <fs_smbook>-peryr.
    gt_data1-perid     = <fs_smbook>-perid.
    gt_data1-sm_id     = <fs_smbook>-objid.
    gt_data1-smstatus  = <fs_smbook>-smstatus.
    gt_data1-modreg_id = <fs_smbook>-id.
    gt_data1-alt_scaleid = <fs_smbook>-alt_scaleid.
    gt_data1-reperyr   = <fs_smbook>-reperyr.
    gt_data1-reperid   = <fs_smbook>-reperid.
    gt_data1-resmid    = <fs_smbook>-resmid.
    gt_data1-reid      = <fs_smbook>-reid.
    gt_data1-repexcept = <fs_smbook>-repexcept.
    gt_data1-adatanr   = <fs_smbook>-adatanr.

    READ TABLE et_acwork WITH KEY modreg_id = gt_data1-modreg_id ASSIGNING FIELD-SYMBOL(<fs_acwork>).
    IF sy-subrc = 0.
      gt_data1-agrid      = <fs_acwork>-agrid.
      gt_data1-gradesym   = <fs_acwork>-gradesym.
      gt_data1-cpattempfu = <fs_acwork>-cpattemp.
      IF <fs_acwork>-agrid IS NOT INITIAL.
        gt_data1-cpearnedfu = <fs_acwork>-cpgained.
      ENDIF.
    ENDIF.

    READ TABLE et_acwork WITH KEY modreg_id = gt_data1-reid ASSIGNING FIELD-SYMBOL(<fs_acwork_re>).
    IF sy-subrc = 0.
      gt_data1-reagrid       = <fs_acwork_re>-agrid.
      gt_data1-re_gradesym   = <fs_acwork_re>-gradesym.
      gt_data1-re_cpearnedfu = <fs_acwork_re>-cpgained.
      gt_data1-resmstatus    = <fs_acwork_re>-smstatus.
    ENDIF.

    LOOP AT lt_smobj WHERE objid = gt_data1-sm_id
                     AND   begda <= <fs_smbook>-begda
                     AND   endda >= <fs_smbook>-begda.
      gt_data1-sm_short = lt_smobj-short.
      gt_data1-sm_stext = lt_smobj-stext.
      EXIT.
    ENDLOOP.

    LOOP AT lt_smobj WHERE objid = gt_data1-resmid
                     AND   begda <= <fs_smbook>-begda
                     AND   endda >= <fs_smbook>-begda.
      gt_data1-resm_short = lt_smobj-short.
      gt_data1-resm_stext = lt_smobj-stext.
      EXIT.
    ENDLOOP.

    APPEND gt_data1. CLEAR gt_data1.
  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LINE_COLOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_line_color .

  CLEAR gs_maxper.
  IF p_peryr = '2024' AND p_perid = '020'.
    READ TABLE gt_data1
          INTO gs_maxper
      WITH KEY peryr = p_peryr
               perid = p_perid.
    RETURN.

  ENDIF.

  SORT gt_data1 BY st_no
                   peryr DESCENDING
                   perid DESCENDING
                   sm_short.

  READ TABLE gt_data1 INDEX 1 INTO gs_maxper.

  LOOP AT gt_data1 ASSIGNING FIELD-SYMBOL(<fs_data1>).
    IF gs_maxper-peryr = <fs_data1>-peryr AND gs_maxper-perid = <fs_data1>-perid.
      <fs_data1>-row_color = 'C500'.
    ENDIF.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_DATA1>
*&      --> ES_REBOOK_INFO
*&---------------------------------------------------------------------*
FORM set_log USING pv_lines
                   ps_data LIKE gt_data1
                   ps_msg  TYPE bapiret2
                   ps_rebook_info TYPE pad506
                   pv_repgb.

  DATA ls_log TYPE zcmt2024_rep.

  ls_log-datum           = sy-datum.
  ls_log-uzeit           = sy-uzeit.
  ls_log-id              = ps_data-modreg_id.
  ls_log-uname           = sy-uname.
  ls_log-repgb           = pv_repgb.
  ls_log-msgty           = ps_msg-type.
  ls_log-msgtx           = ps_msg-message.
  ls_log-adatanr         = ps_data-adatanr.
  ls_log-smstatus        = ps_data-smstatus.
  ls_log-perid           = ps_data-perid.
  ls_log-peryr           = ps_data-peryr.
  ls_log-alt_scaleid     = ps_data-alt_scaleid.

  ls_log-reperyr         = ps_rebook_info-reperyr.
  ls_log-reperid         = ps_rebook_info-reperid.
  ls_log-resmid          = ps_rebook_info-resmid.
  ls_log-reid            = ps_rebook_info-reid.
  ls_log-repeatfg        = ps_rebook_info-repeatfg.
  ls_log-repexcept       = ps_rebook_info-repexcept.
  ls_log-regwindow       = ps_data-regwindow.
  ls_log-booktype        = 'SAPGUI'.
  ls_log-hostname        = sy-host.
  ls_log-smobjid         = ps_data-sm_id.
  ls_log-stobjid         = ps_data-st_id.
  ls_log-agrid           = ps_data-agrid.
  ls_log-reagrid         = ps_data-reagrid.

  MODIFY zcmt2024_rep FROM ls_log.

ENDFORM.
