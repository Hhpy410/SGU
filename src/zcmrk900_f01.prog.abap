*&---------------------------------------------------------------------*
*& Include          ZCMRK900_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module CREATE_ALV0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_alv0100 OUTPUT.

  PERFORM create_single_falv USING 'GT_DATA1' '1' .

ENDMODULE.

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
FORM grid_data_changed   USING    po_grid TYPE REF TO lcl_falv
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

  po_grid->soft_refresh( ).

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

  DATA : lv_text(50).


  DATA lv_flag_cancelled TYPE flag.

  CLEAR gv_trkorr.

  CLEAR : gt_data1, gt_data1[].

  lv_text = |%{ p_text }%|.

  SELECT  a~concept
          a~paket
          a~alias_name
          b~text     AS text_ko
          b~length   AS length_ko
          b~chan_name
          b~chan_tstut
    INTO CORRESPONDING FIELDS OF TABLE gt_data1
    FROM sotr_head AS a
    JOIN sotr_text AS b
      ON a~concept = b~concept
   WHERE a~paket = p_paket
     AND a~alias_name <> ''
     AND a~alias_name IN s_alias
     AND b~langu = '3'
     AND b~text  LIKE lv_text
     AND b~chan_name IN s_cnam.

  LOOP AT gt_data1 ASSIGNING FIELD-SYMBOL(<fs>).
    SELECT SINGLE * INTO @DATA(ls_otr_en)
           FROM sotr_text
           WHERE concept = @<fs>-concept
           AND   langu   = 'E'. " 영문
    IF sy-subrc = 0.
      <fs>-text_en   = ls_otr_en-text.
      <fs>-length_en = ls_otr_en-length.
    ENDIF.
    SELECT SINGLE * INTO @DATA(ls_otr_cn)
           FROM sotr_text
           WHERE concept = @<fs>-concept
           AND   langu   = '1'." 중문
    IF sy-subrc = 0.
      <fs>-text_cn   = ls_otr_cn-text.
      <fs>-length_cn = ls_otr_cn-length.
    ENDIF.
    <fs>-otr_key = |$OTR:{ <fs>-alias_name }|.

    <fs>-btn_std = '(EN)STD 편집'.

    PERFORM add_button USING <fs>.

    IF <fs>-concept IS NOT INITIAL.
      CALL FUNCTION 'BTFR_CORR_CHECK'
        EXPORTING
          package            = <fs>-paket
          concept            = <fs>-concept
        IMPORTING
          corr_num           = <fs>-trkorr
        EXCEPTIONS
          invalid_package    = 1
          permission_failure = 2
          OTHERS             = 3.
    ENDIF.

  ENDLOOP.

  SORT gt_data1 BY alias_name text_ko.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_change_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_change_data .

  DATA : lv_text(100).
  DATA : lv_len TYPE i.

  DATA : ls_sotr_ko TYPE sotr_text.
  DATA : ls_sotr_en TYPE sotr_text.
  DATA : ls_sotr_cn TYPE sotr_text.
  DATA : lt_entries TYPE sotr_text_tt.
  DATA : ls_paket   TYPE sotr_pack.

  DATA lv_msg TYPE string.

  g_grid1->check_changed_data( ).

  READ TABLE gt_data1 WITH KEY change_fg = 'X' TRANSPORTING NO FIELDS.
  IF  sy-subrc <> 0.
    MESSAGE s001 WITH '변경된 내역이 없습니다.' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  lv_text = '저장하시겠습니까?'.
  PERFORM data_popup_to_confirm_yn(zcms0) USING gv_answer
                                                '저장'
                                                lv_text
                                                ''.

  CHECK gv_answer = 'J'.

  PERFORM save_gt_data.

  PERFORM get_data_select.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_uselist
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_uselist .

  DATA : lt_sels TYPE lvc_t_row,
         ls_sels TYPE lvc_s_row.

  DATA : lv_lines TYPE i.

  CLEAR : lt_sels, ls_sels.

  CALL METHOD g_grid1->get_selected_rows
    IMPORTING
      et_index_rows = lt_sels.


  DESCRIBE TABLE lt_sels[] LINES lv_lines.

  IF lv_lines > 1 .
    MESSAGE i001 WITH 'Select at least One ROW'.
    EXIT.
  ENDIF.

  LOOP AT lt_sels INTO ls_sels.
    READ TABLE gt_data1 INDEX ls_sels-index.
    IF sy-subrc = 0.
      CALL FUNCTION 'BTFR_DISPLAY_USAGE'
        EXPORTING
          concept = gt_data1-concept.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form auto_create_alias
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM auto_create_alias .

  DATA : lv_alias_name TYPE sotr_head-alias_name.

  DATA lv_text(100).
  lv_text = 'Alias 자동생성(10) 하시겠습니까?'.
  PERFORM data_popup_to_confirm_yn(zcms0) USING gv_answer
                                                '생성'
                                                lv_text
                                                ''.


  CHECK gv_answer = 'J'.

  DATA: ls_paket   TYPE sotr_pack.
  DATA: lt_entries TYPE sotr_text_tt,
        ls_entry   TYPE sotr_text.

  DATA lv_concept TYPE sotr_text-concept.
  DATA lv_msg     TYPE string.


  PERFORM get_popup_input USING  gv_usegb.
  CHECK sy-ucomm = 'FURT'.
  CHECK gv_usegb IS NOT INITIAL.
  " 미리 10 라인 만들어 줌...

  DO 10 TIMES.

    PERFORM get_alias_name USING p_paket gv_usegb lv_alias_name.

    CLEAR: lt_entries, ls_entry.
    ls_entry-langu  = '3'.
    ls_entry-object = 'WDYV'.
    ls_entry-length = 255.
    ls_entry-text   = ''.
    APPEND ls_entry TO lt_entries.

    ls_entry-langu  = 'E'.
    ls_entry-object = 'WDYV'.
    ls_entry-length = 255.
    ls_entry-text   = ''.
    APPEND ls_entry TO lt_entries.

    ls_entry-langu  = '1'.
    ls_entry-object = 'WDYV'.
    ls_entry-length = 255.
    ls_entry-text   = ''.
    APPEND ls_entry TO lt_entries.

    ls_paket-paket = p_paket.
    CALL FUNCTION 'SOTR_CREATE_CONCEPT'
      EXPORTING
        paket                         = ls_paket
        crea_lan                      = '3'
        alias_name                    = lv_alias_name
        object                        = 'WDYV'
        entries                       = lt_entries
      IMPORTING
        concept                       = lv_concept
      EXCEPTIONS
        package_missing               = 1
        crea_lan_missing              = 2
        object_missing                = 3
        paket_does_not_exist          = 4
        alias_already_exist           = 5
        object_type_not_found         = 6
        langu_missing                 = 7
        identical_context_not_allowed = 8
        text_too_long                 = 9
        error_in_update               = 10
        no_master_langu               = 11
        error_in_concept_id           = 12
        alias_not_allowed             = 13
        tadir_entry_creation_failed   = 14
        internal_error                = 15
        error_in_correction           = 16
        user_cancelled                = 17
        no_entry_found                = 18
        OTHERS                        = 19.

    PERFORM corr_check USING p_paket lv_concept lv_msg.

  ENDDO.

  PERFORM get_data_select.

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

      <fs_grid>->refresh_table_display(
        EXPORTING
          is_stable      = CONV #( 'XX' )
          i_soft_refresh = ''                " Without Sort, Filter, etc.
        EXCEPTIONS
          finished       = 1                " Display was Ended (by Export)
          OTHERS         = 2
      ).

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

  po_grid->set_editable( iv_modify = abap_true ).

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
          WHEN 'TRKORR' .
