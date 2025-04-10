class ZCL_U4A_APP_CMUIK120 definition
  public
  final
  create public .

public section.

  interfaces /U4A/IF_SERVER .

  data GS_MSG type BAPIRET2 .
  data GT_MSG type BAPIRET2_T .
  data GS_LOGIN type ZCMCL000=>TY_ST_CMACBPST .
  data GT_TIMELIMITS type PIQTIMELIMITS_TAB .
  data GS_TIMELIMIT_100 type PIQTIMELIMITS .
  data:
    BEGIN OF gs_cond,
        o_id1 TYPE hrp1000-objid,
        o_id2 TYPE hrp1000-objid,
        o_id3 TYPE hrp1000-objid,
        smsht TYPE hrp1000-short,
        smtxt TYPE hrp1000-stext,
      END OF gs_cond .
  data AT_ORG1 type TIHTTPNVP .
  data AT_ORG2 type TIHTTPNVP .
  data AT_ORG3 type TIHTTPNVP .
  data GT_SELIST type ZCMSK_COURSE_T .
  data GV_INDEX type I .
  data GS_PERSON type ZCMCL000=>TY_ST_PERSON .
  data GS_CREDIT type ZCMCLK100=>TY_CREDIT .
  data:
    BEGIN OF gs_ui ,
        title     TYPE string,
        tab_sel,
        o_id3_vis,
        msg_vis,
        period    TYPE ddtext,
        st_info   TYPE ddtext,
        msg_info  TYPE ddtext,
      END OF gs_ui .
  data GS_ORG type ZCMCL000=>TY_ST_ORGCD .
  data GS_STSTATUS type ZCMCL000=>TY_ST_STATUS_CD .
  data GT_BOOKED type ZCMSK_COURSE_T .
  data GT_REGISTERED type ZCMSK_COURSE_T .
  data GS_SELIST type ZCMSK_COURSE .
  data GT_ACWORK type ZCMZ200_T .
  data GV_MODE type ZCMK_AUTH .
  data GS_MAJOR type ZCMSC .

  class-methods CLASS_CONSTRUCTOR .
  methods CONSTRUCTOR .
  methods EV_BTN_REQ
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_CANCEL
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_CANCEL_OK
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_DDLB_ORG2
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_DDLB_ORG3
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_HELP
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_SEARCH
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
protected section.
private section.

  aliases AR_PARENT_CONTROL
    for /U4A/IF_SERVER~AR_PARENT_CONTROL .
  aliases AR_VIEW
    for /U4A/IF_SERVER~AR_VIEW .
  aliases AS_SERVER_REQ_INFO
    for /U4A/IF_SERVER~AS_SERVER_REQ_INFO .
  aliases AT_APP_USAGE
    for /U4A/IF_SERVER~AT_APP_USAGE .
  aliases AT_SESSIONS
    for /U4A/IF_SERVER~AT_SESSIONS .

  data GV_REGWINDOW type PIQREGWINDOW .

  methods CHECK_SAVE .
  methods CHECK_ST_POSSIBLE .
  methods CHECK_TIMELIMIT
    returning
      value(RV_ERR) type FLAG .
  methods DDLB_ORG1 .
  methods DDLB_ORG2 .
  methods GET_CART .
  methods GET_DATA_SELECT .
  methods GET_LOGIN_ID .
  methods GET_ST_INFO .
  methods GET_TIMELIMIT .
  methods MAIN_UI .
  methods MSG_TOAST
    importing
      !I_MSG type ANY .
  methods NAVI_TO
    importing
      !I_PAGE type ANY .
  methods SAVE_ZCMTK310 .
  methods SET_FIRST_PAGE .
  methods SET_INIT_GS_COND .
  methods SET_MAIN_INIT .
ENDCLASS.



