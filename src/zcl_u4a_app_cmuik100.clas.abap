class ZCL_U4A_APP_CMUIK100 definition
  public
  final
  create public .

public section.

  interfaces /U4A/IF_SERVER .

  types:
    BEGIN OF ty_possb_timelimits ,
        possb_oid TYPE hrt9566-possb_oid,
        timelimit TYPE piqtimelimits,
      END OF ty_possb_timelimits .
  types:
    tt_possb_timelimits TYPE TABLE OF ty_possb_timelimits .

  data GS_MSG type BAPIRET2 .
  data GT_MSG type BAPIRET2_T .
  data GS_ORG type ZCMCL000=>TY_ST_ORGCD .
  data GS_LOGIN type ZCMCL000=>TY_ST_CMACBPST .
  data GT_TIMELIMITS type PIQTIMELIMITS_TAB .
  data GS_TIMELIMIT_100 type PIQTIMELIMITS .
  data:
    BEGIN OF gs_ui ,
        title       TYPE string,
        tab_sel,
        o_id3_vis,
        macro_vis,
        cart_vis,
        refresh_vis,
        book_vis,
      END OF gs_ui .
  data:
    BEGIN OF gs_cart.
        INCLUDE TYPE zcmtk310.
        INCLUDE TYPE objec.
    DATA: END OF gs_cart .
  data:
    gt_cart LIKE TABLE OF gs_cart .
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
  data GS_MAJOR type ZCMSC .
  data GS_STPROG type ZCMZ100 .
  data GS_STSTATUS type ZCMCL000=>TY_ST_STATUS_CD .
  data GT_BOOKED type ZCMSK_COURSE_T .
  data GV_INDEX type I .
  data GS_PERSON type ZCMCL000=>TY_ST_PERSON .
  data GS_CREDIT type ZCMCLK100=>TY_CREDIT .
  data GT_ACWORK type ZCMZ200_T .
  data GS_SELIST type ZCMSK_COURSE .
  data:
    BEGIN OF gs_macro,
        url     TYPE string,
        answer  TYPE char4,
        value   TYPE char4,
        input1  TYPE zcmt2024_macro-answer,
        input2  TYPE zcmt2024_macro-answer,
        input3  TYPE zcmt2024_macro-answer,
        err_cnt TYPE i,
        msg     TYPE bapiret2-message,
        zseq    TYPE zcmt2024_macro-zseq,
        onoff   TYPE zcmt2024_macro-onoff,
      END OF gs_macro .
  data GS_REBOOK_INFO type CI_PAD506 .
  data GS_222 type ZCMTK222 .
  data GS_AUTH type ZCMTW1200 .
  data GV_TIMELIMIT_FG type ZTIMELIMIT_FG .
  data GO_LOG type ref to ZCMCLKLOG .
  data GV_NFKEY type STRING .
  data GT_POSSB_TIMELIMITS type TT_POSSB_TIMELIMITS .
  data GV_REGWINDOW type PIQREGWINDOW .
  constants GC_IMG_PATH type TEXT255 value '/zu4a/public/application/zcmuik100/macroimg/' ##NO_TEXT.
  data:
    gt_macro LIKE TABLE OF gs_macro .
  data GT_TXT type STRING_TABLE .

  methods CONSTRUCTOR .
  methods EV_BLANK
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_BOOKING .
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
  methods EV_IMG_CLICK
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_LOGOUT
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_LOGOUT_OK
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_MACRO_IMG_REFRESH
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_MACRO_OK
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_MSG_OK
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_NETFUNNEL_RETURN
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_NETFUNNEL_START_LOGIN
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_REFRESH
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_SAVE_CART
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
  methods EV_SE_SHORT_CHANGE
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_TAB_SELECT
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

  methods APP_LOG_OFF .
  methods BOOKING_CANC .
  methods BOOKING_CART .
  methods BOOKING_PERIOD .
  methods BOOKING_SINGLE .
  methods CHECK_CANCEL .
  methods CHECK_MACRO_ERROR
    returning
      value(RV_ERR) type FLAG .
  methods CHECK_NETFUNNEL_KEY
    importing
      !IT_FORM_DATA type TIHTTPNVP
    returning
      value(RV_ERR) type FLAG .
  methods CHECK_ST_POSSIBLE .
  methods CHECK_ST_STATUS .
  methods CHECK_TIMELIMIT
    returning
      value(RV_ERR) type FLAG .
  methods DDLB_ORG1 .
  methods DDLB_ORG2 .
  methods GET_ACWORK .
  methods GET_BOOKED_LIST .
  methods GET_CART .
  methods GET_CART_LOCKED
    returning
      value(RV_LOCKED) type FLAG .
  methods GET_DATA_SELECT .
  methods GET_INIT_DATA .
  methods GET_LOGIN_ID .
  methods GET_POSSB_TIMELIMITS .
  methods GET_ST_INFO .
  methods GET_ST_ORG .
  methods MACRO_RANDOM .
  methods MAIN_UI .
  methods MSG_DIALOG .
  methods MSG_TOAST
    importing
      !I_MSG type ANY .
  methods NAVI_TO
    importing
      !I_PAGE type ANY .
  methods NETFUNNEL_START_LOGIN .
  methods NETFUNNEL_START_SAVE .
  methods SESSION_MNG .
  methods SET_FIRST_PAGE .
  methods SET_INIT_GS_COND .
  methods SET_MAIN_INIT .
  methods SET_REFRESH_FLAG .
  methods UPDATE_COMP_FLAG .
ENDCLASS.