*            <fs_fcat>-no_out = 'X'.

          WHEN 'CHANGE_FG'.
            <fs_fcat>-checkbox = 'X'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '수정' .

          WHEN 'PAKET'.
            <fs_fcat>-outputlen = '6'.

          WHEN 'ALIAS_NAME'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '[Alias]OTR 별칭' .
*        ls_fcat-edit = 'X'.
            <fs_fcat>-outputlen = '18'.

          WHEN 'OTR_KEY'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '[WebUI]OTR Text Key' .
            <fs_fcat>-outputlen = '20'.

          WHEN 'TEXT_KO'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '텍스트(국문)' .
            <fs_fcat>-edit = 'X'.
            <fs_fcat>-outputlen = '40'.

          WHEN 'TEXT_EN'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '텍스트(영문)' .
            <fs_fcat>-edit = 'X'.
            <fs_fcat>-outputlen = '40'.

          WHEN 'TEXT_CN'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '텍스트(중문)' .
            <fs_fcat>-edit = 'X'.
            <fs_fcat>-outputlen = '40'.

          WHEN 'BTN_STD'.
            <fs_fcat>-scrtext_s = <fs_fcat>-scrtext_m =
            <fs_fcat>-scrtext_l = <fs_fcat>-reptext = '스탠다드' .

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
*      po_grid->layout->set_info_fname( 'ROW_COLOR' ).
*      po_grid->layout->set_ctab_fname( 'CELL_COLOR' ).
      po_grid->layout->set_cwidth_opt( iv_value = abap_false ).
      po_grid->layout->set_stylefname( 'STYLES' ).
      po_grid->layout->set_zebra( abap_true ).
      po_grid->layout->set_no_rowins( abap_true ).

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
      po_grid->layout->set_zebra( abap_true ).

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
*& Form corr_check
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_DATA1_PAKET
*&      --> GT_DATA1_CONCEPT
*&      --> LV_MSG
*&---------------------------------------------------------------------*
FORM corr_check  USING    pv_paket
                          pv_concept
                          cv_msg .

  DATA lv_flag_cancelled TYPE btfr_flag.

  CLEAR lv_flag_cancelled.
  CLEAR cv_msg.

  " CTS 체크

  CALL FUNCTION 'BTFR_CORR_CHECK'
    EXPORTING
      package            = pv_paket
      concept            = pv_concept
    IMPORTING
      flag_cancelled     = lv_flag_cancelled