CLASS ZCL_U4A_APP_CMUIK120 IMPLEMENTATION.


  method /U4A/IF_SERVER~HANDL_ON_EXIT  ##NEEDED.
    "Define it if necessary.
  endmethod.


  method /U4A/IF_SERVER~HANDL_ON_HASHCHANGE  ##NEEDED.
    "Define it if necessary.
  endmethod.


  METHOD /u4a/if_server~handl_on_init  ##NEEDED.

    gv_mode = 'WISH'.

    get_login_id( ).  "로그인 정보
    zcmclk050=>help_button( ar_view = ar_view u_id = 'BUTTON4' ).

    get_timelimit( ). "학사력

    get_st_info( ).

    check_st_possible( ). "대상자
    IF gs_msg-message IS NOT INITIAL.
      gs_ui-msg_vis = 'X'.
      navi_to( 'PAGE' ).
      RETURN.
    ENDIF.

    set_first_page( ).

  ENDMETHOD.


  method /U4A/IF_SERVER~HANDL_ON_MESSAGE  ##NEEDED.
    "Define it if necessary.
  endmethod.


  method /U4A/IF_SERVER~HANDL_ON_REQUEST  ##NEEDED.
    "Define it if necessary.
  endmethod.


  method /U4A/IF_SERVER~HANDL_ON_RESPONSE  ##NEEDED.
    "Define it if necessary.
  endmethod.


  METHOD check_save.

    SELECT COUNT(*) FROM zcmtk310
      INTO @DATA(lv_cnt)
      WHERE peryr = @gs_timelimit_100-ca_peryr
        AND perid = @gs_timelimit_100-ca_perid
        AND st_id = @gs_login-st_id.
    IF lv_cnt >= 6.
      gs_msg-message = zcmclk100=>otr( alias = 'ZDCM05/TX10000090' ).
      gs_msg-type = 'E'.
      APPEND gs_msg TO gt_msg.
      msg_toast( gt_msg[ 1 ]-message ).
      RETURN.
    ENDIF.

    zcmclk100=>check_is_bookable(
      EXPORTING
        i_mode          = gv_mode
        i_stid          = gs_login-st_id
        i_stno          = gs_login-st_no
        i_st_regwindow  = gv_regwindow
        i_st_gesch      = gs_person-gesch
        i_st_orgid      = gs_org-org_id
        i_st_orgcd      = gs_org-org_comm
        is_st_major     = gs_major
        it_booked       = gt_booked
        it_acwork       = gt_acwork
        i_max_credit    = gs_credit-max
        i_booked_credit = gs_credit-booked
        is_booking_info = gs_selist
        i_peryr         = gs_timelimit_100-ca_peryr
        i_perid         = gs_timelimit_100-ca_perid
        i_keydt         = gs_timelimit_100-ca_lbegda
      IMPORTING
        et_msg          = DATA(lt_msg)
    ).
    IF lt_msg IS NOT INITIAL.
      gt_msg = CORRESPONDING #( BASE ( gt_msg ) lt_msg ).
      msg_toast( gt_msg[ 1 ]-message ).
      RETURN.
    ENDIF.

