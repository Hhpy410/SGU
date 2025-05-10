*&---------------------------------------------------------------------*
*&  Include           MZCMR5060F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_modify_screen .
  IF p_orgcd = '30000204' .
  ELSE .
    LOOP AT SCREEN.
      IF screen-group1 = 'MOD' .
        screen-active = 0 .
      ENDIF.

      IF sy-sysid = 'PRD'.
        IF screen-group1 = 'CAN' AND
           sy-uname <> '302444' AND
           sy-uname <> '110638' AND
           sy-uname <> '302221' AND
           sy-uname <> '110100' AND
           sy-uname <> '113034'.
          screen-active = 0 .
        ENDIF.
      ENDIF.

      MODIFY SCREEN.
    ENDLOOP.
  ENDIF .
ENDFORM.                    " SET_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  F4_PYEAR_PERID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f4_pyear_perid .
  CALL FUNCTION 'ZCM_LIST_BOX_PYEAR_PERID'
    EXPORTING
      year_field  = 'P_PERYR'
      perid_field = 'P_PERID'.
ENDFORM.                    " F4_PYEAR_PERID
*&---------------------------------------------------------------------*
*&      Form  CHECK_DATA_AUTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_data_auth .

ENDFORM.                    " CHECK_DATA_AUTH
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_select .
* 학생정보
  PERFORM get_data_student .

* 학생파일 생성여부 확인
*  IF p_old IS NOT INITIAL.
*    PERFORM get_data_reg.
*  ELSE.
  PERFORM get_data_reg_new.
*  ENDIF.


ENDFORM.                    " GET_DATA_SELECT
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_HRP9530
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_reg.
  DATA: lt_hrp9530 LIKE hrp9530 OCCURS 0 WITH HEADER LINE .
  DATA: lt_grid LIKE gt_grid OCCURS 0 WITH HEADER LINE.
  DATA: lv_perid TYPE piqperid .
  DATA: lt_reg TYPE  piqstreg_p_t,
        ls_reg TYPE LINE OF piqstreg_p_t.
  DATA: lt_studies TYPE  TABLE OF piqrfc_study_spec_txt,
        ls_studies TYPE  piqrfc_study_spec_txt.

  DATA: BEGIN OF lt_9580 OCCURS 0,
          objid   TYPE hrobjid,
          zrealwr LIKE hrp9580-zrealwr,
          zwaers  TYPE hrp9580-zwaers,
        END OF lt_9580.
*
  IF p_perid = '010' OR p_perid = '011'.
    lv_perid = '001'.
  ELSE.
    lv_perid = '002'.
  ENDIF.

  DATA(lv_keydate) = gv_begda - 1.

  DATA(lv_msg) = '※' && '대상자를 조회중입니다.'.
  PERFORM display_status(zcms0) USING  '' lv_msg.
*
  IF NOT gt_stru[] IS INITIAL .
    SELECT * INTO TABLE lt_hrp9530
             FROM hrp9530
             FOR ALL ENTRIES IN gt_stru
             WHERE plvar   = '01'
             AND   otype   = 'ST'
             AND   istat   = '1'
             AND   begda  <= gv_endda                 "학사력 시작일
             AND   endda  >= gv_begda                  "학사력 종료일
             AND   objid   = gt_stru-objid             "학번의 objid
             AND   sts_cd IN ('1000','2000','4000')   "재학/수료/휴학
             AND NOT sts_chng_cd IN ('4400','4500')
             AND   pros_cd = '0003'.                  "완료

    SELECT objid zrealwr zwaers
      FROM hrp9580   INTO TABLE lt_9580
      FOR ALL ENTRIES IN gt_stru
     WHERE plvar = '01'
       AND   otype = 'ST'
       AND   objid = gt_stru-objid
       AND   zblart = 'DR'
       AND   zstatus <> '4'
       AND   zperyr = p_peryr
       AND   zperid = p_perid .
    SORT lt_9580 BY objid.
  ENDIF.
*
  SORT lt_hrp9530 BY objid begda DESCENDING .
  DELETE ADJACENT DUPLICATES FROM lt_hrp9530 COMPARING objid.
** 졸업한 경우 제외한다.
* [등록금계산 시점에는 졸업에 대한 학적상태 변동 안되므로]
  LOOP AT lt_hrp9530 .
    SELECT SINGLE * FROM hrp9600
           WHERE plvar = '01'
           AND   otype = 'ST'
           AND   objid = lt_hrp9530-objid
           AND   compl_cd = '2' .
    IF sy-subrc = 0." AND p_canc = ' '.
      DELETE  lt_hrp9530 .
    ENDIF .
  ENDLOOP.

* 복학예정자중 등록대상
  lv_msg = '※' && '복학예정자중 등록대상 조회중입니다.'.
  PERFORM display_status(zcms0) USING  '' lv_msg.

  LOOP AT lt_hrp9530.
    IF lt_hrp9530-sts_cd = '2000'.             "휴학
      IF ( lt_hrp9530-rtn_peryr  <  p_peryr ) OR
         ( lt_hrp9530-rtn_peryr  = p_peryr    AND
           lt_hrp9530-rtn_period <= lv_perid ).

      ELSE.
        DELETE lt_hrp9530 .
      ENDIF.
    ENDIF.
  ENDLOOP.
*
  CLEAR: gt_grid[],gt_grid .
  LOOP AT lt_hrp9530 .
    CLEAR: lt_reg[],ls_reg.
    CALL FUNCTION 'HRIQ_STUDENT_REGIST_READ'
      EXPORTING
        iv_plvar       = '01'
        iv_st_objid    = lt_hrp9530-objid
        iv_first_perid = p_perid
        iv_first_peryr = p_peryr
      IMPORTING
        et_reg_p       = lt_reg.

    DELETE lt_reg WHERE peryr NE p_peryr.
    DELETE lt_reg WHERE perid NE p_perid.

    IF lt_reg[] IS INITIAL.
      gt_grid-st_objid = lt_hrp9530-objid .
      gt_grid-sts_cd   = lt_hrp9530-sts_cd .
      COLLECT gt_grid .  CLEAR gt_grid .
    ELSE .
      SORT lt_reg BY begda DESCENDING .
      LOOP AT lt_reg INTO ls_reg.
        MOVE-CORRESPONDING ls_reg TO gt_grid .
        gt_grid-priority = ls_reg-cs_priox.
        gt_grid-peryr    = ls_reg-peryr.
        gt_grid-perid    = ls_reg-perid.
        gt_grid-sts_cd   = lt_hrp9530-sts_cd .

        IF ls_reg-cancprocess IS INITIAL.
          gt_grid-msgty = 'S' .
          gt_grid-msg   = '등록완료' .
          COLLECT gt_grid .  CLEAR gt_grid .
        ELSE.
          COLLECT gt_grid .  CLEAR gt_grid .
        ENDIF.

      ENDLOOP.

    ENDIF .

  ENDLOOP .

**-미등록 조회
  lv_msg = '※' && '미등록자 조회중입니다.'.
  PERFORM display_status(zcms0) USING  '' lv_msg.


*  CLEAR: gt_grid[],gt_grid .
*
  DATA(lt_stid) = gt_grid[].
  SORT gt_grid BY st_objid.
  DELETE ADJACENT DUPLICATES FROM lt_stid COMPARING st_objid.

  LOOP AT lt_stid INTO DATA(ls_stid).
    PERFORM get_program_of_study TABLES lt_studies
                                 USING  ls_stid-st_objid.

    LOOP AT lt_studies INTO ls_studies.
      READ TABLE gt_grid WITH KEY st_objid = ls_studies-student_objectid
                                  sc_objid = ls_studies-program_objectid.
      IF sy-subrc NE 0..
        CLEAR gt_grid.
        gt_grid-status = icon_red_light. "'@09@'.
        gt_grid-st_objid = ls_studies-student_objectid.
        gt_grid-sc_objid = ls_studies-program_objectid.
        gt_grid-cs_objid = ls_studies-study_objectid.
        gt_grid-group_category = ls_studies-modulegroup_category.
        gt_grid-sts_cd   = ls_stid-sts_cd.

        CASE gt_grid-group_category.
          WHEN 'MAJO'.
            gt_grid-enrcateg = '01'.
          WHEN 'MAJ1'.
            gt_grid-enrcateg = '02'.
          WHEN 'MAJ2'.
            gt_grid-enrcateg = '03'.
          WHEN 'MAJ3'.
            gt_grid-enrcateg = '04'.
        ENDCASE.

        WRITE gt_grid-enrcateg TO gt_grid-priority NO-ZERO.
        CONDENSE gt_grid-priority.

        APPEND gt_grid.
      ELSE.
        gt_grid-status = icon_green_light. "'@08@'.
        gt_grid-sts_cd = ls_stid-sts_cd.
        gt_grid-group_category = ls_studies-modulegroup_category.
        MODIFY gt_grid INDEX sy-tabix.
      ENDIF.
    ENDLOOP.

  ENDLOOP.


  DELETE gt_grid WHERE cs_objid IS INITIAL.
  IF p_none IS NOT INITIAL.
    DELETE gt_grid WHERE regdate IS NOT INITIAL.
  ENDIF.
*

  CHECK gt_grid[] IS NOT INITIAL.

  DATA: BEGIN OF lt_text OCCURS 0,
          otype TYPE otype,
          objid TYPE hrobjid,
          stext TYPE stext,
        END OF lt_text.

  SELECT otype objid stext
    FROM hrp1000 INTO TABLE lt_text
    FOR ALL ENTRIES IN gt_grid
    WHERE plvar = '01'
      AND otype = 'SC' AND objid = gt_grid-sc_objid
      AND istat ='1'
      AND begda <= gv_begda
      AND endda >= gv_endda
      AND langu = '3'.
  SORT lt_text BY otype objid.

*-학생기본정보
*  lv_msg = icon_information && '학생기본정보 조회중입니다.'.
  CONCATENATE '※' '학생기본정보 조회중입니다.' INTO lv_msg.
  PERFORM display_status(zcms0) USING  '' lv_msg.

  DATA lt_stlist TYPE zcmsif98t WITH HEADER LINE.
  lt_stlist[] = CORRESPONDING #( gt_grid[] MAPPING stid = st_objid ).

** 학생 학년 / 학기 취득
  DATA : lt_zcms50 TYPE TABLE OF zcms50 WITH HEADER LINE.
  CALL FUNCTION 'ZCM_GET_ST_YEAR_SESSION'
    EXPORTING
      it_stid   = lt_stlist[]
    TABLES
      et_zcms50 = lt_zcms50[].

*-학위과정
  DATA lt_hrp1702 TYPE TABLE OF hrp1702 WITH HEADER LINE.
  SELECT objid namzu FROM hrp1702
    INTO CORRESPONDING FIELDS OF TABLE lt_hrp1702
    FOR ALL ENTRIES IN gt_grid
    WHERE plvar = '01'
      AND otype = 'ST'
      AND objid = gt_grid-st_objid
      AND istat = '1'
      AND begda <= gv_begda
      AND endda >= gv_begda.