*     corr_num           = gv_trkorr
    EXCEPTIONS
      invalid_package    = 1
      permission_failure = 2
      OTHERS             = 3.
  IF sy-subrc <> 0 OR lv_flag_cancelled = 'X'.
    MESSAGE s102(sotr_mess) INTO cv_msg.
    MESSAGE s102(sotr_mess) DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.


  CALL FUNCTION 'BTFR_CORR_INSERT'
    EXPORTING
      package            = pv_paket
      concept            = pv_concept
    IMPORTING
      flag_cancelled     = lv_flag_cancelled
    CHANGING
      corr_num           = gv_trkorr
    EXCEPTIONS
      invalid_package    = 1
      permission_failure = 2
      OTHERS             = 3.
  IF sy-subrc <> 0 OR lv_flag_cancelled = 'X'.
    MESSAGE s102(sotr_mess) INTO cv_msg.
    MESSAGE s102(sotr_mess) DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_alias_name
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_PAKET
*&      --> LV_ALIAS_NAME
*&---------------------------------------------------------------------*
FORM get_alias_name  USING pv_paket pv_usegb  pv_alias_name.

  DATA lv_number TYPE hrobjid.
  DATA lv_nr TYPE  inri-nrrangenr.

  CLEAR lv_number.
  CLEAR pv_alias_name.

*
  lv_nr = '01'.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = lv_nr
      object                  = 'ZCMOTR'
    IMPORTING
      number                  = lv_number
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.

*  pv_alias_name = |{ p_paket }/TX{ lv_number }|.
  pv_alias_name = |{ p_paket }/{ pv_usegb }{ lv_number }|.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form button_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ME
*&      --> ES_COL_ID
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM button_click  USING    po_grid TYPE REF TO lcl_falv
                            ps_col_id TYPE lvc_s_col
                            ps_row_no TYPE lvc_s_roid.


  IF po_grid = g_grid1.
    READ TABLE gt_data1 INDEX ps_row_no-row_id ASSIGNING FIELD-SYMBOL(<fs_data1>).
    CHECK sy-subrc = 0.

    CASE ps_col_id-fieldname.
      WHEN 'BTN_STD'.
        PERFORM call_sotr_sel_screen USING <fs_data1>.
        PERFORM get_data_select.

      WHEN OTHERS.

    ENDCASE.


  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_sotr_sel_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_DATA1>