*학사지원팀 요청, 기 수강신청 과목은 담기불가
    zcmclk100=>check_duplicated_sm(
      EXPORTING
        i_target_sm = gs_selist-smobjid
        it_booked   = gt_registered
      IMPORTING
        es_msg      = DATA(ls_msg) ).
    IF ls_msg IS NOT INITIAL.
      msg_toast( ls_msg-message ).
      RETURN.
    ENDIF.

  ENDMETHOD.


  METHOD check_st_possible.

    "학사력
    IF gt_timelimits IS INITIAL.
      gs_msg-message = zcmclk100=>otr( alias = 'ZDCM05/TX10000092' ).
      RETURN.
    ENDIF.

    "학부정규생
    IF gs_person-namzu = 'A0' AND gs_person-titel = 'A0'.
    ELSE.
      gs_msg-message = zcmclk100=>otr( alias = 'ZDCM05/TX10000086' ).
      RETURN.
    ENDIF.

    "재학,휴학만
    IF gs_ststatus-sts_cd = '1000' OR gs_ststatus-sts_cd = '2000'.
    ELSE.
      gs_msg-message = zcmclk100=>otr( alias = 'ZDCM05/TX10000087' ).
      RETURN.
    ENDIF.

  ENDMETHOD.


  method CHECK_TIMELIMIT.

    DATA(lt_times) = gt_timelimits.

    zcmclk100=>check_real_time( CHANGING ct_tab = lt_times ).

    IF lt_times IS INITIAL.
      DATA(lv_msg) = zcmclk100=>otr( alias = 'ZDCM05/TX10000092' ).
      msg_toast( lv_msg ).
      rv_err = 'X'. RETURN.
    ENDIF.

  endmethod.


  method CLASS_CONSTRUCTOR.
  endmethod.


  method CONSTRUCTOR.

  endmethod.


  METHOD ddlb_org1.

    at_org1 = zcmclk100=>get_ddlb_org1( gs_org-org_comm ).


  ENDMETHOD.


  method DDLB_ORG2.

    CLEAR: at_org2, gs_cond-o_id2, gs_cond-o_id3.
    CHECK gs_cond-o_id1 IS NOT INITIAL.

    CASE gs_cond-o_id1.
      WHEN '30000002'.
        gs_ui-o_id3_vis = 'X'.
      WHEN OTHERS.
        gs_ui-o_id3_vis = ''.
    ENDCASE.

    at_org2 = zcmclk100=>get_ddlb_org2( gs_cond-o_id1 ).

  endmethod.


  METHOD ev_btn_req.

    CHECK check_timelimit( ) IS INITIAL.  "학사력 체크

    CLEAR gv_index.
    /u4a/cl_utilities=>get_selected_index(
      EXPORTING
        i_event_name = i_event_name
      IMPORTING
        e_index      = gv_index
    ).

    CLEAR: gs_selist, gs_msg, gt_msg.
    READ TABLE gt_selist INTO gs_selist INDEX gv_index.
    CHECK sy-subrc = 0.

    check_save( ).
    CHECK gt_msg IS INITIAL.

    save_zcmtk310( ).

    get_cart( ).


  ENDMETHOD.


  METHOD ev_cancel.

    CHECK check_timelimit( ) IS INITIAL.  "학사력 체크

    DATA lv_msg TYPE string.

    CLEAR gv_index.
    /u4a/cl_utilities=>get_selected_index(
      EXPORTING
        i_event_name = i_event_name
      IMPORTING
        e_index      = gv_index
    ).

    READ TABLE gt_booked INTO DATA(ls_booked) INDEX gv_index.
    CHECK sy-subrc = 0.

    lv_msg = zcmclk100=>otr( alias = 'ZDCM05/TX10000089' ).

    /u4a/cl_utilities=>m_messagebox(
      io_view          = ar_view
      i_msgtx          = lv_msg
      i_popup_type     = /u4a/cl_utilities=>cs_m_msg_box_tp-confirm
      i_callback_event = 'EV_CANCEL_OK'
    ).


  ENDMETHOD.


  METHOD ev_cancel_ok.

    CHECK i_event_name = 'OK'.

    READ TABLE gt_booked INTO DATA(ls_booked) INDEX gv_index.
    CHECK sy-subrc = 0.

    DELETE FROM zcmtk310 WHERE peryr = ls_booked-peryr
                          AND perid = ls_booked-perid
                          AND st_id = gs_login-st_id
                          AND sm_id = ls_booked-smobjid
                          AND se_id = ls_booked-seobjid.
    IF sy-subrc = 0.
      COMMIT WORK.

      get_cart( ).
    ENDIF.

  ENDMETHOD.


  method EV_DDLB_ORG2.
    ddlb_org2( ).
  endmethod.


  METHOD ev_ddlb_org3.

    CLEAR: at_org3, gs_cond-o_id3.

    CASE gs_cond-o_id1.
      WHEN '30000002'.

        at_org3 = zcmclk100=>get_ddlb_org3( i_oid1 = gs_cond-o_id1 i_oid2 = gs_cond-o_id2 ).

        IF lines( at_org3 ) = 1.
          gs_cond-o_id3 = at_org3[ 1 ]-name.
        ENDIF.

        INSERT INITIAL LINE INTO at_org3 INDEX 1.

      WHEN OTHERS.

    ENDCASE.




  ENDMETHOD.


  METHOD ev_help.


    zcmclk050=>open_manual( ar_view ).

  ENDMETHOD.


  METHOD ev_search.
    get_data_select( ).
  ENDMETHOD.


  METHOD get_cart.

    DATA lt_se TYPE TABLE OF hrobject.
    DATA lr_win TYPE RANGE OF piqregwindow.

    CLEAR: gt_booked, gs_credit-cnt, gs_credit-booked, gs_credit-dvalue, gs_credit-dperc.

    SELECT * FROM zcmtk310
      INTO TABLE @DATA(lt_310)
      WHERE peryr = @gs_timelimit_100-ca_peryr
        AND perid = @gs_timelimit_100-ca_perid
        AND st_id = @gs_login-st_id.
    CHECK sy-subrc = 0.
    SORT lt_310 BY erdat ertim.

    lt_se = CORRESPONDING #( lt_310 MAPPING objid = se_id ).

    zcmclk100=>get_se_list(
      EXPORTING
        i_peryr   = gs_timelimit_100-ca_peryr
        i_perid   = gs_timelimit_100-ca_perid
        it_se     = lt_se
      IMPORTING
        et_detail = DATA(lt_detail)
    ).