CLASS ZCL_U4A_APP_CMUIK100 IMPLEMENTATION.


  METHOD /u4a/if_server~handl_on_exit  ##NEEDED.
    "Define it if necessary.

  ENDMETHOD.


  method /U4A/IF_SERVER~HANDL_ON_HASHCHANGE  ##NEEDED.
    "Define it if necessary.
  endmethod.


  METHOD /u4a/if_server~handl_on_init  ##NEEDED.


    get_login_id( ).  "로그인 정보

    go_log = NEW #( io_view = ar_view i_stid = gs_login-st_id  ). "로그

    get_init_data( ). "셋팅 데이터

    session_mng( ). "멀티 로그인

    CHECK check_macro_error( ) IS INITIAL.  "매크로 5회 오류

    get_st_org( ).  "학생 소속

    booking_period( ).  "수강신청 학사력
    IF gs_msg IS NOT INITIAL.
      app_log_off( ). RETURN.
    ENDIF.

    check_st_status( ). "학생 수강가능 여부
    IF gs_msg IS NOT INITIAL.
      app_log_off( ). RETURN.
    ENDIF.

    get_st_info( ). "학생정보

    check_st_possible( ). "수강대상자
    IF gs_msg IS NOT INITIAL.
      app_log_off( ). RETURN.
    ENDIF.

    go_log->save( 'L' ).

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


  METHOD app_log_off.

    DATA lt_script TYPE TABLE OF string.
    DATA lv_url TYPE string.

    FIND cl_abap_char_utilities=>newline IN gs_msg-message.
    IF sy-subrc = 0.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN gs_msg-message WITH `\n`.
    ENDIF.

    APPEND |alert("{ gs_msg-message }");| TO lt_script.

    CALL METHOD /u4a/cl_utilities=>set_freestyle_script
      EXPORTING
        io_view   = ar_view
        it_script = lt_script.

    gs_msg-type = 'E'.
    go_log->save( 'M' ).
    DELETE FROM zcmt2024_user WHERE uname = sy-uname.

    IF sy-sysid = 'PRD' AND sy-mandt = '100'.
      lv_url = 'https://sis109.sogang.ac.kr/zu4a/zcmuik100'.
    ENDIF.

    IF gs_222-lo_flag IS NOT INITIAL.
      CALL METHOD /u4a/cl_utilities=>app_log_off
        EXPORTING
          io_view        = ar_view
          i_redirect_url = lv_url.
    ENDIF.
  ENDMETHOD.


  METHOD booking_canc.

    CLEAR: gt_msg, gs_msg.

    READ TABLE gt_booked INTO DATA(ls_booked) INDEX gv_index.
    CHECK sy-subrc = 0.

    zcmclk100=>booking_canc(
      EXPORTING
        i_stid    = gs_login-st_id
        is_booked = ls_booked
      IMPORTING
        es_msg    = DATA(ls_msg)
    ).

    IF ls_msg IS INITIAL.

      DATA(lv_now) = zcmclk100=>set_delay_se(
        i_peryr = gs_timelimit_100-ca_peryr
        i_perid = gs_timelimit_100-ca_perid
        i_seid  = ls_booked-seobjid
        i_smid  = ls_booked-smobjid
        i_stid  = gs_login-st_id
      ).
      IF lv_now IS NOT INITIAL.
        zcmclk100=>decrease_booking_count(
          EXPORTING
            i_seid  = ls_booked-seobjid
            i_keydt = gs_timelimit_100-ca_lbegda
            i_st_regwindow = gv_regwindow
        ).
      ENDIF.
      get_booked_list( ).
      ls_msg-message = zcmclk100=>otr( 'ZDCM05/TX10000105' ).
    ELSE.

    ENDIF.

    APPEND ls_msg TO gt_msg.
    msg_dialog( ).

  ENDMETHOD.


  METHOD booking_cart.
    DATA ls_msg TYPE bapiret2.
    DATA lt_detail LIKE TABLE OF gs_selist.

    go_log->save( 'I' ).

    DATA lt_se TYPE TABLE OF hrobject.

    lt_se = CORRESPONDING #( gt_cart MAPPING objid = se_id ).
    zcmclk100=>get_se_list(
      EXPORTING
        i_peryr   = gs_timelimit_100-ca_peryr
        i_perid   = gs_timelimit_100-ca_perid
        it_se     = lt_se
      IMPORTING
        et_detail = DATA(lt_temp)
    ).

    IF lt_temp IS INITIAL.
      msg_toast( zcmclk100=>otr( 'ZDCM05/TX10000153' ) ).
      RETURN.
    ENDIF.

*담아놓기 순서
    CLEAR lt_detail.
    LOOP AT gt_cart INTO DATA(ls_cart).
      READ TABLE lt_temp INTO DATA(ls_temp) WITH KEY seobjid = ls_cart-se_id.
      IF sy-subrc = 0.
        APPEND ls_temp TO lt_detail.
      ENDIF.
    ENDLOOP.

    CLEAR: gs_selist, gs_msg, gt_msg.
    LOOP AT lt_detail INTO gs_selist.
*수강가능 소속 학사력
      IF gs_selist-orgid <> gs_org-org_id.
        READ TABLE gt_possb_timelimits WITH KEY possb_oid = gs_selist-orgid TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          DATA(lv_err) = 'X'.
          ls_msg-type = 'E'.
          ls_msg-message = |[{ gs_selist-seshort }] { gs_selist-smstext } - { zcmclk100=>otr( 'ZDCM05/TX10000156' ) }|.
          APPEND ls_msg TO gt_msg.
        ENDIF.
      ENDIF.
      IF lv_err IS INITIAL.
        ev_booking( ).
      ENDIF.
      CLEAR lv_err.
    ENDLOOP.


    msg_dialog( ).


    CHECK get_cart_locked( ) IS INITIAL.

*매크로
    IF gs_222-mc_flag IS NOT INITIAL.
      macro_random( ).
    ENDIF.

  ENDMETHOD.


  METHOD booking_period.

    DATA lt_txt TYPE TABLE OF string.
    DATA lv_oid TYPE hrobjid.

    CASE gs_org-org_comm.
      WHEN '0002'.  "경영
        lv_oid = gs_org-o_objid.
      WHEN OTHERS.
        lv_oid = gs_org-org_id.
    ENDCASE.

    CLEAR: gs_timelimit_100, gt_timelimits.

    IF gv_timelimit_fg IS INITIAL.    "관리자
*표준학기 시작일 종료일
      zcmcl000=>get_timelimits(
        EXPORTING
          iv_o          = lv_oid
          iv_peryr      = gs_auth-peryr
          iv_perid      = gs_auth-perid
        IMPORTING
          et_timelimits = DATA(lt_times)
      ).
      IF lt_times IS NOT INITIAL.
        gs_timelimit_100 = lt_times[ 1 ].
      ENDIF.
      RETURN.
    ENDIF.

    zcmclk100=>booking_period(
      EXPORTING
        i_oid            = lv_oid
      IMPORTING
        et_timelimits    = gt_timelimits
        es_timelimit_100 = gs_timelimit_100
    ).
    SORT gt_timelimits BY ca_timelimit ca_lbegda ca_lbegtime ca_lendda ca_lendtime.

    IF gt_timelimits IS INITIAL.
      gs_msg-message = zcmclk100=>otr( alias = 'ZDCM05/TX10000544' ).
      RETURN.
    ELSE.

    ENDIF.



  ENDMETHOD.


  method BOOKING_SINGLE.

    ev_booking( ).
    msg_dialog( ).

  endmethod.


  METHOD check_cancel.

    CLEAR gs_msg.

    READ TABLE gt_booked INTO DATA(ls_booked) INDEX gv_index.
    CHECK sy-subrc = 0.

    SELECT SINGLE * FROM hrp9520
      INTO @DATA(ls_9520)
      WHERE plvar  = '01'
        AND otype  = 'SM'
        AND objid  = @ls_booked-smobjid
        AND istat  = '1'
        AND begda <= @gs_timelimit_100-ca_lbegda
        AND endda >= @gs_timelimit_100-ca_lbegda
        AND infty  = '9520'.

    IF sy-subrc = 0 AND ls_9520-canc_not = 'X'.
      gs_msg-type = 'E'.
      gs_msg-message = zcmclk100=>otr( EXPORTING alias = 'ZDCM05/TX10000080'
                                                 v1    = |[{ ls_booked-seshort }] { ls_booked-smstext } - | ).
      msg_toast( gs_msg-message ).
      RETURN.
    ENDIF.

    SELECT SINGLE * FROM hrp9550
      INTO @DATA(ls_9550)
      WHERE plvar = '01'
        AND otype = 'SE'
        AND objid = @ls_booked-seobjid
        AND istat = '1'
        AND begda <= @gs_timelimit_100-ca_lbegda
        AND endda >= @gs_timelimit_100-ca_lbegda.

    IF sy-subrc = 0 AND ls_9550-cu_fg = 'X'.
      gs_msg-type = 'E'.
      gs_msg-message = zcmclk100=>otr( EXPORTING alias = 'ZDCM05/TX10000080'
                                                 v1    = |[{ ls_booked-seshort }] { ls_booked-smstext } - | ).
      msg_toast( gs_msg-message ).
      RETURN.
    ENDIF.

    READ TABLE gt_timelimits INTO DATA(ls_time) WITH KEY ca_timelimit = '0330'.
    IF sy-subrc = 0.
      CHECK ls_time-ca_perid = '010' OR ls_time-ca_perid = '020'.
      CHECK sy-uname BETWEEN '19600001' AND '20999999'.

      IF gs_credit-booked - ls_booked-cpopt < 9.
        gs_msg-type = 'E'.
        gs_msg-message = zcmclk100=>otr( EXPORTING alias = 'ZDCM05/TX10000545'
                                                   v1    = |[{ ls_booked-seshort }] { ls_booked-smstext } - | ).
        msg_toast( gs_msg-message ).
        RETURN.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD check_macro_error.

    DATA lv_block_t TYPE text20.

    CLEAR rv_err.

    SELECT * FROM zcmt2024_block
      INTO TABLE @DATA(lt_block)
      WHERE stobj = @gs_login-st_id
        AND block_date = @sy-datum.
    SORT lt_block BY block_time DESCENDING.

    READ TABLE lt_block INTO DATA(ls_block) INDEX 1.
    CHECK sy-subrc = 0.

    CHECK ls_block-block_time > sy-uzeit.

    WRITE ls_block-block_time TO lv_block_t USING EDIT MASK '__:__:__'.
    gs_macro-msg = zcmclk100=>otr( alias = 'ZDCM05/TX10000083'
                                   v1    = lv_block_t ).

    rv_err = 'X'.

    CALL METHOD /u4a/cl_utilities=>page_navigation
      EXPORTING
        io_view  = ar_view
        i_appid  = 'APP'
        i_pageid = 'MACROERR'.


  ENDMETHOD.


  METHOD check_netfunnel_key.

    DATA lv_key TYPE text1000.
    DATA lv_key_tmp TYPE text1000.
    DATA lv_pattern TYPE text100.
    DATA lt_script TYPE string_table.

    CLEAR: rv_err, gv_nfkey.
    READ TABLE it_form_data INTO DATA(ls_form) WITH KEY name = 'EVENT_NAME'.
    IF sy-subrc = 0.
      lv_key = ls_form-value.
    ENDIF.
    gv_nfkey = lv_key.
    lv_key_tmp = lv_key.

    READ TABLE it_form_data INTO ls_form WITH KEY name = 'UI_OBJ_ID'.
    IF sy-subrc = 0.
      DATA(lv_nf_flag) = ls_form-value.
    ENDIF.

    IF lv_key = 'E'.  "Error
      APPEND |NetFunnel_Start("{ lv_nf_flag }");| TO lt_script.
      CALL METHOD /u4a/cl_utilities=>set_freestyle_script
        EXPORTING
          io_view   = ar_view
          it_script = lt_script.
      rv_err = 'X'.
      RETURN.
    ENDIF.