*&---------------------------------------------------------------------*
FORM call_sotr_sel_screen  USING  ps_data LIKE gt_data1.

  DATA: l_edit_mode      TYPE bapiflag.
  DATA: l_text_entries   TYPE TABLE OF sotr_entry WITH HEADER LINE,
        l_string_entries TYPE TABLE OF sotr_textl WITH HEADER LINE.
  DATA: l_worklist    TYPE sotr_wrkls_tt,
        l_worklist_wa TYPE sotr_wrkls.

  DATA: l_target_context TYPE sotr_cntxt,
        l_source_text    TYPE sotr_txt,
        l_target_text    TYPE sotr_txt.

  l_edit_mode-bapiflag = 'R'.

  SET PARAMETER ID 'DVC' FIELD ps_data-paket.

  CALL FUNCTION 'SOTR_SEL_SCREEN'
    EXPORTING
      edit_mode      = 'R'
      i_slang        = 'E'
      i_alias        = ps_data-alias_name
      start_row      = '5'
      start_col      = '5'
    TABLES
      text_entries   = l_text_entries[]
      string_entries = l_string_entries[]
    EXCEPTIONS
      no_entry_found = 1
      OTHERS         = 2.


  LOOP AT l_text_entries.
    MOVE-CORRESPONDING l_text_entries TO l_worklist_wa.
    APPEND l_worklist_wa TO l_worklist.
  ENDLOOP.
  CALL FUNCTION 'SOTR_EDITOR_WORKLIST'
    EXPORTING
      edit_mode                  = l_edit_mode
      source_langu               = 'E'
      target_langu               = 'E'
      target_context             = l_target_context
      source_term                = l_source_text
      target_term                = l_target_text
    CHANGING
      worklist                   = l_worklist[]
    EXCEPTIONS
      no_entry_found             = 1
      error_in_context           = 2
      error_in_replacement_term  = 3
      edit_mode_not_supported    = 4
      no_authorization           = 5
      internal_error             = 6
      error_in_transport_request = 7
      OTHERS                     = 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_BUTTON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS>
*&---------------------------------------------------------------------*
FORM add_button  USING    ps_data LIKE gt_data1.

  DATA ls_style TYPE lvc_s_styl.

  ls_style-fieldname = 'BTN_STD'.
  ls_style-style     = cl_gui_alv_grid=>mc_style_button.

  INSERT  ls_style INTO TABLE ps_data-styles.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form line_double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ME
*&      --> E_ROW
*&      --> E_COLUMN
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM line_double_click  USING    po_grid TYPE REF TO lcl_falv
                                 p_row  TYPE lvc_s_row
                                 p_column TYPE lvc_s_col
                                 ps_row_no TYPE lvc_s_roid .

  IF po_grid = g_grid1.
    READ TABLE gt_data1 INDEX ps_row_no-row_id ASSIGNING FIELD-SYMBOL(<fs_data1>).
    CHECK sy-subrc = 0.

    CASE p_column-fieldname.
      WHEN 'ALIAS_NAME' OR 'OTR_KEY'.
        PERFORM display_scouce_scan USING <fs_data1> .

      WHEN 'TRKORR'.

        PERFORM display_request USING <fs_data1> .


      WHEN OTHERS.

    ENDCASE.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_request
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_DATA1>
*&---------------------------------------------------------------------*
FORM display_request  USING    ps_data LIKE gt_data1.



  DATA ls_popup TYPE strhi_popup.

  CHECK ps_data-trkorr IS NOT INITIAL.

  ls_popup-start_row    =  2.
  ls_popup-start_column =  1.
  ls_popup-end_row      = 17.
  ls_popup-end_column   = 84.

  CALL FUNCTION 'TR_PRESENT_REQUEST'
    EXPORTING
      iv_trkorr    = ps_data-trkorr
      iv_highlight = 'X'
      is_popup     = ls_popup
      iv_showonly  = 'X'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form corr_check_all
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM corr_check_all .

  DATA lv_text(100).

  lv_text = 'CTS 전체 묶기 하시겠습니까?'.
  PERFORM data_popup_to_confirm_yn(zcms0) USING gv_answer
                                                '저장'
                                                lv_text
                                                ''.

  CHECK gv_answer = 'J'.

  gt_data1-change_fg = 'X'.
  MODIFY gt_data1 TRANSPORTING change_fg WHERE change_fg = ''.

  PERFORM save_gt_data.

  PERFORM get_data_select.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_GT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_gt_data .

  DATA : lv_text(100).
  DATA : lv_len TYPE i.


  DATA : ls_sotr_ko TYPE sotr_text.
  DATA : ls_sotr_en TYPE sotr_text.
  DATA : ls_sotr_cn TYPE sotr_text.
  DATA : lt_entries TYPE sotr_text_tt.
  DATA : ls_paket   TYPE sotr_pack.

  DATA lv_msg TYPE string.

  LOOP AT gt_data1 WHERE change_fg = 'X' ."AND trkorr IS INITIAL.

*--------------------------------------------------------------------*
    " 국문
    CLEAR ls_sotr_ko.
    lv_len = strlen( gt_data1-text_ko ) + 5.
    MOVE-CORRESPONDING gt_data1 TO ls_sotr_ko.
    ls_sotr_ko-langu   = '3'.
    ls_sotr_ko-text    = gt_data1-text_ko.