*정원
    SELECT * FROM hrp9551
      INTO TABLE @DATA(lt_9551)
      FOR ALL ENTRIES IN @lt_se
      WHERE plvar = '01'
        AND otype = 'SE'
        AND istat = '1'
        AND objid = @lt_se-objid
        AND begda <= @gs_timelimit_100-ca_lbegda
        AND endda >= @gs_timelimit_100-ca_lbegda.
    SORT lt_9551 BY objid.

    CASE gs_timelimit_100-ca_perid.
      WHEN '010' OR '020'.
        lr_win = VALUE #( ( sign = 'I' option = 'EQ' low = gv_regwindow ) ).
      WHEN '011' OR '021'.
        lr_win = VALUE #( sign = 'I' option = 'EQ' ( low = '1' ) ( low = '2' ) ( low = '3' ) ( low = '4' ) ).
    ENDCASE.

    IF lt_se IS NOT INITIAL.
      SELECT a~se_id, COUNT(*) AS cnt FROM zcmtk310 AS a
        INNER JOIN @lt_se AS b
        ON a~se_id = b~objid
        WHERE peryr = @gs_timelimit_100-ca_peryr
          AND perid = @gs_timelimit_100-ca_perid
          AND regwindow IN @lr_win
          GROUP BY se_id
          ORDER BY se_id
        INTO TABLE @DATA(lt_310_cnt).
      SORT lt_310_cnt BY se_id.
    ENDIF.

    LOOP AT lt_310 INTO DATA(ls_310).

      READ TABLE lt_detail ASSIGNING FIELD-SYMBOL(<fs>) WITH KEY seobjid = ls_310-se_id.
      CHECK sy-subrc = 0.
      READ TABLE lt_9551 INTO DATA(ls_9551) WITH KEY objid = <fs>-seobjid BINARY SEARCH.
      IF sy-subrc = 0.
        CASE gv_regwindow.
          WHEN '1'.
            <fs>-limit_kapz = ls_9551-book_kapz1.
          WHEN '2'.
            <fs>-limit_kapz = ls_9551-book_kapz2.
          WHEN '3'.
            <fs>-limit_kapz = ls_9551-book_kapz3.
          WHEN '4'.
            <fs>-limit_kapz = ls_9551-book_kapz4.
        ENDCASE.
      ENDIF.

      READ TABLE lt_310_cnt INTO DATA(ls_310_cnt) WITH KEY se_id = <fs>-seobjid BINARY SEARCH.
      IF sy-subrc = 0.
        IF <fs>-limit_kapz IS NOT INITIAL.
          DATA(lv_rt) = CONV zcgpa( ls_310_cnt-cnt / <fs>-limit_kapz ).
          <fs>-cmprt = lv_rt && ` : 1`.
        ENDIF.
      ENDIF.

      APPEND <fs> TO gt_booked.
      CLEAR <fs>.
      CLEAR lv_rt.
    ENDLOOP.

*학사지원팀요청,기수강신청 과목은 담기 안되게 함
    zcmclk100=>booked_list(
      EXPORTING
        i_stid    = gs_login-st_id
        i_peryr   = gs_timelimit_100-ca_peryr
        i_perid   = gs_timelimit_100-ca_perid
      IMPORTING
        et_detail = DATA(lt_booked)
    ).
    gt_registered = lt_booked.