*- 빈값
    IF lv_key IS INITIAL.
      rv_err = 'X'.
      RETURN.
    ENDIF.

*- 200~300자 사이
    DATA(lv_len) = strlen( lv_key ).
    IF lv_len NOT BETWEEN 200 AND 300.
      rv_err = 'X'.
      RETURN.
    ENDIF.

*- 스페이스
    CONDENSE lv_key_tmp.
    IF lv_key_tmp NE lv_key.
      rv_err = 'X'.
      RETURN.
    ENDIF.

*- 대문자,숫자
    CONCATENATE '[A-Z0-9]+$' '' INTO lv_pattern. " 영어
    DATA(lv_succ) = cl_abap_matcher=>create( pattern = lv_pattern text = lv_key )->match( ).
    IF lv_succ IS INITIAL.
      rv_err = 'X'.
      RETURN.
    ENDIF.

    IF rv_err IS INITIAL.
      CALL METHOD /u4a/cl_utilities=>dialog_close
        EXPORTING
          io_view     = ar_view
          i_dialog_id = 'DIALOGNF'.

      APPEND |NetFunnel_Stop("{ lv_nf_flag }");| TO lt_script.
      CALL METHOD /u4a/cl_utilities=>set_freestyle_script
        EXPORTING
          io_view   = ar_view
          it_script = lt_script.
    ENDIF.

  ENDMETHOD.


  METHOD check_st_possible.

    DATA lv_time_flag.

    CLEAR gs_msg.

*학생 여부
    IF gs_login-st_no IS INITIAL.
      gs_msg-message = zcmclk100=>otr( alias = 'ZDCM05/TX10000050' ).
      RETURN.
    ENDIF.

*학생 전공
    IF gs_major IS INITIAL.
      gs_msg-message = zcmclk100=>otr( alias = 'ZDCM05/TX10000053' ).
      RETURN.
    ENDIF.

***학적 상태
**    IF gs_ststatus-sts_cd <> '1000'.
**      gs_msg-message = zcmclk100=>otr( alias = 'ZDCM05/TX10000051' ).
**      RETURN.
**    ENDIF.


*학생그룹별 수강신청 학사력
    IF gv_timelimit_fg IS NOT INITIAL.

      IF gt_timelimits IS NOT INITIAL.
        CASE gt_timelimits[ 1 ]-ca_timelimit.
          WHEN '0300' OR '0320'.
            DELETE gt_timelimits WHERE ca_window <> gv_regwindow.
          WHEN '0310'.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.

      CLEAR lv_time_flag.
      LOOP AT gt_timelimits INTO DATA(ls_time).
        CASE ls_time-ca_timelimit.
          WHEN '0300' OR '0320'.
            IF ls_time-ca_window = gv_regwindow.
              lv_time_flag = 'X'.
            ENDIF.
          WHEN '0310'.
            CASE gv_regwindow.
              WHEN '1' OR '2' OR '3' OR '4'.
                lv_time_flag = 'X'.
              WHEN OTHERS.
            ENDCASE.
          WHEN '0330'.
            lv_time_flag = 'X'.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.

      IF lv_time_flag IS INITIAL.
        gs_msg-type = 'E'.
        gs_msg-message = zcmclk100=>otr( alias = 'ZDCM05/TX10000052' ).
        RETURN.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD check_st_status.

    DATA lv_msgid TYPE symsgid.
    DATA lv_msgtx TYPE char100.
    DATA lv_max TYPE numc4.

    CALL FUNCTION 'ZCM_GET_INITS'
      EXPORTING
        i_peryr = gs_timelimit_100-ca_peryr
        i_perid = gs_timelimit_100-ca_perid
        i_objid = gs_login-st_id
        i_keydt = sy-datum
      IMPORTING
        o_max   = lv_max
        o_msgid = lv_msgid
        o_msgtx = lv_msgtx.

*가능학점
    gs_credit-max = lv_max.

    IF lv_msgid = 'E'.
      gs_msg-type = lv_msgid.
      gs_msg-message = lv_msgtx.
    ENDIF.


  ENDMETHOD.


  METHOD check_timelimit.

    IF gv_timelimit_fg IS INITIAL.  "관리자
      RETURN.
    ENDIF.

    DATA lv_oid TYPE hrobjid.

    CASE gs_org-org_comm.
      WHEN '0002'.  "경영
        lv_oid = gs_org-o_objid.
      WHEN OTHERS.
        lv_oid = gs_org-org_id.
    ENDCASE.

    zcmclk100=>booking_period(
      EXPORTING
        i_oid         = lv_oid
        i_flt_t       = 'X'
      IMPORTING
        et_timelimits = DATA(lt_times)
    ).

    IF lt_times IS NOT INITIAL.
      CASE lt_times[ 1 ]-ca_timelimit.
        WHEN '0300' OR '0320'.
          DELETE lt_times WHERE ca_window <> gv_regwindow.
        WHEN '0310'.
        WHEN '0330'.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.

    IF lt_times IS INITIAL.
      DATA(lv_msg) = zcmclk100=>otr( alias = 'ZDCM05/TX10000052' ).
      msg_toast( lv_msg ).

      gs_msg-message = lv_msg.

      app_log_off( ).
      rv_err = 'X'. RETURN.
    ENDIF.

  ENDMETHOD.


  method CONSTRUCTOR.

  endmethod.


  METHOD ddlb_org1.

    at_org1 = zcmclk100=>get_ddlb_org1( gs_org-org_comm ).