*    ls_sotr_ko-length  = lv_len.
    ls_sotr_ko-length  = 255.
    ls_sotr_ko-object = 'WDYV'.
    CALL FUNCTION 'SOTR_UPDATE_CONCEPT_ENTRY'
      EXPORTING
        entry               = ls_sotr_ko
      EXCEPTIONS
        concept_not_found   = 1
        entry_not_found     = 2
        langu_missing       = 3
        no_master_langu     = 4
        error_in_correction = 5
        user_cancelled      = 6
        OTHERS              = 7.

*--------------------------------------------------------------------*
    " 영문
    CLEAR ls_sotr_en.
    CLEAR lt_entries.
    lv_len = strlen( gt_data1-text_en ) + 5.
    MOVE-CORRESPONDING gt_data1 TO ls_sotr_en.
    ls_sotr_en-langu   = 'E'.
    ls_sotr_en-text    = gt_data1-text_en.
*    ls_sotr_en-length  = lv_len.
    ls_sotr_en-length  = 255.
    ls_sotr_en-object = 'WDYV'.
    CALL FUNCTION 'SOTR_UPDATE_CONCEPT_ENTRY'
      EXPORTING
        entry               = ls_sotr_en
      EXCEPTIONS
        concept_not_found   = 1
        entry_not_found     = 2
        langu_missing       = 3
        no_master_langu     = 4
        error_in_correction = 5
        user_cancelled      = 6
        OTHERS              = 7.
    IF sy-subrc <> 0. " 기존 영문 없을 경우 생성해줌..
      ls_sotr_en-langu  = 'E'.
      ls_sotr_en-object = 'WDYV'.
      ls_sotr_en-length = strlen( gt_data1-text_en ) + 5.
      ls_sotr_en-text   = gt_data1-text_en.
      APPEND ls_sotr_en TO lt_entries.

      ls_paket-paket = gt_data1-paket.
      CALL FUNCTION 'SOTR_CREATE_CONCEPT'
        EXPORTING
          paket                         = ls_paket
          crea_lan                      = '3'
          alias_name                    = gt_data1-alias_name
          object                        = 'WDYV'
          entries                       = lt_entries
        EXCEPTIONS
          package_missing               = 1
          crea_lan_missing              = 2
          object_missing                = 3
          paket_does_not_exist          = 4
          alias_already_exist           = 5
          object_type_not_found         = 6
          langu_missing                 = 7
          identical_context_not_allowed = 8
          text_too_long                 = 9
          error_in_update               = 10
          no_master_langu               = 11
          error_in_concept_id           = 12
          alias_not_allowed             = 13
          tadir_entry_creation_failed   = 14
          internal_error                = 15
          error_in_correction           = 16
          user_cancelled                = 17
          no_entry_found                = 18
          OTHERS                        = 19.
    ENDIF.
*--------------------------------------------------------------------*
    " 중문 추가...
    CLEAR ls_sotr_cn.
    CLEAR lt_entries.
*    lv_len = strlen( gt_data1-text_CN ) + 5.
    MOVE-CORRESPONDING gt_data1 TO ls_sotr_cn.
    ls_sotr_cn-langu   = '1'.
    ls_sotr_cn-text    = gt_data1-text_cn.
*    ls_sotr_en-length  = lv_len.
    ls_sotr_cn-length  = 255.
    ls_sotr_cn-object = 'WDYV'.
    CALL FUNCTION 'SOTR_UPDATE_CONCEPT_ENTRY'
      EXPORTING
        entry               = ls_sotr_cn
      EXCEPTIONS
        concept_not_found   = 1
        entry_not_found     = 2
        langu_missing       = 3
        no_master_langu     = 4
        error_in_correction = 5
        user_cancelled      = 6
        OTHERS              = 7.
    IF sy-subrc <> 0. " 기존 영문 없을 경우 생성해줌..
      ls_sotr_cn-langu  = '1'.
      ls_sotr_cn-object = 'WDYV'.
      ls_sotr_cn-length = strlen( gt_data1-text_cn ) + 5.
      ls_sotr_cn-text   = gt_data1-text_cn.
      APPEND ls_sotr_cn TO lt_entries.

      ls_paket-paket = gt_data1-paket.
      CALL FUNCTION 'SOTR_CREATE_CONCEPT'
        EXPORTING
          paket                         = ls_paket
          crea_lan                      = '3'
          alias_name                    = gt_data1-alias_name
          object                        = 'WDYV'
          entries                       = lt_entries
        EXCEPTIONS
          package_missing               = 1
          crea_lan_missing              = 2
          object_missing                = 3
          paket_does_not_exist          = 4
          alias_already_exist           = 5
          object_type_not_found         = 6
          langu_missing                 = 7
          identical_context_not_allowed = 8
          text_too_long                 = 9
          error_in_update               = 10
          no_master_langu               = 11
          error_in_concept_id           = 12
          alias_not_allowed             = 13
          tadir_entry_creation_failed   = 14
          internal_error                = 15
          error_in_correction           = 16
          user_cancelled                = 17
          no_entry_found                = 18
          OTHERS                        = 19.
    ENDIF.