* 신청학점, 신청과목수
    zcmclk100=>booked_credit(
      EXPORTING
        i_orgcd   = gs_org-org_comm
        i_keydt   = gs_timelimit_100-ca_lbegda
        it_booked = gt_booked
      IMPORTING
        e_booked  = gs_credit-booked
        e_cnt     = gs_credit-cnt
        e_cnt_t   = gs_credit-cnt_t
    ).

    gs_credit-dvalue = |{ zcmclk100=>otr( 'ZDCM/BOOKED_CREDIT' ) } { gs_credit-booked } / { zcmclk100=>otr( 'ZDCM/BOOKABLE_CREDIT' ) } { gs_credit-max }|.
    gs_credit-dperc = gs_credit-booked / gs_credit-max * 100.



  ENDMETHOD.


  METHOD get_data_select.

    CLEAR gt_selist.

    CASE gs_ui-tab_sel.
      WHEN '1'.
        CHECK gs_cond-o_id2 IS NOT INITIAL.
        CASE gs_cond-o_id1.
          WHEN '30000002'.
            IF gs_cond-o_id3 IS NOT INITIAL.
              DATA(lv_cgid) = CONV hrobjid( gs_cond-o_id3 ).
            ELSEIF gs_cond-o_id2 IS NOT INITIAL.
              DATA(lv_oid) = CONV hrobjid( gs_cond-o_id2 ).
            ELSE.
              lv_oid = CONV hrobjid( gs_cond-o_id1 ).
            ENDIF.

          WHEN OTHERS.
            CHECK gs_cond-o_id2 IS NOT INITIAL.
            IF gs_cond-o_id2 IS NOT INITIAL.
              lv_cgid = CONV hrobjid( gs_cond-o_id2 ).
            ELSE.
              lv_oid = CONV hrobjid( gs_cond-o_id1 ).
            ENDIF.
        ENDCASE.
      WHEN '2'.
        CHECK gs_cond-smsht IS NOT INITIAL.
        TRANSLATE gs_cond-smsht TO UPPER CASE.
        DATA(lv_smsht) = CONV short_d( gs_cond-smsht ).
      WHEN '3'.
        CHECK gs_cond-smtxt IS NOT INITIAL.
        DATA(lv_smtxt) = CONV stext( gs_cond-smtxt ).
    ENDCASE.

    zcmclk100=>get_se_list(
      EXPORTING
        i_peryr   = gs_timelimit_100-ca_peryr
        i_perid   = gs_timelimit_100-ca_perid
        i_oid     = lv_oid
        i_cgid    = lv_cgid
        i_smsht   = lv_smsht
        i_smtxt   = lv_smtxt
      IMPORTING
        et_selist = DATA(lt_selist)
        et_detail = DATA(lt_detail)
    ).

*정원, 신청인원
    zcmclk100=>get_se_quota_count(
      EXPORTING
        i_st_regwindow = gv_regwindow
        i_keydt        = gs_timelimit_100-ca_lbegda
        i_peryr        = gs_timelimit_100-ca_peryr
        i_perid        = gs_timelimit_100-ca_perid
        it_selist      = lt_selist
        i_quota_only   = 'X'
      IMPORTING
        et_cnt         = DATA(lt_cnt)
    ).

    IF lt_selist IS NOT INITIAL.
      SELECT a~se_id, COUNT(*) AS cnt FROM zcmtk310 AS a
        INNER JOIN @lt_selist AS b
        ON a~se_id = b~objid
        WHERE peryr = @gs_timelimit_100-ca_peryr
          AND perid = @gs_timelimit_100-ca_perid
          AND regwindow = @gv_regwindow
          GROUP BY se_id
          ORDER BY se_id
        INTO TABLE @DATA(lt_310).
    ENDIF.

    gt_selist = lt_detail.

    LOOP AT gt_selist ASSIGNING FIELD-SYMBOL(<fs>).
      READ TABLE lt_cnt INTO DATA(ls_cnt) WITH KEY se_id = <fs>-seobjid BINARY SEARCH.
      IF sy-subrc = 0.
        <fs>-limit_kapz = ls_cnt-limit_kapz.
      ENDIF.

      READ TABLE lt_310 INTO DATA(ls_310) WITH KEY se_id = <fs>-seobjid BINARY SEARCH.
      IF sy-subrc = 0.
        IF <fs>-limit_kapz IS NOT INITIAL.
          DATA(lv_rt) = CONV zcgpa( ls_310-cnt / <fs>-limit_kapz ).
          <fs>-cmprt = lv_rt && ` : 1`.
        ENDIF.
      ENDIF.

      CLEAR lv_rt.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_login_id.

    CLEAR gs_login.
    zcmclk100=>get_login_id( IMPORTING es_login = gs_login ).

*학생 소속
    CLEAR gs_org.
    zcmcl000=>get_st_orgcd(
      EXPORTING
        it_stobj = VALUE hrobject_tab( ( objid = gs_login-st_id ) )
      IMPORTING
        et_storg = DATA(lt_org)
    ).

    READ TABLE lt_org INTO gs_org INDEX 1.

  ENDMETHOD.


  METHOD get_st_info.

    zcmclk050=>call_st_head(
      ar_view = ar_view
      contid  = 'STHEAD'
      st_no   = gs_login-st_no
      expand  = ''
    ).