*수강가능 소속 학사력
    LOOP AT at_org1 INTO DATA(ls_org1).
      DATA(lv_index) = sy-tabix.
      CHECK ls_org1-name <> gs_org-org_id.

      READ TABLE gt_possb_timelimits WITH KEY possb_oid = ls_org1-name TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        DELETE at_org1 INDEX lv_index.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD ddlb_org2.

    CLEAR: at_org2, at_org3, gs_cond-o_id2, gs_cond-o_id3.
    CHECK gs_cond-o_id1 IS NOT INITIAL.

    CASE gs_cond-o_id1.
      WHEN '30000002'.
        gs_ui-o_id3_vis = 'X'.
      WHEN OTHERS.
        gs_ui-o_id3_vis = ''.
    ENDCASE.

    at_org2 = zcmclk100=>get_ddlb_org2( gs_cond-o_id1 ).

  ENDMETHOD.


  METHOD ev_blank.


  ENDMETHOD.


  METHOD ev_booking.

    CLEAR: gs_msg, gs_rebook_info.

*수강 가능 여부
    zcmclk100=>check_is_bookable(
      EXPORTING
        i_mode          = gs_auth-auth
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
        es_rebook_info  = DATA(ls_rebook_info)
        et_msg          = DATA(lt_msg)
    ).
    IF lt_msg IS NOT INITIAL.
      gt_msg = CORRESPONDING #( BASE ( gt_msg ) lt_msg ).
      gs_msg = lt_msg[ 1 ].
      go_log->save( 'E' ).
      RETURN.
    ENDIF.

    IF ls_rebook_info IS NOT INITIAL.
      gs_rebook_info = ls_rebook_info.
    ENDIF.

**수강신청 함수 실행
    zcmclk100=>booking(
      EXPORTING
        i_stid         = gs_login-st_id
        i_st_regwindow = gv_regwindow
        i_st_major     = gs_major-sc_objid1
        is_book_data   = gs_selist
        is_rebook_info = gs_rebook_info
      IMPORTING
        es_msg         = DATA(ls_msg)
    ).

*수강신청 완료
    IF ls_msg IS INITIAL.
      get_booked_list( ).
      ls_msg-message = zcmclk100=>otr( EXPORTING alias = 'ZDCM05/TX10000081'
                                                 v1    = |[{ gs_selist-seshort }] { gs_selist-smstext } - | ).
    ELSE.

      IF ls_msg-id = 'HRPIQ000' AND ( ls_msg-number = '814' OR ls_msg-number = '168' ).
        ls_msg-message = zcmclk100=>msg( arbgb = 'ZMCCM01' msgnr = '556' ).
        ls_msg-message = |[{ gs_selist-seshort }] { gs_selist-smstext } - { ls_msg-message }|.
      ENDIF.
      gs_msg = ls_msg.
      go_log->save( 'E' ).
      zcmclk100=>decrease_booking_count(
        i_seid = gs_selist-seobjid
        i_keydt = gs_timelimit_100-ca_lbegda
        i_st_regwindow = gv_regwindow ).
    ENDIF.
    APPEND ls_msg TO gt_msg.


  ENDMETHOD.


  METHOD ev_btn_req.

    CHECK check_timelimit( ) IS INITIAL.  "실시간 학사력

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


    IF gs_222-nf_o_flag IS NOT INITIAL.
      DATA lt_script TYPE string_table.

      APPEND 'NetFunnel_Start("save1");' TO lt_script.
      CALL METHOD /u4a/cl_utilities=>set_freestyle_script
        EXPORTING
          io_view   = ar_view
          it_script = lt_script.
    ELSE.

      booking_single( ).
    ENDIF.



  ENDMETHOD.


  METHOD ev_cancel.

    CHECK check_timelimit( ) IS INITIAL.  "실시간 학사력

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

    check_cancel( ).
    CHECK gs_msg IS INITIAL.

    IF gs_222-pu_flag IS NOT INITIAL.
      lv_msg = zcmclk100=>msg( arbgb = 'ZMCCM01' msgnr = '322' ).
      REPLACE ALL OCCURENCES OF '&1' IN lv_msg WITH |[{ ls_booked-seshort }] { ls_booked-smstext } - |.
      /u4a/cl_utilities=>m_messagebox(
        io_view          = ar_view
        i_msgtx          = lv_msg
        i_popup_type     = /u4a/cl_utilities=>cs_m_msg_box_tp-confirm
        i_callback_event = 'EV_CANCEL_OK'
      ).

    ELSE.
      booking_canc( ).
    ENDIF.


  ENDMETHOD.


  METHOD ev_cancel_ok.

    CHECK i_event_name = 'OK'.

    booking_canc( ).



  ENDMETHOD.


  METHOD ev_ddlb_org2.

    ddlb_org2( ).



  ENDMETHOD.


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


  METHOD ev_img_click.

    DATA lv_index TYPE i.

    CALL METHOD /u4a/cl_utilities=>get_selected_index
      EXPORTING
        i_event_name = i_event_name
      IMPORTING
        e_index      = lv_index.

    READ TABLE gt_macro INTO DATA(ls_macro) INDEX lv_index.

    IF gs_macro-input1 IS INITIAL.
      gs_macro-input1 = ls_macro-answer.
    ELSEIF gs_macro-input2 IS INITIAL.
      gs_macro-input2 = ls_macro-answer.
    ELSEIF gs_macro-input3 IS INITIAL.
      gs_macro-input3 = ls_macro-answer.
    ENDIF.


  ENDMETHOD.


  METHOD ev_logout.

    DATA(lv_msg) = zcmclk100=>otr( 'ZDCM/MSG_LOGOUT01' ).

    /u4a/cl_utilities=>m_messagebox(
      io_view          = ar_view
      i_msgtx          = lv_msg
      i_popup_type     = /u4a/cl_utilities=>cs_m_msg_box_tp-confirm
      i_callback_event = 'EV_LOGOUT_OK'
    ).

  ENDMETHOD.


  METHOD ev_logout_ok.

    DATA lv_url TYPE string.

    CHECK i_event_name = 'OK'.

*    DELETE FROM zcmt2024_user WHERE uname = sy-uname.

    zcmclk100=>get_application_url(
      EXPORTING
        im_appid = 'ZCMUIK100'
      RECEIVING
        rm_url   = lv_url
    ).

    CALL METHOD /u4a/cl_utilities=>app_log_off
      EXPORTING
        io_view        = ar_view
        i_redirect_url = lv_url.


  ENDMETHOD.


  METHOD ev_macro_img_refresh.
    CLEAR : gs_macro-input1,gs_macro-input2,gs_macro-input3.
  ENDMETHOD.


  METHOD ev_macro_ok.

    DATA lt_input LIKE TABLE OF gs_macro-input1.

    CHECK gs_macro-input1 IS NOT INITIAL.
    CHECK gs_macro-input2 IS NOT INITIAL.
    CHECK gs_macro-input3 IS NOT INITIAL.

    APPEND gs_macro-input1 TO lt_input.
    APPEND gs_macro-input2 TO lt_input.
    APPEND gs_macro-input3 TO lt_input.
    DELETE ADJACENT DUPLICATES FROM lt_input COMPARING ALL FIELDS.

    IF lines( lt_input ) = 3.
      READ TABLE gt_macro WITH KEY answer = gs_macro-input1 onoff = 'ON' TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        READ TABLE gt_macro WITH KEY answer = gs_macro-input2 onoff = 'ON' TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          READ TABLE gt_macro WITH KEY answer = gs_macro-input3 onoff = 'ON' TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            DATA(lv_ok) = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_ok IS INITIAL.
      gs_macro-err_cnt = gs_macro-err_cnt + 1.
      DATA(lv_msg) = zcmclk100=>otr( alias = 'ZDCM05/TX10000075' v1 = gs_macro-err_cnt ).
      msg_toast( lv_msg ).

      IF gs_macro-err_cnt = 5.
        zcmclk100=>set_macro_block( gs_login-st_id ).
        CHECK check_macro_error( ) IS INITIAL.
      ENDIF.

      macro_random( ).

      RETURN.
    ENDIF.

