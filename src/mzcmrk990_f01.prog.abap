*&---------------------------------------------------------------------*
*& Include          MZCMRK990_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data_select
*&---------------------------------------------------------------------*
FORM get_data_select .

  CLEAR gt_data[].
  SELECT * FROM zcmtk990
    INTO TABLE @DATA(lt_990)
    WHERE obj_id IN @s_obj
      AND datum IN @s_datum
      AND uname IN @s_uname.

  CHECK lt_990[] IS NOT INITIAL.

  SELECT tcode, ttext FROM tstct AS a
    INNER JOIN @lt_990 AS b
    ON a~tcode = b~obj_id
    WHERE sprsl = @sy-langu
    INTO TABLE @DATA(lt_obj).

  SELECT application_name, description FROM wdy_applicationt AS a
    INNER JOIN @lt_990 AS b
    ON a~application_name = b~obj_id
    WHERE langu = @sy-langu
    APPENDING TABLE @lt_obj.
  SORT lt_obj BY tcode.

  LOOP AT lt_990 INTO DATA(ls_990).

    MOVE-CORRESPONDING ls_990 TO gt_data.

    READ TABLE lt_obj INTO DATA(ls_obj) WITH KEY tcode = gt_data-obj_id BINARY SEARCH.
    IF sy-subrc = 0.
      gt_data-obj_nm = ls_obj-ttext.
    ENDIF.

    IF gt_data-data_str IS NOT INITIAL.
      gt_data-btn1 = '조회'.
    ENDIF.

    APPEND gt_data.
    CLEAR gt_data.
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
      WHEN 'OBJ_ID'.
        <fs_fcat>-reptext = '프로그램'.
      WHEN 'OBJ_NM'.
        <fs_fcat>-reptext = '프로그램명' .
      WHEN 'LOG_DESC'.
        <fs_fcat>-reptext = '로그구분' .
      WHEN 'DATUM'.
        <fs_fcat>-reptext = '일자' .
      WHEN 'UZEIT'.
        <fs_fcat>-reptext = '시간' .
      WHEN 'UNAME'.
        <fs_fcat>-reptext = '사용자' .
      WHEN 'TYPE'.
        <fs_fcat>-reptext = '메세지유형' .
      WHEN 'MSG'.
        <fs_fcat>-reptext = '메세지' .
      WHEN 'DATA_STR'.
        <fs_fcat>-reptext = '로그데이터' .
        <fs_fcat>-hotspot = 'X'.
      WHEN 'BTN1'.
        <fs_fcat>-reptext = '상세' .
        <fs_fcat>-hotspot = 'X'.
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
  go_grid->sort = VALUE #( ( fieldname = 'OBJ_ID' up = abap_true )
                           ( fieldname = 'UNAME'  up = abap_true )
                           ( fieldname = 'DATUM'  DOWN = abap_true )
                           ( fieldname = 'UZEIT'  DOWN = abap_true ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_gui_status
*&---------------------------------------------------------------------*
FORM grid_gui_status .

  go_grid->gui_status->fully_dynamic = abap_true.
  go_grid->exclude_functions = go_grid->gui_status->edit_buttons( ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_01
    iv_text   = '로그 삭제'
    iv_icon   = icon_delete ).
  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_02
    iv_text   = '로그 삭제2'
    iv_icon   = icon_delete ).

  go_grid->gui_status->hide_button( zcl_falv_dynamic_status=>b_02 ).

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

  DATA lt_val LIKE TABLE OF sval.
  DATA lv_datum TYPE datum.
  DATA lv_ret.

  CASE p_ucomm.
    WHEN zcl_falv_dynamic_status=>b_01. "로그삭제

      lt_val = VALUE #( ( value = '06' fieldname = 'MON_PA' tabname = 'VIAKUV' field_obl = 'X' fieldtext = 'N월 전' ) ).

      CALL FUNCTION 'POPUP_GET_VALUES'
        EXPORTING
          popup_title = '로그 삭제(N월 전 데이터 삭제)'
        IMPORTING
          returncode  = lv_ret
        TABLES
          fields      = lt_val.
      CHECK lt_val IS NOT INITIAL.
      CHECK lv_ret <> 'A'.

      DATA(lv_mon) = `-` && lt_val[ 1 ]-value.

      CALL FUNCTION 'BKK_ADD_MONTH_TO_DATE'
        EXPORTING
          months  = lv_mon
          olddate = sy-datum
        IMPORTING
          newdate = lv_datum.

      SELECT * FROM zcmtk990
        INTO TABLE @DATA(lt_del)
        WHERE datum <= @lv_datum.
      IF sy-subrc = 0.
        DELETE zcmtk990 FROM TABLE lt_del.
        COMMIT WORK.
        MESSAGE '삭제되었습니다.' TYPE 'S'.
      ELSE.
        MESSAGE '삭제할 데이터가 존재하지 않습니다.' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.

      PERFORM get_data_select.

      go_grid->soft_refresh( ).

    WHEN zcl_falv_dynamic_status=>b_02.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ev_hotspot_click
