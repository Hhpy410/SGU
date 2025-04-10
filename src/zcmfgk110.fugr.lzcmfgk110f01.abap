*----------------------------------------------------------------------*
***INCLUDE LZCMFGK110F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data_select
*&---------------------------------------------------------------------*
FORM get_data_select USING p_keydt p_orgcd p_flag.

  DATA lt_org TYPE TABLE OF qcat_stru.
  DATA lt_temp LIKE TABLE OF gt_data.
  DATA lt_temp2 LIKE TABLE OF gt_data.
  DATA ls_data LIKE LINE OF gt_data.
  DATA lr_org TYPE RANGE OF zcmt0101-map_cd2.
  DATA lt_olist TYPE RANGE OF hrobjid.
  DATA lt_sclist TYPE RANGE OF hrobjid.

  CLEAR : gt_data[], gt_data_all[].

  IF p_orgcd IS INITIAL.
    p_orgcd = '32000000'.
  ELSE.
    IF p_orgcd <> '32000000'.
      SELECT COUNT(*) FROM zcmt0101
        WHERE grp_cd = '100'
          AND map_cd2 = p_orgcd.
      IF sy-subrc <> 0.
        SELECT COUNT(*) FROM zcmt0101
          WHERE grp_cd = '109'
            AND map_cd2 = p_orgcd.
        IF sy-subrc <> 0.
          MESSAGE '유효한 소속을 입력하세요.' TYPE 'S' DISPLAY LIKE 'E'.
          RETURN.
        ENDIF.
      ENDIF.
      lr_org = VALUE #( ( sign = 'I' option = 'EQ' low = p_orgcd ) ).
    ENDIF.
  ENDIF.
  IF p_keydt IS INITIAL.
    p_keydt = sy-datum.
  ENDIF.

  CALL FUNCTION 'RHPH_STRUCTURE_READ'
    EXPORTING
      plvar             = '01'
      otype             = 'O'
      objid             = p_orgcd
      wegid             = 'ORGEH' "하위소속
      begda             = p_keydt
      endda             = p_keydt
    TABLES
      stru_tab          = lt_org
    EXCEPTIONS
      catalogue_problem = 1
      root_not_found    = 2
      wegid_not_found   = 3
      OTHERS            = 4.
  IF lines( lt_org ) > 1.
    DELETE lt_org WHERE level = '1'.
  ENDIF.

  DELETE lt_org WHERE stext CP '*행정팀'.
  DELETE lt_org WHERE stext CP '*센터'.

  CHECK lt_org IS NOT INITIAL.
  SORT lt_org BY pup_objid seqnr.

  SELECT * FROM zcmt0101
    INTO TABLE @DATA(lt_0101)
    WHERE grp_cd = '100'
      AND map_cd2 IN @lr_org.
  SORT lt_0101 BY map_cd2.

*레벨2
  LOOP AT lt_0101 INTO DATA(ls_0101).
    ls_data-objid2 = ls_0101-map_cd2.
    ls_data-org_cd2 = ls_0101-org_cd.
    ls_data-short2 = ls_0101-short.
    ls_data-stext2 = ls_0101-com_nm.
    ls_data-otype2 = 'O'.
    ls_data-level = '2'.
    ls_data-icon = icon_collapse.
    APPEND ls_data TO lt_temp.
    CLEAR ls_data.
  ENDLOOP.