*    IF gt_cart IS INITIAL.
*      gt_cart = VALUE #( ( ) ( ) ( ) ( ) ( ) ( ) ).
*    ENDIF.


    CLEAR gs_macro-err_cnt.
    gs_ui-macro_vis = ''.
    gs_ui-cart_vis = 'X'.

  ENDMETHOD.


  METHOD ev_msg_ok.
    CALL METHOD /u4a/cl_utilities=>dialog_close
      EXPORTING
        io_view     = ar_view
        i_dialog_id = 'DIALOGMSG'.
  ENDMETHOD.


  METHOD ev_netfunnel_return.

    READ TABLE it_form_data INTO DATA(ls_form) WITH KEY name = 'UI_OBJ_ID'.
    CHECK sy-subrc = 0.

    DATA(lv_nf_flag) = ls_form-value.

    DATA(lv_err) = check_netfunnel_key( it_form_data ).
    IF lv_err IS NOT INITIAL.
      RETURN.
    ENDIF.

    CASE lv_nf_flag.
      WHEN 'login'.
        set_main_init( ).
      WHEN 'search'.
        get_data_select( ).
      WHEN 'save'.
        booking_cart( ).
      WHEN 'save1'.
        booking_single( ).
      WHEN OTHERS.
    ENDCASE.



  ENDMETHOD.


  METHOD EV_NETFUNNEL_START_LOGIN.

    CALL METHOD /u4a/cl_utilities=>dialog_close
      EXPORTING
        io_view     = ar_view
        i_dialog_id = 'DIALOGNFLOADING'.

    DATA lt_script TYPE string_table.

    APPEND 'NetFunnel_Start("login");' TO lt_script.

    CALL METHOD /u4a/cl_utilities=>set_freestyle_script
      EXPORTING
        io_view   = ar_view
        it_script = lt_script.

  ENDMETHOD.


  METHOD ev_refresh.

    DATA lv_oid TYPE hrobjid.

    CASE gs_org-org_comm.
      WHEN '0002'.  "경영
        lv_oid = gs_org-o_objid.
      WHEN OTHERS.
        lv_oid = gs_org-org_id.
    ENDCASE.

    CLEAR: gs_timelimit_100, gt_timelimits.

    zcmclk100=>booking_period(
      EXPORTING
        i_oid            = lv_oid
      IMPORTING
        et_timelimits    = gt_timelimits
        es_timelimit_100 = gs_timelimit_100
    ).

    zcmclk100=>check_real_time( CHANGING ct_tab = gt_timelimits ).

    IF gt_timelimits IS NOT INITIAL.
      CASE gt_timelimits[ 1 ]-ca_timelimit.
        WHEN '0300' OR '0320'.
          DELETE gt_timelimits WHERE ca_window <> gv_regwindow.
        WHEN '0310'.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.

*현재시간 Refresh
    IF lines( gt_txt ) = 3.
      DELETE gt_txt INDEX 3.
      DATA(lv_dd) = CONV char10( |{ sy-datum(4) }.{ sy-datum+4(2) }.{ sy-datum+6(2) }| ).
      DATA(lv_tt) = CONV char10( |{ sy-uzeit(2) }:{ sy-uzeit+2(2) }:{ sy-uzeit+4(2) }| ).
      APPEND |{ zcmclk100=>otr( 'ZDCM05/TX10000159' ) } : { lv_dd } { lv_tt } | TO gt_txt.
      CONCATENATE LINES OF gt_txt INTO gs_msg-message SEPARATED BY cl_abap_char_utilities=>newline.
    ENDIF.

    CHECK gt_timelimits IS NOT INITIAL.

    set_first_page( ).

  ENDMETHOD.


  METHOD ev_save_cart.

    CHECK check_timelimit( ) IS INITIAL.  "실시간 학사력

    IF gt_cart IS INITIAL.
      msg_toast( zcmclk100=>otr( 'ZDCM05/TX10000153' ) ).
      RETURN.
    ENDIF.

    DATA(lt_cart) = gt_cart.
    DELETE lt_cart WHERE se_id IS INITIAL.
    CHECK lt_cart IS NOT INITIAL.

    IF gs_222-nf_b_flag IS NOT INITIAL.
      netfunnel_start_save( ).
    ELSE.
      booking_cart( ).
    ENDIF.



  ENDMETHOD.


  METHOD ev_search.

    CHECK check_timelimit( ) IS INITIAL.  "실시간 학사력

    CASE gs_ui-tab_sel.
      WHEN '1'.
        CASE gs_cond-o_id1.
          WHEN '30000002'.
            CHECK gs_cond-o_id2 IS NOT INITIAL.

          WHEN OTHERS.
            CHECK gs_cond-o_id2 IS NOT INITIAL.
        ENDCASE.
      WHEN '2'.
        CHECK gs_cond-smsht IS NOT INITIAL.
        TRANSLATE gs_cond-smsht TO UPPER CASE.
      WHEN '3'.
        CHECK gs_cond-smtxt IS NOT INITIAL.
    ENDCASE.

    IF gs_222-nf_s_flag IS NOT INITIAL.
      DATA lt_script TYPE string_table.

      APPEND 'NetFunnel_Start("search");' TO lt_script.
      CALL METHOD /u4a/cl_utilities=>set_freestyle_script
        EXPORTING
          io_view   = ar_view
          it_script = lt_script.
    ELSE.
      get_data_select( ).
    ENDIF.







  ENDMETHOD.


  METHOD ev_se_short_change.

    DATA lv_index TYPE i.
    DATA lt_sm TYPE TABLE OF hrobject.

    CALL METHOD /u4a/cl_utilities=>get_selected_index
      EXPORTING
        i_event_name = i_event_name
      IMPORTING
        e_index      = lv_index.

    READ TABLE gt_cart ASSIGNING FIELD-SYMBOL(<fs>) INDEX lv_index.
    CHECK sy-subrc = 0.

    TRANSLATE <fs>-se_short TO UPPER CASE.
    CONDENSE <fs>-se_short NO-GAPS.

    CLEAR: <fs>-se_id, <fs>-stext.

    SELECT SINGLE objid FROM hrp1000
      INTO @<fs>-se_id
      WHERE plvar = '01'
        AND otype = 'SE'
        AND istat = '1'
        AND begda <= @sy-datum
        AND endda >= @sy-datum
        AND langu = @sy-langu
        AND short = @<fs>-se_short.

    SELECT SINGLE objid FROM hrp1001
      INTO @DATA(lv_smid)
      WHERE otype = 'SM'
        AND begda <= @sy-datum
        AND endda >= @sy-datum
        AND sclas = 'SE'
        AND sobid = @<fs>-se_id
        AND subty = 'B514'.

    IF lv_smid IS NOT INITIAL.
      lt_sm = VALUE #( ( objid = lv_smid ) ).
      zcmclk100=>sm_stext(
        EXPORTING
          it_sm       = lt_sm
        IMPORTING
          et_sm_stext = DATA(lt_sm_stext)
      ).
    ENDIF.

    IF lt_sm_stext IS NOT INITIAL.
      <fs>-stext = lt_sm_stext[ 1 ]-stext.
    ELSE.
      msg_toast( zcmclk100=>otr( 'ZDCM05/TX10000152' ) ).
    ENDIF.
  ENDMETHOD.


  METHOD ev_tab_select.

    CASE gs_ui-tab_sel.
      WHEN '1'.
      WHEN '2'.
        CALL METHOD /u4a/cl_utilities=>set_ui_focus
          EXPORTING
            io_view = ar_view
            i_uiid  = 'INPUT2'.
      WHEN '3'.
        CALL METHOD /u4a/cl_utilities=>set_ui_focus
          EXPORTING
            io_view = ar_view
            i_uiid  = 'INPUT3'.
      WHEN OTHERS.
    ENDCASE.


  ENDMETHOD.


  METHOD get_acwork.

    CLEAR gt_acwork.
    zcmcl000=>get_aw_acwork(
      EXPORTING
        it_stobj  = VALUE hrobject_t( ( objid = gs_login-st_id ) )
      IMPORTING
        et_acwork = gt_acwork
    ).

