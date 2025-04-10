*&---------------------------------------------------------------------*
*& Include          MZCMRK010_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form init_proc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_proc .

  PERFORM set_current_period.
  PERFORM set_ddlb.

  s_smstat-low = '01'.
  s_smstat-high = '03'.
  APPEND s_smstat.

  p_orgcd = '30000002'.

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
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_ddlb .

  DATA lt_vrm  TYPE vrm_values WITH HEADER LINE.
  DATA lr_org TYPE RANGE OF zcmt0101-map_cd2 WITH HEADER LINE.

* 정규학기만
  CALL FUNCTION 'ZCM_LIST_BOX_PYEAR_PERID'
    EXPORTING
      year_field  = 'P_PERYR'
      perid_field = 'P_PERID'.

  SELECT map_cd2, com_nm
    FROM zcmt0101
   WHERE grp_cd IN ('100')
    AND map_cd2 IN @lr_org
    INTO TABLE @lt_vrm.


  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'P_ORGCD'
      values          = lt_vrm[]
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_split_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_3
*&      --> P_1
*&---------------------------------------------------------------------*
FORM create_split_alv  USING    pv_col
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

    g_splitter->set_column_width(
      EXPORTING
        id    = 2
        width = '20'
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

        <fs_grid>->soft_refresh( ).
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

  PERFORM set_sort USING po_grid pv_tabnm.

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

      LOOP AT po_grid->fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).
        CASE <fs_fcat>-fieldname.
          WHEN 'BOOKDT'.
            <fs_fcat>-reptext = '예약일자'.
          WHEN 'BOOKTM'.
            <fs_fcat>-reptext = '예약시간'.
          WHEN 'BOOKCNT'.
            <fs_fcat>-reptext = '예약건수'.
          WHEN 'BOOKTPS'.
            <fs_fcat>-reptext = 'TPS'.
        ENDCASE.
        <fs_fcat>-scrtext_l = <fs_fcat>-scrtext_m = <fs_fcat>-scrtext_s = <fs_fcat>-reptext.
      ENDLOOP.

    WHEN 'GT_DATA3'.
      LOOP AT po_grid->fcat ASSIGNING <fs_fcat>.
        CASE <fs_fcat>-fieldname.
          WHEN 'BOOK_KAPZA'.
            <fs_fcat>-reptext = '전체정원'.
        ENDCASE.
        <fs_fcat>-scrtext_l = <fs_fcat>-scrtext_m = <fs_fcat>-scrtext_s = <fs_fcat>-reptext.
      ENDLOOP.
  ENDCASE.

  po_grid->set_frontend_fieldcatalog( po_grid->fcat ).
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

  po_grid->layout->set_cwidth_opt( 'A' ).
  po_grid->layout->set_zebra( abap_true ).
  po_grid->layout->set_no_rowins( abap_true ).
  po_grid->layout->set_sel_mode( 'D' ).

  CASE pv_tabnm.
    WHEN 'GT_DATA1'.
      po_grid->layout->set_grid_title( '학생별 수강신청' ).
    WHEN 'GT_DATA2'.
      po_grid->layout->set_grid_title( 'TPS' ).
    WHEN 'GT_DATA3'.
      po_grid->layout->set_grid_title( 'OverBooking' ).
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_sort
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_GRID
*&      --> PV_TABNM
*&---------------------------------------------------------------------*
FORM set_sort   USING  po_grid TYPE REF TO lcl_alv_grid  pv_tabnm.

  CASE pv_tabnm.
    WHEN 'GT_DATA1'.

    WHEN 'GT_DATA2'.
      po_grid->sort = VALUE #( ( fieldname = 'BOOKDT' ) ( fieldname = 'BOOKTM' ) ).

    WHEN 'GT_DATA3'.
  ENDCASE.

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

  CASE pv_tabnm.
    WHEN 'GT_DATA1'.
    WHEN 'GT_DATA2'.
    WHEN 'GT_DATA3'.
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
    WHEN 'GT_DATA2'.
    WHEN 'GT_DATA3'.
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
* 수강신청 정보..
  PERFORM get_data_hrpad506 .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_hrpad506
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data_hrpad506 .

  DATA lv_index TYPE numc2.
  DATA ls_data LIKE LINE OF gt_data1.

  CLEAR: gt_data1[], gt_data2[], gt_data3[], gv_cnt.

*하위 소속
  zcmcl000=>get_struc_get(
    EXPORTING
      iv_act_otype    = 'O'
      iv_act_objid    = p_orgcd
      iv_act_wegid    = 'ORGEH'
      iv_act_begda    = gv_keydt
      iv_act_endda    = gv_keydt
    IMPORTING
      et_result_objec = DATA(lt_obj)
  ).

