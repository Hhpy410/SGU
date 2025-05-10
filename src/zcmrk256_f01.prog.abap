*&---------------------------------------------------------------------*
*& Include          MZCMRK990_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data_select
*&---------------------------------------------------------------------*
FORM get_data_select.

*  DATA lt_txt TYPE TABLE OF string.
*
*  CLEAR : gt_data[].
*
*  SELECT * FROM hrp9566
*    INTO TABLE @DATA(lt_9566)
*    WHERE plvar = '01'
*      AND otype = 'O'
*      AND objid IN @s_objid
*      AND istat = '1'.
*  CHECK lt_9566[] IS NOT INITIAL.
*
*  SELECT * FROM hrt9566
*    INTO TABLE @DATA(lt_t9566)
*    FOR ALL ENTRIES IN @lt_9566
*    WHERE tabnr = @lt_9566-tabnr.
*  SORT lt_t9566 BY tabnr possb_oid.
*
*  SELECT * FROM hrp1000
*    INTO TABLE @DATA(lt_1000)
*    FOR ALL ENTRIES IN @lt_9566
*    WHERE plvar = '01'
*      AND otype = 'O'
*      AND objid = @lt_9566-objid
*      AND istat = '1'
*      AND begda <= @sy-datum
*      AND endda >= @sy-datum
*      AND langu = @sy-langu.
*  SORT lt_1000 BY objid.
*
*  IF lt_t9566 IS NOT INITIAL.
*    SELECT * FROM hrp1000
*      APPENDING TABLE @lt_1000
*      FOR ALL ENTRIES IN @lt_t9566
*      WHERE plvar = '01'
*        AND otype = 'O'
*        AND objid = @lt_t9566-possb_oid
*        AND istat = '1'
*        AND begda <= @sy-datum
*        AND endda >= @sy-datum
*        AND langu = @sy-langu.
*    SORT lt_1000 BY objid.
*  ENDIF.
*
*  SELECT * FROM dd07t
*    INTO TABLE @DATA(lt_dom)
*    WHERE domname IN ('ZCMK_RE_GRD_PRC','')
*      AND ddlanguage = @sy-langu.
*  SORT lt_dom BY domname domvalue_l.
*
*  SELECT * FROM t7piqscalet
*    INTO TABLE @DATA(lt_scl)
*    WHERE langu = @sy-langu.
*  SORT lt_scl BY scaleid.
*
*  LOOP AT lt_9566 INTO DATA(ls_9566).
*    MOVE-CORRESPONDING ls_9566 TO gt_data.
*
*    READ TABLE lt_1000 INTO DATA(ls_1000) WITH KEY objid = gt_data-objid BINARY SEARCH.
*    IF sy-subrc = 0.
*      gt_data-o_stext = ls_1000-stext.
*    ENDIF.
*
*    READ TABLE lt_scl INTO DATA(ls_scl) WITH KEY scaleid = gt_data-re_scale BINARY SEARCH.
*    IF sy-subrc = 0.
*      gt_data-re_scalet = ls_scl-text.
*    ENDIF.
*
*    READ TABLE lt_dom INTO DATA(ls_dom) WITH KEY domname = 'ZCMK_RE_GRD_PRC' domvalue_l = gt_data-re_grd_prc BINARY SEARCH.
*    IF sy-subrc = 0.
*      gt_data-re_grd_prct = ls_dom-ddtext.
*    ENDIF.
*
*    READ TABLE lt_t9566 WITH KEY tabnr = ls_9566-tabnr BINARY SEARCH TRANSPORTING NO FIELDS.
*    IF sy-subrc = 0.
*      LOOP AT lt_t9566 INTO DATA(ls_t9566) FROM sy-tabix.
*        IF ls_t9566-tabnr <> ls_9566-tabnr.
*          EXIT.
*        ENDIF.
*
*        READ TABLE lt_1000 INTO ls_1000 WITH KEY objid = ls_t9566-possb_oid BINARY SEARCH.
*        IF sy-subrc = 0.
*          APPEND |[{ ls_t9566-possb_oid }]{ ls_1000-stext }| TO lt_txt.
*        ENDIF.
*
*      ENDLOOP.
*    ENDIF.
*
*    CONCATENATE LINES OF lt_txt INTO gt_data-possb SEPARATED BY `, `.
*
*    APPEND gt_data.
*    CLEAR: gt_data, lt_txt.
*  ENDLOOP.


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

*(학년순서
  DATA: s1 TYPE i, s2 TYPE i, s3 TYPE i, s4 TYPE i.
  IF p_perid = '010'.
    s1 = 3. s2 = 0. s3 = 1. s4 = 2.
  ELSE.
    s1 = 0. s2 = 1. s3 = 2. s4 = 3.
  ENDIF.
*)


*  LOOP AT go_grid->fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).
*   ff          TYPE lvc_s_fcat,
  LOOP AT go_grid->fcat INTO DATA(ff).
    CASE ff-fieldname.
*     WHEN 'OBJID'.  ff-col_pos = 01.      ff-coltext = 'ST'.
      WHEN 'SHORT'.       ff-col_pos = 02.      ff-coltext = '학번'.
      WHEN 'STEXT'.       ff-col_pos = 03.      ff-coltext = '성명'.
      WHEN 'STS_CD_TXT'.  ff-col_pos = 03.      ff-coltext = '학적상태'.
      WHEN 'RGWIN'.       ff-col_pos = 04.      ff-coltext = '학년'.
      WHEN 'RGSEM'.       ff-col_pos = 04.      ff-coltext = '학기'.
      WHEN 'BKCDT'.  ff-col_pos = 04.      ff-coltext = '학점'.
*     WHEN 'PERYR'.  ff-col_pos = 05.      ff-coltext = '학년도'.
*     WHEN 'PERID'.  ff-col_pos = 06.      ff-coltext = '학기'.
*      WHEN 'SE_SHORT'. ff-col_pos = 06.      ff-coltext = '분반코드'.
      WHEN 'SE_SHORT'. ff-col_pos = 07.      ff-coltext = '입력코드'.