*   이번학기, 이후학기 제외
    DELETE gt_acwork WHERE awotype <> 'SM'.
    DELETE gt_acwork WHERE peryr > gs_timelimit_100-ca_peryr.
    DELETE gt_acwork WHERE peryr = gs_timelimit_100-ca_peryr
                       AND perid >= gs_timelimit_100-ca_perid.


  ENDMETHOD.


  METHOD get_booked_list.

    CLEAR: gt_booked.
    zcmclk100=>booked_list(
      EXPORTING
        i_stid    = gs_login-st_id
        i_peryr   = gs_timelimit_100-ca_peryr
        i_perid   = gs_timelimit_100-ca_perid
      IMPORTING
        et_detail = DATA(lt_booked)
    ).

    gt_booked = lt_booked.

* 신청학점, 신청과목수
    CLEAR: gs_credit-booked, gs_credit-cnt, gs_credit-cnt_t.
    CLEAR: gs_credit-dvalue, gs_credit-dperc.

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

*    gs_credit-dvalue = |{ gs_credit-booked } / { gs_credit-max }|.
    gs_credit-dvalue = |{ zcmclk100=>otr( 'ZDCM/BOOKED_CREDIT' ) } { gs_credit-booked } / { zcmclk100=>otr( 'ZDCM/BOOKABLE_CREDIT' ) } { gs_credit-max }|.
    gs_credit-dperc = gs_credit-booked / gs_credit-max * 100.

  ENDMETHOD.


  METHOD get_cart.

    DATA ls_cart LIKE LINE OF gt_cart.
    DATA lt_sm TYPE TABLE OF hrobject.

    CLEAR gt_cart.

    SELECT * FROM zcmtk310
      INTO TABLE @DATA(lt_310)
      WHERE peryr = @gs_timelimit_100-ca_peryr
        AND perid = @gs_timelimit_100-ca_perid
        AND st_id = @gs_login-st_id
        AND comp = ''.
    SORT lt_310 BY erdat ertim.

    IF lt_310[] IS NOT INITIAL.

      SELECT objid, short FROM hrp1000
        INTO TABLE @DATA(lt_se)
        FOR ALL ENTRIES IN @lt_310
        WHERE plvar = '01'
          AND otype = 'SE'
          AND objid = @lt_310-se_id
          AND langu = '3'
          AND begda <= @gs_timelimit_100-ca_lbegda
          AND endda >= @gs_timelimit_100-ca_lbegda.
      SORT lt_se BY objid.

      lt_sm = CORRESPONDING #( lt_310 MAPPING objid = sm_id ).
      zcmclk100=>sm_stext(
        EXPORTING
          it_sm       = lt_sm
        IMPORTING
          et_sm_stext = DATA(lt_sm_stext) ).
    ENDIF.

    LOOP AT lt_310 INTO DATA(ls_310).
      ls_cart-peryr = ls_310-peryr.
      ls_cart-perid = ls_310-perid.
      ls_cart-se_id = ls_310-se_id.
      READ TABLE lt_se INTO DATA(ls_se) WITH KEY objid = ls_cart-se_id BINARY SEARCH.
      IF sy-subrc = 0.
        ls_cart-se_short = ls_se-short.
      ENDIF.
      ls_cart-sm_id = ls_310-sm_id.
      READ TABLE lt_sm_stext INTO DATA(ls_sm_stext) WITH KEY objid = ls_310-sm_id BINARY SEARCH.
      IF sy-subrc = 0.
        ls_cart-short = ls_sm_stext-short.
        ls_cart-stext = ls_sm_stext-stext.
      ENDIF.

      APPEND ls_cart TO gt_cart.
      CLEAR: ls_cart.
    ENDLOOP.

    DO 6 - lines( gt_cart ) TIMES.
      APPEND INITIAL LINE TO gt_cart.
    ENDDO.


  ENDMETHOD.


  METHOD get_cart_locked.

    get_cart(  ).

    DATA(lt_cart) = gt_cart.
    DELETE lt_cart WHERE se_id IS INITIAL.

    IF lt_cart IS NOT INITIAL.
      rv_locked = 'X'.
    ENDIF.


  ENDMETHOD.


  METHOD get_data_select.

    CASE gs_ui-tab_sel.
      WHEN '1'.
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
    IF lt_detail IS INITIAL.
      msg_toast( zcmclk100=>otr( 'ZDCM/EMPTY_TABLE_TEXT2' ) ).
      CLEAR gt_selist.
      RETURN.
    ENDIF.

*정원, 신청인원
    zcmclk100=>get_se_quota_count(
      EXPORTING
        i_st_regwindow = gv_regwindow
        i_keydt        = gs_timelimit_100-ca_lbegda
        i_peryr        = gs_timelimit_100-ca_peryr
        i_perid        = gs_timelimit_100-ca_perid
        it_selist      = lt_selist
        i_real_506     = ''
      IMPORTING
        et_cnt         = DATA(lt_cnt)
    ).

    CLEAR gt_selist.
    gt_selist = lt_detail.

    LOOP AT gt_selist ASSIGNING FIELD-SYMBOL(<fs>).
      DATA(lv_index) = sy-tabix.
      READ TABLE lt_cnt INTO DATA(ls_cnt) WITH KEY se_id = <fs>-seobjid BINARY SEARCH.
      IF sy-subrc = 0.
        <fs>-limit_kapz = ls_cnt-limit_kapz.
        <fs>-book_cnt = ls_cnt-book_cnt.
        IF <fs>-limit_kapz > <fs>-book_cnt.
          <fs>-status_color = '#30914c'.  "Green
        ELSE.
          <fs>-status_color = '#f53232'.  "Red
        ENDIF.
      ENDIF.