*&---------------------------------------------------------------------*
FORM ev_hotspot_click  USING p_row p_fieldname.

  DATA lo_xml TYPE REF TO cl_xml_document .
  DATA l_xstring TYPE xstring.
  DATA lt_xml TYPE TABLE OF smum_xmltb.
  DATA lt_return TYPE TABLE OF bapiret2.
  DATA lt_fcat TYPE TABLE OF lvc_s_fcat WITH HEADER LINE.
  FIELD-SYMBOLS : <fs_tab>  TYPE table.
  FIELD-SYMBOLS : <fs_line>  TYPE any.
  DATA ld_line TYPE REF TO data.

  READ TABLE gt_data INTO DATA(ls_data) INDEX p_row.
  CHECK sy-subrc = 0.

  CASE p_fieldname.
    WHEN 'DATA_STR'.
      CHECK ls_data-data_str IS NOT INITIAL.
      CREATE OBJECT lo_xml.

      CALL METHOD lo_xml->parse_string
        EXPORTING
          stream = ls_data-data_str.
      CALL METHOD lo_xml->display.

    WHEN 'BTN1'.
      CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
        EXPORTING
          text   = ls_data-data_str
        IMPORTING
          buffer = l_xstring.
      CALL FUNCTION 'SMUM_XML_PARSE'
        EXPORTING
          xml_input = l_xstring
        TABLES
          xml_table = lt_xml
          return    = lt_return.

      DELETE lt_xml WHERE hier = 1 OR hier = 2 OR hier = 3.
      CHECK lt_xml IS NOT INITIAL.

      LOOP AT lt_xml INTO DATA(ls_xml).
        IF sy-tabix = 1.
          CONTINUE.
        ENDIF.
        IF ls_xml-hier = 4.
          EXIT.
        ENDIF.
        lt_fcat-fieldname = ls_xml-cname.
        lt_fcat-ref_table = 'TRM255'.
        lt_fcat-ref_field = 'TEXT'.
        APPEND lt_fcat.
        CLEAR lt_fcat.
      ENDLOOP.
      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog = lt_fcat[]
        IMPORTING
          ep_table        = DATA(ld_table).

      ASSIGN  ld_table->* TO <fs_tab>.
      CREATE DATA ld_line LIKE LINE OF <fs_tab>.
      ASSIGN  ld_line->* TO <fs_line>.

      LOOP AT lt_xml INTO ls_xml.
        IF ls_xml-hier = 4.
          CONTINUE.
        ENDIF.

        ASSIGN COMPONENT ls_xml-cname OF STRUCTURE <fs_line> TO FIELD-SYMBOL(<fs>).
        CHECK sy-subrc = 0.
        <fs> = ls_xml-cvalue.

        AT END OF hier.
          APPEND <fs_line> TO <fs_tab>.
          CLEAR <fs_line>.
        ENDAT.
      ENDLOOP.

      DATA(lo_grid2) = lcl_alv_grid=>create(
        EXPORTING
          i_popup  = abap_true
        CHANGING
          ct_table = <fs_tab>
      ).

      LOOP AT lo_grid2->fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).
        <fs_fcat>-reptext = <fs_fcat>-scrtext_l = <fs_fcat>-scrtext_m = <fs_fcat>-scrtext_s = <fs_fcat>-fieldname.
      ENDLOOP.
      lo_grid2->set_frontend_fieldcatalog( lo_grid2->fcat ).
      lo_grid2->layout->set_cwidth_opt( abap_true ).
      lo_grid2->title_v1 = |{ ls_data-obj_nm } - { ls_data-log_desc } - { lines( <fs_tab> ) } 건|.
      lo_grid2->display( ).
  ENDCASE.


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