*개인정보
    CLEAR gs_person.
    zcmcl000=>get_st_person(
      EXPORTING
        it_stobj    = VALUE hrobject_t( ( objid = gs_login-st_id ) )
        iv_keydate  = gs_timelimit_100-ca_lbegda
      IMPORTING
        et_stperson = DATA(lt_stperson)
    ).
    IF lt_stperson IS NOT INITIAL.
      gs_person = lt_stperson[ 1 ].
    ENDIF.

*전공
    CLEAR gs_major.
    zcmcl000=>get_st_major(
      EXPORTING
        it_stobj   = VALUE hrobject_t( ( objid = gs_login-st_id ) )
        iv_keydate = gs_timelimit_100-ca_lbegda
      IMPORTING
        et_stmajor = DATA(lt_major)
    ).
    IF lt_major IS NOT INITIAL.
      gs_major = lt_major[ 1 ].
    ENDIF.

*성적
    CLEAR gt_acwork.
    zcmcl000=>get_aw_acwork(
      EXPORTING
        it_stobj  = VALUE hrobject_t( ( objid = gs_login-st_id ) )
      IMPORTING
        et_acwork = gt_acwork
    ).

*학적상태
    CLEAR gs_ststatus.
    zcmcl000=>get_st_status(
      EXPORTING
        it_stobj    = VALUE hrobject_t( ( objid = gs_login-st_id ) )
        iv_keydate  = gs_timelimit_100-ca_lbegda
      IMPORTING
        et_ststatus = DATA(lt_status)
    ).
    IF lt_status IS NOT INITIAL.
      gs_ststatus = lt_status[ 1 ].
    ENDIF.

*수강신청 그룹
    zcmclk100=>get_stgrp( EXPORTING i_stid       = gs_login-st_id
                                    i_keydt      = gs_timelimit_100-ca_lbegda
                                    i_namzu      = gs_person-namzu
                          IMPORTING ev_regwindow = gv_regwindow ).

*가능학점
    DATA lv_max TYPE numc4.

    CALL FUNCTION 'ZCM_GET_INITS'
      EXPORTING
        i_peryr = gs_timelimit_100-ca_peryr
        i_perid = gs_timelimit_100-ca_perid
        i_objid = gs_login-st_id
        i_keydt = sy-datum
        i_wish  = 'X'
      IMPORTING
        o_max   = lv_max.

    gs_credit-max = lv_max.

  ENDMETHOD.


  METHOD get_timelimit.

    DATA lv_oid TYPE hrobjid.

    CASE gs_org-org_comm.
      WHEN '0002'.  "경영
        lv_oid = gs_org-o_objid.
      WHEN OTHERS.
        lv_oid = gs_org-org_id.
    ENDCASE.

    zcmclk100=>booking_period(
      EXPORTING
        i_oid            = gs_org-org_id
        i_timelimit      = '0350'
        i_flt_t          = 'X'
      IMPORTING
        et_timelimits    = gt_timelimits
        es_timelimit_100 = gs_timelimit_100
    ).
    SORT gt_timelimits BY ca_timelimit ca_lbegda ca_lbegtime ca_lendda ca_lendtime.

    IF gt_timelimits IS INITIAL.
      gs_msg-message = zcmclk100=>otr( alias = 'ZDCM05/TX10000065' ).
    ELSE.

    ENDIF.

  ENDMETHOD.


  METHOD main_ui.

    SELECT SINGLE peryt FROM t7piqyeart
      INTO @DATA(lv_peryt)
      WHERE spras = @sy-langu
        AND peryr = @gs_timelimit_100-ca_peryr.

    SELECT SINGLE perit FROM t7piqperiodt
      INTO @DATA(lv_perit)
      WHERE spras = @sy-langu
        AND perid = @gs_timelimit_100-ca_perid.

    gs_ui-title = zcmclk100=>otr( 'ZDCM05/TX10000084' ).
*    gs_ui-title = |{ gs_ui-title } - { lv_peryt } { lv_perit } |.

    gs_ui-tab_sel = '1'.

    gs_ui-period = |{ lv_peryt } { lv_perit }|.