*레벨3
  LOOP AT lt_temp INTO DATA(ls_temp).
    MOVE-CORRESPONDING ls_temp TO ls_data.
    APPEND ls_data TO lt_temp2.

    READ TABLE lt_org WITH KEY pup_objid = ls_data-objid2 BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      LOOP AT lt_org INTO DATA(ls_org) FROM sy-tabix.
        IF ls_org-pup_objid <> ls_data-objid2.
          EXIT.
        ENDIF.

        ls_data-pup_objid = ls_data-objid2.
        ls_data-objid3 = ls_org-objid.
        ls_data-stext3 = ls_org-stext.
        ls_data-otype3 = ls_org-otype.
        ls_data-seqnr = ls_org-seqnr.
        ls_data-level = '3'.
        ls_data-icon = icon_collapse.
        APPEND ls_data TO lt_temp2.
      ENDLOOP.
    ENDIF.

    CASE ls_data-objid2.
      WHEN '30000002'.  "학부

      WHEN OTHERS.  "대학원
        zcmcl000=>get_struc_get(
          EXPORTING
            iv_act_otype    = 'O'
            iv_act_objid    = ls_data-objid2
            iv_act_wegid    = 'O-SC'
          IMPORTING
            et_result_objec = DATA(lt_result)
            et_result_struc = DATA(lt_struc)
        ).
        READ TABLE lt_struc INTO DATA(ls_struc) WITH KEY objid = ls_data-objid2.
        IF sy-subrc = 0.
          DELETE lt_struc WHERE pup <> ls_struc-seqnr.
        ENDIF.

        LOOP AT lt_struc INTO ls_struc WHERE otype = 'SC'.
          READ TABLE lt_result INTO DATA(ls_result) WITH KEY otype = ls_struc-otype objid = ls_struc-objid.
          ls_data-pup_objid = ls_data-objid2.
          ls_data-otype3 = ls_result-otype.
          ls_data-objid3 = ls_result-objid.
          ls_data-stext3 = ls_result-short.
          ls_data-seqnr = sy-tabix.
          ls_data-level = '3'.
          CLEAR ls_data-icon.
          APPEND ls_data TO gt_data.
          CLEAR ls_result.
*대학원 sc
          lt_sclist = VALUE #( BASE lt_sclist ( sign = 'I' option = 'EQ' low = ls_data-objid3 ) ).
        ENDLOOP.
    ENDCASE.

    CLEAR:lt_result, ls_data.
  ENDLOOP.

*레벨4
  LOOP AT lt_temp2 INTO ls_temp.
    MOVE-CORRESPONDING ls_temp TO ls_data.
    APPEND ls_data TO gt_data.

    CHECK ls_data-objid3 IS NOT INITIAL.

    CASE ls_data-objid2.
      WHEN '30000002'.  "학부
        READ TABLE lt_org WITH KEY pup_objid = ls_data-objid3 BINARY SEARCH TRANSPORTING NO FIELDS.
        CHECK sy-subrc = 0.
        LOOP AT lt_org INTO ls_org FROM sy-tabix.
          IF ls_org-pup_objid <> ls_data-objid3.
            EXIT.
          ENDIF.

          ls_data-pup_objid = ls_data-objid3.
          ls_data-otype4 = ls_org-otype.
          ls_data-objid4 = ls_org-objid.
          ls_data-stext4 = ls_org-stext.
          ls_data-seqnr = ls_org-seqnr.
          ls_data-level = '4'.
          CLEAR ls_data-icon.
          APPEND ls_data TO gt_data.
*학과 O
          lt_olist = VALUE #( BASE lt_olist ( sign = 'I' option = 'EQ' low = ls_data-objid4 ) ).
        ENDLOOP.

      WHEN OTHERS.  "대학원
        zcmcl000=>get_struc_get(
          EXPORTING
            iv_act_otype    = 'O'
            iv_act_objid    = ls_data-objid3
            iv_act_wegid    = 'O-SC'
          IMPORTING
            et_result_objec = lt_result ).
        LOOP AT lt_result INTO ls_result WHERE otype = 'SC'.

          ls_data-pup_objid = ls_data-objid3.
          ls_data-otype4 = ls_result-otype.
          ls_data-objid4 = ls_result-objid.
          ls_data-stext4 = ls_result-short.
          ls_data-seqnr = sy-tabix.
          ls_data-level = '4'.
          CLEAR ls_data-icon.
          APPEND ls_data TO gt_data.

*대학원 sc
          lt_sclist = VALUE #( BASE lt_sclist ( sign = 'I' option = 'EQ' low = ls_data-objid4 ) ).
        ENDLOOP.
    ENDCASE.

    CLEAR:lt_result, ls_data.
  ENDLOOP.

  CASE p_flag.
    WHEN '1'.
      DELETE gt_data WHERE objid2 <> '30000002'.
    WHEN '2'.
      DELETE gt_data WHERE objid2 = '30000002'.
    WHEN OTHERS.
  ENDCASE.

  SORT lt_olist.
  DELETE ADJACENT DUPLICATES FROM lt_olist COMPARING ALL FIELDS.
  SORT lt_sclist.
  DELETE ADJACENT DUPLICATES FROM lt_sclist COMPARING ALL FIELDS.

