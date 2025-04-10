*&---------------------------------------------------------------------*
*& Include          MZCMRK_DEMO2_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM initialization .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_basic_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_basic_data .

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

  SELECT * UP TO 50 ROWS INTO CORRESPONDING FIELDS OF TABLE gt_data1
    FROM spfli.                                         "#EC CI_NOWHERE

  SELECT * UP TO 10 ROWS INTO CORRESPONDING FIELDS OF TABLE gt_data2
    FROM sflight.                                       "#EC CI_NOWHERE


*  sflight3[] = CORRESPONDING #( sflight2[] EXCEPT styles ).
  gt_data4[] = CORRESPONDING #( gt_data2[] EXCEPT styles ).

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_data3
           FROM hrp1000
           UP TO 50 ROWS
           WHERE plvar = '01'
           AND   otype = 'O'.

  DELETE gt_data4 FROM 31.

  gt_data5[] = gt_data4[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_falv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_COL
*&      --> P_ROW
*&---------------------------------------------------------------------*
FORM create_falv  USING    pv_col
                           pv_row.

  DATA lv_curr_col TYPE i.
  DATA lv_curr_row TYPE i.
  DATA lv_seq      TYPE i.
  DATA lv_tabnm(20).
  DATA lv_tabnm_tb(20).
  FIELD-SYMBOLS <fs_tab> TYPE STANDARD TABLE.

  IF g_splitter IS INITIAL.
    g_splitter = NEW cl_gui_splitter_container( columns = pv_col
                                                rows    = pv_row
*                                              parent = NEW cl_gui_custom_container( container_name = custom_container_name )
                                                parent = NEW cl_gui_docking_container(   style     = cl_gui_control=>ws_child
                                                                                         repid     = sy-cprog                          "현재 프로그램 ID
                                                                                         dynnr     = sy-dynnr                          "현재 화면번호
                                                                                         side      = 1 "CONTAINER POS
                                                                                         lifetime  = cl_gui_control=>lifetime_imode
                                                                                         extension = 3000 )
                                             ).

    g_splitter->set_row_height(
      EXPORTING
        id     = 1                 " Row ID
        height = '50'                 " Height
    ).

  ENDIF.


  DO pv_col TIMES.
    lv_curr_col = sy-index.

    DO pv_row TIMES.
      lv_curr_row = sy-index.

      ADD 1 TO lv_seq.

      " 각 Contrainer 구성 object
      PERFORM get_ref_cont_object USING  lv_seq.
      IF <fs_grid> IS ASSIGNED AND <fs_grid> IS NOT BOUND.

        " TAB NAME & ITAB NAME Assign
        lv_tabnm    = |{ gc_tabpatt }{ lv_seq }|.
        lv_tabnm_tb = |{ gc_tabpatt }{ lv_seq }[]|.

        ASSIGN (lv_tabnm_tb) TO <fs_tab>.
        IF <fs_tab> IS NOT ASSIGNED.
          MESSAGE e001(zcm01) WITH 'Internal Table Assign Error!!'.
          EXIT.
        ENDIF.

        <fs_grid> ?= zcl_falv=>create( EXPORTING i_subclass = cl_abap_classdescr=>describe_by_name( p_name = gc_falv )
                                                 i_handle = CONV slis_handl( lv_seq )
                                                 i_parent =  g_splitter->get_container(
                                                                                     row       = lv_curr_row
                                                                                     column    = lv_curr_col
                                                                                 )
                                        CHANGING ct_table = <fs_tab> ).

        CHECK  <fs_grid> IS BOUND.
        PERFORM create_grid_object USING <fs_grid> lv_tabnm lv_seq.
      ELSE.
*        <fs_grid>->soft_refresh( ).
        <fs_grid>->refresh_table_display(
          EXPORTING
            is_stable      = CONV #( 'XX' )
            i_soft_refresh = ''                " Without Sort, Filter, etc.
          EXCEPTIONS
            finished       = 1                " Display was Ended (by Export)
            OTHERS         = 2
        ).

      ENDIF.

    ENDDO.
  ENDDO.


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
*&---------------------------------------------------------------------*
FORM create_grid_object  USING    po_grid TYPE REF TO lcl_alv_grid
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

  po_grid->display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcatalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_TABNM
*&---------------------------------------------------------------------*
FORM set_fieldcatalog  USING  po_grid TYPE REF TO lcl_alv_grid  pv_tabnm.

  CASE pv_tabnm.
    WHEN 'GT_DATA1'.


    WHEN 'GT_DATA2'.
      po_grid->column( 'PAYMENTSUM' )->set_scrtext_l( iv_value = 'SSS 총계' )->set_scrtext_m( iv_value = 'SSS 총계' ).

      po_grid->column( 'SEATSMAX' )->set_hotspot( abap_true ).

      po_grid->column( 'SEATSMAX_B' )->set_edit( iv_value = abap_true ).


    WHEN 'GT_DATA3'.

    WHEN 'GT_DATA4'.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_exclude_code
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_TABNM
*&---------------------------------------------------------------------*
FORM make_exclude_code  USING  po_grid TYPE REF TO lcl_alv_grid  pv_tabnm.


  po_grid->exclude_functions  = po_grid->gui_status->edit_buttons( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_TABNM
*&---------------------------------------------------------------------*
FORM set_layout  USING  po_grid TYPE REF TO lcl_alv_grid  pv_tabnm.

  "change some row colors
*    po_grid->layout->set_sel_mode( iv_value = 'D' ).
*    po_grid->layout->set_grid_title( 'FALV1 TITLE' ).
*    po_grid->layout->set_info_fname( 'ROW_COLOR' ).


  "change some cell colors.
*    po_grid->layout->set_ctab_fname( 'CELL_COLOR' ).


*    po_grid->layout->set_stylefname( 'STYLES' ).

  po_grid->set_editable( iv_modify = abap_true ).

  CASE pv_tabnm.
    WHEN 'GT_DATA1'.
      po_grid->layout->set_sel_mode( iv_value = 'D' ).
      po_grid->layout->set_grid_title( 'FALV1 TITLE' ).
      po_grid->layout->set_info_fname( 'ROW_COLOR' ).
      po_grid->layout->set_ctab_fname( 'CELL_COLOR' ).


    WHEN 'GT_DATA2'.
      po_grid->layout->set_stylefname( 'STYLES' ).

      DO 20 TIMES.
        po_grid->set_cell_disabled(
          EXPORTING
            iv_fieldname = 'SEATSMAX_B'
            iv_row       = 2 * sy-index
        ).
      ENDDO.

    WHEN 'GT_DATA3'.
      po_grid->layout->set_stylefname( 'STYLES' ).
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
FORM create_dropdown  USING    po_grid TYPE REF TO lcl_alv_grid
                               pv_tabnm.

  DATA: lt_listbox TYPE lvc_t_dral.

  SELECT 1 AS handle, planetype AS int_value, planetype AS value FROM saplane
    INTO TABLE @lt_listbox
    WHERE producer = 'BOE'.

  CASE pv_tabnm.
    WHEN 'GT_DATA1'.

    WHEN 'GT_DATA2'.
      po_grid->column( 'PLANETYPE' )->set_edit( iv_value = abap_true )->set_drdn_hndl(
        EXPORTING
          iv_value             = 1
          it_drop_down_alias   = lt_listbox
      ).

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
FORM set_f4  USING    po_grid TYPE REF TO lcl_alv_grid
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
*&---------------------------------------------------------------------*
FORM set_variant  USING    po_grid TYPE REF TO lcl_alv_grid
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
*& Form set_Toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_GRID
*&      --> PV_TABNM
*&---------------------------------------------------------------------*
FORM set_toolbar  USING    po_grid TYPE REF TO lcl_alv_grid
                           pv_tabnm.

*    po_grid->add_button(
*        EXPORTING
*        iv_function  = 'BALV1'
*        iv_text      = 'ALV1 버튼'
*        iv_icon      = icon_abc
*        ).

  CASE pv_tabnm.
    WHEN 'GT_DATA1'.
      po_grid->add_button(
        EXPORTING
          iv_function = 'BALV1'
          iv_text     = 'SetStyle 버튼'
          iv_icon     = icon_abc
      ).

    WHEN 'GT_DATA2'.
      po_grid->add_button(
        EXPORTING
          iv_function = 'BALV2'
          iv_text     = 'Add Line 버튼'
          iv_icon     = icon_finite
      ).

    WHEN 'GT_DATA3'.

    WHEN 'GT_DATA4'.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form show_top_of_page
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_GRID
*&      --> PV_TABNM
*&---------------------------------------------------------------------*
FORM show_top_of_page  USING    po_grid TYPE REF TO lcl_alv_grid
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
*& Form grid_data_changed
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ME
*&      --> ER_DATA_CHANGED
*&      --> E_ONF4
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM grid_data_changed  USING    po_grid TYPE REF TO lcl_alv_grid
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
          CASE ls_mod_cells-fieldname.
            WHEN 'REQAMT'.
              CONDENSE ls_mod_cells-value.
              REPLACE ALL OCCURRENCES OF ',' IN ls_mod_cells-value WITH ''.
              UNASSIGN <fs_modi>.
              ASSIGN COMPONENT ls_mod_cells-fieldname OF STRUCTURE <fs_line> TO <fs_modi>.
              IF <fs_modi> IS ASSIGNED.
                " DOC -> SAP INPUT KRW
                TRY .
                    PERFORM conversion_amount(zcms0) USING '%INPUT'
                                                           'KRW'
                                                           ls_mod_cells-value
                                                           <fs_modi>.
                  CATCH cx_root INTO DATA(ls_root).
                    <fs_modi> = 0.

                ENDTRY.

              ENDIF.

              po_data_changed->modify_cell(
                i_row_id    = ls_mod_cells-row_id    " Row ID
                i_fieldname = ls_mod_cells-fieldname              " Field Name
                i_value     = <fs_modi>       " Value
              ).

            WHEN OTHERS.

          ENDCASE.

        ENDIF.
      ENDLOOP.

    WHEN g_grid2.
      LOOP AT po_data_changed->mt_mod_cells INTO ls_mod_cells.

        READ TABLE gt_data2 ASSIGNING FIELD-SYMBOL(<fs_line2>) INDEX ls_mod_cells-row_id.
        IF sy-subrc = 0.
          "체인지 필드 변경
          UNASSIGN <fs_value>.
          ASSIGN COMPONENT 'CHANGE_FG' OF STRUCTURE <fs_line2> TO <fs_value>.
          IF <fs_value> IS ASSIGNED.
            <fs_value> = 'X'.
          ENDIF.
        ENDIF.
      ENDLOOP.


    WHEN g_grid3.
    WHEN g_grid4.
    WHEN OTHERS.
  ENDCASE.

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
FORM line_double_click USING    po_grid TYPE REF TO lcl_alv_grid
                                 e_row TYPE lvc_s_row
                                 e_column TYPE lvc_s_col
                                 es_row_no TYPE lvc_s_roid.

  CASE po_grid.
    WHEN g_grid1.

      MESSAGE i001(zcm01) WITH 'evf_double_click1'.
    WHEN g_grid2.

      MESSAGE i001(zcm01) WITH 'evf_double_click2'.
    WHEN g_grid3.

      MESSAGE i001(zcm01) WITH 'evf_double_click3'.
    WHEN g_grid4.

      MESSAGE i001(zcm01) WITH 'evf_double_click4'.

    WHEN OTHERS.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_POPUP_FALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_popup_falv .

  g_grid5 ?= zcl_falv=>create( EXPORTING i_subclass = cl_abap_classdescr=>describe_by_name( p_name = gc_falv )
                                         i_handle   = '5'
                                         i_popup    = abap_true
                               CHANGING  ct_table   = gt_data5[] ).

  g_grid5->display( EXPORTING iv_start_row = 1 iv_start_column = 1 iv_end_row = 30 iv_end_column = 180 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_style_grid1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_style_grid1 USING po_grid TYPE REF TO lcl_alv_grid.
  DO 10 TIMES.
    po_grid->set_row_color(
      EXPORTING
        iv_color = 'C300'
        iv_row   = 2 * sy-index
    ).
  ENDDO.

  DO 10 TIMES.
    po_grid->set_cell_color(
      EXPORTING
        iv_fieldname = 'COUNTRYFR'
        iv_color     = VALUE #( col = 6 int = 0 inv = 0 )
        iv_row       = 5 * sy-index
    ).

    po_grid->set_cell_color(
      EXPORTING
        iv_fieldname = 'COUNTRYTO'
        iv_color     = VALUE #( col = 5 int = 0 inv = 0 )
        iv_row       = 5 * sy-index
    ).

  ENDDO.

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
FORM button_click  USING    po_grid TYPE REF TO lcl_alv_grid
                            ps_col_id TYPE lvc_s_col
                            ps_row_no TYPE lvc_s_roid.

  CASE po_grid.
    WHEN g_grid2.
      MESSAGE i003(zcm01) WITH ps_col_id-fieldname '라인-' ps_row_no-row_id.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