* 수강신청 대상학년/학기/가능학점
    DATA: lv_regwin TYPE piqregwindow,
          lv_regsem TYPE zregsemstr,
          lv_bokcdt TYPE zcmbook_cdt,
          lv_inits  TYPE inits,
          lv_max    TYPE numc04.

    SELECT SINGLE regwindow regsemstr book_cdt
      INTO (lv_regwin, lv_regsem, lv_bokcdt)
      FROM hrp1705
     WHERE plvar  = '01'
       AND otype  = 'ST'
       AND objid  = gs_login-st_id
       AND begda <= gs_timelimit_100-ca_lbegda
       AND endda >= gs_timelimit_100-ca_lbegda.

    lv_max = lv_bokcdt. "DEC5,2 -> NUMC4
    lv_inits = lv_max. "NUMC4 -> TEXT

    SHIFT lv_inits LEFT DELETING LEADING '0'.
    IF lv_inits IS INITIAL. lv_inits = '0'. ENDIF.

    IF sy-langu = '3'. "한국어
      CONCATENATE `대상학년: ` lv_regwin `학년　/　`
                  `대상학기: ` lv_regsem `학기`
              INTO gs_ui-st_info.
    ELSE. "영어
      CONCATENATE `Grade: ` lv_regwin ` / `
                  `Semester: ` lv_regsem
              INTO gs_ui-st_info.
    ENDIF.
*}

*(수강가능학점 넣기: 2016.08.02
    IF gs_timelimit_100-ca_perid = '010' OR
       gs_timelimit_100-ca_perid = '020'.

      IF sy-langu = '3'. "한국어
        CONCATENATE gs_ui-st_info
                   `　/　가능학점: ` lv_inits  `학점`
               INTO gs_ui-st_info.
      ELSE. "영어
        CONCATENATE gs_ui-st_info
                   `　/　Maximum credits to register: ` lv_inits
               INTO gs_ui-st_info.
      ENDIF.

    ENDIF.

    DATA: lv_perid TYPE piqperid.
    CASE gs_timelimit_100-ca_perid.
      WHEN '010' OR '011' OR '001'. lv_perid = '001'.
      WHEN '020' OR '021' OR '002'. lv_perid = '002'.
    ENDCASE.
    SELECT COUNT(*)
      FROM hrp9561
     WHERE plvar    = '01'
       AND otype    = 'ST'
       AND objid    = gs_login-st_id
       AND piqperyr = gs_timelimit_100-ca_peryr
       AND piqperid = lv_perid.
    IF sy-dbcnt > 0.
      CONCATENATE gs_ui-st_info `　( `
                  gs_timelimit_100-ca_peryr  `-` lv_perid+2(1) ` 재이수 유예대상 )`
             INTO gs_ui-st_info.
    ENDIF.
*
*)
  ENDMETHOD.


  method MSG_TOAST.
    /u4a/cl_utilities=>m_messagetoast(
      io_view = ar_view
      i_msgtx = i_msg
    ).
  endmethod.


  method NAVI_TO.

    /u4a/cl_utilities=>page_navigation(
      io_view  = ar_view
      i_appid  = 'APP'
      i_pageid = i_page
    ).

  endmethod.


  METHOD save_zcmtk310.

    DATA ls_310 TYPE zcmtk310.

    ls_310-peryr = gs_timelimit_100-ca_peryr.
    ls_310-perid = gs_timelimit_100-ca_perid.
    ls_310-st_id = gs_login-st_id.
    ls_310-sm_id = gs_selist-smobjid.
    ls_310-se_id = gs_selist-seobjid.
    ls_310-e_id = gs_selist-eobjid.
    ls_310-o_id = gs_selist-orgid.
    ls_310-se_short = gs_selist-seshort.
    ls_310-cpopt = gs_selist-cpopt.
    ls_310-regwindow = gv_regwindow.
    ls_310-bookdate = sy-datum.
    ls_310-booktime = sy-uzeit.

    ls_310-ernam = sy-uname.
    ls_310-erdat = sy-datum.
    ls_310-ertim = sy-uzeit.

    MODIFY zcmtk310 FROM ls_310.
    COMMIT WORK.

  ENDMETHOD.


  method SET_FIRST_PAGE.


      set_main_init( ).


  endmethod.


  method SET_INIT_GS_COND.

    gs_cond-o_id1 = gs_org-org_id.

    ddlb_org1( ).
    ddlb_org2( ).

  endmethod.


  method SET_MAIN_INIT.

    main_ui( ).
    set_init_gs_cond( ).

    get_cart( ).



  endmethod.
ENDCLASS.