*소속에 해당하는 학생
  SELECT a~otype, a~objid, a~sclas, a~sobid FROM hrp1001 AS a
    INNER JOIN @lt_obj AS b
    ON a~sobid = b~objid
    WHERE a~otype = 'ST'
      AND a~plvar = '01'
      AND a~begda <= @gv_keydt
      AND a~endda >= @gv_keydt
      AND a~sclas = 'O'
    INTO TABLE @DATA(lt_sto).
  CHECK lt_sto IS NOT INITIAL.

*수강신청 내역
  SELECT  a~objid AS st_id, a~sobid AS sm_id, b~packnumber AS se_id,
          b~peryr, b~perid, b~id, b~smstatus, b~bookdate, b~booktime
      FROM hrp1001 AS a
 INNER JOIN hrpad506 AS b
    ON  a~adatanr = b~adatanr
    INNER JOIN @lt_sto AS c
    ON a~otype = c~otype
    AND a~objid = c~objid
  WHERE a~plvar = '01'
    AND a~otype = 'ST'
    AND a~istat = '1'
    AND a~subty = 'A506'
    AND a~sclas = 'SM'
    AND b~peryr = @p_peryr
    AND b~perid = @p_perid
    AND b~smstatus IN @s_smstat
    AND b~bookdate IN @s_bookdt
    AND b~booktime IN @s_booktm
  INTO TABLE @DATA(lt_506).
  SORT lt_506 BY st_id.

  CHECK lt_506 IS NOT INITIAL.

  SELECT objid, short, stext FROM hrp1000
    INTO TABLE @DATA(lt_se)
    FOR ALL ENTRIES IN @lt_506
      WHERE plvar = '01'
        AND otype = 'SE'
        AND objid = @lt_506-se_id
        AND begda <= @gv_keydt
        AND endda >= @gv_keydt
        AND istat = '1'
        AND langu = @sy-langu.
  SORT lt_se BY objid.

  SELECT * FROM hrp9551
    INTO TABLE @DATA(lt_9551)
    FOR ALL ENTRIES IN @lt_506
      WHERE plvar = '01'
        AND otype = 'SE'
        AND objid = @lt_506-se_id
        AND begda <= @gv_keydt
        AND endda >= @gv_keydt
        AND istat = '1'.
  SORT lt_9551 BY objid.

  SELECT stobjid, student12 FROM cmacbpst
    INTO TABLE @DATA(lt_cmst)
    FOR ALL ENTRIES IN @lt_506
    WHERE stobjid = @lt_506-st_id.
  SORT lt_cmst BY stobjid.

  DATA(lt_stlist) = VALUE hrobject_t( FOR ls_cmst IN lt_cmst ( plvar = '01' otype = 'ST' objid = ls_cmst-stobjid ) ).

  zcmcl000=>get_st_status(
    EXPORTING
      it_stobj    = lt_stlist
      iv_keydate  = gv_keydt
    IMPORTING
      et_ststatus = DATA(lt_status)
  ).

  LOOP AT lt_506 INTO DATA(ls_506) GROUP BY ( st_id = ls_506-st_id )
                                   ASSIGNING FIELD-SYMBOL(<fg>).
    LOOP AT GROUP <fg> ASSIGNING FIELD-SYMBOL(<fs>).
      lv_index = lv_index + 1.
      CHECK lv_index <= 12.

      ASSIGN COMPONENT |SE{ lv_index }| OF STRUCTURE ls_data TO FIELD-SYMBOL(<fse>).
      CHECK sy-subrc = 0.

      READ TABLE lt_se INTO DATA(ls_se) WITH KEY objid = <fs>-se_id BINARY SEARCH.
      <fse> = ls_se-short.

*TPS
      gt_data2-bookdt = <fs>-bookdate.
      gt_data2-booktm = <fs>-booktime(4).
      gt_data2-bookcnt = 1.
      COLLECT gt_data2. CLEAR gt_data2.