**-학적상태
*  DATA: lt_stobj TYPE hrobject_tab WITH HEADER LINE.
*  DATA: lt_status TYPE zcmcl000=>tt_st_status_cd WITH HEADER LINE.
*  lt_stobj[] = CORRESPONDING #( gt_grid[] MAPPING objid = st_objid ).
*  zcmcl000=>get_st_status(
*    EXPORTING
*      it_stobj    = lt_stobj[]
*      iv_keydate  = gv_begda
*    IMPORTING
*      et_ststatus = lt_status[] ).

*-도메인값
  CLEAR gt_domain[].
  SELECT 'ENRCATEG' AS domanme,
          enrcateg AS key,
          enrcategt AS text
          FROM t7piqenrcategt
    INTO TABLE @gt_domain WHERE spras = '3'.

  SELECT 'CATEGORY' AS domanme,
          category AS key,
          categoryt AS text
          FROM t7piqmodgrpcatt
    APPENDING TABLE @gt_domain WHERE spras = '3'.

  SORT gt_domain BY domname key.

  SELECT * FROM zcmt0101 INTO TABLE @DATA(lt_zcmt0101)
    WHERE grp_cd IN ('103', '160').
  SORT lt_zcmt0101 BY grp_cd com_cd.

  CLEAR: gv_tot, gv_cur.
  gv_tot = lines( gt_grid ).

  LOOP AT gt_grid ASSIGNING FIELD-SYMBOL(<grid>).

    PERFORM set_progress.

* 학생 오브젝ID/학생명/학년
    PERFORM get_student_objectid USING    <grid>-st_objid
                                 CHANGING <grid>-student12
                                          <grid>-name1.
* 소속
    CALL FUNCTION 'ZCM_STUDENT_ORGCD_SEARCH'
      EXPORTING
        e_stobjid = <grid>-st_objid
        e_langu   = sy-langu
        e_endda   = gv_endda
      IMPORTING
        i_orgcd   = <grid>-o_objid
        i_stext   = <grid>-otext.
* 단과대학
    PERFORM get_data_zcolg USING    <grid>-o_objid
                           CHANGING <grid>-zcolg
                                    <grid>-zcolgnm.
* 학년도/학기
    PERFORM get_tepeatid USING    <grid>-st_objid
                                  gv_bperyr
                                  gv_bperid
                         CHANGING <grid>-tepeatid
                                  <grid>-grade.

    READ TABLE lt_text INTO DATA(ls_text) WITH KEY otype = 'SC'
                                                   objid = <grid>-sc_objid.
    IF sy-subrc EQ 0.
      <grid>-sctext = ls_text-stext.
    ENDIF.

* 등록금생성 및 성적확인
    READ TABLE lt_9580 INTO DATA(ls_9580) WITH KEY objid = <grid>-st_objid.
    IF sy-subrc EQ 0.
      <grid>-zrealwr = ls_9580-zrealwr.
      <grid>-zwaers = ls_9580-zwaers.
    ENDIF.

*-학생정보
*      <grid>-crsnmko      = lt_zcms60-crsnmko.
*      <grid>-statnmko     = lt_zcms60-statnmko.

    "현학년 / 현학기
    READ TABLE lt_zcms50 WITH KEY stid = <grid>-st_objid.
    IF sy-subrc EQ 0.
      <grid>-acad_year    = lt_zcms50-acad_year.
      <grid>-acad_session = lt_zcms50-acad_session.
    ENDIF.

    "학위과정
    READ TABLE lt_hrp1702 WITH KEY objid = <grid>-st_objid.
    IF sy-subrc EQ 0.
      READ TABLE lt_zcmt0101 INTO DATA(ls_zcmt0101) WITH KEY grp_cd = '103'
                                                              short = lt_hrp1702-namzu.
      IF sy-subrc EQ 0.
        <grid>-crsnmko = ls_zcmt0101-com_nm.
      ENDIF.
    ENDIF.

    "학적상태
*    READ TABLE lt_status WITH KEY objid = <grid>-st_objid.
*    IF sy-subrc EQ 0.
*      <grid>-statnmko = lt_status-sts_cd_t.
*    ENDIF.
    READ TABLE lt_zcmt0101 INTO ls_zcmt0101 WITH KEY grp_cd = '160'
                                                     com_cd = <grid>-sts_cd.
    IF sy-subrc EQ 0.
      <grid>-statnmko = ls_zcmt0101-com_nm.
    ENDIF.

*-도메인값
    PERFORM get_domain_text USING 'CATEGORY' <grid>-group_category  <grid>-group_categoryt.
    PERFORM get_domain_text USING 'ENRCATEG' <grid>-enrcateg  <grid>-enrcategt.

  ENDLOOP .
*
  SORT gt_grid BY st_objid group_category DESCENDING.


ENDFORM.                    " GET_DATA_HRP9530
*&---------------------------------------------------------------------*
*&      Form  SET_TIMELIMITS_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_timelimits_info .
  DATA: lt_searchtl   TYPE piqsearchtl_tab,
        lt_timelimits TYPE piqtimelimits_tab,
        lt_timeinfo   TYPE zcms023_tab.
  DATA: ls_searchtl   LIKE piqsearchtl,
        ls_timelimits LIKE piqtimelimits,
        ls_timeinfo   LIKE zcms023.

  ls_searchtl = '0100'.

  APPEND ls_searchtl TO lt_searchtl.

  CALL FUNCTION 'ZCM_TIMELIMITS_INFO'
    EXPORTING
      it_searchtl   = lt_searchtl
*     IV_DATUM      = sy-datum
    IMPORTING
      et_timelimits = lt_timelimits
      et_timeinfo   = lt_timeinfo.

  CHECK NOT lt_timeinfo[] IS INITIAL.


  DELETE lt_timeinfo WHERE perid NE '010'
                       AND perid NE '011'
                       AND perid NE '020'
                       AND perid NE '021'.

  LOOP AT lt_timeinfo INTO ls_timeinfo.
    MOVE: ls_timeinfo-peryr TO p_peryr,
          ls_timeinfo-perid TO p_perid.
  ENDLOOP.
ENDFORM.                    " SET_TIMELIMITS_INFO
*&---------------------------------------------------------------------*
*&      Form  GET_USER_AUTHORG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_user_authorg .
  CALL FUNCTION 'ZCM_USER_AUTHORITY'
    EXPORTING
      im_userid             = sy-uname
*     IM_PROFL              =
    TABLES
      itab_auth             = gt_authobj
    EXCEPTIONS
      no_authority_for_user = 1
      OTHERS                = 2.

  IF sy-subrc <> 0.
    MESSAGE ID   sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    STOP.
  ELSE .
    READ TABLE gt_authobj INDEX 1.
    IF sy-subrc = 0.
      p_orgcd = gt_authobj-objid.
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_USER_AUTHORG
*&---------------------------------------------------------------------*
*&      Form  CREATE_DOCKING_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_docking_container .
* Docking Container Object 선언.
  CREATE OBJECT g_docking_container
    EXPORTING
      style     = cl_gui_control=>ws_child
      repid     = sy-cprog                          "현재 프로그램 ID
      dynnr     = sy-dynnr                          "현재 화면번호
      side      = g_docking_container->dock_at_left "CONTAINER POS
      lifetime  = cl_gui_control=>lifetime_imode
      extension = gc_extension                      "CONTAINER SIZE
    EXCEPTIONS
      OTHERS    = 1.
* Splitter Container Object 선언.
  CREATE OBJECT g_splitter
    EXPORTING
      parent  = g_docking_container
      rows    = 1
      columns = 1.                  " 1개의 ROW, 2개의 COLUME
*
*  CALL METHOD g_splitter->set_column_width
*    EXPORTING
*      id    = 1
*      width = 20.

  g_container1  = g_splitter->get_container( row = 1 column = 1 ).
*  g_container2  = g_splitter->get_container( row = 1 column = 2 ).

ENDFORM.                    " CREATE_DOCKING_CONTAINER
*&---------------------------------------------------------------------*
*&      Form  CREATE_GRID_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_grid_object .
* Create Code type ALV List
  CREATE OBJECT g_grid
    EXPORTING
      i_parent      = g_container1
      i_appl_events = 'X'.
* Field_Catalog Define
  PERFORM make_grid_field_catalog USING gt_grid_fcat .
* Sort
  PERFORM make_grid_sort.
*
  PERFORM make_exclude_code USING gt_fcode.
*
  PERFORM register_grid_event.
* Grid event handler 등록
  PERFORM assign_grid_event_handlers.
* Layout
  PERFORM create_grid_layout .
*
  CALL METHOD cl_gui_cfw=>flush.
ENDFORM.                    " CREATE_GRID_OBJECT
*&---------------------------------------------------------------------*
*&      Form  MAKE_GRID_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_gt_sdata_FCAT  text
*----------------------------------------------------------------------*
FORM make_grid_field_catalog  USING  pt_fieldcat TYPE lvc_t_fcat .
  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        ls_fcat     TYPE lvc_s_fcat.
*
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'GT_GRID'
      i_client_never_display = gc_set
      i_inclname             = sy-repid
      i_bypassing_buffer     = gc_set
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc = 0.
    PERFORM transfer_slis_to_lvc CHANGING lt_fieldcat pt_fieldcat.
  ENDIF.
* Modify fieldcatalog
  LOOP AT pt_fieldcat INTO ls_fcat.
    CASE ls_fcat-fieldname.
      WHEN 'ZWAERS' OR 'ST_OBJID' OR 'O_OBJID' OR 'ZCOLG'  .
        ls_fcat-no_out = gc_set .

      WHEN 'STATUS'..
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '상태' .
        ls_fcat-icon = 'X'.

      WHEN 'STUDENT12' .
        ls_fcat-hotspot   = gc_set .
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '학번' .
      WHEN 'NAME1'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '성명' .
*      WHEN 'ZCOLGNM'.
*        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
*        ls_fcat-scrtext_l = ls_fcat-reptext = '모집단위' .
      WHEN 'OTEXT'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '학과' .
      WHEN 'SC_OBJID'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '프로그램' .
      WHEN 'SCTEXT'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '프로그램명' .

      WHEN 'CS_OBJID'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '학업 ID' .


*      WHEN 'PRIORITY'.
*        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
*        ls_fcat-scrtext_l = ls_fcat-reptext = '우선순위' .
      WHEN 'PERYR'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '학년도' .
      WHEN 'PERID'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '학기' .
        ls_fcat-convexit = 'PERI2'.

      WHEN 'REGDATE'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '등록일자' .
        ls_fcat-datatype = 'DATS'.
      WHEN 'ENRCATEG'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '등록유형' .
      WHEN 'ENRCATEGT'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '등록유형명' .