*      WHEN 'SHORT2'. ff-col_pos = 08.      ff-coltext = '입력코드2'.
*      WHEN 'SHORT3'. ff-col_pos = 09.      ff-coltext = '입력코드3'.
*      WHEN 'SHORT4'. ff-col_pos = 10.      ff-coltext = '입력코드4'.
*      WHEN 'SHORT5'. ff-col_pos = 11.      ff-coltext = '입력코드5'.
*      WHEN 'SHORT6'. ff-col_pos = 12.      ff-coltext = '입력코드6'.
      WHEN 'SMCNT'.  ff-col_pos = 13.      ff-coltext = '입력수'.
**      WHEN 'SMTX1'.  ff-col_pos = 14.      ff-coltext = '과목명1'.
**      WHEN 'SMTX2'.  ff-col_pos = 15.      ff-coltext = '과목명2'.
**      WHEN 'SMTX3'.  ff-col_pos = 16.      ff-coltext = '과목명3'.
**      WHEN 'SMTX4'.  ff-col_pos = 17.      ff-coltext = '과목명4'.
**      WHEN 'SMTX5'.  ff-col_pos = 18.      ff-coltext = '과목명5'.
**      WHEN 'SMTX6'.  ff-col_pos = 19.      ff-coltext = '과목명6'.
      WHEN 'R_SEOBJID'. ff-col_pos = 30.      ff-coltext = '저장1'.
      WHEN 'R_SHORT'. ff-col_pos = 31.      ff-coltext = '저장2'.
*      WHEN 'R_SHORT3'. ff-col_pos = 32.      ff-coltext = '저장3'.
*      WHEN 'R_SHORT4'. ff-col_pos = 33.      ff-coltext = '저장4'.
*      WHEN 'R_SHORT5'. ff-col_pos = 34.      ff-coltext = '저장5'.
*      WHEN 'R_SHORT6'. ff-col_pos = 35.      ff-coltext = '저장6'.
*      WHEN 'ERNAM'.  ff-col_pos = 50.      ff-coltext = '생성학번'.
      WHEN 'ERDAT'.  ff-col_pos = 51.      ff-coltext = '생성일자'.
      WHEN 'ERTIM'.  ff-col_pos = 52.      ff-coltext = '생성시간'.
      WHEN 'COMP'.   ff-col_pos = 53.      ff-coltext = '저장'.
*      WHEN 'AENAM'.  ff-col_pos = 54.      ff-coltext = '저장학번'.
      WHEN 'AEDAT'.  ff-col_pos = 55.      ff-coltext = '저장일자'.
      WHEN 'AETIM'.  ff-col_pos = 56.      ff-coltext = '저장시간'.

*      WHEN 'CTYPE1'.  ff-col_pos = 27.     ff-coltext = '구분'.
*      WHEN 'RATEA'.  ff-col_pos = 28.      ff-coltext = '전체'.
*      WHEN 'RATE1'.  ff-col_pos = 29 + s1. ff-coltext = '1학년'.
*      WHEN 'RATE2'.  ff-col_pos = 29 + s2. ff-coltext = '2학년'.
*      WHEN 'RATE3'.  ff-col_pos = 29 + s3. ff-coltext = '3학년'.
*      WHEN 'RATE4'.  ff-col_pos = 29 + s4. ff-coltext = '4학년'.

*      WHEN 'CTYPE2'.  ff-col_pos = 33.     ff-coltext = '구분'.
*      WHEN 'APPCA'.  ff-col_pos = 34.      ff-coltext = '전체'.
*      WHEN 'APPC1'.  ff-col_pos = 35 + s1. ff-coltext = '1학년'.
*      WHEN 'APPC2'.  ff-col_pos = 35 + s2. ff-coltext = '2학년'.
*      WHEN 'APPC3'.  ff-col_pos = 35 + s3. ff-coltext = '3학년'.
*      WHEN 'APPC4'.  ff-col_pos = 35 + s4. ff-coltext = '4학년'.
*
*      WHEN 'CTYPE3'.  ff-col_pos = 39.     ff-coltext = '구분'.
*      WHEN 'KAPZA'.  ff-col_pos = 40.      ff-coltext = '전체'.
*      WHEN 'KAPZ1'.  ff-col_pos = 41 + s1. ff-coltext = '1학년'.
*      WHEN 'KAPZ2'.  ff-col_pos = 41 + s2. ff-coltext = '2학년'.
*      WHEN 'KAPZ3'.  ff-col_pos = 41 + s3. ff-coltext = '3학년'.
*      WHEN 'KAPZ4'.  ff-col_pos = 41 + s4. ff-coltext = '4학년'.
      WHEN OTHERS.   ff-no_out  = gc_set.
    ENDCASE.

    IF ff-fieldname = 'SHORT' OR
       ff-fieldname = 'STEXT'.
      ff-key = 'X'.
    ENDIF.

    IF ff-fieldname+0(5) = 'SHORT'.
      ff-emphasize = 'C300'.
    ENDIF.

    IF ff-fieldname = 'SE_SHORT'.
      ff-emphasize = 'C300'.
    ENDIF.

    IF ff-fieldname = 'COMP'.
      ff-checkbox = 'X'.
    ENDIF.

*   경쟁률
    IF ff-fieldname = 'CTYPE'  OR
       ff-fieldname = 'CTYPE1' OR
       ff-fieldname = 'RATEA'  OR
       ff-fieldname = 'RATE1'  OR
       ff-fieldname = 'RATE2'  OR
       ff-fieldname = 'RATE3'  OR
       ff-fieldname = 'RATE4'.
      ff-emphasize = 'C500'.
    ENDIF.

*   신청수
    IF ff-fieldname = 'CTYPE2' OR
       ff-fieldname = 'APPCA' OR
       ff-fieldname = 'APPC1' OR
       ff-fieldname = 'APPC2' OR
       ff-fieldname = 'APPC3' OR
       ff-fieldname = 'APPC4'.
      ff-emphasize = 'C110'.
    ENDIF.