*SC 카운트
  SELECT sc_objid1 AS sc_id, COUNT(*) AS cnt FROM zcmta446
    WHERE st_stscd IN ( '1000', '2000' )
      AND sc_objid1 IN @lt_sclist
    GROUP BY sc_objid1
    UNION ALL
  SELECT sc_objid2 AS sc_id, COUNT(*) AS cnt FROM zcmta446
    WHERE st_stscd IN ( '1000', '2000' )
      AND sc_objid2 IN @lt_sclist
    GROUP BY sc_objid2
    UNION ALL
  SELECT sc_objid3 AS sc_id, COUNT(*) AS cnt FROM zcmta446
    WHERE st_stscd IN ( '1000', '2000' )
      AND sc_objid3 IN @lt_sclist
    GROUP BY sc_objid3
  INTO TABLE @DATA(lt_sc_cnt).
  SORT lt_sc_cnt BY sc_id.

*O 카운트
  SELECT objid AS sc_id, sobid AS o_id, COUNT(*) AS cnt FROM hrp1001 AS a
    INNER JOIN zcmta446 AS b
    ON a~objid = b~sc_objid1
    WHERE a~otype = 'SC'
      AND a~begda <= @p_keydt
      AND a~endda >= @p_keydt
      AND a~sclas = 'O'
      AND a~sobid IN @lt_olist
      AND b~st_stscd IN ( '1000', '2000' )
    GROUP BY sobid, objid
    UNION ALL
  SELECT objid AS sc_id, sobid AS o_id, COUNT(*) AS cnt FROM hrp1001 AS a
    INNER JOIN zcmta446 AS b
    ON a~objid = b~sc_objid2
    WHERE a~otype = 'SC'
      AND a~begda <= @p_keydt
      AND a~endda >= @p_keydt
      AND a~sclas = 'O'
      AND a~sobid IN @lt_olist
      AND b~st_stscd IN ( '1000', '2000' )
    GROUP BY sobid, objid
    UNION ALL
  SELECT objid AS sc_id, sobid AS o_id, COUNT(*) AS cnt FROM hrp1001 AS a
    INNER JOIN zcmta446 AS b
    ON a~objid = b~sc_objid3
    WHERE a~otype = 'SC'
      AND a~begda <= @p_keydt
      AND a~endda >= @p_keydt
      AND a~sclas = 'O'
      AND a~sobid IN @lt_olist
      AND b~st_stscd IN ( '1000', '2000' )
    GROUP BY sobid, objid
    INTO TABLE @DATA(lt_o_sc_cnt).
  SORT lt_o_sc_cnt BY o_id sc_id.


  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs>).

    CASE <fs>-objid2.
      WHEN '30000002'.  "학과별 카운트
        CLEAR <fs>-cnt.
        READ TABLE lt_o_sc_cnt WITH KEY o_id = <fs>-objid4 BINARY SEARCH TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          LOOP AT lt_o_sc_cnt INTO DATA(ls_cnt) FROM sy-tabix.
            IF ls_cnt-o_id <> <fs>-objid4.
              EXIT.
            ENDIF.
            <fs>-cnt = <fs>-cnt + ls_cnt-cnt.
          ENDLOOP.
        ENDIF.

      WHEN OTHERS.  "대학원
        READ TABLE lt_sc_cnt INTO DATA(ls_sc_cnt) WITH KEY sc_id = <fs>-objid4 BINARY SEARCH.
        IF sy-subrc = 0.
          <fs>-cnt = ls_sc_cnt-cnt.
        ELSE.
          READ TABLE lt_sc_cnt INTO ls_sc_cnt WITH KEY sc_id = <fs>-objid3 BINARY SEARCH.
          IF sy-subrc = 0.
            <fs>-cnt = ls_sc_cnt-cnt.
          ENDIF.
        ENDIF.

    ENDCASE.
    CONDENSE <fs>-cnt.
    IF <fs>-cnt = '0'.
      CLEAR <fs>-cnt.
    ENDIF.

    CHECK <fs>-icon IS NOT INITIAL.
    CASE <fs>-level.
      WHEN '2'.
        READ TABLE gt_data WITH KEY pup_objid = <fs>-objid2 level = '3' TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          CLEAR <fs>-icon.
        ENDIF.
      WHEN '3'.
        READ TABLE gt_data WITH KEY pup_objid = <fs>-objid3 level = '4' TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          CLEAR <fs>-icon.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  SORT gt_data BY objid2 stext2 org_cd2 short2 otype3 objid3 stext3.

  gt_data_all[] = gt_data[].
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv_data
*&---------------------------------------------------------------------*
FORM grid_display_alv.

  go_grid ?= lcl_alv_grid=>create( EXPORTING i_popup = 'X' CHANGING ct_table = gt_data[] ).
  go_grid->title_v1 = |{ TEXT-tit } - { lines( gt_data ) }|.

  PERFORM grid_field_catalog.
  PERFORM grid_layout.
  PERFORM grid_sort.
  PERFORM grid_gui_status.
  PERFORM set_row_color.

  go_grid->display(
    EXPORTING
      iv_start_row    = 1
      iv_start_column = 1
      iv_end_row      = 30
      iv_end_column   = 130
  ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_field_catalog
*&---------------------------------------------------------------------*
FORM grid_field_catalog .


  LOOP AT go_grid->fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).

    CASE <fs_fcat>-fieldname.
      WHEN 'ICON'.
        <fs_fcat>-reptext = icon_display_tree.
        <fs_fcat>-outputlen = 4.
        <fs_fcat>-icon = 'X'.
        <fs_fcat>-hotspot = 'X'.