*      WHEN 'PR_STATUS'.
*        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
*        ls_fcat-scrtext_l = ls_fcat-reptext = '상태' .
*      WHEN 'PRS_STATE'.
*        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
*        ls_fcat-scrtext_l = ls_fcat-reptext = '전공상태' .
*      WHEN 'REGCLASS'.
*        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
*        ls_fcat-scrtext_l = ls_fcat-reptext = '등록분류' .
      WHEN 'CANCPROCESS'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '취소 액티비티' .
      WHEN 'GROUP_CATEGORY'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '전공구분' .
      WHEN 'GROUP_CATEGORYT'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '전공구분명' .
      WHEN 'CRSNMKO'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '학위과정' .
      WHEN 'ACAD_YEAR'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '현학년' .
      WHEN 'ACAD_SESSION'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '현학기' .
      WHEN 'STATNMKO'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '학적상태' .

*      WHEN 'MSGTY'.
*        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
*        ls_fcat-scrtext_l = ls_fcat-reptext = '메세지유형' .
      WHEN 'MSG'.
*      ls_fcat-outputlen = '10'.
        ls_fcat-scrtext_s = ls_fcat-scrtext_m =
        ls_fcat-scrtext_l = ls_fcat-reptext = '처리내역' .

      WHEN OTHERS.
        ls_fcat-no_out = 'X'.

    ENDCASE .
    MODIFY pt_fieldcat FROM ls_fcat.
  ENDLOOP.
ENDFORM.                    " MAKE_GRID_FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  TRANSFER_SLIS_TO_LVC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_FIELDCAT  text
*      <--P_PT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM transfer_slis_to_lvc  CHANGING pt_fieldcat TYPE slis_t_fieldcat_alv
                                    pt_field TYPE lvc_t_fcat.

  DATA : lt_fieldcat TYPE kkblo_t_fieldcat.

  CALL FUNCTION 'REUSE_ALV_TRANSFER_DATA'
    EXPORTING
      it_fieldcat = pt_fieldcat
    IMPORTING
      et_fieldcat = lt_fieldcat.

  CALL FUNCTION 'LVC_TRANSFER_FROM_KKBLO'
    EXPORTING
      it_fieldcat_kkblo = lt_fieldcat
    IMPORTING
      et_fieldcat_lvc   = pt_field.
ENDFORM.                    " TRANSFER_SLIS_TO_LVC
*&---------------------------------------------------------------------*
*&      Form  MAKE_GRID_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_grid_sort .
  DATA: ls_sort_wa TYPE lvc_s_sort.
  CLEAR: gt_sort, gt_sort[].

  CLEAR ls_sort_wa .
  ls_sort_wa-fieldname = 'STUDENT12'.
  APPEND ls_sort_wa TO gt_sort.

  CLEAR ls_sort_wa .
  ls_sort_wa-fieldname = 'NAME1'.
  APPEND ls_sort_wa TO gt_sort.

ENDFORM.                    " MAKE_GRID_SORT
*&---------------------------------------------------------------------*
*&      Form  MAKE_EXCLUDE_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FCODE  text
*----------------------------------------------------------------------*
FORM make_exclude_code  USING  pt_fcode TYPE ui_functions.
  DATA: ls_fcode TYPE ui_func.
  CLEAR: pt_fcode, pt_fcode[].
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_fcode TO gt_fcode.
*  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_copy.
*  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_fcode TO gt_fcode.
  ls_fcode  = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_fcode TO gt_fcode.
ENDFORM.                    " MAKE_EXCLUDE_CODE
*&---------------------------------------------------------------------*
*&      Form  REGISTER_GRID_EVENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM register_grid_event .
* 변경이벤트 속성 정의
* Enter event
  CALL METHOD g_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.
* Modify event
  CALL METHOD g_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.
ENDFORM.                    " REGISTER_GRID_EVENT
*&---------------------------------------------------------------------*
*&      Form  ASSIGN_GRID_EVENT_HANDLERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM assign_grid_event_handlers .
* GRID Event receiver object 선언.
  CREATE OBJECT g_event_receiver_grid.
* Double Click
  SET HANDLER g_event_receiver_grid->handle_double_click
                                     FOR g_grid .
* Hotspot Click
  SET HANDLER g_event_receiver_grid->handle_hotspot_click
                                      FOR g_grid .
ENDFORM.                    " ASSIGN_GRID_EVENT_HANDLERS
*&---------------------------------------------------------------------*
*&      Form  CREATE_GRID_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_grid_layout .
  CLEAR gs_layout.
  gs_layout-sel_mode   = 'D' .
  gs_layout-cwidth_opt = 'A' .
ENDFORM.                    " CREATE_GRID_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  ALV_DATA_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_data_display .
*
  CALL METHOD g_grid->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout
      it_toolbar_excluding = gt_fcode
    CHANGING
      it_sort              = gt_sort[]
      it_fieldcatalog      = gt_grid_fcat[]
      it_outtab            = gt_grid[].
ENDFORM.                    " ALV_DATA_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  ALV_REFRESH_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_refresh_grid .
  DATA: gs_scroll TYPE lvc_s_stbl.
*
  CLEAR: gs_scroll.
  gs_scroll-row = 'X'.
  gs_scroll-col = 'X'.
  CALL METHOD g_grid->refresh_table_display
    EXPORTING
      is_stable = gs_scroll.
ENDFORM.                    " ALV_REFRESH_GRID
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_INIT_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_init_info .
* 조직정보
  IF p_orgcd = '30000204' .
    gv_orgcd = p_orgcd2 .
  ELSE .
    gv_orgcd = p_orgcd .
  ENDIF .

* 학사력
  PERFORM get_calendar_id_from_objid USING gv_orgcd
                                           p_peryr
                                           p_perid
                                  CHANGING gv_begda
                                           gv_endda.
ENDFORM.                    " GET_DATA_INIT_INFO
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_1703
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_ITAB_STOBJID  text
*      <--P_P_ITAB_CHGRP  text
*      <--P_P_ITAB_SBPRF  text
*      <--P_P_ITAB_CHTYP  text
*----------------------------------------------------------------------*
FORM get_data_1703  USING    pt_zcmt0502-stobjid
                    CHANGING pv_chgrp
                             pv_sbprf
                             pv_chtyp.

ENDFORM.                    " GET_DATA_1703
*&---------------------------------------------------------------------*
*&      Form  GET_CALENDAR_ID_FROM_OBJID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0733   text
*      -->P_P_PERYR  text
*      -->P_P_PERID  text
*      <--P_GV_BEGDA  text
*      <--P_GV_ENDDA  text
*----------------------------------------------------------------------*
FORM get_calendar_id_from_objid  USING    pv_objid
                                          pv_peryr
                                          pv_perid
                                 CHANGING pv_begda
                                          pv_endda.
* 해당소속 OBJECT ID 로 학사력을 읽어온다
  CALL FUNCTION 'ZCM_CALENDAR_ID_FROM_ORG'
    EXPORTING
      st_objid = pv_objid
      peryr    = pv_peryr
      perid    = pv_perid
    IMPORTING
      begda    = pv_begda
      endda    = pv_endda.