*   정원
    IF ff-fieldname = 'CTYPE3' OR
       ff-fieldname = 'KAPZA' OR
       ff-fieldname = 'KAPZ1' OR
       ff-fieldname = 'KAPZ2' OR
       ff-fieldname = 'KAPZ3' OR
       ff-fieldname = 'KAPZ4'.
      ff-emphasize = 'C210'.
    ENDIF.

    IF ff-fieldname+0(4) = 'CVAL'.
      ff-just = 'C'.
    ENDIF.

    MODIFY go_grid->fcat FROM ff.
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
*  go_grid->sort =
*    VALUE #( ( fieldname = 'TEST1_UZEIT' up = abap_true )
*             ( fieldname = 'TEST1_STIME' up = abap_true )
*             ( fieldname = 'TEST2_UZEIT' up = abap_true )
*             ( fieldname = 'TEST2_STIME' up = abap_true )
*             ( fieldname = 'TEST3_UZEIT' up = abap_true )
*             ( fieldname = 'TEST3_STIME' up = abap_true ) ).

*  go_grid->sort =
*  VALUE #( ( fieldname = 'STNO' up = abap_true )
*           ( fieldname = 'TEST1_DATE' up = abap_true )
*           ( fieldname = 'TEST1_TIME' up = abap_true )
*           ( fieldname = 'TEST2_DATE' up = abap_true )
*           ( fieldname = 'TEST2_TIME' up = abap_true )
*           ( fieldname = 'TEST3_DATE' up = abap_true )
*           ( fieldname = 'TEST3_TIME' up = abap_true ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form grid_gui_status
*&---------------------------------------------------------------------*
FORM grid_gui_status .

  go_grid->gui_status->fully_dynamic = abap_true.
  go_grid->exclude_functions = go_grid->gui_status->edit_buttons( ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_02
    iv_text   = '1. earliest-time by Round'
    iv_icon   = icon_xxl ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_03
    iv_text   = '2. fastest-time by Round'
    iv_icon   = icon_xxl ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_04
    iv_text   = '3. effort Prize'
    iv_icon   = icon_xxl ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_05
    iv_text   = '4. coffee Prize'
    iv_icon   = icon_xxl ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_06
    iv_text   = '5. added'
    iv_icon   = icon_xxl ).

  go_grid->gui_status->add_button(
    iv_button = zcl_falv_dynamic_status=>b_07
    iv_text   = '6. additional Info'
    iv_icon   = icon_xxl ).


*  go_grid->gui_status->add_button(
*   iv_button = zcl_falv_dynamic_status=>b_02
*   iv_text   = 'Fastest-time'
*   iv_icon   = icon_xxl ).

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

  IF po_me = go_grid.
    CASE p_ucomm.
      WHEN zcl_falv_dynamic_status=>b_01. "새로고침
*        PERFORM get_data_select.

      WHEN zcl_falv_dynamic_status=>b_02.
        PERFORM earliest-time.
        go_grid->title_v1 = |{ TEXT-t20 } - { lines( gt_data ) } 건|.

      WHEN zcl_falv_dynamic_status=>b_03.
        PERFORM fastest-time.

      WHEN zcl_falv_dynamic_status=>b_04.
        PERFORM effort-prize.

      WHEN zcl_falv_dynamic_status=>b_05.
        PERFORM coffee-prize.
      WHEN zcl_falv_dynamic_status=>b_06.
        PERFORM added.
        go_grid->title_v1 = |{ TEXT-t30 } - { lines( gt_data ) } 건|.
      WHEN zcl_falv_dynamic_status=>b_07.
        PERFORM extra_info.

      WHEN OTHERS.
    ENDCASE.
  ELSE.
    CASE p_ucomm.
      WHEN zcl_falv_dynamic_status=>b_01.
      WHEN zcl_falv_dynamic_status=>b_02.
        LEAVE TO SCREEN 0.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.
  po_me->soft_refresh( ).

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
*
*  IF sy-subrc = 0.
*    MOVE f4_objec-realo TO s_objid-low.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_datum
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_datum.

  CLEAR gs_timelimits.
  zcmcl000=>get_timelimits(
    EXPORTING
      iv_o          = '30000002' "학부
      iv_timelimit  = '0100'     "시한
      iv_peryr      = p_peryr    "학년도
      iv_perid      = p_perid    "학기
    IMPORTING
      et_timelimits = DATA(et_timelimits)
  ).
  READ TABLE et_timelimits INDEX 1 INTO gs_timelimits.
  IF sy-subrc = 0.

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
FORM initialization.

*  zcmcl000=>get_timelimits(
*    EXPORTING
*      iv_o          = '30000002'                " 소속 오브젝트 ID
*      iv_timelimit  = '0100'           " 시한
*      iv_keydate    = sy-datum
*    IMPORTING
*      et_timelimits = DATA(et_timelimits)
*  ).
*
*  LOOP AT et_timelimits ASSIGNING FIELD-SYMBOL(<fs_time>) WHERE ca_lbegda <= sy-datum AND ca_lendda >= sy-datum.
*    IF <fs_time>-ca_perid = '001' OR <fs_time>-ca_perid = '002'.
*      " 큰학기 제외.
*    ELSE.
*      gs_timelimits = CORRESPONDING #( <fs_time> ).
*      EXIT.
*    ENDIF.
*  ENDLOOP.
*  p_peryr  = gs_timelimits-ca_peryr.
*  p_perid  = gs_timelimits-ca_perid.
*p_date1 = gs_timelimits-ca_lbegda.
*  p_date2 = gs_timelimits-ca_lbegda.
*  p_date3 = gs_timelimits-ca_lbegda.

  p_peryr = '2025'.
  p_perid = '010'.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data.

*  PERFORM get_stobj. "학번필터
  PERFORM get_event_data. "생성된 이벤트 개설 데이터 (표준)
  PERFORM get_info.
  PERFORM get_wish.
  PERFORM get_etc.

  PERFORM get_save.
  PERFORM edit_data.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init.

  go_adbc = NEW zcmcl_adbc( i_dbs1 = 'SIPSSTEST' ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_input_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_input_data.

*  CLEAR: gt_input[], gt_input.
*
*  SELECT *
*    FROM zcmt2024_input
*   WHERE uname IN @p_stno
*     AND (
*          sdate = @p_date1
*      OR  sdate = @p_date2
*      OR  sdate = @p_date3
*         )
*    INTO TABLE @gt_input.
*  SORT gt_input BY sdate uzeit stime.
*
** 1차
*  DELETE gt_input
*   WHERE sdate = p_date1
*     AND uzeit < p_time1.
*
** 2차
**  DELETE gt_input
**   WHERE sdate = p_date2
**     AND uzeit < p_time2.
*
** 3차
*  DELETE gt_input
*   WHERE sdate = p_date3
*     AND uzeit < p_time1.
*
** 1차 종료시간
**  SELECT SINGLE MAX( uzeit )
**    INTO @gv_endtime1
**    FROM zcmt2024_input
**   WHERE sdate = @p_date1.
*  gv_endtime1 = '101000'.
*
** 2차 종료시간
*  SELECT SINGLE MAX( uzeit )
*    INTO @gv_endtime2
*    FROM zcmt2024_input
*   WHERE sdate = @p_date2.
*
** 3차 종료시간
*  SELECT SINGLE MAX( uzeit )
*    INTO @gv_endtime3
*    FROM zcmt2024_input
*   WHERE sdate = @p_date3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form edit_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM edit_data.

  LOOP AT gt_data.

    READ TABLE gt_hrpad506
      WITH KEY smstatus = '01' "수강신청
               packnumber = gt_data-se_id
               peryr = p_peryr
               perid = p_perid.
    IF sy-subrc IS INITIAL.
      gt_data-r_seobjid = gt_hrpad506-packnumber.

    ENDIF.



  ENDLOOP.

*  SELECT objid AS stobjid, stext AS name
*    INTO TABLE @DATA(lt_name)
*    FROM hrp1000
*    FOR ALL ENTRIES IN @gt_input
*   WHERE plvar = '01'
*     AND otype = 'ST'
*     AND objid = @gt_input-stobj
*     AND istat = 1
*     AND begda <= @sy-datum
*     AND endda >= @sy-datum
*     AND langu = '3'
*     AND short = @gt_input-uname.
*  SORT lt_name BY stobjid.
*
*  SELECT stobjid, st_stscd, o_short
*    INTO TABLE @DATA(lt_zcmta446)
*    FROM zcmta446
*    FOR ALL ENTRIES IN @gt_input
*   WHERE stobjid = @gt_input-stobj.
*  SORT lt_zcmta446 BY stobjid.
*
**--------------------------------------------------------------------*
** # 19.08.2024 15:42:43 # 진급정보
**--------------------------------------------------------------------*
*  DATA lt_stobj TYPE TABLE OF hrobject WITH HEADER LINE.
*  LOOP AT gt_input INTO DATA(ls_input).
*    CLEAR lt_stobj.
*    lt_stobj-plvar = '01'.
*    lt_stobj-otype = 'ST'.
*    lt_stobj-objid = ls_input-stobj.
*    APPEND lt_stobj.
*
*  ENDLOOP.
*
*  CALL METHOD zcmcl000=>get_st_progression
*    EXPORTING
*      it_stobj   = lt_stobj[]
*      iv_keydate = sy-datum
*    IMPORTING
*      et_stprog  = DATA(et_stprog).
*
*  LOOP AT gt_input.
*    CLEAR gt_data.
*    gt_data-stno = gt_input-uname.
*    gt_data-stobjid = gt_input-stobj.
*
*    READ TABLE lt_name INTO DATA(ls_name) WITH KEY stobjid = gt_input-stobj BINARY SEARCH.
*    IF sy-subrc = 0.
*      gt_data-name = ls_name-name.
*    ENDIF.
*
*    READ TABLE lt_zcmta446 INTO DATA(ls_446) WITH KEY stobjid = gt_input-stobj BINARY SEARCH.
*    IF sy-subrc = 0.
*      gt_data-stscd = ls_446-st_stscd.
*    ENDIF.
*    CASE gt_data-stscd.
*      WHEN '1000'. gt_data-stscd_txt = '재학'.
*      WHEN '2000'. gt_data-stscd_txt = '휴학'.
*      WHEN '3000'. gt_data-stscd_txt = '제적(자퇴)'.
*      WHEN '4000'. gt_data-stscd_txt = '수료'.
*      WHEN '5000'. gt_data-stscd_txt = '졸업'.
*      WHEN '6000'. gt_data-stscd_txt = '입학취소'.
*    ENDCASE.
*
*    gt_data-o_short = ls_446-o_short.
*
*    READ TABLE et_stprog WITH KEY objid = gt_input-stobj BINARY SEARCH ASSIGNING FIELD-SYMBOL(<fs_stprog>).
*    IF sy-subrc = 0.
*      gt_data-cacst = <fs_stprog>-cacst.
*    ENDIF.
*
*    READ TABLE gt_pre_applicants INTO DATA(ls_pre) WITH KEY user_id = gt_data-stno.
*    IF sy-subrc = 0.
*      gt_data-pre_registration = 'X'.
*      gt_data-mobile = ls_pre-mobile.
*    ENDIF.
*
*    DATA lv_round(1).
*    PERFORM get_round USING gt_input
*                            gt_data
*                      CHANGING lv_round.
*
*    CASE lv_round.
*      WHEN 1.
*        gt_data-test1_date = gt_input-sdate.
*        gt_data-test1_uzeit = gt_input-uzeit.
*        gt_data-test1_stime = gt_input-stime.
*        PERFORM get_time USING gt_data-test1_uzeit
*                               gt_data-test1_stime
*                         CHANGING gt_data-test1_time.
*      WHEN 2.
*        gt_data-test2_date = gt_input-sdate.
*        gt_data-test2_uzeit = gt_input-uzeit.
*        gt_data-test2_stime = gt_input-stime.
*        PERFORM get_time USING gt_data-test2_uzeit
*                               gt_data-test2_stime
*                         CHANGING gt_data-test2_time.
*      WHEN 3.
*        gt_data-test3_date = gt_input-sdate.
*        gt_data-test3_uzeit = gt_input-uzeit.
*        gt_data-test3_stime = gt_input-stime.
*        PERFORM get_time USING gt_data-test3_uzeit
*                               gt_data-test3_stime
*                         CHANGING gt_data-test3_time.
*    ENDCASE.
*
*    APPEND gt_data.
*
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_time
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> p_uzeit
*&      --> p_stime
*&      <-- p_time
*&---------------------------------------------------------------------*
FORM get_time  USING    p_uzeit
                        p_stime
               CHANGING p_time.

  DATA: lt_parts  TYPE TABLE OF string,
        lv_result TYPE string,
        lv_stime  TYPE string.

  CLEAR p_time.
  lv_stime = CONV string( p_stime ).
  CHECK lv_stime CP '*.*'.

  SPLIT lv_stime AT '.' INTO TABLE lt_parts.

  READ TABLE lt_parts INDEX 2 INTO lv_result.
  p_time = p_uzeit && '.' && lv_result.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_round
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ROUND
*&---------------------------------------------------------------------*
FORM get_round USING ps_input LIKE gt_input
                     ps_data LIKE gt_data
               CHANGING pv_round.

*  DATA(lv_input) = ps_input-sdate && ps_input-uzeit.
*
*  DATA(test1_beg) = p_date1 && p_time1.
*  DATA(test1_end) = p_date1 && gv_endtime1.
*
*  DATA(test2_beg) = p_date2 && p_time2.
*  DATA(test2_end) = p_date2 && gv_endtime2.
*
*  DATA(test3_beg) = p_date3 && p_time3.
*  DATA(test3_end) = p_date3 && gv_endtime3.
*
*  CLEAR pv_round.
*  IF lv_input BETWEEN test1_beg AND test1_end.
*    pv_round = 1.
*
*  ELSEIF lv_input BETWEEN test2_beg AND test2_end.
*    pv_round = 2.
*
*  ELSEIF lv_input BETWEEN test1_beg AND test3_end.
*    pv_round = 3.
*
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form earliest-time
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM earliest-time.

*  DATA: lt_final LIKE TABLE OF gt_data,
*        ls_final LIKE gt_data.
*
*  lt_final[] = gt_data[].
*
*  SORT lt_final BY stno.
*  DELETE ADJACENT DUPLICATES FROM lt_final COMPARING stno.
*
** 1 Round
** Sort gt_data by stno and test1_date and test1_time (ascending order)
*  DATA: lt_test1 LIKE TABLE OF gt_data,
*        lt_test2 LIKE TABLE OF gt_data,
*        lt_test3 LIKE TABLE OF gt_data.
*
*  lt_test1[] = gt_data[].
*  lt_test2[] = gt_data[].
*  lt_test3[] = gt_data[].
*
*  SORT lt_test1 BY stno test1_date test1_time ASCENDING.
*  SORT lt_test2 BY stno test2_date test2_time ASCENDING.
*  SORT lt_test3 BY stno test3_date test3_time ASCENDING.
*
*  LOOP AT lt_final INTO ls_final.
*
**   1 round
*    LOOP AT lt_test1 INTO DATA(ls_test1)
*      WHERE stno = ls_final-stno
*        AND test1_date IS NOT INITIAL
*        AND test1_time IS NOT INITIAL.
*
*      ls_final-test1_date = ls_test1-test1_date.
*      ls_final-test1_time = ls_test1-test1_time.
*      ls_final-test1_uzeit = ls_test1-test1_uzeit.
*      ls_final-test1_stime = ls_test1-test1_stime.
*      EXIT.
*    ENDLOOP.
*
**   2 round
*    LOOP AT lt_test2 INTO DATA(ls_test2)
*      WHERE stno = ls_final-stno
*        AND test2_date IS NOT INITIAL
*        AND test2_time IS NOT INITIAL.
*
*      ls_final-test2_date = ls_test2-test2_date.
*      ls_final-test2_time = ls_test2-test2_time.
*      ls_final-test2_uzeit = ls_test2-test2_uzeit.
*      ls_final-test2_stime = ls_test2-test2_stime.
*      EXIT.
*    ENDLOOP.
*
**   3 round
*    LOOP AT lt_test3 INTO DATA(ls_test3)
*      WHERE stno = ls_final-stno
*        AND test3_date IS NOT INITIAL
*        AND test3_time IS NOT INITIAL.
*
*      ls_final-test3_date = ls_test3-test3_date.
*      ls_final-test3_time = ls_test3-test3_time.
*      ls_final-test3_uzeit = ls_test3-test3_uzeit.
*      ls_final-test3_stime = ls_test3-test3_stime.
*      EXIT.
*    ENDLOOP.
*
*    MODIFY lt_final FROM ls_final.
*
*  ENDLOOP.
*
*  CLEAR: gt_data[], gt_data.
*  gt_data[] = lt_final[].
*
*  SORT gt_data BY stno test1_date test1_time test2_date test2_time test3_date test3_time.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fastest-time
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fastest-time.

*  DATA lv_beg1 TYPE timestampl.
*  DATA lv_beg2 TYPE timestampl.
*  DATA lv_beg3 TYPE timestampl.
*
*  DATA lv_stime TYPE timestampl.
**  DATA lv_min TYPE timestampl.
*  DATA lv_diff1 TYPE timestampl.
*  DATA lv_diff2 TYPE timestampl.
*  DATA lv_diff3 TYPE timestampl.
*
*  lv_beg1 = p_time1 && '.' && '0000000'.
*  lv_beg2 = p_time2 && '.' && '0000000'.
*  lv_beg3 = p_time3 && '.' && '0000000'.
*
*  SORT gt_data BY stno.
*  LOOP AT gt_data.
*
*    CLEAR: lv_stime, lv_diff1, lv_diff2, lv_diff3.
*
*    IF gt_data-test1_time IS NOT INITIAL.
*      lv_stime = gt_data-test1_time.
*      lv_diff1 = lv_stime - lv_beg1.
*    ENDIF.
*
*    IF gt_data-test2_time IS NOT INITIAL.
*      lv_stime = gt_data-test2_time.
*      lv_diff2 = lv_stime - lv_beg2.
*    ENDIF.
*
*    IF gt_data-test3_time IS NOT INITIAL.
*      lv_stime = gt_data-test3_time.
*      lv_diff3 = lv_stime - lv_beg3.
*    ENDIF.
*
*    PERFORM get_min_diff USING lv_diff1 lv_diff2 lv_diff3
*                         CHANGING gt_data-min_time.
*
*    CHECK gt_data-min_time IS NOT INITIAL.
*
*    CASE gt_data-min_time.
*      WHEN lv_diff1.
*        gt_data-sdate = gt_data-test1_date.
*        gt_data-time = gt_data-test1_time.
*        gt_data-uzeit = gt_data-test1_uzeit.
*        gt_data-stime = gt_data-test1_stime.
*      WHEN lv_diff2.
*        gt_data-sdate = gt_data-test2_date.
*        gt_data-time = gt_data-test2_time.
*        gt_data-uzeit = gt_data-test2_uzeit.
*        gt_data-stime = gt_data-test2_stime.
*      WHEN lv_diff3.
*        gt_data-sdate = gt_data-test3_date.
*        gt_data-time = gt_data-test3_time.
*        gt_data-uzeit = gt_data-test3_uzeit.
*        gt_data-stime = gt_data-test3_stime.
*    ENDCASE.
*
*    MODIFY gt_data.
*
*  ENDLOOP.
*
*  SORT gt_data BY min_time.
*
*  DATA lv_rank TYPE int4.
*  CLEAR lv_rank.
*  LOOP AT gt_data.
*    ADD 1 TO lv_rank.
*    gt_data-prize1_rank = lv_rank.
*
*    MODIFY gt_data.
*
*  ENDLOOP.
*
*  LOOP AT gt_data.
*
*    IF gt_data-prize1_rank = 1.
*      gt_data-prize1 = 'iPhone'.
*    ENDIF.
*
*    IF gt_data-prize1_rank BETWEEN 2 AND 6.
*      gt_data-prize1 = 'AirPods'.
*    ENDIF.
*
*    MODIFY gt_data.
*
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_min_diff
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> pv_diff1
*&      --> pv_diff2
*&      --> pv_diff3
*&---------------------------------------------------------------------*
FORM get_min_diff USING pv_diff1
                        pv_diff2
                        pv_diff3
                  CHANGING pv_min.

*  IF pv_diff1 IS NOT INITIAL.
*    pv_min = pv_diff1.
*  ELSEIF pv_diff2 IS NOT INITIAL.
*    pv_min = pv_diff2.
*  ELSEIF pv_diff3 IS NOT INITIAL.
*    pv_min = pv_diff3.
*  ENDIF.
*
*  CHECK pv_min IS NOT INITIAL.
*
*  IF pv_diff2 IS NOT INITIAL AND pv_diff2 < pv_min.
*    pv_min = pv_diff2.
*  ENDIF.
*
*  IF pv_diff3 IS NOT INITIAL AND pv_diff3 < pv_min.
*    pv_min = pv_diff3.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form effort-prize
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM effort-prize.

*  LOOP AT gt_data.
*
*    IF gt_data-test1_time IS NOT INITIAL AND gt_data-test2_time IS NOT INITIAL.
*      gt_data-effort = abap_true.
*    ENDIF.
*
*    IF gt_data-test2_time IS NOT INITIAL AND gt_data-test3_time IS NOT INITIAL.
*      gt_data-effort = abap_true.
*    ENDIF.
*
*    IF gt_data-test3_time IS NOT INITIAL AND gt_data-test1_time IS NOT INITIAL.
*      gt_data-effort = abap_true.
*    ENDIF.
*
*    MODIFY gt_data.
*
*  ENDLOOP.
*
*  SORT gt_data BY min_time.
*
*  DATA lv_rank TYPE int4.
*  CLEAR lv_rank.
*  LOOP AT gt_data
*    WHERE effort = abap_true
*      AND prize1 IS INITIAL.
*
*    ADD 1 TO lv_rank.
*    gt_data-prize2_rank = lv_rank.
*
*    MODIFY gt_data.
*
*  ENDLOOP.
*
** prize for effort
*  LOOP AT gt_data.
*
*    IF gt_data-prize2_rank BETWEEN 1 AND 5.
*      gt_data-prize2 = 'AirPods'.
*    ENDIF.
*
*    MODIFY gt_data.
*
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form coffee-prize
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM coffee-prize.

*  SORT gt_data BY min_time.
*
*  DATA lv_rank TYPE int4.
*  CLEAR lv_rank.
*  LOOP AT gt_data
*    WHERE prize1 IS INITIAL
*      AND prize2 IS INITIAL.
*
*    ADD 1 TO lv_rank.
*    gt_data-prize3_rank = lv_rank.
*    gt_data-prize3 = '스벅쿠폰'. "coffee prize
*
*    MODIFY gt_data.
*
*  ENDLOOP.
*
*  SORT gt_data BY prize1_rank prize2_rank prize3_rank.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form added
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM added.

*  SELECT *
*    INTO TABLE @DATA(lt_zcmtk600)
*    FROM zcmtk600.
*
*  DATA added_data LIKE TABLE OF gt_data WITH HEADER LINE.
*  LOOP AT lt_zcmtk600 INTO DATA(ls_zcmtk600).
*    CLEAR added_data.
*    added_data-stno = ls_zcmtk600-stno.
*    added_data-prize3_rank = '9999'.
*    added_data-prize3 = '스벅쿠폰'.
*
*    APPEND added_data.
*
*  ENDLOOP.
*
*  SORT added_data BY stno.
*
*  DATA lr_stno TYPE RANGE OF piqstudent12.
*  lr_stno = VALUE #( FOR ls_added IN added_data ( sign = 'I' option = 'EQ' low = ls_added-stno ) ).
*  CHECK lr_stno IS NOT INITIAL.
*  SELECT *
*    INTO TABLE @DATA(lt_cmacbpst)
*    FROM cmacbpst
*   WHERE student12 IN @lr_stno.
*  SORT lt_cmacbpst BY student12.
*
*  DATA lr_stobjid TYPE RANGE OF piqstudent.
*  lr_stobjid = VALUE #( FOR ls_tmp1 IN lt_cmacbpst ( sign = 'I' option = 'EQ' low = ls_tmp1-stobjid ) ).
*
*  CHECK lr_stobjid IS NOT INITIAL.
*  SELECT objid AS stobjid, stext AS name
*   INTO TABLE @DATA(lt_name)
*   FROM hrp1000
*  WHERE plvar = '01'
*    AND otype = 'ST'
*    AND objid IN @lr_stobjid
*    AND istat = 1
*    AND begda <= @sy-datum
*    AND endda >= @sy-datum
*    AND langu = '3'.
*  SORT lt_name BY stobjid.
*
*  SELECT stobjid, st_stscd, o_short
*    INTO TABLE @DATA(lt_zcmta446)
*    FROM zcmta446
*   WHERE stobjid IN @lr_stobjid.
*  SORT lt_zcmta446 BY stobjid.
*
**--------------------------------------------------------------------*
** # 19.08.2024 15:42:43 # 진급정보
**--------------------------------------------------------------------*
*  DATA lt_stobj TYPE TABLE OF hrobject.
*  lt_stobj = VALUE #( FOR ls_tmp2 IN lt_cmacbpst ( plvar = '01' otype = 'ST' objid = ls_tmp2-stobjid ) ).
*  CALL METHOD zcmcl000=>get_st_progression
*    EXPORTING
*      it_stobj   = lt_stobj[]
*      iv_keydate = sy-datum
*    IMPORTING
*      et_stprog  = DATA(et_stprog).
*
*  LOOP AT added_data.
*
*    READ TABLE lt_cmacbpst INTO DATA(ls_cmacbpst) WITH KEY student12 = added_data-stno BINARY SEARCH.
*    IF sy-subrc = 0.
*      added_data-stobjid = ls_cmacbpst-stobjid.
*    ENDIF.
*
*    READ TABLE lt_name INTO DATA(ls_name) WITH KEY stobjid = added_data-stobjid BINARY SEARCH.
*    IF sy-subrc = 0.
*      added_data-name = ls_name-name.
*    ENDIF.
*
*    READ TABLE lt_zcmta446 INTO DATA(ls_446) WITH KEY stobjid = added_data-stobjid BINARY SEARCH.
*    IF sy-subrc = 0.
*      added_data-stscd = ls_446-st_stscd.
*      added_data-o_short = ls_446-o_short.
*    ENDIF.
*    CASE added_data-stscd.
*      WHEN '1000'. added_data-stscd_txt = '재학'.
*      WHEN '2000'. added_data-stscd_txt = '휴학'.
*      WHEN '3000'. added_data-stscd_txt = '제적(자퇴)'.
*      WHEN '4000'. added_data-stscd_txt = '수료'.
*      WHEN '5000'. added_data-stscd_txt = '졸업'.
*      WHEN '6000'. added_data-stscd_txt = '입학취소'.
*    ENDCASE.
*
*    READ TABLE et_stprog WITH KEY objid = added_data-stobjid BINARY SEARCH ASSIGNING FIELD-SYMBOL(<fs_stprog>).
*    IF sy-subrc = 0.
*      added_data-cacst = <fs_stprog>-cacst.
*    ENDIF.
*
*    READ TABLE gt_pre_applicants INTO DATA(ls_pre) WITH KEY user_id = added_data-stno.
*    IF sy-subrc = 0.
*      added_data-pre_registration = 'X'.
*      added_data-mobile = ls_pre-mobile.
*    ENDIF.
*
*    MODIFY added_data.
*
*  ENDLOOP.
*
*  CHECK added_data[] IS NOT INITIAL.
*
*  SORT added_data BY stno.
*  DELETE ADJACENT DUPLICATES FROM added_data.
*
*  LOOP AT added_data.
*
*    READ TABLE gt_data WITH KEY stno = added_data-stno.
*    IF sy-subrc <> 0. "not existing
*      APPEND added_data TO gt_data.
*    ENDIF.
*
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form extra_info
*&---------------------------------------------------------------------*
*& additional information
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM extra_info.

*  DATA lt_stobj TYPE TABLE OF hrobject.
*  lt_stobj = VALUE #( FOR ls_tmp1 IN gt_data ( plvar = '01' otype = 'ST' objid = ls_tmp1-stobjid ) ).
*
*  CALL METHOD zcmcl000=>get_st_address
*    EXPORTING
*      it_stobj = lt_stobj[]
*    IMPORTING
*      et_addr  = DATA(et_addr).
*
*  CHECK et_addr[] IS NOT INITIAL.
*
*  LOOP AT gt_data.
*
*    CHECK gt_data-mobile IS INITIAL.
*    READ TABLE et_addr INTO DATA(ls_addr) WITH KEY objid = gt_data-stobjid BINARY SEARCH.
*    CHECK sy-subrc = 0.
*    gt_data-mobile = ls_addr-cell.
*    MODIFY gt_data.
*
*  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_wish
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_wish.

* 담아놓기 rawdata
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_wish
    FROM zcmtk310
   WHERE peryr = p_peryr
     AND perid = p_perid.
*     AND st_id IN s_stobj
*     AND se_short IN p_smnum.
  SORT gt_wish BY st_id se_id.

  CLEAR: gt_temp[], gt_temp.
  MOVE-CORRESPONDING gt_wish[] TO gt_temp[].
  DELETE ADJACENT DUPLICATES FROM gt_temp COMPARING st_id.

  gv_status_txt = |[조회] { p_peryr }학년도 { p_perid }학기 담아놓기|.
  PERFORM set_progtext USING gv_status_txt.

  DESCRIBE TABLE gt_temp LINES gv_tot.
  LOOP AT gt_temp.
    ADD 1 TO gv_cnt.
    ADD 1 TO gv_100_cnt.
    ADD 1 TO gv_1000_cnt.
    IF gv_100_cnt = 100.
      CLEAR: gv_100_cnt, gv_1000_cnt.
      PERFORM set_progress USING sy-tabix.
    ENDIF.

    MOVE-CORRESPONDING gt_temp TO gt_data.
*    gt_data-ctype1 = '담아놓기'.
    SELECT SINGLE regwindow regsemstr book_cdt
      INTO (gt_data-rgwin, gt_data-rgsem, gt_data-bkcdt)
      FROM hrp1705
     WHERE plvar  = '01'
       AND otype  = 'ST'
       AND objid  = gt_data-st_id
       AND begda <= gv_begda "sy-datum
       AND endda >= gv_begda."sy-datum.

*    CLEAR: gt_data-smcnt.

*    DATA lv_cnt TYPE i.
*    LOOP AT gt_wish WHERE st_id = gt_temp-st_id.
*      AT NEW st_id.
*        CLEAR lv_cnt.
*      ENDAT.
*      ADD 1 TO lv_cnt.
*      CASE lv_cnt.
*        WHEN 1.
*          set_se_short: 1 gt_wish-se_short.
*        WHEN 2.
*          set_se_short: 2 gt_wish-se_short.
*        WHEN 3.
*          set_se_short: 3 gt_wish-se_short.
*        WHEN 4.
*          set_se_short: 4 gt_wish-se_short.
*        WHEN 5.
*          set_se_short: 5 gt_wish-se_short.
*        WHEN 6.
*          set_se_short: 6 gt_wish-se_short.
*      ENDCASE.
*      ADD 1 TO gt_data-smcnt.
*
*    ENDLOOP.

    SELECT SINGLE a~sts_cd "현재 학적상태(텍스트) 가져오기
      INTO gt_data-sts_cd
      FROM hrp9530 AS a
     WHERE a~plvar   =  '01'
       AND a~otype   =  'ST'
       AND a~istat   =  '1'
       AND a~begda  <= sy-datum
       AND a~endda  >= sy-datum
       AND a~objid   = gt_data-st_id. "stobjid

    PERFORM get_text_0101 USING    '160' gt_data-sts_cd
                          CHANGING gt_data-sts_cd_txt.
    APPEND gt_data.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  get_text_0101
*&---------------------------------------------------------------------*
FORM get_text_0101  USING    p_grp
                             p_com
                    CHANGING p_txt.

  "//__ASPN08 2024.02.20 :: SORT 구문 추가
  SORT gt_0101 BY grp_cd com_cd.
  READ TABLE gt_0101 WITH KEY grp_cd = p_grp
                              com_cd = p_com
                     BINARY SEARCH.
  IF sy-subrc IS INITIAL.
    p_txt = gt_0101-com_nm.
  ENDIF.

ENDFORM.                    " GET_TEXT_0101
*&---------------------------------------------------------------------*
*&      Form  SET_PROGRESS
*&---------------------------------------------------------------------*
FORM set_progress USING p_cur_cnt.

  DATA: lv_msg TYPE string, c(5),t(5).
  c = p_cur_cnt. t = gv_tot. CONDENSE: c, t.
  CONCATENATE c ` / ` t INTO lv_msg.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = lv_msg
    EXCEPTIONS
      OTHERS = 0.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_PROGTEXT
*&---------------------------------------------------------------------*
FORM set_progtext USING p_msg .

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = p_msg
    EXCEPTIONS
      OTHERS = 0.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_STOBJ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_stobj.

*  CLEAR: s_stobj[], s_stobj.
*  SELECT DISTINCT objid AS low
*    INTO CORRESPONDING FIELDS OF TABLE s_stobj
*    FROM hrp1000
*   WHERE plvar = '01'
*     AND otype = 'ST'
*     AND langu = '3'
*     AND mc_short IN p_stnum.
*  LOOP AT s_stobj.
*    s_stobj-sign   = 'I'.
*    s_stobj-option = 'EQ'.
*    MODIFY s_stobj.
*  ENDLOOP.

ENDFORM.                    " GET_STOBJ
*&---------------------------------------------------------------------*
*& Form get_etc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_etc.

  LOOP AT gt_data.
    SELECT SINGLE short stext "학번/성명
      INTO (gt_data-short, gt_data-stext)
      FROM hrp1000
     WHERE plvar  = '01'
       AND otype  = 'ST'
       AND objid  = gt_data-st_id
       AND langu  = '3'
       AND begda <= sy-datum
       AND endda >= sy-datum.

*    set_smtx: 1,2,3,4,5,6. "과목명
    MODIFY gt_data.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_event_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_event_data.
*--------------------------------------------------------------------*
*//___ # 04.09.2024 14:22:15 #  ZCM_GET_COURSE_DETAIL 로직 추가... __//
*--------------------------------------------------------------------*
*구분(1:소속ID,2:과목그룹ID,3:과목코드,4:과목명,5:과목ID,
*     6:분반코드,7:분반ID,8:교수사번,9:교수명,10:강의실)

*  DATA et_course TYPE TABLE OF zcmscourse.
  DATA ev_error TYPE flag.
  DATA ev_msg TYPE string.
  " 구분(1:소속ID,2:과목그룹ID,3:과목코드,4:과목명,5:과목ID,6:분반코드,7:분반ID,8:교수사번
  zcmcl000=>get_course_detail(
    EXPORTING
      i_peryr   = p_peryr
      i_perid   = p_perid
      i_stype   = '1'
      i_kword   = '30000002' "소속ID
      i_langu   = '3'              "
    IMPORTING
      et_course = gt_evob
      ev_error  = ev_error
      ev_msg    = ev_msg
  ).

  LOOP AT gt_evob INTO gs_evob.
    CONCATENATE gs_evob-smshort '-' gs_evob-seshort
           INTO gs_evob-seshort.
    MODIFY gt_evob FROM gs_evob.
  ENDLOOP.
  SORT gt_evob BY seshort.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_info
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_info.

*{공통코드 설정(학적상태표기), 20170804, 정재현
  SELECT grp_cd com_cd com_nm
    INTO TABLE gt_0101
    FROM zcmt0101
   WHERE grp_cd = '160'.
*}

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_save.

  SELECT *
    INTO TABLE gt_hrpad506
    FROM hrpad506
   WHERE smstatus = '01' "수강신청
     AND bookdate IN ('20250212', '20250213')
     AND peryr = '2025'
     AND perid = '010'.


ENDFORM.
