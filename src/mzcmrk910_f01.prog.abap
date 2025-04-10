*&---------------------------------------------------------------------*
*& Include          MZCMRK990_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data_select
*&---------------------------------------------------------------------*
FORM get_data_select .

  DATA lt_t0015 TYPE TABLE OF /u4a/s9999.
  DATA lv_index TYPE i.

  CLEAR gt_data[].

  SELECT * INTO TABLE @DATA(lt_/u4a/t0010)
           FROM /u4a/t0010
           WHERE packg = @p_paket
           AND   appid IN @s_appid.

  CHECK sy-subrc = 0.

*--------------------------------------------------------------------*
*//___ # 03.04.2025 11:13:23 # get UIOBJ OTR __//
*--------------------------------------------------------------------*
  LOOP AT lt_/u4a/t0010 ASSIGNING FIELD-SYMBOL(<fs_t0010>).

    CLEAR lt_t0015[].

    SELECT SINGLE * INTO @DATA(ls_/u4a/t0011)
           FROM /u4a/t0011
           WHERE appid = @<fs_t0010>-appid.

    CHECK sy-subrc = 0.

    IMPORT tab = lt_t0015 FROM DATABASE /u4a/t0015(oa) ID ls_/u4a/t0011-guinr.

    DELETE lt_t0015 WHERE f05 NS '$OTR:'.
    DELETE lt_t0015 WHERE f05 NOT IN s_uikey.

    LOOP AT lt_t0015 ASSIGNING FIELD-SYMBOL(<fs_t0015>).
      ADD 1 TO lv_index.
      gt_data-seqnr = lv_index.
      gt_data-appid = <fs_t0010>-appid.
      gt_data-appnm = <fs_t0010>-appnm.
      gt_data-clsid = <fs_t0010>-clsid.
      gt_data-uiobj = <fs_t0015>-f03.
      gt_data-uiotr = <fs_t0015>-f05.
      gt_data-uicat = <fs_t0015>-f09.
      gt_data-uiref = <fs_t0015>-f11.
      APPEND gt_data. CLEAR gt_data.
    ENDLOOP.

  ENDLOOP.


*--------------------------------------------------------------------*
*//___ # 03.04.2025 11:13:32 # get OTR Text __//
*--------------------------------------------------------------------*
  DATA lv_alias_name TYPE sotr_head-alias_name.
  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
    CLEAR lv_alias_name.
    <fs_data>-uiali = <fs_data>-uiotr.
    REPLACE ALL OCCURRENCES OF '$OTR:' IN <fs_data>-uiali WITH ''.

    SELECT  SINGLE  b~text INTO <fs_data>-uiotr_ko
              FROM sotr_head AS a
              JOIN sotr_text AS b
                ON a~concept = b~concept
             WHERE a~paket      = p_paket
               AND a~alias_name = <fs_data>-uiali
               AND b~langu      = '3'.

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

*         seqnr LIKE hrp1001-seqnr,
*         appid LIKE /u4a/t0010-appid,
*         appnm LIKE /u4a/t0010-appnm,
*         uiobj TYPE text100,  " UI OBJECT ID
*         uiotr TYPE text100,  " OTR
*         uicat TYPE text50,   " UI Category
*         uiref TYPE text50,   " UI Ref

  LOOP AT go_grid->fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).

    CASE <fs_fcat>-fieldname.
      WHEN 'SEQNR'.
        <fs_fcat>-reptext = '순번'.
      WHEN 'UIOBJ'.
        <fs_fcat>-reptext = 'UIOBJ ID' .
      WHEN 'UIOTR'.
        <fs_fcat>-reptext = 'OTR' .
        <fs_fcat>-emphasize = 'X'.
      WHEN 'UIALI'.
*        <fs_fcat>-hotspot = 'X'.

      WHEN 'UIOTR_KO'.
        <fs_fcat>-reptext = 'OTR 국문' .
        <fs_fcat>-emphasize = 'X'.
      WHEN 'UICAT'.
        <fs_fcat>-reptext = 'UI Category' .
      WHEN 'UIREF'.
        <fs_fcat>-reptext = 'UI Reference' .
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
  go_grid->layout->set_zebra( abap_false ).
  go_grid->layout->set_sel_mode( 'D' ).
  go_grid->layout->set_no_toolbar( abap_false ).
  go_grid->layout->set_no_rowins( abap_true ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_sort
*&---------------------------------------------------------------------*
FORM grid_sort .
*  go_grid->sort = VALUE #( ( fieldname = 'OBJ_ID' up = abap_true )
*                           ( fieldname = 'UNAME'  up = abap_true )
*                           ( fieldname = 'DATUM'  down = abap_true )
*                           ( fieldname = 'UZEIT'  down = abap_true ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_gui_status
*&---------------------------------------------------------------------*
FORM grid_gui_status .

  go_grid->gui_status->fully_dynamic = abap_true.
  go_grid->exclude_functions = go_grid->gui_status->edit_buttons( ).

*  go_grid->gui_status->add_button(
*    iv_button = zcl_falv_dynamic_status=>b_01
*    iv_text   = '로그 삭제'
*    iv_icon   = icon_delete ).
*  go_grid->gui_status->add_button(
*    iv_button = zcl_falv_dynamic_status=>b_02
*    iv_text   = '로그 삭제2'
*    iv_icon   = icon_delete ).
*
*  go_grid->gui_status->hide_button( zcl_falv_dynamic_status=>b_02 ).

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

  RANGES : lr_devc FOR tadir-devclass,
           lr_objc FOR tadir-obj_name.

  READ TABLE gt_data INDEX p_row ASSIGNING FIELD-SYMBOL(<fs_data>).
  CHECK sy-subrc = 0.

  lr_devc[] = VALUE #( sign = 'I' option = 'EQ' ( low = p_paket ) ).
  lr_objc[] = VALUE #( sign = 'I' option = 'EQ' ( low = <fs_data>-clsid ) ).

  SUBMIT afx_code_scanner WITH s_devc  IN lr_devc[]
                          WITH s_rest  IN lr_objc[]
                          WITH p_strg1 EQ 'OTR'
                          WITH p_strg2 EQ <fs_data>-uiali
                          AND RETURN.


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