*OVERBOOKING
      gt_data3-se_id = <fs>-se_id.
      gt_data3-short = ls_se-short.
      gt_data3-stext = ls_se-stext.
      gt_data3-book_cnt = 1.
      COLLECT gt_data3. CLEAR gt_data3.

      CLEAR ls_se.
    ENDLOOP.

    READ TABLE lt_cmst INTO DATA(sl_cmst) WITH KEY stobjid = <fs>-st_id BINARY SEARCH.
    IF sy-subrc = 0.
      ls_data-st_no = sl_cmst-student12.
    ENDIF.

    READ TABLE lt_status INTO DATA(ls_stat) WITH KEY objid = <fs>-st_id BINARY SEARCH.
    IF sy-subrc = 0.
      ls_data-sts_cd = ls_stat-sts_cd.
      ls_data-sts_cdt = ls_stat-sts_cd_t.
    ENDIF.

    ls_data-st_id = <fs>-st_id.
    APPEND ls_data TO gt_data1.
    CLEAR: ls_data, lv_index.
  ENDLOOP.

  SORT gt_data2 BY bookdt booktm.
  DATA(lv_tps_t) = lines( gt_data2 ).
  DATA lv_sum TYPE p DECIMALS 3.

  CLEAR : gv_cnt,gv_tps.
  LOOP AT gt_data2 ASSIGNING FIELD-SYMBOL(<fs2>).
    <fs2>-booktps = <fs2>-bookcnt / 60 .
    IF sy-tabix = 1 OR sy-tabix = lv_tps_t.
    ELSE.
      lv_sum = lv_sum + <fs2>-booktps.
    ENDIF.
    gv_cnt = gv_cnt + <fs2>-bookcnt.
  ENDLOOP.

  gv_tps = lv_sum / ( lv_tps_t - 2 ).

  LOOP AT gt_data3 ASSIGNING FIELD-SYMBOL(<fs3>).
    DATA(lv_index3) = sy-tabix.

    READ TABLE lt_9551 INTO DATA(ls_9551) WITH KEY objid = <fs3>-se_id BINARY SEARCH.
    IF sy-subrc = 0.
      <fs3>-book_kapz = ls_9551-book_kapz.
      <fs3>-book_kapz1_r = ls_9551-book_kapz1_r.
      <fs3>-book_kapz2_r = ls_9551-book_kapz2_r.
      <fs3>-book_kapz3_r = ls_9551-book_kapz3_r.
      <fs3>-book_kapz4_r = ls_9551-book_kapz4_r.
      <fs3>-book_kapzg = ls_9551-book_kapzg.

      <fs3>-book_kapza = ls_9551-book_kapz + ls_9551-book_kapz1 + ls_9551-book_kapz2 +
                         ls_9551-book_kapz3 + ls_9551-book_kapz4 + ls_9551-book_kapzg.
    ENDIF.

    IF <fs3>-book_kapza >= <fs3>-book_cnt.
      DELETE gt_data3 INDEX lv_index3.
    ENDIF.

  ENDLOOP.

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
  IF sy-subrc = 0.
    gv_begda = ls_tili-ca_lbegda.
    gv_endda = ls_tili-ca_lendda.
    gv_keydt = ls_tili-ca_lbegda.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form setting_popup
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM setting_popup .
  IF sy-sysid = 'PRD' AND sy-mandt = '100'.
    RETURN.
  ENDIF.

  CLEAR gs_222.
  SELECT SINGLE * FROM zcmtk222
    INTO gs_222.

  CALL SCREEN 200 STARTING AT 5 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZCMTK222
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_zcmtk222 .

  MODIFY zcmtk222 FROM gs_222.
  COMMIT WORK.
  MESSAGE s011.

  LEAVE TO SCREEN 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_PAD506
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_booking_data.
  IF sy-sysid = 'PRD' AND sy-mandt = '100'.
    RETURN.
  ENDIF.

  CHECK zcmcl000=>popup_to_confirm( '삭제하시겠습니까?' ) IS NOT INITIAL.

  SELECT * FROM hrpad506
    INTO TABLE @DATA(lt_ad506)
    WHERE peryr = @p_peryr
      AND perid = @p_perid.
  CHECK sy-subrc = 0.

*ST - SM
  SELECT * FROM hrp1001
    INTO TABLE @DATA(lt_stms)
    FOR ALL ENTRIES IN @lt_ad506
    WHERE adatanr = @lt_ad506-adatanr.

*E
  SELECT * FROM hrp1739
    INTO TABLE @DATA(lt_1739)
    WHERE plvar = '01'
      AND otype = 'E'
      AND istat = '1'
      AND peryr = @p_peryr
      AND perid = @p_perid.

  IF lt_1739[] IS NOT INITIAL.
