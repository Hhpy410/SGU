*&---------------------------------------------------------------------*
*& Include          MZCMRK_DEMO1_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data_select
*&---------------------------------------------------------------------*
FORM get_data_select .

  SELECT * FROM sflight
    INTO CORRESPONDING FIELDS OF TABLE gt_data
    UP TO 1000 ROWS.

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
  PERFORM grid_toolbar_button.
  PERFORM grid_f4_field.
  PERFORM grid_ddlb.
  PERFORM grid_top_of_page.


  go_grid->display( ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_field_catalog
*&---------------------------------------------------------------------*
FORM grid_field_catalog .

**  LOOP AT go_grid->get_columns( ) ASSIGNING FIELD-SYMBOL(<fs_column>).
**    CASE <fs_column>->fieldname.
**      WHEN 'CARRID'.
**        <fs_column>->set_reptext( '항공사코드' )->set_edit( abap_true )->set_f4availabl( abap_true ).
**      WHEN 'CONNID'.
**        <fs_column>->set_reptext( '항공편 연결 번호' )->set_edit( abap_true )->set_f4availabl( abap_true ).
**      WHEN 'FLDATE'.
**        <fs_column>->set_reptext( '항공편 일자' ).
**      WHEN 'PRICE'.
**        <fs_column>->set_reptext( '항공 요금111' )->set_cfieldname( 'CURRENCY' )->set_do_sum( abap_true )->set_emphasize( 'C000' ).
**      WHEN 'CURRENCY'.
**        <fs_column>->set_reptext( '통화' )->set_hotspot( abap_true ).
**      WHEN 'PLANETYPE'.
**        <fs_column>->set_reptext( '항공기유형' )->set_edit( abap_true )->set_drdn_hndl( 1 ).
**      WHEN 'SEATSOCC'.
**        <fs_column>->set_no_out( abap_true ).
**    ENDCASE.
**
**    CHECK <fs_column>->get_no_out( ) IS INITIAL.
**    <fs_column>->set_scrtext_s( CONV #( <fs_column>->get_reptext( ) ) ).
**    <fs_column>->set_scrtext_m( CONV #( <fs_column>->get_reptext( ) ) ).
**    <fs_column>->set_scrtext_l( CONV #( <fs_column>->get_reptext( ) ) ).
**  ENDLOOP.

  LOOP AT go_grid->fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).

    CASE <fs_fcat>-fieldname.
      WHEN 'CARRID'.
        <fs_fcat>-reptext = '항공사 코드'.
        <fs_fcat>-edit = abap_true.
        <fs_fcat>-f4availabl = abap_true.
      WHEN 'CONNID'.
        <fs_fcat>-reptext = '항공편 연결 번호' .
        <fs_fcat>-f4availabl = abap_true.
        <fs_fcat>-edit = abap_true.
      WHEN 'FLDATE'.
        <fs_fcat>-reptext = '항공편 일자' .
      WHEN 'PRICE'.
        <fs_fcat>-reptext = '항공 요금111' .
        <fs_fcat>-cfieldname = 'CURRENCY'.
        <fs_fcat>-do_sum = abap_true.
        <fs_fcat>-emphasize = 'C000'.
      WHEN 'CURRENCY'.
        <fs_fcat>-reptext = '통화' .
        <fs_fcat>-hotspot = abap_true.
      WHEN 'PLANETYPE'.
        <fs_fcat>-reptext = '항공기유형' .
        <fs_fcat>-drdn_hndl = 1.
        <fs_fcat>-edit = abap_true.
      WHEN 'SEATSOCC'.
        <fs_fcat>-no_out = abap_true .
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_sort
*&---------------------------------------------------------------------*
FORM grid_sort .
  go_grid->sort = VALUE #(
                   ( fieldname = 'CARRID'   )
                   ( fieldname = 'CARRID'   )
                   ( fieldname = 'CONNID'  ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_gui_status
*&---------------------------------------------------------------------*
FORM grid_gui_status .

  go_grid->gui_status->fully_dynamic = abap_true.
  go_grid->exclude_functions = go_grid->gui_status->edit_buttons( ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_01
    iv_text   = 'Refresh'
    iv_icon   = icon_refresh ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_toolbar_button
*&---------------------------------------------------------------------*
FORM grid_toolbar_button .
  go_grid->add_button(
    iv_function = zcl_falv_dynamic_status=>b_02
    iv_icon     = icon_activate
    iv_text     = 'TEST' ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_DETAIL
*&---------------------------------------------------------------------*
FORM call_detail .

  SELECT * FROM sflight
    INTO CORRESPONDING FIELDS OF TABLE gt_data2
    WHERE currency = 'USD'.

  DATA(lo_grid2) = lcl_alv_grid=>create(
    EXPORTING
      i_popup  = abap_true
    CHANGING
      ct_table = gt_data2[]
  ).

  lo_grid2->display( ).

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

  LOOP AT po_data_changed->mt_mod_cells INTO DATA(ls_mod).
    CASE ls_mod-fieldname.
      WHEN 'CARRID'.
        READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<fs>) INDEX ls_mod-row_id.
        CHECK sy-subrc = 0.
        <fs>-carrid = ls_mod-value.
        CLEAR <fs>-carrname.
        SELECT SINGLE carrname FROM scarr
          INTO <fs>-carrname
          WHERE carrid = <fs>-carrid.
      WHEN 'CONNID'.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

  go_grid->set_frontend_layout( go_grid->lvc_layout ).
  go_grid->soft_refresh( ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form EV_user_command
*&---------------------------------------------------------------------*
FORM ev_user_command  USING p_ucomm   po_me TYPE REF TO lcl_alv_grid.

  CASE p_ucomm.
    WHEN zcl_falv_dynamic_status=>b_01.
      po_me->check_changed_data( ).
      MESSAGE 'BUTTON1' TYPE 'S'.

    WHEN zcl_falv_dynamic_status=>b_02.
      PERFORM call_detail.

    WHEN OTHERS.
  ENDCASE.

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
FORM ev_top_of_page  USING    po_dyndoc_id TYPE REF TO cl_dd_document.
  po_dyndoc_id->add_text( text = 'Top Of Page' ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EV_ON_F4
*&---------------------------------------------------------------------*
FORM ev_on_f4  USING    p_fieldname  p_fieldvalue  p_row.

  DATA lt_return TYPE TABLE OF ddshretval.

  CASE p_fieldname.
    WHEN 'CONNID'.
      SELECT carrid, connid, cityfrom, cityto FROM spfli
        INTO TABLE @DATA(lt_spfli).

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield        = 'CONNID'
          dynpprog        = sy-cprog
          dynpnr          = sy-dynnr
          value_org       = 'S'
        TABLES
          value_tab       = lt_spfli
          return_tab      = lt_return
        EXCEPTIONS
          parameter_error = 1
          no_values_found = 2
          OTHERS          = 3.
      CHECK lt_return IS NOT INITIAL.
      READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<fs>) INDEX p_row.
      CHECK sy-subrc = 0.
      <fs>-connid = lt_return[ 1 ]-fieldval.

    WHEN OTHERS.
  ENDCASE.

  go_grid->soft_refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_top_of_page
*&---------------------------------------------------------------------*
FORM grid_top_of_page .

*  go_grid->top_of_page_height = 50.
*  go_grid->show_top_of_page( ).

ENDFORM.