*--------------------------------------------------------------------*

    PERFORM corr_check USING gt_data1-paket gt_data1-concept lv_msg.


  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_popup_input
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_USEGB
*&---------------------------------------------------------------------*
FORM get_popup_input  USING    pv_value.

  DATA: lt_seltab TYPE STANDARD TABLE OF rsparams WITH HEADER LINE.
  DATA: ls_seltab LIKE LINE OF lt_seltab.
  DATA: lt_sval LIKE sval OCCURS 0 WITH HEADER LINE.

  CLEAR lt_sval[].
  lt_sval-tabname   = 'HRP1000'.
  lt_sval-fieldname = 'SHORT'.
  IF pv_value IS INITIAL .
    lt_sval-value     = 'TX' .
  ELSE.
    lt_sval-value     = pv_value .
  ENDIF.
  lt_sval-field_obl = 'X' .
  lt_sval-fieldtext = 'ALIAS 구분' .
  APPEND lt_sval.
*
  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title  = 'ALIAS 구분자 입력'
      start_column = '5'
      start_row    = '5'
    TABLES
      fields       = lt_sval.

  IF sy-ucomm = 'FURT'.
    READ TABLE lt_sval INDEX 1.
    IF sy-subrc = 0 .
      pv_value = lt_sval-value.
      TRANSLATE pv_value TO UPPER CASE.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_uselist_U4A
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_uselist_u4a .

  DATA : lt_sels TYPE lvc_t_row,
         ls_sels TYPE lvc_s_row.

  RANGES : lr_uikey FOR sotr_head-alias_name.

  DATA : lv_lines TYPE i.

  CLEAR : lt_sels, ls_sels.
  CLEAR : lr_uikey, lr_uikey[].

  CALL METHOD g_grid1->get_selected_rows
    IMPORTING
      et_index_rows = lt_sels.


  DESCRIBE TABLE lt_sels[] LINES lv_lines.

  IF lv_lines = 0 .
    MESSAGE i001 WITH '라인 선택하세요.'.
    EXIT.
  ENDIF.

  LOOP AT lt_sels INTO ls_sels.
    READ TABLE gt_data1 INDEX ls_sels-index.
    IF sy-subrc = 0.
      lr_uikey-sign   = 'I'.
      lr_uikey-option = 'EQ'.
      lr_uikey-low    = gt_data1-otr_key.
      APPEND lr_uikey.
    ENDIF.
  ENDLOOP.

  SUBMIT zcmrk910 WITH p_paket EQ p_paket WITH s_uikey IN lr_uikey[] AND RETURN.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_uselist_source
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_uselist_source .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_scouce_scan
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_DATA1>
*&---------------------------------------------------------------------*
FORM display_scouce_scan  USING    ps_data LIKE gt_data1.

  DATA lv_sstring TYPE text255.

  PERFORM display_status(zcms0) USING '' 'OTR 사용처 소스 검색 중...'.

  RANGES lr_str FOR lv_sstring.
  RANGES : lr_devc FOR tadir-devclass,
           lr_objc FOR tadir-obj_name.

  lr_str[]  = VALUE #( sign = 'I' option = 'EQ' ( low = ps_data-alias_name  ) ).
  lr_devc[] = VALUE #( sign = 'I' option = 'EQ' ( low = p_paket ) ).
  lr_objc[] = VALUE #( sign = 'I' option = 'CP' ( low = |ZCL_U4A_APP*| ) ).

  SUBMIT rs_abap_source_scan WITH sstring  IN lr_str[]
                             WITH devclass IN lr_devc[]
                             WITH p_class  IN lr_objc[]
                             AND RETURN .

ENDFORM.