ENDFORM.                    " GET_CALENDAR_ID_FROM_OBJID
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ERROR_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_error_list .
  DATA : lt_fieldcat TYPE slis_t_fieldcat_alv,
         ls_fcat     TYPE slis_fieldcat_alv.

  CLEAR : lt_fieldcat[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'GT_ERROR'
      i_client_never_display = 'X'
      i_inclname             = sy-repid
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
*
  CHECK sy-subrc = 0.
  LOOP AT lt_fieldcat INTO ls_fcat.
    CASE ls_fcat-fieldname.
      WHEN 'CODE1'.
        ls_fcat-seltext_l = ls_fcat-seltext_m =
        ls_fcat-seltext_s = '학번'.
      WHEN 'ETEXT'.
        ls_fcat-seltext_l = ls_fcat-seltext_m =
        ls_fcat-seltext_s = '에러내역'.
    ENDCASE.
    MODIFY lt_fieldcat FROM ls_fcat.
  ENDLOOP.
*
  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title       = TEXT-t01
      i_tabname     = 'GT_ERROR'
      it_fieldcat   = lt_fieldcat
    TABLES
      t_outtab      = gt_error
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.

ENDFORM.                    " DISPLAY_ERROR_LIST
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_STUDENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_student .
  DATA: lt_cmacbpst LIKE cmacbpst OCCURS 0 WITH HEADER LINE .
  CLEAR: gt_stru[],gt_stru.
  IF NOT s_stno12[] IS INITIAL .
    SELECT * INTO TABLE lt_cmacbpst
             FROM cmacbpst
             WHERE student12 IN s_stno12 .
    IF sy-subrc = 0 .
      LOOP AT lt_cmacbpst .
        gt_stru-objid = lt_cmacbpst-stobjid  .
        COLLECT gt_stru .  CLEAR gt_stru .
      ENDLOOP .
    ENDIF .
  ELSE .
    CALL FUNCTION 'ZRHPH_STRUCTURE_READ'
      EXPORTING
        plvar             = '01'
        otype             = 'O'
        objid             = gv_orgcd
*       wegid             = 'ORGEH'
        begda             = gv_endda
        endda             = gv_endda
      TABLES
        stru_tab          = gt_stru
      EXCEPTIONS
        catalogue_problem = 1
        root_not_found    = 2
        wegid_not_found   = 3
        OTHERS            = 4.
    IF gt_stru[] IS INITIAL.
      MESSAGE s101.
      STOP .
    ENDIF .
  ENDIF .
ENDFORM.                    " GET_DATA_STUDENT
*&---------------------------------------------------------------------*
*&      Form  GET_ACAD_READ_TIMELIMITS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_SDATE  text
*      -->P_LV_EDATE  text
*----------------------------------------------------------------------*
FORM get_acad_read_timelimits  USING pv_sdate
                                     pv_edate.
  DATA: lt_searchtl   TYPE piqsearchtl_tab,
        lt_timelimits TYPE piqtimelimits_tab,
        lt_timeinfo   TYPE zcms023_tab.
  DATA: lv_timepoint  TYPE piqtimepoint,
        ls_searchtl   LIKE piqsearchtl,
        ls_timelimits LIKE piqtimelimits,
        ls_timeinfo   LIKE zcms023.
  DATA: ls_ca_object  TYPE hrobject.
  DATA: lv_subrc LIKE sy-subrc .
  CLEAR: ls_searchtl.
  lv_timepoint = '0400' .
  ls_searchtl = lv_timepoint .
  APPEND ls_searchtl TO lt_searchtl.

  ls_ca_object-plvar = '01'.
  ls_ca_object-otype = 'CA'.
  ls_ca_object-objid = '20000000'.

  CALL FUNCTION 'HRIQ_ACAD_READ_TIMELIMITS'
    EXPORTING
      iv_timepoint             = lv_timepoint
*     IV_TARGET_DATE           = SY-DATUM
      iv_peryr                 = p_peryr
      iv_perid                 = p_perid
      is_ca_object             = ls_ca_object
      it_searchtl              = lt_searchtl
      iv_get_fact              = 0
    IMPORTING
      et_timelimits            = lt_timelimits
      ev_subrc                 = lv_subrc
    EXCEPTIONS
      no_start_object_imported = 1
      customizing_incomplete   = 2
      invalid_ca_object        = 3
      no_eval_path             = 4
      relative_timelimit_error = 5
      no_data_found            = 6
      internal_error           = 7
      OTHERS                   = 8.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE .
    CHECK NOT lt_timelimits[] IS INITIAL.
    LOOP AT lt_timelimits INTO ls_timelimits .
      MOVE: ls_timelimits-ca_lbegda TO pv_sdate,
            ls_timelimits-ca_lendda TO pv_edate.
    ENDLOOP.

  ENDIF.
ENDFORM.                    " GET_ACAD_READ_TIMELIMITS
*&---------------------------------------------------------------------*
*&      Form  GET_STUDENT_OBJECTID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_DATA_OBJID  text
*      <--P_LT_ZCMT0700_STUDENT  text
*      <--P_LT_ZCMT0700_NAME1  text
*----------------------------------------------------------------------*
FORM get_student_objectid  USING    pv_stobjid
                           CHANGING pv_student12
                                    pv_name.

  SELECT SINGLE a~student12 b~stext INTO (pv_student12,pv_name)
         FROM cmacbpst AS a
          JOIN hrp1000 AS b ON b~objid = a~stobjid
         WHERE a~stobjid = pv_stobjid
         AND   b~plvar     = '01'
         AND   b~otype     = 'ST'
         AND   b~istat     = '1'
         AND   b~endda    >= sy-datum
         AND   b~langu     = sy-langu.
ENDFORM.                    " GET_STUDENT_OBJECTID
*&---------------------------------------------------------------------*
*&      Form  ORGCD_F4_ENTRY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM orgcd_f4_entry .
  DATA: lt_data LIKE zcmt5001 OCCURS 0 WITH HEADER LINE.
  DATA: lt_fields LIKE help_value OCCURS 0 WITH HEADER LINE.
  DATA: BEGIN OF lt_f4 OCCURS 0,
          objid LIKE hrp9580-objid,
          orgtx LIKE zcmt5001-orgtx,
        END OF lt_f4.
  DATA: lv_selectfield LIKE help_info-fieldname,
        lv_selectvalue LIKE  help_info-fldvalue,
        lv_idx         LIKE sy-tabix.
*
  CLEAR: lv_selectvalue,lv_selectfield .
  CALL FUNCTION 'ZCM_F4IF_ORGCD_DATA'
    TABLES
      lt_zcmt5001 = lt_data.
  LOOP AT lt_data .
    lt_f4-objid = lt_data-orgcd .
    lt_f4-orgtx = lt_data-orgtx .
    COLLECT lt_f4 .  CLEAR lt_f4 .
  ENDLOOP .
*
  SORT lt_f4 .
* 화면에서 읽기
  CLEAR: lt_fields, lt_fields[].
  lt_fields-tabname    = 'HRP9580'.
  lt_fields-fieldname  = 'OBJID'.
  lt_fields-selectflag = 'X'.
  APPEND lt_fields.
  CLEAR: lt_fields.
  lt_fields-tabname    = 'ZCMT5001'.
  lt_fields-fieldname  = 'ORGTX'.
  lt_fields-selectflag = ' '.
  APPEND lt_fields.
*
  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      selectfield                  = lv_selectfield
    IMPORTING
      ind                          = lv_idx
      select_value                 = lv_selectvalue
    TABLES
      fields                       = lt_fields
      full_table                   = lt_f4
    EXCEPTIONS
      full_table_empty             = 1
      no_tablestructure_given      = 2
      no_tablefields_in_dictionary = 3
      more_then_one_selectfield    = 4
      no_selectfield               = 5
      OTHERS                       = 6.

  CHECK NOT lv_idx IS INITIAL.
  READ TABLE lt_f4 INDEX lv_idx.
  p_orgcd = lt_f4-objid.

ENDFORM.                    " ORGCD_F4_ENTRY
*&---------------------------------------------------------------------*
*&      Form  ORGCD2_F4_ENTRY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM orgcd2_f4_entry .
  DATA: lt_fields LIKE help_value OCCURS 0 WITH HEADER LINE.
  DATA: BEGIN OF lt_f4 OCCURS 0,
          objid  LIKE hrp9580-objid,
          com_nm LIKE zcmt0101-com_nm,
        END OF lt_f4.
  DATA: lv_selectfield LIKE help_info-fieldname,
        lv_selectvalue LIKE  help_info-fldvalue,
        lv_idx         LIKE sy-tabix.
*
  CLEAR: lv_selectvalue,lv_selectfield .
*
  lt_f4-objid  = '30000205'.
  lt_f4-com_nm = '주간MBA' . APPEND lt_f4 .
  lt_f4-objid  = '30000206'.
  lt_f4-com_nm = '박사MBA' . APPEND lt_f4 .
  lt_f4-objid  = '30000207'.
  lt_f4-com_nm = '야간MBA' . APPEND lt_f4 .
  lt_f4-objid  = '30000208'.
  lt_f4-com_nm = 'E-MBA' .   APPEND lt_f4 .
  lt_f4-objid  = '50000252'.
  lt_f4-com_nm = '경영컨설팅학과' .   APPEND lt_f4 .
  lt_f4-objid  = '50000254'.
  lt_f4-com_nm = '서비스시스템경영공학' .   APPEND lt_f4 .
  lt_f4-objid  = '50001401'.
  lt_f4-com_nm = '금융 E-MBA' .   APPEND lt_f4 .

*
  SORT lt_f4 .
* 화면에서 읽기
  CLEAR: lt_fields, lt_fields[].
  lt_fields-tabname    = 'HRP9580'.
  lt_fields-fieldname  = 'OBJID'.
  lt_fields-selectflag = 'X'.
  APPEND lt_fields.
  CLEAR: lt_fields.
  lt_fields-tabname    = 'ZCMT0101'.
  lt_fields-fieldname  = 'COM_NM'.
  lt_fields-selectflag = ' '.
  APPEND lt_fields.
*
  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      selectfield                  = lv_selectfield
    IMPORTING
      ind                          = lv_idx
      select_value                 = lv_selectvalue
    TABLES
      fields                       = lt_fields
      full_table                   = lt_f4
    EXCEPTIONS
      full_table_empty             = 1
      no_tablestructure_given      = 2
      no_tablefields_in_dictionary = 3
      more_then_one_selectfield    = 4
      no_selectfield               = 5
      OTHERS                       = 6.

  CHECK NOT lv_idx IS INITIAL.
  READ TABLE lt_f4 INDEX lv_idx.
*
  p_orgcd2 = lt_f4-objid.
ENDFORM.                    " ORGCD2_F4_ENTRY
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_ZCOLG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_DATA_ZDEPT  text
*      <--P_GT_DATA_ZCOLG  text
*      <--P_GT_DATA_ZCOLGNM  text
*----------------------------------------------------------------------*
FORM get_data_zcolg  USING    pv_zdept
                     CHANGING pv_zcolg
                              pv_zcolgnm .
*                              pv_oobjid .
  DATA: lv_sobid LIKE hrp1001-sobid .
*
  SELECT SINGLE b~objid c~stext INTO (pv_zcolg,pv_zcolgnm)
         FROM hrp1001 AS a
          JOIN hrp1001 AS b ON  a~sclas = b~otype
                            AND a~sobid = b~objid
                            AND a~plvar = b~plvar
          JOIN hrp1000 AS c ON  b~plvar = c~plvar
                            AND b~objid = c~objid
                            AND b~otype = c~otype
         WHERE a~otype = 'SC'
         AND   a~objid = pv_zdept
         AND   a~plvar = '01'
         AND   a~endda >= gv_begda
         AND   a~sclas = 'O'
         AND   b~endda >= gv_begda
         AND   b~sclas = 'O'
         AND   c~endda >= gv_begda .

  IF sy-subrc IS NOT INITIAL.
    IF gt_grid-otext IS NOT INITIAL.
      pv_zcolgnm = gt_grid-otext.
      pv_zcolg = gt_grid-o_objid.
    ELSE.

      SELECT SINGLE b~objid b~stext INTO (pv_zcolg,pv_zcolgnm)
             FROM hrp1001 AS a
              JOIN hrp1000 AS b ON  a~sclas = b~otype
                                AND a~sobid = b~objid
                                AND a~plvar = b~plvar
             WHERE a~otype = 'O'
             AND   a~objid = pv_zdept
             AND   a~plvar = '01'
             AND   a~rsign = 'A'
             AND   a~relat = '002'
             AND   a~sclas = 'O'
             AND   a~endda >= gv_begda
             AND   b~endda >= gv_begda .
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_DATA_ZCOLG
*&---------------------------------------------------------------------*
*&      Form  GET_TEPEATID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_HRP9580_OBJID  text
*      -->P_GV_BPERYR  text
*      -->P_GV_BPERID  text
*      <--P_GT_DATA_TEPEATID  text
*      <--P_GT_DATA_GRADE  text
*----------------------------------------------------------------------*
FORM get_tepeatid  USING   pv_stobjid
                            pv_peryr
                            pv_perid
                   CHANGING pv_tepeatid
                            pv_grade.
  CLEAR: pv_tepeatid, pv_grade.
  CALL FUNCTION 'ZCM_STUDENT_TEPEATID_CALCULATE'
    EXPORTING
      e_stobjid = pv_stobjid
      e_begda   = gv_begda
      e_endda   = gv_endda
      e_peryr   = pv_peryr
      e_perid   = pv_perid
    IMPORTING
      i_grade   = pv_grade
      i_hakgi   = pv_tepeatid.
ENDFORM.                    " GET_TEPEATID
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID_INDEX  text
*      -->P_E_COLUMN_ID_FIELDNAME  text
*----------------------------------------------------------------------*
FORM display_hotspot_click  USING  p_row    LIKE lvc_s_row-index
                                   p_column LIKE lvc_s_col-fieldname.
  READ TABLE gt_grid INDEX p_row.
  CASE p_column .
    WHEN 'STUDENT12' .
      CHECK NOT gt_grid-st_objid IS INITIAL .
      PERFORM call_transaction_piqst00(zcmsubpool) USING
      gt_grid-st_objid .
  ENDCASE .
ENDFORM.                    " DISPLAY_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA_registration
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_data_registration .
  DATA: lv_lines TYPE i .
  DATA: lt_row_no TYPE lvc_t_roid,
        ls_row_no TYPE lvc_s_roid.
  DATA: lv_msgty    TYPE sy-msgty,
        lv_msg(100),
        lv_return   TYPE sy-subrc,
        lv_check    TYPE c,
        lv_tabix    TYPE sy-tabix.
  DATA: lt_return TYPE bapiret2_t,
        ls_return TYPE bapiret2.
  DATA: ls_stregper  TYPE piqstregper_p .
  DATA: lv_subrc LIKE sy-subrc .
  DATA: lv_elog(1).
  DATA: lt_reg TYPE piqstreg_p_t.
* 기존에 선택한 정보 Clear
  gt_grid-check  = ' ' .
  MODIFY gt_grid TRANSPORTING check WHERE check = 'X' .
*
  IF lcl_common IS INITIAL.
    CREATE OBJECT lcl_common.
  ENDIF.
*
  CLEAR: lt_row_no[],lt_row_no,gt_error[],gt_error.
  CALL METHOD g_grid->get_selected_rows
    IMPORTING
      et_row_no = lt_row_no.
* 복수라인 선택한다
  DESCRIBE TABLE lt_row_no LINES lv_lines.
  IF lv_lines = 0 .
    MESSAGE e318 .
  ELSE .
    LOOP AT lt_row_no INTO ls_row_no .
      READ TABLE gt_grid INDEX ls_row_no-row_id .
      IF sy-subrc = 0 AND gt_grid-regdate IS INITIAL.
        IF gt_grid-msgty = ' ' .
          gt_grid-check = 'X' .
          MODIFY gt_grid INDEX sy-tabix .
        ENDIF .
      ENDIF .
    ENDLOOP .
  ENDIF .

  READ TABLE gt_grid WITH KEY check = 'X' .
  IF sy-subrc = 0 .
    PERFORM data_popup_to_confirm_yn USING gv_answer
                                           TEXT-p01
                                           TEXT-p02 .
    IF gv_answer = gc_answer .
      SORT gt_grid BY st_objid .
      LOOP AT gt_grid WHERE check = 'X' .
        CLEAR: ls_stregper,lt_return,lv_return,lv_msgty,lv_msg.
        PERFORM check_lock_object USING lv_elog .
        IF lv_elog IS INITIAL .
          PERFORM data_objid_enqueue USING gt_grid-st_objid
                                           'ST'
                                           lv_subrc .
          PERFORM registration_fill_data USING ls_stregper.
          PERFORM registration_process   TABLES lt_return
                                         USING  ls_stregper
                                                lv_return.
          IF lv_return IS INITIAL.
            READ TABLE lt_return INTO ls_return WITH KEY type = 'S'.
            lv_msgty = 'S'.
            lv_msg   = '등록완료'.

            CALL FUNCTION 'HRIQ_STUDENT_REGIST_READ'
              EXPORTING
                iv_plvar       = '01'
                iv_st_objid    = gt_grid-st_objid
                iv_first_perid = p_perid
                iv_first_peryr = p_peryr
              IMPORTING
                et_reg_p       = lt_reg.

            gt_grid-status  = '@08@'.

            READ TABLE lt_reg INTO DATA(ls_reg) WITH KEY st_objid = gt_grid-st_objid
                                                         sc_objid = gt_grid-sc_objid.
            IF sy-subrc EQ 0..
              gt_grid-regdate     = ls_reg-regdate.
              gt_grid-pr_status   = ls_reg-pr_status.
              gt_grid-prs_state   = ls_reg-prs_state.
              gt_grid-priority    = ls_reg-cs_priox.
              gt_grid-peryr       = ls_reg-peryr.
              gt_grid-perid       = ls_reg-perid.
              gt_grid-enrcateg    = ls_reg-enrcateg.
              gt_grid-regclass    = ls_reg-regclass.
              gt_grid-cancprocess = ls_reg-cancprocess.
            ENDIF.

          ELSE.
            READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.
            lv_msgty = ls_return-type.
            lv_msg   = ls_return-message.
          ENDIF.

          gt_grid-msgty = lv_msgty.
          gt_grid-msg   = lv_msg .
          MODIFY gt_grid .
          PERFORM data_objid_dequeue USING gt_grid-st_objid
                                           'ST' .
          CLEAR gt_grid .
        ENDIF .

        WAIT UP TO '0.1' SECONDS.

      ENDLOOP .
    ENDIF .
  ELSE .
    MESSAGE e000 WITH '등록할 데이터가 없습니다.'.
  ENDIF .
ENDFORM.                    " SAVE_DATA_registration
*&---------------------------------------------------------------------*
*&      Form  REGISTRATION_FILL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_STREGPER  text
*----------------------------------------------------------------------*
FORM registration_fill_data  USING ps_stregper  TYPE  piqstregper_p .

  CLEAR ps_stregper.
  ps_stregper-st_objid  = gt_grid-st_objid.
  ps_stregper-sc_objid  = gt_grid-sc_objid.
  ps_stregper-cs_objid  = gt_grid-cs_objid.
  ps_stregper-begda     = gv_begda.
  ps_stregper-endda     = gv_endda.
  ps_stregper-peryr     = p_peryr.
  ps_stregper-perid     = p_perid.
  ps_stregper-cs_priox  = gt_grid-priority.           "Main
  ps_stregper-enrcateg  = gt_grid-enrcateg."'01'.
* ps_stregper-regdate   = gv_begda.      " 학사력 시작일
  ps_stregper-regdate   = sy-datum.

*  READ TABLE gt_objid WITH KEY st_objid = gt_grid-st_objid.
  IF gt_grid-sts_cd = '4000'.
    ps_stregper-regclass = '04'.
  ENDIF.
ENDFORM.                    " REGISTRATION_FILL_DATA
*&---------------------------------------------------------------------*
*&      Form  DATA_POPUP_TO_CONFIRM_YN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_ANSWER  text
*      -->P_TEXT_P03  text
*      -->P_TEXT_P04  text
*----------------------------------------------------------------------*
FORM data_popup_to_confirm_yn  USING pv_answer
                                     pv_text01
                                     pv_text02 .
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption  = 'Y'
      textline1      = pv_text02
*     TEXTLINE2      = ' '
      titel          = pv_text01
      start_column   = 25
      start_row      = 6
      cancel_display = 'X'
    IMPORTING
      answer         = pv_answer.
ENDFORM.                    " DATA_POPUP_TO_CONFIRM_YN
*&---------------------------------------------------------------------*
*&      Form  CHECK_TELNOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_telnos .

  DATA : l_chk2  TYPE  c .

  IF NOT zxit0010-phone IS INITIAL .
    PERFORM telno_numerchk USING zxit0010-phone
                                 l_chk2 .
    IF l_chk2 = 'E' .
      MESSAGE '전화번호는 숫자로만 입력되어야 합니다.'
                                      TYPE 'E' .
    ENDIF .
  ENDIF .

  IF NOT zxit0010-callback_no IS INITIAL .
    PERFORM telno_numerchk USING zxit0010-callback_no
                                 l_chk2 .
    IF l_chk2 = 'E' .
      MESSAGE '회신번호는 숫자로만 입력되어야 합니다.' TYPE 'E' .
    ENDIF .
  ENDIF .

ENDFORM.                    " CHECK_TELNOS
*&---------------------------------------------------------------------*
*&      Form  TELNO_NUMERCHK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZXIT0010_PHONE  text
*      -->P_L_CHK2  text
*----------------------------------------------------------------------*
FORM telno_numerchk   USING    p_number
                              p_chk.
  DATA: l_number_in      LIKE sph_call-no_dialed,
        l_number_out     LIKE sph_call-no_dialed,
        allowed_char(39) VALUE '0123456789',
        l_char_len       TYPE i,
        l_num_len        TYPE i,
        l_pos            TYPE i,
        l_cnt            TYPE i.

  CLEAR : p_chk .

  l_cnt = 1 .

  MOVE p_number TO l_number_in.
  CLEAR l_number_out.
  CONDENSE l_number_in NO-GAPS.
  TRANSLATE l_number_in TO UPPER CASE.                   "#EC TRANSLANG
  IF l_number_in CN allowed_char.
    l_num_len = strlen( l_number_in ).
    l_pos = 0.
    WHILE l_pos < l_num_len.
      l_char_len = charlen( l_number_in+l_pos ).
      IF l_number_in+l_pos(l_char_len) CO allowed_char.
      ELSE .
        p_chk = 'E' .
        RETURN .
      ENDIF.
      ADD l_char_len TO l_pos.
    ENDWHILE.
  ENDIF.

ENDFORM.                    " TELNO_NUMERCHK
*&---------------------------------------------------------------------*
*&      Form  CHECK_PROC_CONTINUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_Z_ANSWER  text
*----------------------------------------------------------------------*
FORM check_proc_continue  USING   $answer.

  DATA: l_defaultoption, l_textline1(70),  l_textline2(70).

  CLEAR: $answer.

  l_defaultoption = 'N'.
  l_textline1     = TEXT-101.

  PERFORM popup_to_confirm(zcmsubpool)
    USING l_defaultoption l_textline1 l_textline2 z_return.

  CHECK z_return  EQ 'J'.    "Yes
  $answer = 'X'.
ENDFORM.                    " CHECK_PROC_CONTINUE
*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT_SMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_CHK2  text
*----------------------------------------------------------------------*
FORM check_input_sms  USING    p_chk.

  CLEAR : p_chk.

  IF zxit0010-userid IS INITIAL .
    MESSAGE '발송자아이디를 입력하세요' TYPE 'S' .
    p_chk = 'E' .
    RETURN .
  ENDIF .

  IF zxit0010-subject IS INITIAL .
    MESSAGE 'SMS_제목을 입력하세요' TYPE 'S' .
    p_chk = 'E' .
    RETURN .
  ENDIF .

  IF zxit0010-name IS INITIAL .
    MESSAGE 'SMS_발송자이름을 입력하세요' TYPE 'S' .
    p_chk = 'E' .
    RETURN .
  ENDIF .

  IF zxit0010-content IS INITIAL .
    MESSAGE '메시지내용을 입력하세요' TYPE 'S' .
    p_chk = 'E' .
    RETURN .
  ENDIF .

  IF zxit0010-callback_no IS INITIAL .
    MESSAGE '회신번호를 입력하세요' TYPE 'S' .
    p_chk = 'E' .
    RETURN .
  ELSE .
    PERFORM telno_numerchk USING zxit0010-callback_no
                                 p_chk .
    IF p_chk = 'E' .
      MESSAGE '회신번호는 숫자로만 입력되어야 합니다.' TYPE 'S' .
      RETURN .
    ENDIF .
  ENDIF .

  IF zxit0010-indate  IS INITIAL .
    MESSAGE 'SMS_전송일자를 입력하세요' TYPE 'S' .
    p_chk = 'E' .
    RETURN .
  ENDIF .

  IF zxit0010-intime  IS INITIAL .
    MESSAGE 'SMS_전송시간을 입력하세요' TYPE 'S' .
    p_chk = 'E' .
    RETURN .
  ENDIF .

ENDFORM.                    " CHECK_INPUT_SMS
*&---------------------------------------------------------------------*
*&      Form  SEND_SMS_PROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_sms_proc .

*DATA   :   l_jobtype     TYPE char1,
*             l_retcode     TYPE char1,
*             l_msg         TYPE char255,
*             l_phone       TYPE char20,
*             l_callback_no TYPE char20.
*
*  CLEAR : l_retcode, l_msg, gt_log, gt_log[].
*
*  l_jobtype = '1'.
*  l_phone   = zxit0010-phone .
*  l_callback_no = zxit0010-callback_no.
*
*  LOOP AT gt_grid WHERE mark = 'X'
*                  AND   augbd <> '00000000'.
*    IF  gt_grid-caller_no IS INITIAL.
*      MOVE-CORRESPONDING gt_grid TO result_itab.
*      result_itab-zled = '@0A@'.
*      result_itab-text = '핸드폰번호누락자'.
*      APPEND result_itab.
*      CLEAR  result_itab.
*    ELSEIF gt_grid-caller_no+0(2) <> '01'.
*      MOVE-CORRESPONDING gt_grid TO result_itab.
*      result_itab-zled = '@0A@'.
*      result_itab-text = '핸드폰번호이상자'.
*      APPEND result_itab.
*      CLEAR result_itab.
*    ELSE.
*      CLEAR : l_phone.
*      MOVE itab-caller_no TO l_phone.
*
*      CALL FUNCTION 'ZXI_PUSH_SMS'
*        EXPORTING
*          i_jobtype     = l_jobtype
*          i_userid      = zxit0010-userid
*          i_phone       = l_phone
*          i_subject     = zxit0010-subject
*          i_name        = zxit0010-name
*          i_content     = zxit0010-content
*          i_callback_no = l_callback_no
*          i_rev_date    = zxit0010-indate
*          i_rev_time    = zxit0010-intime
*        IMPORTING
*          e_retcode     = l_retcode
*          e_msg         = l_msg.
*
*      CLEAR gt_log.
*      IF l_retcode = 'Y'.
*        gt_log-message = 'SMS발송 성공!!'.
*        MOVE-CORRESPONDING itab TO result_itab.
*        result_itab-zled = '@08@'.
*        result_itab-text = 'SMS발송 성공!!'.
*        APPEND result_itab.
*        CLEAR  result_itab.
*      ELSE.
*        gt_log-message = l_msg.
*        MOVE-CORRESPONDING itab TO result_itab.
*        result_itab-zled = '@0A@'.
*        result_itab-text = gt_log-message.
*        APPEND result_itab.
*        CLEAR  result_itab.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.


ENDFORM.                    " SEND_SMS_PROC
*&---------------------------------------------------------------------*
*&      Form  REGISTRATION_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_RETURN  text
*      -->P_LS_STREGPER  text
*      -->P_LV_RETURN  text
*----------------------------------------------------------------------*
FORM registration_process  TABLES  pt_return    TYPE  bapiret2_t
                           USING   ps_stregper  TYPE  piqstregper_p
                                   p_return.

  DATA : ev_return TYPE  sy-subrc,
         et_return TYPE  bapiret2_t.

  CALL FUNCTION 'HRIQ_STUDENT_REG_CREATE_DB'
    EXPORTING
      plvar            = '01'
      iv_process       = 'RK01'
      is_stregper      = ps_stregper
      check_only       = ' '
      rule_check       = 'X'
*     VTASK            = 'D'
*     IV_LOG_HANDLE    =
      iv_mode          = 'D'
*     IV_CHECKS_INIT   = 'X'
      iv_commit        = 'X'
*     IV_NO_DB_UPDATE  = ' '
    IMPORTING
*     RESULT_VSR       =
      ev_result        = ev_return
      et_return        = et_return
*     EV_CS_OBJID      =
    EXCEPTIONS
      internal_error   = 1
      no_authorisation = 2
      corr_exit        = 3
      cancelled        = 4
      OTHERS           = 5.

  IF ev_return <> 0.
    p_return = ev_return.
    APPEND LINES OF et_return TO pt_return.
  ENDIF.

ENDFORM.                    " REGISTRATION_PROCESS
*&---------------------------------------------------------------------*
*&      Form  GET_PROGRAM_OF_STUDY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_STUDIES  text
*      -->P_GT_GRID_ST_OBJID  text
*----------------------------------------------------------------------*
FORM get_program_of_study  TABLES pt_studies  STRUCTURE  piqrfc_study_spec_txt"piqstudies_t
                            USING  p_st_objid.

  DATA : lt_speci_text LIKE piqrfc_study_spec_txt OCCURS 0 WITH HEADER
  LINE.

  CLEAR: pt_studies, pt_studies[].

* Read Study and Admission Data
  CALL FUNCTION 'HRIQ_STUDENT_STUDIES_GET_RFC'
    EXPORTING
      objectid             = p_st_objid
      planversion          = '01'
*     begda                =
*     endda                =
      acad_year            = p_peryr
      acad_session         = p_perid
*     READ_STUDYSEGMENTS   =
*     READ_SESSIONAL_REGISTS        =
*     READ_ADMISSIONS      =
      read_modulegroups    = 'X'
*     READ_ANTICIP_GRADUATION       =
      read_texts           = 'X'
*     LANGUAGE             = SY-LANGU
    TABLES
*     STUDYSEGMENTS        =
*     STUDYSEGMENTS_TEXT   =
*     SESSIONAL_REGISTS    =
*     SESSIONAL_REGISTS_TEXT        =
*     ADMISSIONS           =
*     ADMISSIONS_TEXT      =
*     SPECIALIZATIONS      =
      specializations_text = pt_studies[].
*     ANTICIP_GRADUATION            =
*     ANTICIP_GRADUATION_TEXT       =
*     RETURN                        =

*  IF sy-subrc = 0.
**    IF p_reg = 'X'.
**---- 등록 Reg. -> 전공만 생성
**    LOOP AT  lt_speci_text  WHERE modulegroup_category = 'MAJO'
**                            AND   endda >= sy-datum.
*    LOOP AT  lt_speci_text  WHERE endda >= sy-datum.
*      MOVE :   '01'                           TO  pt_studies-plvar,
*               lt_speci_text-student_objectid TO  pt_studies-st_objid,
*               lt_speci_text-study_objectid   TO  pt_studies-cs_objid,
*               lt_speci_text-program_objectid TO  pt_studies-sc_objid.
*
*      IF lt_speci_text-modulegroup_category = 'MAJO'.
*        pt_studies-priox = '01'.
*      ELSE.
*        pt_studies-priox = '02'.
*      ENDIF.
*
*      APPEND  pt_studies.
*    ENDLOOP.
*  ENDIF.


*  DELETE pt_studies  WHERE endda < sy-datum.

ENDFORM.                    " GET_PROGRAM_OF_STUDY
*&---------------------------------------------------------------------*
*&      Form  SAVE_CANCEL_REGISTRATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_cancel_registration .
  DATA: lv_lines TYPE i .
  DATA: lt_row_no TYPE lvc_t_roid,
        ls_row_no TYPE lvc_s_roid.
  DATA : lv_msgty    TYPE sy-msgty,
         lv_msg(100),
         lv_return   TYPE sy-subrc,
         lv_check    TYPE c,
         lv_tabix    TYPE sy-tabix.
  DATA : lt_return TYPE bapiret2_t,
         ls_return TYPE bapiret2.
  DATA : ls_stregper  TYPE piqstregper_p .
  DATA: lv_subrc LIKE sy-subrc .
  DATA: lv_elog(1).
* 기존에 선택한 정보 Clear
  gt_grid-check  = ' ' .
  MODIFY gt_grid TRANSPORTING check WHERE check = 'X' .
*
  IF lcl_common IS INITIAL.
    CREATE OBJECT lcl_common.
  ENDIF.
*
  CLEAR: lt_row_no[],lt_row_no,gt_error[],gt_error.
  CALL METHOD g_grid->get_selected_rows
    IMPORTING
      et_row_no = lt_row_no.
* 복수라인 선택한다
  DESCRIBE TABLE lt_row_no LINES lv_lines.
  IF lv_lines = 0 .
    MESSAGE e318 .
  ELSE .
    LOOP AT lt_row_no INTO ls_row_no .
      READ TABLE gt_grid INDEX ls_row_no-row_id .
      IF sy-subrc = 0 AND gt_grid-regdate IS NOT INITIAL.
        IF gt_grid-msgty = 'S' .
          gt_grid-check  = 'X' .
          MODIFY gt_grid INDEX sy-tabix .
        ENDIF .
      ENDIF .

    ENDLOOP .
  ENDIF .

  READ TABLE gt_grid WITH KEY check = 'X' .
  IF sy-subrc = 0 .
    PERFORM data_popup_to_confirm_yn USING gv_answer
                                           TEXT-p01
                                           TEXT-p03 .
    IF gv_answer = gc_answer .
      LOOP AT gt_grid WHERE check = 'X' .
        CLEAR: lt_return,lv_return,lv_msgty,lv_msg.
        PERFORM check_lock_object USING lv_elog .
        IF lv_elog IS INITIAL .
          PERFORM data_objid_enqueue USING gt_grid-st_objid
                                           'ST'
                                           lv_subrc .
          PERFORM de_registration_process TABLES lt_return
                                          USING  lv_return.
          IF lv_return IS INITIAL.
            READ TABLE lt_return INTO ls_return WITH KEY type = 'S'.
            lv_msgty = ' '.
            lv_msg   = '등록취소'.
            gt_grid-status = icon_yellow_light.
            CLEAR: gt_grid-regdate, gt_grid-pr_status, gt_grid-prs_state,
                    gt_grid-peryr, gt_grid-perid,
                    gt_grid-regclass, gt_grid-cancprocess.
          ELSE.
*            READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.
            lv_msgty = 'E'.
            lv_msg   = '등록취소 오류'.
            gt_grid-status = icon_red_light.
          ENDIF.

          gt_grid-msgty = lv_msgty.
          gt_grid-msg   = lv_msg .
          MODIFY gt_grid .
          PERFORM data_objid_dequeue USING gt_grid-st_objid
                                           'ST' .
          CLEAR gt_grid .
        ENDIF .

        WAIT UP TO '0.1' SECONDS.

      ENDLOOP .
    ENDIF .
  ELSE .
    MESSAGE e000 WITH '등록할 데이터가 없습니다.'.
  ENDIF .

ENDFORM.                    " SAVE_CANCEL_REGISTRATION
*&---------------------------------------------------------------------*
*&      Form  DE_REGISTRATION_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_RETURN  text
*      -->P_LV_RETURN  text
*----------------------------------------------------------------------*
FORM de_registration_process  TABLES pt_return  TYPE  bapiret2_t
                              USING  pv_return.

  DATA : ev_result TYPE  sy-subrc,
         et_return TYPE  bapiret2_t.

  CALL FUNCTION 'HRIQ_STUDENT_REG_CANCEL_DB'
    EXPORTING
      iv_plvar         = '01'
      iv_process       = 'RM03'
      iv_st_objid      = gt_grid-st_objid
      iv_sc_objid      = gt_grid-sc_objid
      iv_begda         = gv_begda          "학사력 시작일
      iv_endda         = gv_endda          "학사력 종료일
      iv_cancreason    = '22'              "취소사유(22->42)
      iv_cancdate      = sy-datum          "삭제일자
*     IV_CHECK_ONLY    =
      iv_mode          = 'D'              "background
      iv_commit        = 'X'
    IMPORTING
      ev_result        = ev_result
      et_return        = et_return
    EXCEPTIONS
      internal_error   = 1
      no_authorisation = 2
      corr_exit        = 3
      OTHERS           = 4.

*  IF et_return IS NOT INITIAL.
  IF sy-subrc NE 0.
    pv_return = '4'.
    APPEND LINES OF et_return TO pt_return.
  ENDIF.
ENDFORM.                    " DE_REGISTRATION_PROCESS
*&---------------------------------------------------------------------*
*&      Form  CHECK_LOCK_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_ELOG  text
*----------------------------------------------------------------------*
FORM check_lock_object  USING    pv_elog.
  CALL FUNCTION 'ZCM_ENQUE_READ'
    EXPORTING
      i_plvar   = '01'
      i_otype   = 'ST'
      i_objid   = gt_grid-st_objid
      i_student = gt_grid-student12
    IMPORTING
      e_elog    = pv_elog
    TABLES
      t_error   = gt_error.
ENDFORM.                    " CHECK_LOCK_OBJECT
*&---------------------------------------------------------------------*
*&      Form  DATA_OBJID_ENQUEUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_GRID_ST_OBJID  text
*      -->P_1930   text
*      -->P_GT_GRID_CHECK  text
*      -->P_=  text
*      -->P_1933   text
*----------------------------------------------------------------------*
FORM data_objid_enqueue  USING  pv_objid
                                pv_otype
                                pv_subrc.

  CALL METHOD lcl_common->enqueue_object
    EXPORTING
      im_plvar = '01'
      im_otype = pv_otype
      im_objid = pv_objid
    RECEIVING
      ex_subrc = pv_subrc.
ENDFORM.                    " DATA_OBJID_ENQUEUE
*&---------------------------------------------------------------------*
*&      Form  DATA_OBJID_DEQUEUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_GRID_ST_OBJID  text
*      -->P_2049   text
*----------------------------------------------------------------------*
FORM data_objid_dequeue  USING  pv_objid
                                pv_otype.
  CALL METHOD lcl_common->dequeue_object
    EXPORTING
      im_plvar = '01'
      im_otype = pv_otype
      im_objid = pv_objid.
ENDFORM.                    " DATA_OBJID_DEQUEUE
*&---------------------------------------------------------------------*
*& Form get_domain_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_DOMAIN
*&      --> <GRID>_GROUP_CATEGORY
*&      --> <GRID>_GROUP_CATEGORYT
*&---------------------------------------------------------------------*
FORM get_domain_text  USING pv_domname   pv_key pv_text.

  CHECK pv_key IS NOT INITIAL.

  READ TABLE gt_domain WITH KEY domname = pv_domname
                                key = pv_key.
  IF sy-subrc EQ 0.
    pv_text = gt_domain-text.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_progress
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_progress .

  ADD 1 TO gv_cur.  "현재...
  DATA: lv_msg TYPE string.
  DATA: lv_cur(8), lv_tot(8).
  lv_cur = gv_cur. CONDENSE lv_cur.
  lv_tot = gv_tot. CONDENSE lv_tot.
  CONCATENATE `[ ` lv_cur ` / ` lv_tot ` ] 학생을 조회중입니다.` INTO lv_msg.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = lv_msg
    EXCEPTIONS
      OTHERS = 0.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_data_reg_new
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data_reg_new .

  DATA: lt_hrp9530 LIKE hrp9530 OCCURS 0 WITH HEADER LINE .
  DATA: lt_grid LIKE gt_grid OCCURS 0 WITH HEADER LINE.
  DATA: lv_perid TYPE piqperid .
*  DATA: lt_studies TYPE  TABLE OF piqrfc_study_spec_txt,
*        ls_studies TYPE  piqrfc_study_spec_txt.

  DATA: BEGIN OF lt_9580 OCCURS 0,
          objid   TYPE hrobjid,
          zrealwr LIKE hrp9580-zrealwr,
          zwaers  TYPE hrp9580-zwaers,
        END OF lt_9580.
*
  IF p_perid = '010' OR p_perid = '011'.
    lv_perid = '001'.
  ELSE.
    lv_perid = '002'.
  ENDIF.

  DATA(lv_keydate) = gv_begda - 1.

  DATA(lv_msg) = '※' && '대상자를 조회중입니다.'.
  PERFORM display_status(zcms0) USING  '' lv_msg.
*
  IF NOT gt_stru[] IS INITIAL .
    SELECT * INTO TABLE lt_hrp9530
             FROM hrp9530
             FOR ALL ENTRIES IN gt_stru
             WHERE plvar   = '01'
             AND   otype   = 'ST'
             AND   istat   = '1'
             AND   begda  <= gv_endda                 "학사력 시작일
             AND   endda  >= gv_begda                  "학사력 종료일
             AND   objid   = gt_stru-objid             "학번의 objid
             AND   sts_cd IN ('1000','2000','4000')   "재학/수료/휴학
             AND NOT sts_chng_cd IN ('4400','4500')
             AND   pros_cd = '0003'.                  "완료

    SELECT objid zrealwr zwaers
      FROM hrp9580   INTO TABLE lt_9580
      FOR ALL ENTRIES IN gt_stru
     WHERE plvar = '01'
       AND   otype = 'ST'
       AND   objid = gt_stru-objid
       AND   zblart = 'DR'
       AND   zstatus <> '4'
       AND   zperyr = p_peryr
       AND   zperid = p_perid .
    SORT lt_9580 BY objid.
  ENDIF.

  CLEAR gt_regst[].


  IF lt_hrp9530[] IS NOT INITIAL.
    "ZCM_GET_STUDENT_MAJOR_MULTI FUNCTION 참고
    SELECT a~objid AS st_objid
           c~objid AS sc_objid
           b~objid AS cs_objid
           a~begda AS cs_begda
           c~short
           c~stext
           d~enrcateg
           f~objid AS cg_objid
           f~category AS cg_category
           g~sobid AS o_objid
           h~short AS o_short
      INTO CORRESPONDING FIELDS OF TABLE gt_regst
      FROM hrp1001 AS a      " ST/A513/CS
     INNER JOIN hrp1001 AS b " CS/A514/SC
        ON b~plvar = a~plvar
       AND b~objid = a~sobid
       AND b~istat = a~istat
     INNER JOIN hrp1000 AS c " SC 전공명
        ON c~plvar = a~plvar
       AND c~objid = b~sobid
       AND c~istat = a~istat
     INNER JOIN hrp1770 AS d " CS 전공순서
        ON d~plvar = a~plvar
       AND d~objid = a~sobid
       AND d~istat = a~istat
     INNER JOIN hrp1001 AS e " CS-A516-CG
        ON e~plvar = a~plvar
       AND e~objid = a~sobid
       AND e~istat = a~istat
     INNER JOIN hrp1733 AS f " CG 카테고리
        ON f~plvar = e~plvar
       AND f~objid = e~sobid
       AND f~istat = e~istat
     INNER JOIN hrp1001 AS g " ST/A502/O
        ON g~plvar = a~plvar
       AND g~otype = a~otype
       AND g~objid = a~objid
       AND g~istat = a~istat
     INNER JOIN hrp1000 AS h " O 소속명
        ON h~plvar = g~plvar
       AND h~objid = g~sobid
       AND h~otype = g~sclas

       FOR ALL ENTRIES IN lt_hrp9530
     WHERE a~otype  = 'ST'
       AND a~objid  = lt_hrp9530-objid
       AND a~plvar  = '01'
       AND a~rsign  = 'A'
       AND a~relat  = '513' " ST/A513/CS (A517은 재적생만 해당)
       AND a~istat  = '1'
       AND a~begda <= gv_endda
       AND a~endda >= gv_begda
       AND b~otype  = 'CS'
       AND b~rsign  = 'A'
       AND b~relat  = '514' " CS/A514/SC
       AND b~begda <= gv_endda
       AND b~endda >= gv_begda
       AND c~otype  = 'SC'  " SC 전공명
       AND c~langu  = '3'
       AND c~begda <= gv_endda
       AND c~endda >= gv_begda
       AND d~otype  = 'CS'  " CS 전공순서
       AND d~begda <= gv_endda
       AND d~endda >= gv_begda
       AND e~otype  = 'CS'
       AND e~rsign  = 'A'
       AND e~relat  = '516' " CS-A516-CG
       AND e~begda <= gv_endda
       AND e~endda >= gv_begda
       AND f~otype  = 'CG'  " CG 카테고리
       AND f~begda <= gv_endda
       AND f~endda >= gv_begda
       AND g~rsign  = 'A'
       AND g~relat  = '502' " ST/A502/O
       AND g~begda <= gv_endda
       AND g~endda >= gv_endda
*       AND h~otype  = 'O'   " O 소속명
       AND h~langu  = '3'
       AND h~begda <= gv_endda
       AND h~endda >= gv_endda.
    SORT gt_regst BY st_objid.

    IF gt_regst[] IS NOT INITIAL.
      SELECT * FROM hrp1771 INTO TABLE @DATA(lt_hrp1771)
        FOR ALL ENTRIES IN @gt_regst
        WHERE plvar = '01'
          AND otype = 'CS'
          AND objid = @gt_regst-cs_objid
          AND istat = '1'
          AND begda <= @gv_endda
          AND endda >= @gv_begda
          AND ayear = @p_peryr
          AND perid = @p_perid.

      SORT lt_hrp1771 BY objid.
    ENDIF.

    LOOP AT gt_regst ASSIGNING FIELD-SYMBOL(<regst>).
      READ TABLE lt_hrp1771 INTO DATA(ls_1771)
          WITH KEY objid = <regst>-cs_objid BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING ls_1771 TO <regst>.
      ENDIF.
    ENDLOOP.

  ENDIF.
*
  SORT lt_hrp9530 BY objid begda DESCENDING .
  DELETE ADJACENT DUPLICATES FROM lt_hrp9530 COMPARING objid.
** 졸업한 경우 제외한다.
* [등록금계산 시점에는 졸업에 대한 학적상태 변동 안되므로]
  SELECT * FROM hrp9600 INTO TABLE @DATA(lt_hrp9600)
    FOR ALL ENTRIES IN @lt_hrp9530
      WHERE plvar = '01'
        AND otype = 'ST'
        AND objid = @lt_hrp9530-objid
        AND istat = '1'
        AND compl_cd = '2'.
  SORT lt_hrp9600 BY objid.

  LOOP AT lt_hrp9530 .
*    SELECT SINGLE * FROM hrp9600
*           WHERE plvar = '01'
*           AND   otype = 'ST'
*           AND   objid = lt_hrp9530-objid
*           AND   compl_cd = '2' .
    READ TABLE lt_hrp9600 WITH KEY objid = lt_hrp9530-objid
          BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc = 0." AND p_canc = ' '.
      DELETE  lt_hrp9530 .
    ENDIF .
  ENDLOOP.

* 복학예정자중 등록대상
  lv_msg = '※' && '복학예정자중 등록대상 조회중입니다.'.
  PERFORM display_status(zcms0) USING  '' lv_msg.

  LOOP AT lt_hrp9530.
    IF lt_hrp9530-sts_cd = '2000'.             "휴학
      IF ( lt_hrp9530-rtn_peryr  <  p_peryr ) OR
         ( lt_hrp9530-rtn_peryr  = p_peryr    AND
           lt_hrp9530-rtn_period <= lv_perid ).

      ELSE.
        DELETE lt_hrp9530 .
      ENDIF.
    ENDIF.
  ENDLOOP.
*
  CLEAR: gt_grid[],gt_grid .
  DATA(lt_regst) = gt_regst[].
  DELETE lt_regst WHERE prs_state NE 'A'.

  LOOP AT lt_hrp9530 .

    READ TABLE lt_regst INTO gs_regst WITH KEY st_objid = lt_hrp9530-objid.

    IF sy-subrc NE 0..
      gt_grid-st_objid = lt_hrp9530-objid .
      gt_grid-sts_cd   = lt_hrp9530-sts_cd .
      COLLECT gt_grid .  CLEAR gt_grid .
    ELSE.
      LOOP AT lt_regst INTO gs_regst FROM sy-tabix.
        IF gs_regst-st_objid NE lt_hrp9530-objid.
          EXIT.
        ENDIF.

        MOVE-CORRESPONDING gs_regst TO gt_grid .
        gt_grid-priority = gs_regst-priox.
        gt_grid-peryr    = gs_regst-ayear.
        gt_grid-perid    = gs_regst-perid.
        gt_grid-sts_cd   = lt_hrp9530-sts_cd .
        gt_grid-regdate   = gs_regst-regdate.

        IF gs_regst-cancprocess IS INITIAL.
          gt_grid-msgty = 'S' .
          gt_grid-msg   = '등록완료' .
          COLLECT gt_grid .  CLEAR gt_grid .
        ELSE.
          COLLECT gt_grid .  CLEAR gt_grid .
        ENDIF.

      ENDLOOP.
    ENDIF.

  ENDLOOP .

**-미등록 조회
  lv_msg = '※' && '미등록자 조회중입니다.'.
  PERFORM display_status(zcms0) USING  '' lv_msg.

  DATA(lt_stid) = gt_grid[].
  SORT gt_grid BY st_objid.
  DELETE ADJACENT DUPLICATES FROM lt_stid COMPARING st_objid.

  LOOP AT lt_stid INTO DATA(ls_stid).
    READ TABLE gt_regst INTO gs_regst WITH KEY st_objid = ls_stid-st_objid.
    IF sy-subrc EQ 0.
      LOOP AT gt_regst INTO gs_regst FROM sy-tabix..
        IF gs_regst-st_objid NE ls_stid-st_objid.
          EXIT.
        ENDIF.

        READ TABLE gt_grid WITH KEY st_objid = gs_regst-st_objid
                                    sc_objid = gs_regst-sc_objid.
        IF sy-subrc NE 0..
          CLEAR gt_grid.
          gt_grid-status = icon_red_light. "'@09@'.
          gt_grid-st_objid = gs_regst-st_objid.
          gt_grid-sc_objid = gs_regst-sc_objid.
          gt_grid-cs_objid = gs_regst-cs_objid.
          gt_grid-group_category = gs_regst-cg_category.
          gt_grid-sts_cd   = ls_stid-sts_cd.

          CASE gt_grid-group_category.
            WHEN 'MAJO'.
              gt_grid-enrcateg = '01'.
            WHEN 'MAJ1'.
              gt_grid-enrcateg = '02'.
            WHEN 'MAJ2'.
              gt_grid-enrcateg = '03'.
            WHEN 'MAJ3'.
              gt_grid-enrcateg = '04'.
          ENDCASE.

          WRITE gt_grid-enrcateg TO gt_grid-priority NO-ZERO.
          CONDENSE gt_grid-priority.

          APPEND gt_grid.
        ELSE.
          gt_grid-status = icon_green_light. "'@08@'.
          gt_grid-sts_cd = ls_stid-sts_cd.
          gt_grid-group_category = gs_regst-cg_category.
          MODIFY gt_grid INDEX sy-tabix.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDLOOP.


  DELETE gt_grid WHERE cs_objid IS INITIAL.
  IF p_none IS NOT INITIAL.
    DELETE gt_grid WHERE regdate IS NOT INITIAL.
  ENDIF.
*

  CHECK gt_grid[] IS NOT INITIAL.

  DATA: BEGIN OF lt_text OCCURS 0,
          otype TYPE otype,
          objid TYPE hrobjid,
          stext TYPE stext,
        END OF lt_text.

  SELECT otype objid stext
    FROM hrp1000 INTO TABLE lt_text
    FOR ALL ENTRIES IN gt_grid
    WHERE plvar = '01'
      AND otype = 'SC' AND objid = gt_grid-sc_objid
      AND istat ='1'
      AND begda <= gv_begda
      AND endda >= gv_endda
      AND langu = '3'.
  SORT lt_text BY otype objid.

*-학생기본정보
*  lv_msg = icon_information && '학생기본정보 조회중입니다.'.
  CONCATENATE '※' '학생기본정보 조회중입니다.' INTO lv_msg.
  PERFORM display_status(zcms0) USING  '' lv_msg.

  DATA lt_stlist TYPE zcmsif98t WITH HEADER LINE.
  lt_stlist[] = CORRESPONDING #( gt_grid[] MAPPING stid = st_objid ).

** 학생 학년 / 학기 취득
  DATA : lt_zcms50 TYPE TABLE OF zcms50 WITH HEADER LINE.
  CALL FUNCTION 'ZCM_GET_ST_YEAR_SESSION'
    EXPORTING
      it_stid   = lt_stlist[]
    TABLES
      et_zcms50 = lt_zcms50[].

*-도메인값
  CLEAR gt_domain[].
  SELECT 'ENRCATEG' AS domanme,
          enrcateg AS key,
          enrcategt AS text
          FROM t7piqenrcategt
    INTO TABLE @gt_domain WHERE spras = '3'.

  SELECT 'CATEGORY' AS domanme,
          category AS key,
          categoryt AS text
          FROM t7piqmodgrpcatt
    APPENDING TABLE @gt_domain WHERE spras = '3'.

  SORT gt_domain BY domname key.

  SELECT * FROM zcmt0101 INTO TABLE @DATA(lt_zcmt0101)
    WHERE grp_cd IN ('103', '160').
  SORT lt_zcmt0101 BY grp_cd com_cd.

  DATA: BEGIN OF lt_stinfo OCCURS 0,
          stobjid   TYPE hrobjid,
          student12 TYPE piqstudent12,
          stname    TYPE hrp1000-stext,
        END OF lt_stinfo.

  IF gt_grid[] IS NOT INITIAL.
    SELECT a~stobjid
           a~student12
           b~stext AS stname INTO TABLE lt_stinfo
           FROM cmacbpst AS a
            JOIN hrp1000 AS b ON b~objid = a~stobjid
      FOR ALL ENTRIES IN gt_grid
           WHERE a~stobjid = gt_grid-st_objid
           AND   b~plvar     = '01'
           AND   b~otype     = 'ST'
           AND   b~istat     = '1'
           AND   b~endda    >= sy-datum
           AND   b~langu     = '3'.
    SORT lt_stinfo BY stobjid.
  ENDIF.

  CLEAR: gv_tot, gv_cur.
  gv_tot = lines( gt_grid ).

  LOOP AT gt_grid ASSIGNING FIELD-SYMBOL(<grid>).

    PERFORM set_progress.

* 학생 오브젝ID/학생명/학년
    READ TABLE lt_stinfo INTO DATA(ls_stinfo)
        WITH KEY stobjid = <grid>-st_objid BINARY SEARCH.
    IF sy-subrc EQ 0.
      <grid>-student12 = ls_stinfo-student12.
      <grid>-name1 = ls_stinfo-stname.
    ENDIF.

* 소속
    READ TABLE gt_regst INTO gs_regst
      WITH KEY st_objid = <grid>-st_objid BINARY SEARCH.
    IF sy-subrc EQ 0.
      <grid>-o_objid = gs_regst-o_objid.
      <grid>-otext = gs_regst-o_short.
    ENDIF.


** 단과대학
*    PERFORM get_data_zcolg USING    <grid>-o_objid
*                           CHANGING <grid>-zcolg
*                                    <grid>-zcolgnm.
** 학년도/학기
*    PERFORM get_tepeatid USING    <grid>-st_objid
*                                  gv_bperyr
*                                  gv_bperid
*                         CHANGING <grid>-tepeatid
*                                  <grid>-grade.

    READ TABLE lt_text INTO DATA(ls_text) WITH KEY otype = 'SC'
                                                   objid = <grid>-sc_objid.
    IF sy-subrc EQ 0.
      <grid>-sctext = ls_text-stext.
    ENDIF.

* 등록금생성 및 성적확인
    READ TABLE lt_9580 INTO DATA(ls_9580) WITH KEY objid = <grid>-st_objid.
    IF sy-subrc EQ 0.
      <grid>-zrealwr = ls_9580-zrealwr.
      <grid>-zwaers = ls_9580-zwaers.
    ENDIF.

*-학생정보

    "현학년 / 현학기
    READ TABLE lt_zcms50 WITH KEY stid = <grid>-st_objid.
    IF sy-subrc EQ 0.
      <grid>-acad_year    = lt_zcms50-acad_year.
      <grid>-acad_session = lt_zcms50-acad_session.
      IF lt_zcms50-namzu IS NOT INITIAL.  "학위과정
        READ TABLE lt_zcmt0101 INTO DATA(ls_zcmt0101) WITH KEY grp_cd = '103'
                                                        short = lt_zcms50-namzu.
        IF sy-subrc EQ 0.
          <grid>-crsnmko = ls_zcmt0101-com_nm.
        ENDIF.
      ENDIF.
    ENDIF.
*
    "학적상태
    READ TABLE lt_zcmt0101 INTO ls_zcmt0101 WITH KEY grp_cd = '160'
                                                     com_cd = <grid>-sts_cd.
    IF sy-subrc EQ 0.
      <grid>-statnmko = ls_zcmt0101-com_nm.
    ENDIF.

*-도메인값
    PERFORM get_domain_text USING 'CATEGORY' <grid>-group_category  <grid>-group_categoryt.
    PERFORM get_domain_text USING 'ENRCATEG' <grid>-enrcateg  <grid>-enrcategt.

  ENDLOOP .
*
  SORT gt_grid BY st_objid group_category DESCENDING.

ENDFORM.