*      WHEN 'OBJID2'.
*        <fs_fcat>-reptext = '소속1'.
*        <fs_fcat>-outputlen = 10.
*      WHEN 'STEXT2'.
*        <fs_fcat>-reptext = '소속명1'.
*        <fs_fcat>-outputlen = 25.
      WHEN 'ORG_CD2'.
        <fs_fcat>-reptext = '소속구분'.
        <fs_fcat>-outputlen = 8.
      WHEN 'SHORT2'.
        <fs_fcat>-reptext = '소속구분명'.
        <fs_fcat>-outputlen = 8.
      WHEN 'OTYPE3'.
        <fs_fcat>-reptext = 'OTYPE2'.
        <fs_fcat>-outputlen = 3.
      WHEN 'OBJID3'.
        <fs_fcat>-reptext = '소속2'.
        <fs_fcat>-outputlen = 10.
      WHEN 'STEXT3'.
        <fs_fcat>-reptext = '소속명2'.
        <fs_fcat>-outputlen = 25.
      WHEN 'OTYPE4'.
        <fs_fcat>-reptext = 'OTYPE3'.
        <fs_fcat>-outputlen = 3.
      WHEN 'OBJID4'.
        <fs_fcat>-reptext = '소속3'.
        <fs_fcat>-outputlen = 10.
      WHEN 'STEXT4'.
        <fs_fcat>-reptext = '소속명3'.
        <fs_fcat>-outputlen = 25.
      WHEN 'CNT'.
        <fs_fcat>-reptext = '학생수'.
        <fs_fcat>-outputlen = 5.
      WHEN 'LEVEL'.
        <fs_fcat>-reptext = '레벨'.
        <fs_fcat>-outputlen = 5.
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