*수강가능 소속 학사력
      CHECK <fs>-orgid <> gs_org-org_id.
      READ TABLE gt_possb_timelimits WITH KEY possb_oid = <fs>-orgid TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        DELETE gt_selist INDEX lv_index.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_init_data.

    SELECT SINGLE * FROM zcmtk222 INTO gs_222.

  ENDMETHOD.


  METHOD get_login_id.

    CLEAR: gs_login, gs_auth, gv_timelimit_fg.

    zcmclk100=>get_login_id( IMPORTING es_login        = gs_login
                                       es_auth         = gs_auth
                                       ev_timelimit_fg = gv_timelimit_fg ).

  ENDMETHOD.


  METHOD get_possb_timelimits.

    DATA ls_possb TYPE ty_possb_timelimits.

    CLEAR gt_possb_timelimits.
    CHECK gt_timelimits[] IS NOT INITIAL.

    SELECT a~objid, b~possb_oid FROM hrp9566 AS a
      INNER JOIN hrt9566 AS b
      ON a~tabnr = b~tabnr
      INTO TABLE @DATA(lt_9566)
      WHERE a~plvar = '01'
        AND a~otype = 'O'
        AND a~istat = '1'
        AND a~objid = @gs_org-org_id
        AND a~begda <= @gs_timelimit_100-ca_lbegda
        AND a~endda >= @gs_timelimit_100-ca_lbegda.

    IF gv_regwindow = 'G'.
      lt_9566[] = VALUE #( BASE lt_9566[] ( objid = '30000100' possb_oid = '30000002' ) ).
    ENDIF.

    CHECK lt_9566 IS NOT INITIAL.
    SORT lt_9566 BY possb_oid.

    LOOP AT lt_9566 INTO DATA(ls_9566).
      CHECK ls_9566-possb_oid <> gs_org-org_id.
      CALL METHOD zcmclk100=>booking_period
        EXPORTING
          i_oid         = ls_9566-possb_oid
          i_timelimit   = gt_timelimits[ 1 ]-ca_timelimit
          i_flt_t       = 'X'
        IMPORTING
          et_timelimits = DATA(lt_timelimits).
      IF lt_timelimits IS NOT INITIAL.
        ls_possb-possb_oid = ls_9566-possb_oid.
        ls_possb-timelimit = lt_timelimits[ 1 ].
        APPEND ls_possb TO gt_possb_timelimits.
        CLEAR: ls_possb.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_st_info.

    CHECK gs_login-st_no IS NOT INITIAL.

*개인정보
    CLEAR gs_person.
    zcmcl000=>get_st_person(
      EXPORTING
        it_stobj    = VALUE hrobject_t( ( objid = gs_login-st_id ) )
      IMPORTING
        et_stperson = DATA(lt_stperson)
    ).
    IF lt_stperson IS NOT INITIAL.
      gs_person = lt_stperson[ 1 ].
    ENDIF.

*수강신청 그룹
    zcmclk100=>get_stgrp( EXPORTING i_stid       = gs_login-st_id
                                    i_keydt      = gs_timelimit_100-ca_lbegda
                                    i_namzu      = gs_person-namzu
                          IMPORTING ev_regwindow = gv_regwindow ).
    IF gv_regwindow = 'G'.
      gs_auth-auth = 'STUDENT_G'.
    ENDIF.

*전공
    CLEAR gs_major.
    zcmcl000=>get_st_major(
      EXPORTING
        it_stobj   = VALUE hrobject_t( ( objid = gs_login-st_id ) )
        iv_keydate = gs_timelimit_100-ca_lbegda
        iv_langu   = '3'
      IMPORTING
        et_stmajor = DATA(lt_major)
    ).
    IF lt_major IS NOT INITIAL.
      gs_major = lt_major[ 1 ].
    ENDIF.

*진급
    CLEAR gs_stprog.
    zcmcl000=>get_st_progression(
      EXPORTING
        it_stobj  = VALUE hrobject_t( ( objid = gs_login-st_id ) )
      IMPORTING
        et_stprog = DATA(lt_stprog)
    ).
    IF lt_stprog IS NOT INITIAL.
      gs_stprog = lt_stprog[ 1 ].
    ENDIF.
    IF gs_person-namzu = 'A0'.
      SELECT SINGLE regwindow regsemstr FROM hrp1705
        INTO ( gs_stprog-cprcl, gs_stprog-cacst )
        WHERE plvar = '01'
          AND otype = 'ST'
          AND istat = '1'
          AND objid = gs_login-st_id
          AND begda <= gs_timelimit_100-ca_lbegda
          AND endda >= gs_timelimit_100-ca_lbegda.
    ENDIF.


**
***학적상태
**    CLEAR gs_ststatus.
**    zcmcl000=>get_st_status(
**      EXPORTING
**        it_stobj    = VALUE hrobject_t( ( objid = gs_login-st_id ) )
**        iv_keydate  = gs_timelimit_100-ca_lbegda
**      IMPORTING
**        et_ststatus = DATA(lt_status)
**    ).
**    IF lt_status IS NOT INITIAL.
**      gs_ststatus = lt_status[ 1 ].
**    ENDIF.



  ENDMETHOD.


  METHOD get_st_org.

    CLEAR gs_org.

    zcmcl000=>get_st_orgcd(
      EXPORTING
        it_stobj = VALUE hrobject_tab( ( objid = gs_login-st_id ) )
      IMPORTING
        et_storg = DATA(lt_org)
    ).

    READ TABLE lt_org INTO gs_org INDEX 1.


  ENDMETHOD.


  METHOD macro_random.

    DATA lt_int TYPE TABLE OF int4.
    DATA lt_int2 TYPE TABLE OF int4.
    DATA ls_mac TYPE zcmt2024_macro.
    DATA ls_macro LIKE LINE OF gt_macro.

    DO 6 TIMES.
      zcmclk100=>get_random_macro( EXPORTING max = 99 min = 10 CHANGING ct_int = lt_int ).
    ENDDO.

    DO 3 TIMES.
      zcmclk100=>get_random_macro( EXPORTING max = 6 min = 1 CHANGING ct_int = lt_int2 ).
    ENDDO.

    SELECT * FROM zcmt2024_macro
      INTO TABLE @DATA(lt_img).
    SORT lt_img BY zseq onoff.

    CLEAR gt_macro.
    LOOP AT lt_int INTO DATA(lv_int).
      READ TABLE lt_img INTO DATA(ls_img) WITH KEY zseq = lv_int onoff = 'OFF' BINARY SEARCH.
      IF sy-subrc = 0.
        ls_macro-url = |{ gc_img_path }{ ls_img-img }.{ ls_img-img_type }|.
        ls_macro-zseq = ls_img-zseq.
        ls_macro-onoff = ls_img-onoff.
        ls_macro-answer = ls_img-answer.
      ENDIF.

      APPEND ls_macro TO gt_macro.
      CLEAR ls_macro.
    ENDLOOP.

    LOOP AT lt_int2 INTO DATA(lv_int2).
      READ TABLE gt_macro ASSIGNING FIELD-SYMBOL(<fs>) INDEX lv_int2.
      CHECK sy-subrc = 0.

      READ TABLE lt_img INTO ls_img WITH KEY zseq = <fs>-zseq onoff = 'ON' BINARY SEARCH.
      IF sy-subrc = 0.
        <fs>-url = |{ gc_img_path }{ ls_img-img }.{ ls_img-img_type }|.
        <fs>-zseq = ls_img-zseq.
        <fs>-onoff = ls_img-onoff.
        <fs>-answer = ls_img-answer.
      ENDIF.
    ENDLOOP.

    CLEAR: gs_macro-input1, gs_macro-input2, gs_macro-input3.

    gs_ui-macro_vis = 'X'.
    gs_ui-cart_vis = ''.

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

    gs_ui-title = zcmclk100=>otr( 'ZDCM05/TX10000047' ).
    gs_ui-title = |{ gs_ui-title } - { lv_peryt } { lv_perit } - { gs_login-st_nm } [{ gs_login-st_no }] |.

    gs_ui-tab_sel = '1'.

    IF gs_222-mc_flag IS INITIAL.
      gs_ui-macro_vis = ''.
      gs_ui-cart_vis = 'X'.
    ELSE.
      IF gt_cart IS NOT INITIAL.
        gs_ui-macro_vis = ''.
        gs_ui-cart_vis = 'X'.
      ELSE.
        macro_random( ).
      ENDIF.
    ENDIF.


    IF gt_timelimits IS NOT INITIAL.
      IF gt_timelimits[ 1 ]-ca_timelimit = '0330'.  "수강신청 삭제기간
        gs_ui-book_vis = ''.
        gs_ui-cart_vis = ''.
      ELSE.
        gs_ui-book_vis = 'X'.
      ENDIF.
    ENDIF.

    IF gs_auth-auth <> 'STUDENT' AND gs_auth-auth <> 'STUDENT_G'.
      gs_ui-book_vis = 'X'.
    ENDIF.

  ENDMETHOD.


  METHOD msg_dialog.
    DATA lv_msg TYPE string.

    CHECK gt_msg IS NOT INITIAL.

    LOOP AT gt_msg ASSIGNING FIELD-SYMBOL(<fs>).
      CASE <fs>-type.
        WHEN 'E'.
          <fs>-message_v4 = 'Error'.
        WHEN OTHERS.
          <fs>-message_v4 = 'Success'.
      ENDCASE.
      IF lv_msg IS INITIAL.
        lv_msg = <fs>-message.
      ELSE.
        lv_msg = lv_msg && cl_abap_char_utilities=>newline && <fs>-message.
      ENDIF.
    ENDLOOP.

    IF gs_222-pu_flag IS NOT INITIAL.
      CALL METHOD /u4a/cl_utilities=>dialog_open
        EXPORTING
          io_view     = ar_view
          i_dialog_id = 'DIALOGMSG'.
    ELSE.
      msg_toast( lv_msg ).
    ENDIF.



  ENDMETHOD.


  METHOD msg_toast.

    /u4a/cl_utilities=>m_messagetoast(
      io_view = ar_view
      i_msgtx = i_msg
    ).

  ENDMETHOD.


  METHOD navi_to.

    /u4a/cl_utilities=>page_navigation(
      io_view  = ar_view
      i_appid  = 'APP'
      i_pageid = i_page
    ).

  ENDMETHOD.


  METHOD netfunnel_start_login.