*E - ST
    SELECT * FROM hrp1001
      INTO TABLE @DATA(lt_ste)
        FOR ALL ENTRIES IN @lt_1739
      WHERE plvar = '01'
        AND otype = 'E'
        AND objid = @lt_1739-objid
        AND rsign = 'A'
        AND relat IN ('025','040')
        AND istat = '1'
        AND begda = @lt_1739-begda
        AND endda = @lt_1739-endda
        AND subty IN ('A025','A040')
        AND sclas = 'ST'.
    IF lt_ste IS NOT INITIAL.
      SELECT * FROM hrpad25
        INTO TABLE @DATA(lt_p25)
        FOR ALL ENTRIES IN @lt_ste
        WHERE adatanr = @lt_ste-adatanr.
    ENDIF.
  ENDIF.

  SELECT * FROM hrp1724
    INTO TABLE @DATA(lt_p1724)
    FOR ALL ENTRIES IN @lt_ad506
    WHERE modreg_id = @lt_ad506-id.

  SELECT * FROM hrp1725
    INTO TABLE @DATA(lt_p1725)
    FOR ALL ENTRIES IN @lt_ad506
    WHERE modreg_id = @lt_ad506-id.

  DELETE hrp1725 FROM TABLE lt_p1725.
  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.

  DELETE hrp1724 FROM TABLE lt_p1724.
  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.

  DELETE hrpad25 FROM TABLE lt_p25.
  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.

  LOOP AT lt_ste INTO DATA(ls_ste).
    DELETE FROM hrp1001 WHERE adatanr = ls_ste-adatanr.
  ENDLOOP.
  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.

  LOOP AT lt_stms INTO DATA(ls_stms).
    DELETE FROM hrp1001 WHERE adatanr = ls_stms-adatanr.
  ENDLOOP.
  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.