*  go_grid->layout->set_cwidth_opt( abap_true ).
*  go_grid->layout->set_zebra( abap_true ).
  go_grid->layout->set_sel_mode( 'D' ).
  go_grid->layout->set_no_toolbar( abap_false ).
  go_grid->layout->set_info_fname( 'ROW_COLOR' ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_sort
*&---------------------------------------------------------------------*
FORM grid_sort .
  go_grid->sort = VALUE #(
    ( fieldname = 'OBJID2'  up = abap_true subtot = abap_true )
    ( fieldname = 'STEXT2'  up = abap_true subtot = abap_true )
    ( fieldname = 'ORG_CD2' up = abap_true subtot = abap_true )
    ( fieldname = 'SHORT2'  up = abap_true subtot = abap_true )
    ( fieldname = 'OTYPE3'  up = abap_true subtot = abap_true )
    ( fieldname = 'OBJID3'  up = abap_true subtot = abap_true )
    ( fieldname = 'STEXT3'  up = abap_true subtot = abap_true )
  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_gui_status
*&---------------------------------------------------------------------*
FORM grid_gui_status .

  go_grid->gui_status->fully_dynamic = abap_true.
  go_grid->exclude_functions = go_grid->gui_status->edit_buttons( ).

  APPEND cl_gui_alv_grid=>mc_fc_sort TO go_grid->exclude_functions.
  APPEND cl_gui_alv_grid=>mc_fc_sort_asc TO go_grid->exclude_functions.
  APPEND cl_gui_alv_grid=>mc_fc_sort_dsc TO go_grid->exclude_functions.
  APPEND cl_gui_alv_grid=>mc_fc_filter TO go_grid->exclude_functions.
  APPEND cl_gui_alv_grid=>mc_fc_subtot TO go_grid->exclude_functions.
  APPEND cl_gui_alv_grid=>mc_fc_sum TO go_grid->exclude_functions.
  APPEND cl_gui_alv_grid=>mc_fc_average TO go_grid->exclude_functions.
  APPEND cl_gui_alv_grid=>mc_fc_count TO go_grid->exclude_functions.
  APPEND cl_gui_alv_grid=>mc_fc_maximum TO go_grid->exclude_functions.
  APPEND cl_gui_alv_grid=>mc_fc_minimum TO go_grid->exclude_functions.
  APPEND cl_gui_alv_grid=>mc_mb_variant TO go_grid->exclude_functions.

*  go_grid->layout->set_no_toolbar( abap_true ).
  go_grid->add_button(
    iv_function = zcl_falv_dynamic_status=>b_01
    iv_icon     = icon_collapse_all
    iv_text     = '' ).
*  go_grid->add_button(
*    iv_function = zcl_falv_dynamic_status=>b_02
*    iv_icon     = icon_expand_all
*    iv_text     = '' ).



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

  CASE p_ucomm.
    WHEN zcl_falv_dynamic_status=>b_01.
      PERFORM expand_all.

    WHEN zcl_falv_dynamic_status=>b_02.
      gt_data[] = gt_data_all[].

    WHEN 'CONTINUE'.
      go_grid->get_selected_rows( IMPORTING et_index_rows = DATA(lt_rows) ).
      CASE gv_multi.
        WHEN 'X'.
          IF lines( lt_rows ) IS INITIAL.
            MESSAGE i318(zcm01).
            RETURN.
          ENDIF.
        WHEN OTHERS.
          IF lines( lt_rows ) <> 1.
            MESSAGE i328(zcm01).
            RETURN.
          ENDIF.
      ENDCASE.

      CLEAR gt_orgeh[].
      LOOP AT lt_rows INTO DATA(ls_row).
        READ TABLE gt_data INTO DATA(ls_data) INDEX ls_row-index.
        CHECK sy-subrc = 0.

        PERFORM move_return USING ls_data.
      ENDLOOP.
      CHECK gt_orgeh[] IS NOT INITIAL.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

  PERFORM set_row_color.
  go_grid->set_sort_criteria( go_grid->sort ).
  go_grid->soft_refresh( ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ev_hotspot_click
*&---------------------------------------------------------------------*
FORM ev_hotspot_click  USING p_row p_fieldname.

  READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<fs>) INDEX p_row.

  CASE p_fieldname.
    WHEN 'ICON'.
      CASE <fs>-icon.
        WHEN icon_collapse. "접기
          <fs>-icon = icon_expand.
          CASE <fs>-level.
            WHEN '2'.
              DELETE gt_data WHERE objid2 = <fs>-objid2 AND objid3 IS NOT INITIAL.
            WHEN '3'.
              DELETE gt_data WHERE pup_objid = <fs>-objid3.
          ENDCASE.

        WHEN icon_expand. "펼치기
          <fs>-icon = icon_collapse.

          CASE <fs>-level.
            WHEN '2'.
              PERFORM collapse_level2 USING <fs>-objid2 p_row.

            WHEN '3'.
              PERFORM collapse_level3 USING <fs>-objid3 p_row.
          ENDCASE.
      ENDCASE.

    WHEN OTHERS.
  ENDCASE.

  PERFORM set_row_color.

  go_grid->soft_refresh( ).

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
*& Form SET_ROW_COLOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_row_color .

  LOOP AT gt_data INTO DATA(ls_data).
    CASE ls_data-level.
      WHEN '2'.
        go_grid->set_row_color( iv_color = 'C110' iv_row = sy-tabix ).
      WHEN '3'.
        go_grid->set_row_color( iv_color = 'C210' iv_row = sy-tabix ).
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ev_double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&---------------------------------------------------------------------*
FORM ev_double_click  USING    p_row.

  CLEAR gt_orgeh[].

  READ TABLE gt_data INTO DATA(ls_data) INDEX p_row.
  CHECK sy-subrc = 0.

  PERFORM move_return USING ls_data.
  CHECK gt_orgeh[] IS NOT INITIAL.

  LEAVE TO SCREEN 0.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form MOVE_RETURN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_DATA
*&---------------------------------------------------------------------*
FORM move_return  USING    ps_data STRUCTURE gt_data.

  IF ps_data-objid4 IS NOT INITIAL.
    gt_orgeh[] = VALUE #( BASE gt_orgeh ( objid = ps_data-objid4 stext = ps_data-stext4 otype = ps_data-otype4  ) ).
  ELSEIF ps_data-objid3 IS NOT INITIAL.
    gt_orgeh[] = VALUE #( BASE gt_orgeh ( objid = ps_data-objid3 stext = ps_data-stext3 otype = ps_data-otype3 ) ).
  ELSEIF ps_data-objid2 IS NOT INITIAL.
    gt_orgeh[] = VALUE #( BASE gt_orgeh ( objid = ps_data-objid2 stext = ps_data-stext2 otype = ps_data-otype2 ) ).
  ENDIF.

  CASE ps_data-objid2.
    WHEN '30000002'.
    WHEN OTHERS.
      DELETE gt_orgeh WHERE otype = 'O'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form expand_orgcd
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IV_EXPAND
*&---------------------------------------------------------------------*
FORM expand_orgcd  USING    pv_expand.

  DATA lv_row TYPE sy-tabix.

  CHECK pv_expand IS NOT INITIAL.

  PERFORM expand_all.

  READ TABLE gt_data WITH KEY objid2 = pv_expand ASSIGNING FIELD-SYMBOL(<fs>).
  IF sy-subrc = 0.
    <fs>-icon = icon_collapse.
    lv_row = sy-tabix.
    PERFORM collapse_level2 USING pv_expand lv_row.

    UNASSIGN <fs>.
  ELSE.
    READ TABLE gt_data_all INTO DATA(ls_all) WITH KEY objid3 = pv_expand.
    CHECK sy-subrc = 0.

    READ TABLE gt_data WITH KEY objid2 = ls_all-objid2 ASSIGNING <fs>.
    CHECK sy-subrc = 0.
    <fs>-icon = icon_collapse.
    lv_row = sy-tabix.
    PERFORM collapse_level2 USING ls_all-objid2 lv_row.

    UNASSIGN <fs>.

    READ TABLE gt_data WITH KEY objid3 = pv_expand ASSIGNING <fs>.
    CHECK sy-subrc = 0.
    <fs>-icon = icon_collapse.
    lv_row = sy-tabix.
    PERFORM collapse_level3 USING pv_expand lv_row.

    UNASSIGN <fs>.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXPAND_ALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM expand_all .

  CLEAR gt_data[].
  gt_data[] = gt_data_all[].
  DELETE gt_data WHERE level <> '2'.
  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs>).
    IF <fs>-icon IS NOT INITIAL.
      <fs>-icon = icon_expand.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form COLLAPSE_LEVEL2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS>_OBJID2