*넷퍼넬 팝업
    CALL METHOD /u4a/cl_utilities=>dialog_open
      EXPORTING
        io_view     = ar_view
        i_dialog_id = 'DIALOGNFLOADING'.



  ENDMETHOD.


  METHOD netfunnel_start_save.

    DATA lt_script TYPE string_table.

    APPEND 'NetFunnel_Start("save");' TO lt_script.
    CALL METHOD /u4a/cl_utilities=>set_freestyle_script
      EXPORTING
        io_view   = ar_view
        it_script = lt_script.
  ENDMETHOD.


  METHOD session_mng.

*    CHECK sy-uname(4) <> 'ASPN'.
*    CHECK sy-uname <> '113034'.

    IF gs_222-mult_flag IS NOT INITIAL.
      CALL METHOD /u4a/cl_utilities=>delete_same_browser_session
        EXPORTING
          io_view = ar_view.

      zcmclk100=>session_manage( gs_login-st_no ).
    ENDIF.



  ENDMETHOD.


  METHOD set_first_page.

    IF gv_timelimit_fg IS INITIAL.  "관리자
      set_main_init( ).
      RETURN.
    ENDIF.

    set_refresh_flag( ).
    IF gs_ui-refresh_vis IS NOT INITIAL.
      app_log_off( ). RETURN.
    ENDIF.

    IF gs_222-nf_l_flag IS NOT INITIAL.
      netfunnel_start_login( ).
    ELSE.
      set_main_init( ).
    ENDIF.



  ENDMETHOD.


  METHOD set_init_gs_cond.

    get_possb_timelimits( ).  "학생 수강가능 학사력

    gs_cond-o_id1 = gs_org-org_id.

    ddlb_org1( ).
    ddlb_org2( ).

    CASE gs_cond-o_id1.
      WHEN '30000002'.
        gs_ui-o_id3_vis = 'X'.
      WHEN OTHERS.
        gs_ui-o_id3_vis = ''.
    ENDCASE.

  ENDMETHOD.


  METHOD set_main_init.

*To Main Page
    set_init_gs_cond( ).
    get_acwork( ).
    get_cart( ).
    get_booked_list( ).

    main_ui( ).

    navi_to( 'MAIN' ).

    go_log->save( 'C' ).

  ENDMETHOD.


  METHOD set_refresh_flag.

    DATA lt_txt TYPE string_table.
    DATA(lt_times) = gt_timelimits.

    CLEAR gt_txt.

    zcmclk100=>check_real_time( CHANGING ct_tab = lt_times ).

    IF lt_times IS INITIAL.
      LOOP AT gt_timelimits INTO DATA(ls_time).
        CALL METHOD zcmclk100=>timelimit_to_text
          EXPORTING
            is_time = ls_time
          RECEIVING
            rv_msg  = DATA(lv_txt).
        CASE sy-langu.
          WHEN '3'.
            SELECT SINGLE com_nm FROM zcmt0101
              INTO @DATA(lv_orgnm)
              WHERE grp_cd = '100'
                AND com_cd = @gs_org-org_comm.
          WHEN OTHERS.
            SELECT SINGLE com_nm_en FROM zcmt0101
              INTO @lv_orgnm
              WHERE grp_cd = '100'
                AND com_cd = @gs_org-org_comm.
        ENDCASE.

        SELECT SINGLE peryt FROM t7piqyeart
          INTO @DATA(lv_peryt)
          WHERE spras = @sy-langu
            AND peryr = @gs_timelimit_100-ca_peryr.

        SELECT SINGLE perit FROM t7piqperiodt
          INTO @DATA(lv_perit)
          WHERE spras = @sy-langu
            AND perid = @gs_timelimit_100-ca_perid.

        APPEND |{ lv_orgnm } { lv_peryt } { lv_perit } { lv_txt }| TO lt_txt.
      ENDLOOP.

      DELETE ADJACENT DUPLICATES FROM lt_txt COMPARING ALL FIELDS.
      lv_txt = zcmclk100=>otr( alias = 'ZDCM05/TX10000066' ).
      INSERT lv_txt INTO lt_txt INDEX 1.

      DATA(lv_dd) = CONV char10( |{ sy-datum(4) }.{ sy-datum+4(2) }.{ sy-datum+6(2) }| ).
      DATA(lv_tt) = CONV char10( |{ sy-uzeit(2) }:{ sy-uzeit+2(2) }:{ sy-uzeit+4(2) }| ).
      APPEND |{ zcmclk100=>otr( 'ZDCM05/TX10000159' ) } : { lv_dd } { lv_tt } | TO lt_txt.
      CONCATENATE LINES OF lt_txt INTO gs_msg-message SEPARATED BY cl_abap_char_utilities=>newline.

      gt_txt = lt_txt.
      gs_ui-refresh_vis = 'X'.
    ELSE.
      gs_ui-refresh_vis = ''.
    ENDIF.

  ENDMETHOD.


  METHOD update_comp_flag.

**    SELECT * FROM zcmtk310
**      INTO TABLE @DATA(lt_310)
**      WHERE peryr = @gs_timelimit_100-ca_peryr
**        AND perid = @gs_timelimit_100-ca_perid
**        AND st_id = @gs_login-st_id
**        AND comp = ''.
**
**    UPDATE zcmtk310 SET comp = 'X'
**                        aenam = sy-uname
**                        aedat = sy-datum
**                        aetim = sy-uzeit
**                  WHERE peryr = gs_timelimit_100-ca_peryr
**                    AND perid = gs_timelimit_100-ca_perid
**                    AND st_id = gs_login-st_id
**                    AND comp = ''.
**
**    gt_cart = VALUE #( ( ) ( ) ( ) ( ) ( ) ( ) ).

  ENDMETHOD.
ENDCLASS.