*  DELETE hrpad506 FROM TABLE lt_ad506.
  LOOP AT lt_ad506 INTO DATA(ls_ad506).
    DELETE FROM hrpad506 WHERE id = ls_ad506-id.
  ENDLOOP.
  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.

  DELETE FROM lsocrpcntxtstage.
  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.

  UPDATE zcmtk310 SET comp = ''
                WHERE peryr = p_peryr
                  AND perid = p_perid.
  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.

  PERFORM get_data_select.

  MESSAGE s014.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_to_cart
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM add_to_cart .
  IF sy-sysid = 'PRD' AND sy-mandt = '100'.
    RETURN.
  ENDIF.

  DATA lt_310 TYPE TABLE OF zcmtk310 WITH HEADER LINE.
  DATA lv_cnt TYPE i.

  CHECK zcmcl000=>popup_to_confirm( '담아놓기 하시겠습니까?' ) IS NOT INITIAL.

  SELECT b~peryr,
         b~perid,
         a~objid AS  st_id,
         a~sobid AS  sm_id,
         b~packnumber AS se_id,
         b~bookdate,
         b~booktime,
         c~short AS se_short,
         b~cpattemp AS cpopt
    FROM hrp1001 AS a
    JOIN hrpad506 AS b
      ON b~adatanr = a~adatanr
    JOIN hrp1000 AS c
      ON c~objid = b~packnumber
   WHERE a~plvar = '01'
     AND a~otype = 'ST'
     AND a~istat = '1'
     AND a~subty = 'A506'
     AND a~sclas = 'SM'

     AND b~peryr = @p_peryr
     AND b~perid = @p_perid
     AND b~smstatus IN @s_smstat

     AND c~plvar = '01'
     AND c~istat = '1'
     AND c~otype = 'SE'
     AND c~langu = @sy-langu
     AND c~begda <= @gv_keydt
     AND c~endda >= @gv_keydt
    INTO TABLE @DATA(lt_506).
  CHECK sy-subrc = 0.
  SORT lt_506 BY st_id.

  LOOP AT lt_506 INTO DATA(ls_506) GROUP BY ( st_id = ls_506-st_id )
                                   ASSIGNING FIELD-SYMBOL(<fg>).
    CLEAR lv_cnt.
    LOOP AT GROUP <fg> ASSIGNING FIELD-SYMBOL(<fs>).
      lv_cnt = lv_cnt + 1.
      IF lv_cnt > 6.
        EXIT.
      ENDIF.
      lt_310-peryr = <fs>-peryr.
      lt_310-perid = <fs>-perid.
      lt_310-perid = '020'.
      lt_310-st_id = <fs>-st_id.
      lt_310-se_id = <fs>-se_id.
      lt_310-sm_id = <fs>-sm_id.
      lt_310-se_short = <fs>-se_short.
      APPEND lt_310.
      CLEAR: lt_310.
    ENDLOOP.
  ENDLOOP.

  MODIFY zcmtk310 FROM TABLE lt_310.
  COMMIT WORK.

  MESSAGE s011.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form st_session_del
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM st_session_del .
  IF sy-sysid = 'PRD' AND sy-mandt = '100'.
    RETURN.
  ENDIF.

  DATA :
    lv_rfcdest  TYPE msxxlist-name,
    lv_seqnr(1) TYPE n,
    lv_int      TYPE i,
    lv_taskname TYPE string,
    lv_last     TYPE char02.
  DATA : lt_list     TYPE TABLE OF uinfos WITH HEADER LINE.

  DATA : lv_stno TYPE char12.
  DATA : ls_cmac TYPE cmacbpst.
  DATA : lv_tabix TYPE sy-tabix.

  CHECK zcmcl000=>popup_to_confirm( '삭제하시겠습니까?' ) IS NOT INITIAL.

  CALL FUNCTION 'TH_SYSTEMWIDE_USER_LIST'
    TABLES
      list           = lt_list
    EXCEPTIONS
      argument_error = 1
      send_error     = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  DELETE lt_list WHERE mandt <> sy-mandt.

  LOOP AT lt_list.
    lv_tabix = sy-tabix.
    CLEAR lv_stno.
    lv_stno = lt_list-bname.

    CLEAR ls_cmac.
    SELECT SINGLE *
             FROM cmacbpst
             INTO ls_cmac
            WHERE student12 = lv_stno.
    CHECK sy-subrc = 0.

    lv_rfcdest = lt_list-apserver.
    lv_taskname = lt_list-apserver && '_' && lv_tabix.
    CALL FUNCTION 'ZCMK_SESSION_DELETE' DESTINATION lv_rfcdest
      STARTING NEW TASK lv_taskname " 'mytask'
      EXPORTING
        user            = lt_list-bname
        client          = sy-mandt
        tid             = lt_list-tid
      EXCEPTIONS
        authority_error = 1
        OTHERS          = 2.

    CALL FUNCTION 'ZCMK_SESSION_DELETE' DESTINATION lv_rfcdest
      STARTING NEW TASK lv_taskname " 'mytask'
      EXPORTING
        user            = lt_list-bname
        client          = sy-mandt
      EXCEPTIONS
        authority_error = 1
        OTHERS          = 2.
  ENDLOOP.

  DELETE FROM zcmt2024_user.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_QT_HRP9551
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_qt_hrp9551 .
  IF sy-sysid = 'PRD' AND sy-mandt = '100'.
    RETURN.
  ENDIF.

  DATA lt_val LIKE TABLE OF sval.
  DATA lv_ret.
  DATA lv_keywd TYPE stext.
  DATA ls_p9551 TYPE p9551.

  lt_val = VALUE #( ( value = '999' fieldname = 'BOOK_KAPZ' tabname = 'HRP9551' field_obl = 'X' fieldtext = '정원' ) ).

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title = '정원 셋팅'
    IMPORTING
      returncode  = lv_ret
    TABLES
      fields      = lt_val.
  CHECK lt_val IS NOT INITIAL.
  CHECK lv_ret <> 'A'.
  READ TABLE lt_val INTO DATA(ls_val) INDEX 1.

  lv_keywd = p_orgcd.

  zcmcl000=>get_course_detail(
    EXPORTING
      i_peryr   = p_peryr
      i_perid   = p_perid
      i_stype   = '1'
      i_kword   = lv_keywd
      i_langu   = '3'
    IMPORTING
      et_course = DATA(et_course)
      ev_error  = DATA(ev_error)
      ev_msg    = DATA(ev_msg)
  ).

  CONDENSE ls_val-value NO-GAPS.

  LOOP AT et_course INTO DATA(ls_course).
    ls_p9551-book_kapz4 = ls_val-value.
    ls_p9551-book_kapz3 = ls_val-value.
    ls_p9551-book_kapz2 = ls_val-value.
    ls_p9551-book_kapz1 = ls_val-value.
    ls_p9551-book_kapzg = ls_val-value.
    ls_p9551-book_kapz  = ls_val-value.

    ls_p9551-book_kapz4_r = ls_val-value.
    ls_p9551-book_kapz3_r = ls_val-value.
    ls_p9551-book_kapz2_r = ls_val-value.
    ls_p9551-book_kapz1_r = ls_val-value.

    ls_p9551-plvar      = '01'.
    ls_p9551-otype      = 'SE'.
    ls_p9551-objid      = ls_course-seobjid.
    ls_p9551-istat      = '1'.
    ls_p9551-begda      = gv_begda.
    ls_p9551-endda      = gv_endda.
    ls_p9551-infty      = '9551'.
    ls_p9551-aedtm      = sy-datum.
    ls_p9551-uname      = sy-uname.

    zcmcl000=>hriq_modify_infty(
      EXPORTING
        iv_mode  = 'I'
        is_pnnnn = ls_p9551
    ).
  ENDLOOP.

  COMMIT WORK.
  MESSAGE s011.

ENDFORM.