*&---------------------------------------------------------------------*
FORM collapse_level2  USING    p_objid2 pv_row.
  DATA lv_index TYPE i.
  DATA lv_append TYPE i.

  CLEAR : lv_append, lv_index.

  LOOP AT gt_data_all INTO DATA(ls_all) WHERE objid2 = p_objid2.
    CHECK ls_all-objid3 IS NOT INITIAL.
    CHECK ls_all-objid4 IS INITIAL.
    lv_index = lv_index + 1.
    lv_append = pv_row + lv_index.
    IF ls_all-icon IS NOT INITIAL.
      ls_all-icon = icon_expand.
    ENDIF.
    INSERT ls_all INTO gt_data INDEX lv_append.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form collapse_level3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS>_OBJID2
*&      --> P_ROW
*&---------------------------------------------------------------------*
FORM collapse_level3  USING    p_objid3
                               p_row.
  DATA lv_index TYPE i.
  DATA lv_append TYPE i.

  CLEAR : lv_append, lv_index.

  LOOP AT gt_data_all INTO DATA(ls_all) WHERE pup_objid = p_objid3.
    lv_index = lv_index + 1.
    lv_append = p_row + lv_index.
    INSERT ls_all INTO gt_data INDEX lv_append.
  ENDLOOP.
ENDFORM.
