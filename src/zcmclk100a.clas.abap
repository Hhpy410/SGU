class ZCMCLK100A definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_obj,
        otype TYPE hrp1001-otype,
        objid TYPE hrp1001-objid,
        sclas TYPE hrp1001-sclas,
        sobid TYPE hrp1001-objid,
      END OF ty_obj .
  types:
    tt_obj TYPE TABLE OF ty_obj .
  types:
    BEGIN OF ty_506,
        st_id     TYPE hrp1001-objid,
        sm_id     TYPE hrp1001-objid,
        se_id     TYPE hrp1001-objid,
        peryr     TYPE hrpad506-peryr,
        perid     TYPE hrpad506-perid,
        id        TYPE hrpad506-id,
        smstatus  TYPE hrpad506-smstatus,
        reperyr   TYPE hrpad506-reperyr,
        reperid   TYPE hrpad506-reperid,
        regwindow TYPE hrpad506-regwindow,
        resmid    TYPE hrpad506-resmid,
        reid      TYPE hrpad506-reid,
        repeatfg  TYPE hrpad506-repeatfg,
        cpattemp  TYPE hrpad506-cpattemp,
        cpunit    TYPE hrpad506-cpunit,
      END OF ty_506 .
  types:
    tt_506 TYPE TABLE OF ty_506 .
  types:
    BEGIN OF ty_se_e,
        se_id  TYPE hrp1000-objid,
        se_sht TYPE hrp1000-short,
        se_txt TYPE hrp1000-stext,
        e_id   TYPE hrp1000-objid,
      END OF ty_se_e .
  types:
    tt_se_e TYPE TABLE OF ty_se_e .
  types:
    BEGIN OF ty_se_cnt,
        se_id      TYPE hrp1000-objid,
        limit_kapz TYPE zcmsk_course-limit_kapz,
        book_cnt   TYPE zcmsk_course-book_cnt,
      END OF ty_se_cnt .
  types:
    tt_se_cnt TYPE TABLE OF ty_se_cnt .
  types:
    BEGIN OF ty_se_delay,
        se_id TYPE hrp1000-objid,
        cnt   TYPE zcmsk_course-book_cnt,
      END OF ty_se_delay .
  types:
    tt_se_delay TYPE TABLE OF ty_se_delay .
  types:
    BEGIN OF ty_credit,
        max(4)    TYPE p DECIMALS 1,
        booked(4) TYPE p DECIMALS 1,
        cnt       TYPE i,
        cnt_t     TYPE ddtext,
        dvalue    TYPE ddtext,
        dperc(3)  TYPE p DECIMALS 1,
      END OF ty_credit .
  types:
    BEGIN OF ty_sm_t,
        objid TYPE hrp1000-objid,
        otype TYPE hrp1000-otype,
        short TYPE hrp1000-short,
        stext TYPE hrp9450-ltext,
      END OF ty_sm_t .
  types:
    tt_sm_t TYPE TABLE OF ty_sm_t .
  types:
    BEGIN OF ty_ad506,
              st_id    TYPE cmacbpst-stobjid,
              sm_id    TYPE piqsmobjid,
              se_id    TYPE piqseobjid,
              adatanr  TYPE hrpad506-adatanr,
              smstatus TYPE hrpad506-smstatus,
              peryr    TYPE hrpad506-peryr,
              perid    TYPE hrpad506-perid,
              id       TYPE hrpad506-id,
              bookdate TYPE hrpad506-bookdate,
              reperyr  TYPE hrpad506-reperyr,
              reperid  TYPE hrpad506-reperid,
              resmid   TYPE hrpad506-resmid,
              reid     TYPE hrpad506-reid,
              repeatfg TYPE hrpad506-repeatfg,
            END OF ty_ad506 .
  types:
    tt_ad506 TYPE TABLE OF ty_ad506 .

  constants DAYS_MONDAY_3 type TEXT10 value '월' ##NO_TEXT.
  constants DAYS_TUESDAY_3 type TEXT10 value '화' ##NO_TEXT.
  constants DAYS_WEDNESDAY_3 type TEXT10 value '수' ##NO_TEXT.
  constants DAYS_THURSDAY_3 type TEXT10 value '목' ##NO_TEXT.
  constants DAYS_FRIDAY_3 type TEXT10 value '금' ##NO_TEXT.
  constants DAYS_SATURDAY_3 type TEXT10 value '토' ##NO_TEXT.
  constants DAYS_SUNDAY_3 type TEXT10 value '일' ##NO_TEXT.
  constants DAYS_MONDAY_E type TEXT10 value 'MO' ##NO_TEXT.
  constants DAYS_TUESDAY_E type TEXT10 value 'TU' ##NO_TEXT.
  constants DAYS_WEDNESDAY_E type TEXT10 value 'WE' ##NO_TEXT.
  constants DAYS_THURSDAY_E type TEXT10 value 'TH' ##NO_TEXT.
  constants DAYS_FRIDAY_E type TEXT10 value 'FR' ##NO_TEXT.
  constants DAYS_SATURDAY_E type TEXT10 value 'SA' ##NO_TEXT.
  constants DAYS_SUNDAY_E type TEXT10 value 'SU' ##NO_TEXT.
  constants DELAY_MIN type I value '600' ##NO_TEXT.
  constants DELAY_MAX type I value '1200' ##NO_TEXT.
  constants BLOCK_TIME type I value '300' ##NO_TEXT.

  class-methods BOOKED_LIST
    importing
      !I_STID type PIQSTUDENT
      !I_PERYR type PIQPERYR optional
      !I_PERID type PIQPERID optional
      !I_LANGU type SY-LANGU default SY-LANGU
    exporting
      !ET_SELIST type HROBJECT_T
      !ET_DETAIL type ZCMSK_COURSE_T
      !ET_506 type TT_506
      !ES_CREDIT type TY_CREDIT .
  class-methods BOOKING
    importing
      !I_STID type PIQSTUDENT
      !I_ST_MAJOR type PIQSCOBJID
      !I_ST_REGWINDOW type PIQREGWINDOW
      !IS_BOOK_DATA type ZCMSK_COURSE
      !IS_REBOOK_INFO type CI_PAD506 optional
      value(I_MODE) type PIQCHAR1 default 'V'
    exporting
      !ES_MSG type BAPIRET2
      !EV_ID type HRPAD506-ID .
  class-methods BOOKING_CANC
    importing
      !I_STID type PIQSTUDENT
      !IS_BOOKED type ZCMSK_COURSE
    exporting
      !ES_MSG type BAPIRET2 .
  class-methods BOOKING_PERIOD
    importing
      !I_OID type PIQOOBJID
      !I_KEYDT type DATUM default SY-DATUM
      !I_TIMELIMIT type PIQTIMELIMIT optional
      !I_FLT_T type FLAG optional
    exporting
      !ET_TIMELIMITS type PIQTIMELIMITS_TAB
      !ES_TIMELIMIT_100 type PIQTIMELIMITS .
  class-methods CHECK_DUPLICATED_SM
    importing
      !I_TARGET_SM type PIQSMOBJID
      value(IT_BOOKED) type ZCMSK_COURSE_T
    exporting
      !ES_MSG type BAPIRET2 .
  class-methods CHECK_HRP9550
    importing
      !I_KEYDT type DATUM
      !I_PERYR type PIQPERYR
      !I_PERID type PIQPERID
      !I_SMID type PIQSMOBJID
      !I_SEID type PIQSEOBJID
      !I_STID type PIQSTUDENT
      !I_STNO type PIQSTUDENT12
      !I_GESCH type AD_SEX
    exporting
      !ES_MSG type BAPIRET2 .
  class-methods CHECK_HRP9552
    importing
      !I_PERYR type PIQPERYR
      !I_PERID type PIQPERID
      !I_STNO type PIQSTUDENT12
      !I_SEID type PIQSEOBJID
      !I_KEYDT type DATUM
      !IS_MAJOR type ZCMSC
    exporting
      !ES_MSG type BAPIRET2 .
  class-methods CHECK_IS_BOOKABLE
    importing
      !I_MODE type ZCMK_AUTH
      !I_STID type PIQSTUDENT
      !I_STNO type PIQSTUDENT12
      !I_ST_GESCH type HRP1702-GESCH
      !I_ST_ORGID type ZCMCL000=>TY_ST_ORGCD-ORG_ID
      !I_ST_ORGCD type ZCMCL000=>TY_ST_ORGCD-ORG_COMM
      !I_ST_REGWINDOW type PIQREGWINDOW
      !IS_ST_MAJOR type ZCMSC
      !IT_BOOKED type ZCMSK_COURSE_T
      !IT_ACWORK type ZCMZ200_T
      !I_MAX_CREDIT type ZCMCLK100=>TY_CREDIT-MAX
      !I_BOOKED_CREDIT type ZCMCLK100=>TY_CREDIT-BOOKED
      !IS_BOOKING_INFO type ZCMSK_COURSE
      !I_PERYR type PIQPERYR
      !I_PERID type PIQPERID
      !I_KEYDT type DATUM
    exporting
      !ES_REBOOK_INFO type CI_PAD506
      !ET_MSG type BAPIRET2_T .
  class-methods CHECK_POSSB_ORG
    importing
      !I_ST_ORG type PIQOOBJID
      !I_SEID type PIQSEOBJID
      !I_SE_ORG type PIQOOBJID
      !I_KEYDT type DATUM
    exporting
      !ES_MSG type BAPIRET2 .
  class-methods CHECK_PRECEDENCE
    importing
      !I_TARGET_SM type PIQSMOBJID
      !I_KEYDT type DATUM
      !I_OID type PIQOOBJID
      !IT_ACWORK type ZCMZ200_T
    exporting
      !ES_MSG type BAPIRET2 .
  class-methods CHECK_REAL_TIME
    changing
      !CT_TAB type PIQTIMELIMITS_TAB .
  class-methods CHECK_SE_QUOTA_V2
    importing
      !I_STID type PIQST_OBJID
      !I_ST_REGWINDOW type PIQREGWINDOW
      !I_KEYDT type DATUM
      !I_PERYR type PIQPERYR
      !I_PERID type PIQPERID
      !I_SE type PIQSEOBJID
    exporting
      !ES_MSG type BAPIRET2 .
  class-methods CHECK_SE_QUOTA
    importing
      !I_ST_REGWINDOW type PIQREGWINDOW
      !I_KEYDT type DATUM
      !I_PERYR type PIQPERYR
      !I_PERID type PIQPERID
      !I_SE type PIQSEOBJID
    exporting
      !ES_MSG type BAPIRET2 .
  class-methods CHECK_SM_REBOOK_ADMIN
    importing
      !I_STID type PIQSTUDENT
      !I_SMID type PIQSMOBJID
      !I_BOOK_ID type HRPAD506-ID
      !I_KEYDT type DATUM
      !I_PERYR type PIQPERYR
      !I_PERID type PIQPERID
      !I_OID type PIQOOBJID
      !IT_ACWORK type ZCMZ200_T
      !I_BOOK_RE_ID type HRPAD506-REID optional
      !I_CHECK_ONLY type FLAG optional
    exporting
      !ES_MSG type BAPIRET2
      !ES_REBOOK_INFO type PAD506 .
  class-methods CHECK_SM_REBOOK
    importing
      !I_STID type PIQSTUDENT
      !I_TARGET_SM type PIQSMOBJID
      !I_KEYDT type DATUM
      !I_PERYR type PIQPERYR
      !I_PERID type PIQPERID
      !I_ORGCD type ZORGCD
      !I_OID type PIQOOBJID
      !IT_ACWORK type ZCMZ200_T
    exporting
      !ES_MSG type BAPIRET2
      !ES_REBOOK_INFO type CI_PAD506 .
  class-methods CHECK_SM_SHARE
    importing
      !I_TARGET_SM type PIQSMOBJID
      !I_KEYDT type DATUM
      value(IT_BOOKED_SM) type HROBJECT_T
    exporting
      !ES_MSG type BAPIRET2 .
  class-methods CHECK_TIMECONF_FOR_EVENT
    importing
      !I_TARGET_E type PIQEVE_OBJID
      !I_OID type PIQOOBJID
      !I_KEYDT type DATUM
      value(IT_BOOKED_E) type OBJEC_T
    exporting
      !ES_MSG type BAPIRET2 .
  class-methods GET_APPLICATION_URL
    importing
      value(IM_APPID) type C
      value(IM_TITLE) type C optional
      value(IM_SHOW) type FLAG optional
      value(IT_PARAM) type TIHTTPNVP optional
    returning
      value(RM_URL) type STRING .
  class-methods GET_SE_LIST
    importing
      !I_PERYR type PIQPERYR
      !I_PERID type PIQPERID
      !I_OID type PIQOOBJID optional
      !I_CGID type PIQCGOBJID optional
      !I_SMSHT type SHORT_D optional
      !I_SMTXT type STEXT optional
      !IT_SE type HROBJECT_T optional
      value(I_LANGU) type SY-LANGU default SY-LANGU
    exporting
      !ET_SELIST type HROBJECT_T
      !ET_DETAIL type ZCMSK_COURSE_T .
  class-methods GET_SE_QUOTA_COUNT
    importing
      !I_ST_REGWINDOW type PIQREGWINDOW
      !I_KEYDT type DATUM
      !I_PERYR type PIQPERYR
      !I_PERID type PIQPERID
      !IT_SELIST type HROBJECT_T
      !I_QUOTA_ONLY type FLAG optional
      !I_REAL_506 type FLAG default 'X'
    exporting
      !ET_CNT type TT_SE_CNT .
  class-methods GET_STGRP
    importing
      !I_STID type PIQSTUDENT
      !I_KEYDT type DATUM
      !I_NAMZU type NAMZU
    exporting
      value(EV_REGWINDOW) type PIQREGWINDOW .
  class-methods MSG
    importing
      value(ARBGB) type ARBGB default 'ZCM05'
      value(MSGNR) type MSGNR
    returning
      value(TEXT) type NATXT .
  class-methods OTR
    importing
      !ALIAS type ANY
      !V1 type ANY optional
      !V2 type ANY optional
      value(LANGU) type SY-LANGU default SY-LANGU
    returning
      value(ATEXT) type STRING .
  class-methods REBOOKED_LIST
    importing
      !IT_ST type HROBJECT_T
      value(I_PERYR) type PIQPERYR optional
      value(I_PERID) type PIQPERID optional
      value(I_ONLY_AD506) type FLAG optional
    exporting
      !ET_LIST type ZCMSK550_T
      !ET_CNT type ZCMSK551_T .
  class-methods SCHEDULE_TEXT
    importing
      !IS_T1716 type HRT1716
      !I_LANGU type SY-LANGU
    returning
      value(RV_TXT) type DDTEXT .
  class-methods SESSION_MANAGE
    importing
      !I_STNO type PIQSTUDENT12 .
  class-methods SET_DELAY_SE
    importing
      !I_PERYR type PIQPERYR
      !I_PERID type PIQPERID
      !I_SEID type PIQSEOBJID
      !I_SMID type PIQSMOBJID
      !I_STID type PIQSTUDENT
    returning
      value(R_NOW) type FLAG .
  class-methods SET_MACRO_BLOCK
    importing
      !I_STID type PIQSTUDENT .
  class-methods SM_STEXT
    importing
      !IT_SM type HROBJECT_T
      !I_LANGU type SY-LANGU default SY-LANGU
      !I_KEYDT type DATUM default SY-DATUM
    exporting
      !ET_SM_STEXT type TT_SM_T .
  class-methods TIMELIMIT_TO_TEXT
    importing
      !IV_TLT type ANY optional
      !IS_TIME type PIQTIMELIMITS
    returning
      value(RV_MSG) type STRING .
  class-methods GET_LOGIN_PERSON
    exporting
      !EV_TIMELIMIT_FG type ZTIMELIMIT_FG
      !ES_AUTH type ZCMTW1200
      value(ES_LOGIN) type ZCMCL000=>TY_PERSON .
  class-methods GET_LOGIN_ID
    exporting
      !EV_TIMELIMIT_FG type ZTIMELIMIT_FG
      !ES_AUTH type ZCMTW1200
      value(ES_LOGIN) type ZCMCL000=>TY_ST_CMACBPST .
  class-methods GET_DDLB_ORG1
    importing
      !I_ORGCD type ZCMT0101-ORG_CD
    returning
      value(RT_ORG) type TIHTTPNVP .
  class-methods GET_DDLB_ORG2
    importing
      !I_OID1 type PIQOOBJID
    returning
      value(RT_ORG) type TIHTTPNVP .
  class-methods GET_DDLB_ORG3
    importing
      !I_OID1 type PIQOOBJID
      !I_OID2 type PIQOOBJID
    returning
      value(RT_ORG) type TIHTTPNVP .
  class-methods BOOKED_CREDIT
    importing
      !I_ORGCD type HRP9500-ORG
      !I_KEYDT type DATUM
      !IT_BOOKED type ZCMSK_COURSE_T
    exporting
      !E_BOOKED type TY_CREDIT-BOOKED
      !E_CNT type TY_CREDIT-CNT
      !E_CNT_T type TY_CREDIT-CNT_T .
  class-methods SE_LOCK
    importing
      !I_STID type PIQST_OBJID
      !I_SEID type PIQSEOBJID
      !I_ST_REGWINDOW type PIQREGWINDOW
      !I_KEYDT type DATUM
      !I_PERYR type PIQPERYR
      !I_PERID type PIQPERID
    exporting
      !ES_MSG type BAPIRET2
    returning
      value(RV_ERR) type FLAG .
  class-methods SE_UNLOCK .
  class-methods GET_RANDOM_MACRO
    importing
      !MAX type INT4
      !MIN type INT4
    changing
      !CT_INT type INT4_TABLE .
  class-methods GET_SE_FROM_O_CG
    importing
      !I_PERYR type PIQPERYR
      !I_PERID type PIQPERID
      !I_OID type PIQOOBJID
    exporting
      value(ET_SELIST) type HROBJECT_T
      value(ET_SMSE) type TT_OBJ .
  class-methods READ_HRP9550_COUNT
    importing
      !I_SEID type PIQSEOBJID
      !I_KEYDT type DATUM
    returning
      value(R_CNT) type NUMC5 .
  class-methods DEQUEUE_COUNT_HRP9550
    importing
      !I_SEID type PIQSEOBJID
      !I_KEYDT type DATUM
    returning
      value(R_ERR) type FLAG .
  class-methods ENQUEUE_COUNT_HRP9550
    importing
      !I_SEID type PIQSEOBJID
      !I_KEYDT type DATUM
    returning
      value(R_ERR) type FLAG .
  class-methods DECREASE_BOOKING_COUNT
    importing
      !I_SEID type PIQSEOBJID
      !I_KEYDT type DATUM
    exporting
      !ES_MSG type BAPIRET2
    returning
      value(R_ERR) type FLAG .
protected section.
private section.

  class-data:
    BEGIN OF gs_period,
      peryr TYPE piqperyr,
      perid TYPE piqperid,
      begda TYPE begda,
      endda TYPE endda,
      keyda TYPE datum,
    END OF gs_period .

  class-methods SE_LOCK_LOG
    importing
      !I_STID type PIQSTUDENT
      !I_SMID type PIQSMOBJID
      !I_SEID type PIQSEOBJID
      !I_PERYR type PIQPERYR
      !I_PERID type PIQPERID .
  class-methods CHECK_CREDIT
    importing
      !I_ORGCD type ZCMCL000=>TY_ST_ORGCD-ORG_COMM
      !I_SEID type PIQSEOBJID
      !I_SMID type PIQSMOBJID
      !I_KEYDT type DATUM
      !I_MAX_CREDIT type ZCMCLK100=>TY_CREDIT-MAX
      !I_BOOKED_CREDIT type ZCMCLK100=>TY_CREDIT-BOOKED
      !I_CPOPT type ZCMSK_COURSE-CPOPT
    exporting
      !ES_MSG type BAPIRET2 .
  class-methods CHECK_SE_HRP1739
    importing
      !IT_SE type HROBJECT_T
    exporting
      value(ET_SESME) type TT_OBJ .
  class-methods GET_KEY_DATE
    importing
      !I_PERYR type PIQPERYR
      !I_PERID type PIQPERID .
  class-methods GET_SE_DELAY_COUNT
    importing
      !I_PERYR type PIQPERYR
      !I_PERID type PIQPERID
      !IT_SELIST type HROBJECT_T
    exporting
      !ET_DELAY_CNT type TT_SE_DELAY .
  class-methods GET_SE_FROM_CG
    importing
      !I_CGID type PIQCGOBJID
    exporting
      !ET_SELIST type HROBJECT_T .
  class-methods GET_SE_FROM_O
    importing
      !I_OID type PIQOOBJID
    exporting
      value(ET_SELIST) type HROBJECT_T
      value(ET_SMSE) type TT_OBJ .
  class-methods GET_SE_FROM_SM
    importing
      !I_SMSHT type SHORT_D optional
      !I_SMTXT type STEXT optional
    exporting
      value(ET_SMSE) type TT_OBJ
      value(ET_SELIST) type HROBJECT_T .
  class-methods RETURN_MSG
    importing
      !I_MODE type ZCMK_AUTH
      !I_SHORT type SHORT_D
      !I_STEXT type ANY
      value(IS_MSG) type BAPIRET2
    changing
      !CT_MSG type BAPIRET2_T
    returning
      value(RV_ERR) type FLAG .
  class-methods SE_DETAIL
    importing
      value(IT_SESME) type TT_OBJ
      !IT_SELIST type HROBJECT_T
      !I_LANGU type SY-LANGU
    exporting
      !ET_DETAIL type ZCMSK_COURSE_T .
ENDCLASS.



CLASS ZCMCLK100A IMPLEMENTATION.


  METHOD BOOKED_CREDIT.

    CLEAR: e_booked, e_cnt, e_cnt_t.

    e_cnt = lines( it_booked ).
    e_cnt_t = |{ zcmclk100a=>otr( 'ZDCM05/TX10000106' ) } : { e_cnt } |.

    IF it_booked IS NOT INITIAL.
      SELECT * FROM hrp9520
        INTO TABLE @DATA(lt_9520)
        FOR ALL ENTRIES IN @it_booked
        WHERE plvar = '01'
          AND otype = 'SM'
          AND istat = '1'
          AND objid = @it_booked-smobjid
          AND begda <= @i_keydt
          AND endda >= @i_keydt.
      SORT lt_9520 BY objid.

      SELECT * FROM hrp9550
        INTO TABLE @DATA(lt_9550)
        FOR ALL ENTRIES IN @it_booked
        WHERE plvar = '01'
          AND otype = 'SE'
          AND istat = '1'
          AND objid = @it_booked-seobjid
          AND begda <= @i_keydt
          AND endda >= @i_keydt.
      SORT lt_9550 BY objid.
    ENDIF.

    LOOP AT it_booked INTO DATA(ls_booked).
*SM, hrp9520, 학점초과 미적용 과목
      READ TABLE lt_9520 INTO DATA(ls_9520) WITH KEY objid = ls_booked-smobjid BINARY SEARCH.
      IF sy-subrc = 0.
        IF ls_9520-cexc_not = 'X'.
          CONTINUE.
        ENDIF.
      ENDIF.

*경영전문대학원 별도로직
      IF i_orgcd = '0002'.
        READ TABLE lt_9550 INTO DATA(ls_9550) WITH KEY objid = ls_booked-seobjid BINARY SEARCH.
        IF sy-subrc = 0.
          IF ls_9550-cyber_fg = 'X' AND ls_9550-cyber_class = '0515'.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDIF.

      e_booked = e_booked + ls_booked-cpopt.
    ENDLOOP.



  ENDMETHOD.


  METHOD BOOKED_LIST.

    DATA lr_peryr TYPE RANGE OF piqperyr.
    DATA lr_perid TYPE RANGE OF piqperid.
    DATA lt_seid TYPE hrobject_t.

    CLEAR: et_selist, et_detail, et_506, es_credit.

    IF i_peryr IS NOT INITIAL.
      lr_peryr = VALUE #( ( sign = 'I' option = 'EQ' low = i_peryr ) ).
    ENDIF.
    IF i_perid IS NOT INITIAL.
      lr_perid = VALUE #( ( sign = 'I' option = 'EQ' low = i_perid ) ).
    ENDIF.

    CHECK i_stid IS NOT INITIAL.

    SELECT  a~objid AS st_id, a~sobid AS sm_id, b~packnumber AS se_id,
            b~peryr, b~perid, b~id, b~smstatus, b~repeatfg, b~cpattemp, b~cpunit,
            b~reperyr, b~reperid, b~resmid
        FROM hrp1001 AS a
   INNER JOIN hrpad506 AS b
      ON  a~adatanr = b~adatanr
    WHERE a~plvar = '01'
      AND a~otype = 'ST'
      AND a~objid = @i_stid
      AND a~istat = '1'
      AND a~subty = 'A506'
      AND a~sclas = 'SM'
      AND b~peryr IN @lr_peryr
      AND b~perid IN @lr_perid
      AND b~smstatus IN ('1','2','3')
      INTO TABLE @DATA(lt_506).
    SORT lt_506 BY se_id.

    IF i_peryr IS INITIAL OR i_perid IS INITIAL.
      et_506 = CORRESPONDING #( lt_506 ).
      RETURN.
    ENDIF.

    lt_seid = VALUE #( FOR ls_506 IN lt_506 ( plvar = '01' otype = 'SE' objid = ls_506-se_id ) ).
    CHECK lt_seid IS NOT INITIAL.

*KEY DATE
    get_key_date( i_peryr = i_peryr i_perid = i_perid ).

*개설분반 필터
    check_se_hrp1739( EXPORTING it_se    = lt_seid
                      IMPORTING et_sesme = DATA(lt_sesme) ).

    et_selist = lt_seid.
    SORT et_selist.
    DELETE ADJACENT DUPLICATES FROM et_selist COMPARING ALL FIELDS.

*SE 세부정보
    CHECK et_selist[] IS NOT INITIAL.
    se_detail( EXPORTING it_sesme  = lt_sesme
                         it_selist = et_selist
                         i_langu   = i_langu
               IMPORTING et_detail = et_detail ).

    LOOP AT et_detail ASSIGNING FIELD-SYMBOL(<fs>).
      READ TABLE lt_506 INTO DATA(ls_ad506) WITH KEY se_id = <fs>-seobjid BINARY SEARCH.
      CHECK sy-subrc = 0.
      <fs>-id = ls_ad506-id.
      <fs>-smstatus = ls_ad506-smstatus.
      <fs>-cpattemp = ls_ad506-cpattemp.

*     재이수여부
      CHECK ls_ad506-reperyr IS NOT INITIAL.
      CHECK ls_ad506-reperid IS NOT INITIAL.
      CHECK ls_ad506-resmid IS NOT INITIAL.

      <fs>-retake_txt = zcmclk100a=>otr( 'ZDCM/REASSIGN_MODULE' ).

    ENDLOOP.



  ENDMETHOD.


  METHOD BOOKING.

    DATA lt_moduletab TYPE TABLE OF piq_get_sm_se_pad506.
    DATA lt_cptab TYPE TABLE OF piqstructimepoint.
    DATA lt_return TYPE TABLE OF bapiret2.
    DATA ls_mrcontext TYPE piqmrcontext.
    DATA ls_module LIKE LINE OF lt_moduletab.
    DATA lv_return_code TYPE i.
    DATA lt_guidlist TYPE TABLE OF piqguidpublish.
    DATA lv_booktype TYPE hrpad506-booktype.

    CLEAR: lt_moduletab, lt_cptab, lt_return, ev_id, es_msg.

*Data Transfer for ST Booking in SM, SE
    ls_module-plvar = '01'.
    ls_module-begda = is_book_data-begda.
    ls_module-endda = is_book_data-endda.
    ls_module-sm_objid = is_book_data-smobjid.
    ls_module-priox = is_book_data-priox.
    ls_module-smstatus = '01'.
    ls_module-cpattemp = is_book_data-cpopt.
    ls_module-cpunit = is_book_data-cpunit.
    ls_module-norm_val = is_book_data-norm_val.
    ls_module-bookdate = sy-datum.
    ls_module-booktime = sy-uzeit.
    ls_module-packnumber = is_book_data-seobjid.
    ls_module-peryr = is_book_data-peryr.
    ls_module-perid = is_book_data-perid.
    ls_module-alt_scaleid = is_book_data-scaleid.
    IF is_rebook_info-rescale IS NOT INITIAL. "재이수 성적 스케일
      ls_module-alt_scaleid = is_rebook_info-rescale.
    ENDIF.
    APPEND ls_module TO lt_moduletab.

*Module Booking Context
    SELECT SINGLE progcvar FROM hrp1730
      INTO @DATA(lv_progc)
      WHERE plvar = '01'
        AND otype = 'SC'
        AND istat = '1'
        AND objid = @i_st_major
        AND begda <= @sy-datum
        AND endda >= @sy-datum.
    ls_mrcontext-cont_program = i_st_major.
    ls_mrcontext-cont_programtype = lv_progc.
    ls_mrcontext-cont_peryr = is_book_data-peryr.
    ls_mrcontext-cont_perid = is_book_data-perid.

*Callup Point
    CASE is_book_data-perid.
      WHEN '010' OR '020'.
        lt_cptab = VALUE #( ( timepoint = '0000' ) ).
      WHEN '011' OR '021'.
        lt_cptab = VALUE #( ( timepoint = '0001' ) ).
      WHEN OTHERS.
    ENDCASE.

    CALL FUNCTION 'HRIQ_STUDENT_BOOKING'
      EXPORTING
        iv_vtask                = 'B'
        iv_plvar                = '01'
        iv_otype                = 'ST'
        iv_objid                = i_stid
        is_mrcontext            = ls_mrcontext
        iv_mode                 = i_mode
        iv_dialog               = 'B'
      IMPORTING
        return_code             = lv_return_code
      TABLES
        it_moduletab            = lt_moduletab
        it_cptab                = lt_cptab
        et_return               = lt_return
        et_guidlist             = lt_guidlist
      EXCEPTIONS
        wrong_input_data        = 1
        plvar_not_found         = 2
        otype_not_supported     = 3
        no_program_registration = 4
        student_not_found       = 5
        program_not_found       = 6
        modules_missing         = 7
        negative_check_result   = 8
        study_not_found         = 9
        student_lock_failed     = 10
        database_update_failed  = 11
        mode_not_supported      = 12
        OTHERS                  = 13.

    DATA(lv_subrc) = sy-subrc.

*표준함수 로그
    DATA ls_retmsg TYPE zcmt2024_return.

    LOOP AT lt_return INTO DATA(ls_return).
      ls_retmsg-type = |{ ls_retmsg-type } / { ls_return-type }|.
      ls_retmsg-message = |{ ls_retmsg-message } / { ls_return-message }|.
    ENDLOOP.
    ls_retmsg-stobj = i_stid.
    ls_retmsg-sdate = sy-datum.
    ls_retmsg-uname = sy-uname.
    ls_retmsg-uzeit = sy-uzeit.
    GET TIME STAMP FIELD ls_retmsg-stime.

    ls_retmsg-subrc = lv_subrc.
    ls_retmsg-return_code = lv_return_code.
    ls_retmsg-se_id = is_book_data-seobjid.
    ls_retmsg-se_short = is_book_data-seshort.

    MODIFY zcmt2024_return FROM ls_retmsg.

    IF lv_subrc IS NOT INITIAL.
      lt_return = VALUE #( ( id = 'HRPIQ000' number = '814' type = 'E' ) ).
    ENDIF.
    LOOP AT lt_return INTO es_msg WHERE type = 'E' OR type = 'A'.
      EXIT.
    ENDLOOP.

    IF lv_subrc <> 0 OR es_msg IS NOT INITIAL.
    ELSE.

      READ TABLE lt_guidlist INTO DATA(ls_guid) INDEX 1.

      IF sy-tcode IS NOT INITIAL.
        lv_booktype = 'SAPGUI'.
      ELSE.
        lv_booktype = 'SAINT'.
      ENDIF.

      UPDATE hrpad506 SET reid = is_rebook_info-reid
                          resmid = is_rebook_info-resmid
                          reperyr = is_rebook_info-reperyr
                          reperid = is_rebook_info-reperid
                          rescale = is_rebook_info-rescale
                          repeatfg = is_rebook_info-repeatfg
                          regwindow = i_st_regwindow
                          hostname = sy-host
                          booktype = lv_booktype
                          smobjid = is_book_data-smobjid
                          stobjid = i_stid
                          ernam = sy-uname
                          erdat = sy-datum
                          ertim = sy-uzeit
                    WHERE id = ls_guid-guid.
      IF sy-subrc = 0.
        UPDATE zcmtk310 SET comp = 'X'
                            aenam = sy-uname
                            aedat = sy-datum
                            aetim = sy-uzeit
        WHERE peryr = is_book_data-peryr
          AND perid = is_book_data-perid
          AND st_id = i_stid
          AND se_id = is_book_data-seobjid.
        COMMIT WORK.
      ENDIF.
      ev_id = ls_guid-guid.
    ENDIF.

    "수강신청 변경자 Update.
    DATA: ls_trans TYPE zcmt2018_trans.
    ls_trans-objid = i_stid.
    MODIFY zcmt2018_trans FROM ls_trans.
    COMMIT WORK.

    zcmclk100a=>se_unlock( ).

  ENDMETHOD.


  METHOD BOOKING_CANC.

    DATA lt_moduletab TYPE TABLE OF piq_get_sm_se_pad506.
    DATA lt_cptab TYPE TABLE OF piqstructimepoint.
    DATA lt_return TYPE TABLE OF bapiret2.
    DATA ls_mrcontext TYPE piqmrcontext.
    DATA ls_module LIKE LINE OF lt_moduletab.
    DATA lv_return_code TYPE i.

    CLEAR: lt_moduletab, lt_cptab, lt_return, es_msg.

    ls_module-plvar = '01'.
    ls_module-smstatus = '04'.
    ls_module-storreason = 'CALC'.
    ls_module-stordate = sy-datum.
    ls_module-id = is_booked-id.
    ls_module-sm_objid = is_booked-smobjid.
    ls_module-packnumber = is_booked-seobjid.
    ls_module-peryr = is_booked-peryr.
    ls_module-perid = is_booked-perid.
    APPEND ls_module TO lt_moduletab.

*Callup Point
    lt_cptab = VALUE #( ( timepoint = '000' ) ).


    CALL FUNCTION 'HRIQ_STUDENT_BOOKING'
      EXPORTING
        iv_vtask                = 'B'
        iv_plvar                = '01'
        iv_otype                = 'ST'
        iv_objid                = i_stid
        iv_mode                 = 'V'
        iv_dialog               = 'B'
      IMPORTING
        return_code             = lv_return_code
      TABLES
        it_moduletab            = lt_moduletab
        it_cptab                = lt_cptab
        et_return               = lt_return
      EXCEPTIONS
        wrong_input_data        = 1
        plvar_not_found         = 2
        otype_not_supported     = 3
        no_program_registration = 4
        student_not_found       = 5
        program_not_found       = 6
        modules_missing         = 7
        negative_check_result   = 8
        study_not_found         = 9
        student_lock_failed     = 10
        database_update_failed  = 11
        mode_not_supported      = 12
        OTHERS                  = 13.
    IF sy-subrc <> 0 OR lv_return_code = '4'.
      READ TABLE lt_return INTO es_msg WITH KEY type = 'E'.
    ELSE.
      UPDATE hrpad506 SET stortime = sy-uzeit
                             aenam = sy-uname
                             aedat = sy-datum
                             aetim = sy-uzeit
                    WHERE id = is_booked-id.
      IF sy-subrc = 0.
        COMMIT WORK.
      ENDIF.

    ENDIF.



  ENDMETHOD.


  METHOD BOOKING_PERIOD.

    DATA lr_time TYPE RANGE OF piqtimelimit.
    DATA lt_time_tab TYPE piqtimelimits_tab.
    DATA lt_result_tab TYPE TABLE OF swhactor.

    CLEAR: et_timelimits, es_timelimit_100.

    SELECT SINGLE sobid FROM hrp1001
      INTO @DATA(lv_caid)
     WHERE plvar = '01'
       AND otype = 'O'
       AND objid = @i_oid
       AND rsign = 'A'
       AND relat = '510'
       AND begda <= @i_keydt
       AND endda >= @i_keydt.
    CHECK sy-subrc = 0.

    IF i_timelimit IS INITIAL.
      lr_time = VALUE #( sign = 'I' option = 'EQ' ( low = '0300' ) ( low = '0310' ) ( low = '0320' ) ( low = '0330' ) ).
    ELSE.
      lr_time = VALUE #( sign = 'I' option = 'EQ' ( low = i_timelimit ) ).
    ENDIF.

    SELECT a~otype       AS ca_otype
           a~objid       AS ca_objid
           b~timelimit   AS ca_timelimit
           b~peryr       AS ca_peryr
           b~perid       AS ca_perid
           b~window      AS ca_window
           b~begda       AS ca_lbegda
           b~begtime     AS ca_lbegtime
           b~endda       AS ca_lendda
           b~endtime     AS ca_lendtime
           b~number_from AS ca_number_from
           b~unit_from   AS ca_unit_from
           b~point_from  AS ca_point_from
           b~number_to   AS ca_number_to
           b~unit_to     AS ca_unit_to
           b~point_to    AS ca_point_to
           b~reference   AS ca_reference
           b~timelimit_r AS ca_timelimit_r
      FROM hrp1750 AS a
     INNER JOIN hrt1750 AS b
        ON b~tabnr      = a~tabnr
      INTO CORRESPONDING FIELDS OF TABLE et_timelimits
     WHERE a~plvar      = '01'
       AND a~otype      = 'CA'
       AND a~objid      = lv_caid
       AND b~begda     <= i_keydt
       AND b~endda     >= i_keydt
       AND b~timelimit IN lr_time.

    DELETE et_timelimits WHERE ca_lendda = sy-datum AND ca_lendtime < sy-uzeit.

    IF i_flt_t IS NOT INITIAL.
      check_real_time( CHANGING ct_tab = et_timelimits ).
    ENDIF.

    READ TABLE et_timelimits INTO DATA(ls_time) INDEX 1.
    CHECK sy-subrc = 0.

*표준학기 시작일 종료일
    CLEAR lt_time_tab.
    zcmcl000=>get_timelimits(
      EXPORTING
        iv_o          = '30000002'
        iv_peryr      = ls_time-ca_peryr
        iv_perid      = ls_time-ca_perid
      IMPORTING
        et_timelimits = lt_time_tab
    ).

    READ TABLE lt_time_tab INTO es_timelimit_100 INDEX 1.

  ENDMETHOD.


  METHOD CHECK_CREDIT.

    DATA lv_total TYPE zcmsk_course-cpopt.


    SELECT * FROM hrp9520
      INTO TABLE @DATA(lt_9520)
      WHERE plvar = '01'
        AND otype = 'SM'
        AND istat = '1'
        AND objid = @i_smid
        AND begda <= @i_keydt
        AND endda >= @i_keydt.
    SORT lt_9520 BY objid.

    SELECT * FROM hrp9550
      INTO TABLE @DATA(lt_9550)
      WHERE plvar = '01'
        AND otype = 'SE'
        AND istat = '1'
        AND objid = @i_seid
        AND begda <= @i_keydt
        AND endda >= @i_keydt.
    SORT lt_9550 BY objid.


*SM, hrp9520, 학점초과 미적용 과목
    READ TABLE lt_9520 INTO DATA(ls_9520) WITH KEY objid = i_smid BINARY SEARCH.
    IF sy-subrc = 0.
      IF ls_9520-cexc_not = 'X'.
        RETURN.
      ENDIF.
    ENDIF.

*경영전문대학원 별도로직
    IF i_orgcd = '0002'.
      READ TABLE lt_9550 INTO DATA(ls_9550) WITH KEY objid = i_seid BINARY SEARCH.
      IF sy-subrc = 0.
        IF ls_9550-cyber_fg = 'X' AND ls_9550-cyber_class = '0515'.
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.

    lv_total = i_booked_credit + i_cpopt.

    IF lv_total > i_max_credit.
      es_msg-type = 'E'.
      es_msg-message = zcmclk100a=>otr( EXPORTING alias = 'ZDCM05/TX10000059' ).
    ENDIF.


  ENDMETHOD.


  METHOD CHECK_DUPLICATED_SM.

    SORT it_booked BY smobjid.

    CLEAR es_msg.
    READ TABLE it_booked INTO DATA(ls_sm) WITH KEY smobjid = i_target_sm BINARY SEARCH.
    IF sy-subrc = 0.
      es_msg-type = 'E'.
      DATA(lv_otr) = otr( EXPORTING alias = 'ZDCM05/TX10000049' ).
      es_msg-message = lv_otr.
      RETURN.
    ENDIF.



  ENDMETHOD.


  METHOD CHECK_HRP9550.

    DATA: lv_expcd TYPE c. "예외자구분

    SELECT SINGLE * FROM hrp9550
      INTO @DATA(ls_9550)
      WHERE plvar = '01'
        AND otype = 'SE'
        AND objid = @i_seid
        AND istat = '1'
        AND begda <= @i_keydt
        AND endda >= @i_keydt.
    CHECK sy-subrc = 0.

*남녀
    IF ls_9550-gen_cd <> i_gesch AND ls_9550-gen_cd IS NOT INITIAL.
      SELECT SINGLE ddtext FROM dd07t
        INTO @DATA(lv_txt)
        WHERE domname = 'ZZGEN_CD'
          AND ddlanguage = @sy-langu
          AND domvalue_l = @ls_9550-gen_cd.
      es_msg-message = otr( EXPORTING alias = 'ZDCM05/TX10000060'
                                      v1    = lv_txt ).
      es_msg-type = 'E'.
      RETURN.
    ENDIF.

*홀짝
    IF ls_9550-oddeven_cd IS NOT INITIAL.
      DATA(lv_len) = strlen( i_stno ) - 1.
      DATA(lv_last) = i_stno+lv_len(1).
      IF ls_9550-oddeven_cd NA lv_last.
        es_msg-message = otr( EXPORTING alias = 'ZDCM05/TX10000061'
                                        v1    = ls_9550-oddeven_cd ).
        es_msg-type = 'E'.
        RETURN.
      ENDIF.
    ENDIF.

*우열
    IF ls_9550-inferi_fg = 'X'.
      SELECT SINGLE se_id FROM  zcmt0122
                          INTO  @DATA(lv_possible_se)
                          WHERE piqpeyr = @i_peryr
                          AND   piqperid = @i_perid
                          AND   st_id = @i_stid
                          AND   sm_id = @i_smid.
      IF sy-subrc = 0 AND lv_possible_se <> i_seid.
        es_msg-message = otr( EXPORTING alias = 'ZDCM05/TX10000062' ).
        es_msg-type = 'E'.
        RETURN.
      ENDIF.
    ENDIF.

*승인과목
    IF ls_9550-recog_fg = 'X'.
      es_msg-message = otr( EXPORTING alias = 'ZDCM05/TX10000063' ).
      es_msg-type = 'E'.
      RETURN.
    ENDIF.

*CU
    IF ls_9550-cu_fg = 'X'.
      es_msg-message = otr( EXPORTING alias = 'ZDCM05/TX10000150' ).
      es_msg-type = 'E'.
      RETURN.
    ENDIF.

*국제학생 전용분반
    IF ls_9550-intlst_fg = 'X'.
      CLEAR: lv_expcd.
      CALL FUNCTION 'ZCM_GET_RELEVAL_EXCEPT'
        EXPORTING
          i_stobj = i_stid
        IMPORTING
          e_expcd = lv_expcd.
      IF lv_expcd <> 'X'.
        es_msg-message = otr( EXPORTING alias = 'ZDCM05/TX10000064' ).
        es_msg-type = 'E'.
        RETURN.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD CHECK_HRP9552.

    DATA lt_scid TYPE RANGE OF hrobjid.
    DATA lt_scid_mj TYPE RANGE OF hrobjid.
    DATA lv_possb TYPE flag.
    DATA lt_osc TYPE TABLE OF swhactor.
    DATA lt_txt TYPE TABLE OF stext.

*설계전공학생 허용
    SELECT SINGLE stno
      FROM zcmt2024_grant
     WHERE peryr = @i_peryr
       AND perid = @i_perid
       AND stno = @i_stno
       AND se_id = @i_seid
      INTO @DATA(lv_stno).
    IF sy-subrc = 0.
      RETURN.
    ENDIF.


    SELECT a~objid AS se_id, a~begda, a~endda, a~apply_fg,
           b~book_fg, b~otype, b~objid AS limit_id FROM hrp9552 AS a
      INNER JOIN hrt9552 AS b
      ON a~tabnr = b~tabnr
      WHERE a~plvar = '01'
        AND a~otype = 'SE'
        AND a~objid = @i_seid
        AND a~begda <= @i_keydt
        AND a~endda >= @i_keydt
        AND a~apply_fg = 'X'
      INTO TABLE @DATA(lt_9552).
    DELETE lt_9552 WHERE limit_id IS INITIAL.
    DELETE lt_9552 WHERE limit_id = '00000000'.
    CHECK lt_9552 IS NOT INITIAL.

    SELECT otype, objid, short, stext FROM hrp1000
      INTO TABLE @DATA(lt_1000)
      FOR ALL ENTRIES IN @lt_9552
      WHERE plvar = '01'
        AND otype = @lt_9552-otype
        AND objid = @lt_9552-limit_id
        AND istat = '1'
        AND langu = @sy-langu
        AND begda <= @i_keydt
        AND endda >= @i_keydt.
    SORT lt_1000 BY otype objid.

*1전공 소속
    lt_scid_mj = VALUE #( ( sign = 'I' option = 'EQ' low = is_major-sc_objid1 ) ).

*학생 전체전공
    lt_scid = VALUE #( BASE lt_scid ( sign = 'I' option = 'EQ' low = is_major-sc_objid1 ) ).
    lt_scid = VALUE #( BASE lt_scid ( sign = 'I' option = 'EQ' low = is_major-sc_objid2 ) ).
    lt_scid = VALUE #( BASE lt_scid ( sign = 'I' option = 'EQ' low = is_major-sc_objid3 ) ).
    lt_scid = VALUE #( BASE lt_scid ( sign = 'I' option = 'EQ' low = is_major-sc_objid4 ) ).
    DELETE lt_scid WHERE low = '00000000'.

    LOOP AT lt_9552 INTO DATA(ls_9552).


      READ TABLE lt_1000 INTO DATA(ls_1000) WITH KEY otype = ls_9552-otype objid = ls_9552-limit_id BINARY SEARCH.
      IF sy-subrc = 0.
        APPEND ls_1000-stext TO lt_txt.
      ENDIF.

      IF ls_9552-otype = 'O'.
        CLEAR lt_osc.
        zcmcl000=>get_struc_get(
          EXPORTING
            iv_act_otype  = 'O'
            iv_act_objid  = ls_9552-limit_id
            iv_act_wegid  = 'O-SC'
          IMPORTING
            et_result_tab = lt_osc
        ).
        DELETE lt_osc WHERE otype NE 'SC'.
        SORT lt_osc BY objid.
      ENDIF.

      CASE ls_9552-book_fg.
        WHEN '1'. "가능(전체전공)
          CASE ls_9552-otype.
            WHEN 'O'.
              DELETE lt_osc WHERE objid IN lt_scid.
              IF sy-subrc = 0.
                lv_possb = 'X'.
                EXIT.
              ENDIF.
            WHEN 'SC'.
              IF ls_9552-limit_id IN lt_scid.
                lv_possb = 'X'.
                EXIT.
              ENDIF.
          ENDCASE.

        WHEN '2'. "불가(전체전공)
          CASE ls_9552-otype.
            WHEN 'O'.
              DELETE lt_osc WHERE objid IN lt_scid.
              IF sy-subrc = 0.
                lv_possb = ''.
                EXIT.
              ELSE.
                lv_possb = 'X'.
              ENDIF.
            WHEN 'SC'.
              IF ls_9552-limit_id IN lt_scid.
                IF sy-subrc = 0.
                  lv_possb = ''.
                  EXIT.
                ELSE.
                  lv_possb = 'X'.
                ENDIF.
              ENDIF.
          ENDCASE.

        WHEN '3'. "가능(1전공)
          CASE ls_9552-otype.
            WHEN 'O'.
              DELETE lt_osc WHERE objid IN lt_scid_mj.
              IF sy-subrc = 0.
                lv_possb = 'X'.
                EXIT.
              ENDIF.
            WHEN 'SC'.
              IF ls_9552-limit_id IN lt_scid_mj.
                lv_possb = 'X'.
                EXIT.
              ENDIF.
          ENDCASE.

        WHEN '4'. "불가(1전공)
          CASE ls_9552-otype.
            WHEN 'O'.
              DELETE lt_osc WHERE objid IN lt_scid_mj.
              IF sy-subrc = 0.
                lv_possb = ''.
                EXIT.
              ELSE.
                lv_possb = 'X'.
              ENDIF.
            WHEN 'SC'.
              IF ls_9552-limit_id IN lt_scid_mj.
                IF sy-subrc = 0.
                  lv_possb = ''.
                  EXIT.
                ELSE.
                  lv_possb = 'X'.
                ENDIF.
              ENDIF.
          ENDCASE.
      ENDCASE.
    ENDLOOP.

*신청 불가능
    IF lv_possb IS INITIAL.
      CONCATENATE LINES OF lt_txt INTO DATA(lv_txt) SEPARATED BY ','.
      CASE ls_9552-book_fg.
        WHEN '1' OR '3'.  "가능
          DATA(lv_otr) = otr( EXPORTING alias = 'ZDCM05/TX10000056'
                                        v1    = lv_txt ).

        WHEN '2' OR '4'.  "불가
          lv_otr = otr( EXPORTING alias = 'ZDCM05/TX10000057'
                                  v1    = lv_txt ).
      ENDCASE.
      es_msg-type = 'E'.
      es_msg-message = lv_otr.
    ENDIF.


  ENDMETHOD.


  METHOD CHECK_IS_BOOKABLE.

    CLEAR:es_rebook_info, et_msg.

    SELECT SINGLE * FROM zcmt2024_auth
      INTO @DATA(ls_auth)
      WHERE auth = @i_mode.

    "과목 중복
    IF ls_auth-sm_dup IS NOT INITIAL.
      zcmclk100a=>check_duplicated_sm(
        EXPORTING
          i_target_sm = is_booking_info-smobjid
          it_booked   = it_booked
        IMPORTING
          es_msg      = DATA(ls_msg) ).
      CHECK return_msg( EXPORTING is_msg = ls_msg
                                  i_mode = i_mode
                                  i_short = is_booking_info-seshort
                                  i_stext = is_booking_info-smstext
                        CHANGING ct_msg = et_msg ) IS INITIAL.
    ENDIF.

    "수강학점
    IF ls_auth-credit_fg IS NOT INITIAL.
      zcmclk100a=>check_credit(
        EXPORTING
          i_orgcd         = i_st_orgcd
          i_smid          = is_booking_info-smobjid
          i_seid          = is_booking_info-seobjid
          i_keydt         = i_keydt
          i_max_credit    = i_max_credit
          i_booked_credit = i_booked_credit
          i_cpopt         = is_booking_info-cpopt
        IMPORTING
          es_msg          = ls_msg
      ).
      CHECK return_msg( EXPORTING is_msg = ls_msg
                                  i_mode = i_mode
                                  i_short = is_booking_info-seshort
                                  i_stext = is_booking_info-smstext
                        CHANGING ct_msg = et_msg ) IS INITIAL.
    ENDIF.

    "코드 쉐어링 과목
    IF ls_auth-codeshare_fg IS NOT INITIAL.
      DATA lt_sm TYPE TABLE OF hrobject.
      lt_sm = CORRESPONDING #( it_booked MAPPING objid = smobjid  ).

      zcmclk100a=>check_sm_share(
        EXPORTING
          i_target_sm  = is_booking_info-smobjid
          i_keydt      = i_keydt
          it_booked_sm = lt_sm
        IMPORTING
          es_msg       = ls_msg ).
      CHECK return_msg( EXPORTING is_msg = ls_msg
                                  i_mode = i_mode
                                  i_short = is_booking_info-seshort
                                  i_stext = is_booking_info-smstext
                        CHANGING ct_msg = et_msg ) IS INITIAL.
    ENDIF.

    "수강가능소속
    IF ls_auth-possibleorg_fg IS NOT INITIAL.
      zcmclk100a=>check_possb_org(
        EXPORTING
          i_st_org = i_st_orgid
          i_seid   = is_booking_info-seobjid
          i_se_org = is_booking_info-orgid
          i_keydt  = i_keydt
        IMPORTING
          es_msg   = ls_msg
      ).
      CHECK return_msg( EXPORTING is_msg = ls_msg
                                  i_mode = i_mode
                                  i_short = is_booking_info-seshort
                                  i_stext = is_booking_info-smstext
                        CHANGING ct_msg = et_msg ) IS INITIAL.
    ENDIF.


    "남녀, 홀짝, 우열, 승인과목
    IF ls_auth-hrp9550_fg IS NOT INITIAL.
      zcmclk100a=>check_hrp9550(
        EXPORTING
          i_keydt = i_keydt
          i_peryr = i_peryr
          i_perid = i_perid
          i_smid  = is_booking_info-smobjid
          i_seid  = is_booking_info-seobjid
          i_stid  = i_stid
          i_stno  = i_stno
          i_gesch = i_st_gesch
        IMPORTING
          es_msg  = ls_msg
      ).
      CHECK return_msg( EXPORTING is_msg = ls_msg
                                  i_mode = i_mode
                                  i_short = is_booking_info-seshort
                                  i_stext = is_booking_info-smstext
                        CHANGING ct_msg = et_msg ) IS INITIAL.
    ENDIF.

    "선수과목
    IF ls_auth-prerequisite_fg IS NOT INITIAL.
      zcmclk100a=>check_precedence(
        EXPORTING
          i_target_sm = is_booking_info-smobjid
          i_keydt     = i_keydt
          i_oid       = i_st_orgid
          it_acwork   = it_acwork
        IMPORTING
          es_msg      = ls_msg ).
      CHECK return_msg( EXPORTING is_msg = ls_msg
                                  i_mode = i_mode
                                  i_short = is_booking_info-seshort
                                  i_stext = is_booking_info-smstext
                        CHANGING ct_msg = et_msg ) IS INITIAL.
    ENDIF.


    "소속제한
    IF ls_auth-hrp9552_fg IS NOT INITIAL.
      zcmclk100a=>check_hrp9552(
        EXPORTING
          i_peryr  = i_peryr
          i_perid  = i_perid
          i_stno   = i_stno
          i_seid   = is_booking_info-seobjid
          i_keydt  = i_keydt
          is_major = is_st_major
        IMPORTING
          es_msg   = ls_msg ).
      CHECK return_msg( EXPORTING is_msg = ls_msg
                                  i_mode = i_mode
                                  i_short = is_booking_info-seshort
                                  i_stext = is_booking_info-smstext
                        CHANGING ct_msg = et_msg ) IS INITIAL.
    ENDIF.

    "이벤트 중복
    IF ls_auth-e_dup IS NOT INITIAL.
      DATA lt_booked_e TYPE objec_t.
      lt_booked_e = CORRESPONDING #( it_booked MAPPING  objid = eobjid short = seshort stext = smstext ).

      zcmclk100a=>check_timeconf_for_event(
        EXPORTING
          i_target_e  = is_booking_info-eobjid
          i_oid       = i_st_orgid
          i_keydt     = i_keydt
          it_booked_e = lt_booked_e
        IMPORTING
          es_msg      = ls_msg
      ).
      CHECK return_msg( EXPORTING is_msg = ls_msg
                                  i_mode = i_mode
                                  i_short = is_booking_info-seshort
                                  i_stext = is_booking_info-smstext
                        CHANGING ct_msg = et_msg ) IS INITIAL.
    ENDIF.

    "재이수
    zcmclk100a=>check_sm_rebook(
      EXPORTING
        i_stid         = i_stid
        i_target_sm    = is_booking_info-smobjid
        i_keydt        = i_keydt
        i_peryr        = i_peryr
        i_perid        = i_perid
        i_orgcd        = i_st_orgcd
        i_oid          = i_st_orgid
        it_acwork      = it_acwork
      IMPORTING
        es_msg         = ls_msg
        es_rebook_info = es_rebook_info
    ).
    IF ls_auth-retake_fg IS NOT INITIAL.
      CHECK return_msg( EXPORTING is_msg = ls_msg
                                  i_mode = i_mode
                                  i_short = is_booking_info-seshort
                                  i_stext = is_booking_info-smstext
                        CHANGING ct_msg = et_msg ) IS INITIAL.
    ENDIF.


    "정원
    IF ls_auth-quota_fg IS NOT INITIAL.

      zcmclk100a=>check_se_quota_v2(
        EXPORTING
          i_stid         = i_stid
          i_st_regwindow = i_st_regwindow
          i_keydt        = i_keydt
          i_peryr        = i_peryr
          i_perid        = i_perid
          i_se           = is_booking_info-seobjid
        IMPORTING
          es_msg         = ls_msg
      ).
      CHECK return_msg( EXPORTING is_msg = ls_msg
                                  i_mode = i_mode
                                  i_short = is_booking_info-seshort
                                  i_stext = is_booking_info-smstext
                        CHANGING ct_msg = et_msg ) IS INITIAL.


**      zcmclk100a=>check_se_quota(
**        EXPORTING
**          i_st_regwindow = i_st_regwindow
**          i_keydt        = i_keydt
**          i_peryr        = i_peryr
**          i_perid        = i_perid
**          i_se           = is_booking_info-seobjid
**        IMPORTING
**          es_msg         = ls_msg
**      ).
**      CHECK return_msg( EXPORTING is_msg = ls_msg
**                                  i_mode = i_mode
**                                  i_short = is_booking_info-seshort
**                                  i_stext = is_booking_info-smstext
**                        CHANGING ct_msg = et_msg ) IS INITIAL.
**
***분반 LOCK
**      CHECK zcmclk100a=>se_lock( EXPORTING i_stid = i_stid
**                                          i_seid         = is_booking_info-seobjid
**                                          i_st_regwindow = i_st_regwindow
**                                          i_keydt        = i_keydt
**                                          i_peryr        = i_peryr
**                                          i_perid        = i_perid
**                                IMPORTING es_msg         = ls_msg ) IS INITIAL.
**      IF ls_msg IS NOT INITIAL.
**        zcmclk100a=>se_lock_log( i_stid  = i_stid
**                                i_smid  = is_booking_info-smobjid
**                                i_seid  = is_booking_info-seobjid
**                                i_peryr = i_peryr
**                                i_perid = i_perid ).
**        zcmclk100a=>se_unlock( ).
**      ENDIF.
**      CHECK return_msg( EXPORTING is_msg = ls_msg
**                                  i_mode = i_mode
**                                  i_short = is_booking_info-seshort
**                                  i_stext = is_booking_info-smstext
**                        CHANGING ct_msg = et_msg ) IS INITIAL.
**
**      zcmclk100a=>check_se_quota(
**        EXPORTING
**          i_st_regwindow = i_st_regwindow
**          i_keydt        = i_keydt
**          i_peryr        = i_peryr
**          i_perid        = i_perid
**          i_se           = is_booking_info-seobjid
**        IMPORTING
**          es_msg         = ls_msg
**      ).
**      IF ls_msg IS NOT INITIAL.
**        zcmclk100a=>se_unlock( ).
**      ENDIF.
**      CHECK return_msg( EXPORTING is_msg = ls_msg
**                                  i_mode = i_mode
**                                  i_short = is_booking_info-seshort
**                                  i_stext = is_booking_info-smstext
**                        CHANGING ct_msg = et_msg ) IS INITIAL.
    ENDIF.

  ENDMETHOD.


  METHOD CHECK_POSSB_ORG.

    SELECT a~objid, b~possb_oid FROM hrp9566 AS a
      INNER JOIN hrt9566 AS b
      ON a~tabnr = b~tabnr
      INTO TABLE @DATA(lt_9566)
      WHERE a~plvar = '01'
        AND a~otype = 'O'
        AND a~istat = '1'
        AND a~objid = @i_st_org
        AND a~begda <= @i_keydt
        AND a~endda >= @i_keydt.
    CHECK lt_9566 IS NOT INITIAL.
    SORT lt_9566 BY possb_oid.

    READ TABLE lt_9566 WITH KEY possb_oid = i_se_org BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      es_msg-type = 'E'.
      es_msg-message = zcmclk100a=>otr( 'ZDCM05/TX10000067' ).
    ENDIF.

  ENDMETHOD.


  METHOD CHECK_PRECEDENCE.

    DATA lt_acwork TYPE zcmz200_t.
    DATA lv_smobjid  TYPE hrobjid.
    DATA lv_smobjid2 TYPE hrobjid.

    CLEAR es_msg.

    SELECT SINGLE precd FROM hrp9566
      INTO @DATA(lv_precd)
      WHERE plvar = '01'
        AND otype = 'O'
        AND istat = '1'
        AND objid = @i_oid
        AND begda <= @i_keydt
        AND endda >= @i_keydt.
    IF lv_precd IS INITIAL.
      RETURN.
    ENDIF.

*선수과목
    SELECT otype, objid, sclas, sobid FROM hrp1001
      INTO TABLE @DATA(lt_pre)
      WHERE plvar = '01'
      AND   otype = 'SM'
      AND   objid = @i_target_sm
      AND   rsign = 'A'
      AND   relat = '529'
      AND   subty = 'A529'
      AND   sclas = 'SM'
      AND   begda <= @i_keydt
      AND   endda >= @i_keydt.
    CHECK lt_pre[] IS NOT INITIAL.

*선수과목의 대체과목
    SELECT a~otype, a~objid, a~sclas, a~sobid FROM hrp1001 AS a
      INNER JOIN @lt_pre AS b
      ON a~objid = b~sobid
      WHERE a~plvar = '01'
      AND   a~otype = 'SM'
      AND   a~rsign = 'B'
      AND   a~relat = '511'
      AND   a~subty = 'B511'
      AND   a~sclas = 'SM'
      AND   a~begda <= @i_keydt
      AND   a~endda >= @i_keydt
      INTO TABLE @DATA(lt_same).

*선수과목의 선택과목
    SELECT a~otype, a~objid, a~sclas, a~sobid FROM hrp1001 AS a
      INNER JOIN @lt_pre AS b
      ON a~objid = b~sobid
      WHERE a~plvar = '01'
      AND   a~otype = 'SM'
      AND   a~rsign = 'A'
      AND   a~relat = 'Z30'
      AND   a~subty = 'AZ30'
      AND   a~sclas = 'SM'
      AND   a~begda <= @i_keydt
      AND   a~endda >= @i_keydt
      APPENDING TABLE @lt_same.
    SORT lt_same BY objid.

    lt_acwork = it_acwork.
    DELETE lt_acwork WHERE smstatus <> '02'.
    DELETE lt_acwork WHERE agrnotrated = 'X'.
    SORT lt_acwork BY awobjid.

    LOOP AT lt_pre INTO DATA(ls_pre).

      CLEAR: lv_smobjid.
      lv_smobjid = ls_pre-sobid.

*해당 선수과목의 이수여부 체크
      READ TABLE lt_acwork TRANSPORTING NO FIELDS WITH KEY awobjid = lv_smobjid BINARY SEARCH.
      IF sy-subrc <> 0.
        es_msg-type = 'E'.

        LOOP AT lt_same INTO DATA(ls_same) WHERE objid = lv_smobjid.
          CLEAR: lv_smobjid2.
          lv_smobjid2 = ls_same-sobid.

*선수과목의 대체과목 中 하나라도 이수했으면 통과!
          READ TABLE lt_acwork TRANSPORTING NO FIELDS WITH KEY awobjid = lv_smobjid2 BINARY SEARCH.
          IF sy-subrc = 0.
            CLEAR: es_msg-type.
            EXIT.
          ENDIF.

        ENDLOOP.
      ENDIF.

      IF es_msg-type = 'E'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF es_msg-type = 'E'.
      es_msg-message = zcmclk100a=>otr( 'ZDCM05/TX10000055' ).
    ENDIF.

  ENDMETHOD.


  METHOD CHECK_REAL_TIME.

    DATA(lv_real) = sy-datum && sy-uzeit.

    LOOP AT ct_tab ASSIGNING FIELD-SYMBOL(<fs>).

      DATA(lv_beg) = <fs>-ca_lbegda && <fs>-ca_lbegtime.
      DATA(lv_end) = <fs>-ca_lendda && <fs>-ca_lendtime.

      IF lv_real BETWEEN lv_beg AND lv_end.
      ELSE.
        DELETE ct_tab INDEX sy-tabix.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.


  METHOD CHECK_SE_HRP1739.

    DATA lt_rel TYPE tt_obj.
    DATA lr_e TYPE RANGE OF hrobjid.

    CLEAR et_sesme[].

    SELECT b~otype, b~objid, b~sclas, b~sobid
      FROM hrp1739 AS a
      INNER JOIN hrp1001 AS b
      ON b~plvar = a~plvar
     AND b~otype = a~otype
     AND b~objid = a~objid
      INNER JOIN @it_se AS c
      ON c~objid = a~objid
     WHERE a~plvar = '01'
       AND a~otype = 'SE'
       AND a~peryr = @gs_period-peryr
       AND a~perid = @gs_period-perid
       AND b~rsign = 'A'
       AND b~relat IN ('514','512')
       AND b~sclas IN ('SM','E')
       AND b~istat = '1'
       AND ( ( b~begda <= @gs_period-keyda AND b~endda >= @gs_period-keyda ) OR
             ( b~begda >= @gs_period-begda AND b~endda <= @gs_period-endda ) )
      INTO TABLE @DATA(lt_1001).
    lt_rel = CORRESPONDING #( lt_1001 ).

    SELECT 'I' AS sign, 'EQ' AS option, objid AS low FROM hrp1739
      INTO TABLE @lr_e
     WHERE plvar = '01'
       AND otype = 'E'
       AND peryr = @gs_period-peryr
       AND perid = @gs_period-perid.

    DELETE lt_rel WHERE sclas = 'E' AND sobid NOT IN lr_e.

    et_sesme[] = lt_rel[].
    SORT et_sesme BY otype objid sclas sobid.

  ENDMETHOD.


  METHOD CHECK_SE_QUOTA.

    DATA lt_se TYPE TABLE OF hrobject.

    lt_se = VALUE #( ( plvar = '01' otype = 'SE' objid = i_se ) ).

    CLEAR es_msg.

*정원, 신청인원
    zcmclk100a=>get_se_quota_count(
      EXPORTING
        i_st_regwindow = i_st_regwindow
        i_keydt        = i_keydt
        i_peryr        = i_peryr
        i_perid        = i_perid
        it_selist      = lt_se
      IMPORTING
        et_cnt         = DATA(lt_cnt)
    ).

    READ TABLE lt_cnt INTO DATA(ls_cnt) INDEX 1.
    IF ls_cnt-book_cnt >= ls_cnt-limit_kapz.
      es_msg-type = 'E'.
      es_msg-message = zcmclk100a=>otr( EXPORTING alias = 'ZDCM05/TX10000058' ).
    ENDIF.

  ENDMETHOD.


  METHOD CHECK_SE_QUOTA_V2.

    DATA lt_se TYPE TABLE OF hrobject.
    DATA lv_booking_count TYPE int4.
    DATA lv_index TYPE sy-index.
    DATA lv_do_cnt TYPE i.
    DATA lv_err.
    DATA ls_ret TYPE zcmt2024_retlock.

    lt_se = VALUE #( ( plvar = '01' otype = 'SE' objid = i_se ) ).

    CLEAR es_msg.

*정원, 신청인원
    zcmclk100a=>get_se_quota_count(
      EXPORTING
        i_st_regwindow = i_st_regwindow
        i_keydt        = i_keydt
        i_peryr        = i_peryr
        i_perid        = i_perid
        it_selist      = lt_se
        i_quota_only   = 'X'
      IMPORTING
        et_cnt         = DATA(lt_cnt)
    ).

    READ TABLE lt_cnt INTO DATA(ls_cnt) INDEX 1.
*    IF ls_cnt-book_cnt >= ls_cnt-limit_kapz.
*      es_msg-type = 'E'.
*      es_msg-message = zcmclk100a=>otr( EXPORTING alias = 'ZDCM05/TX10000058' ).
*    ENDIF.

*{ 현재 수강 여석을 가져온다.
    lv_booking_count = zcmclk100a=>read_hrp9550_count( i_seid = i_se i_keydt = i_keydt ).

    DO 100 TIMES.
      lv_do_cnt = lv_do_cnt + 1.


      CLEAR: lv_index, lv_booking_count.
      lv_index = sy-index.
      lv_index = lv_index MOD 50.
      IF lv_index = 1.
        lv_booking_count = zcmclk100a=>read_hrp9550_count( i_seid = i_se i_keydt = i_keydt ).

        IF lv_booking_count >= ls_cnt-limit_kapz.
          es_msg-type = 'E'.
          es_msg-message = zcmclk100a=>otr( EXPORTING alias = 'ZDCM05/TX10000058' ).
          RETURN.
        ENDIF.
      ENDIF.

      lv_err = zcmclk100a=>enqueue_count_hrp9550( i_seid = i_se i_keydt = i_keydt ).

      IF lv_err IS INITIAL.
        EXIT.
      ENDIF.
    ENDDO.


    IF lv_err = 'X'.
      es_msg-type = 'E'.
*      es_msg-message = |{ zcmclk100a=>msg( arbgb = 'ZMCCM01' msgnr = '556' ) }  |.
      es_msg-message = zcmclk100a=>otr( EXPORTING alias = 'ZDCM05/TX10000543' ).

      CLEAR ls_ret.
      ls_ret-stobj = i_stid.
      ls_ret-sdate = sy-datum.
      ls_ret-uzeit = sy-uzeit.
      ls_ret-uname = sy-uname.
      ls_ret-do_cnt = lv_do_cnt.
      ls_ret-mtype = 'E'.
      GET TIME STAMP FIELD ls_ret-stime.
      MODIFY zcmt2024_retlock FROM ls_ret.
      COMMIT WORK.
      RETURN.
    ELSE.
      CLEAR ls_ret.
      ls_ret-stobj = i_stid.
      ls_ret-sdate = sy-datum.
      ls_ret-uzeit = sy-uzeit.
      ls_ret-uname = sy-uname.
      ls_ret-do_cnt = lv_do_cnt.
      ls_ret-mtype = 'S'.
      GET TIME STAMP FIELD ls_ret-stime.
      MODIFY zcmt2024_retlock FROM ls_ret.
      COMMIT WORK.
    ENDIF.


*{ 현재 수강 여석을 가져온다.
    lv_booking_count = zcmclk100a=>read_hrp9550_count( i_seid = i_se i_keydt = i_keydt ).
    IF lv_booking_count >= ls_cnt-limit_kapz.
      es_msg-type = 'E'.
      es_msg-message = zcmclk100a=>otr( EXPORTING alias = 'ZDCM05/TX10000058' ).
      zcmclk100a=>dequeue_count_hrp9550( i_seid = i_se i_keydt = i_keydt ).
      RETURN.
    ENDIF.

    ADD 1 TO lv_booking_count.

    UPDATE hrp9550 SET book_cnt = lv_booking_count WHERE plvar = '01'
                                                   AND   otype = 'SE'
                                                   AND   objid = i_se
                                                   AND   begda <= i_keydt
                                                   AND   endda >= i_keydt.

    IF sy-subrc <> 0.
      ROLLBACK WORK.
      RETURN.
    ELSE.
      COMMIT WORK.
    ENDIF.

    zcmclk100a=>dequeue_count_hrp9550( i_seid = i_se i_keydt = i_keydt ).

  ENDMETHOD.


  METHOD CHECK_SM_REBOOK.

    DATA lt_acwork TYPE TABLE OF zcmz200.
    DATA lt_acwork_re TYPE TABLE OF zcmz200.
    DATA lt_sm TYPE TABLE OF hrobject.

    CLEAR: es_msg, es_rebook_info.

    lt_acwork[] = it_acwork[].
    SORT lt_acwork BY awobjid ASCENDING
                      peryr   DESCENDING
                      perid   DESCENDING.

* 대체과목
    SELECT otype, objid, sclas, sobid FROM hrp1001
      WHERE plvar = '01'
      AND   otype = 'SM'
      AND   objid = @i_target_sm
      AND   rsign = 'B'
      AND   relat = '511'
      AND   subty = 'B511'
      AND   sclas = 'SM'
      AND   begda <= @i_keydt
      AND   endda >= @i_keydt
      INTO TABLE @DATA(lt_same).

    lt_sm = CORRESPONDING #( lt_same MAPPING objid = sobid ).
    lt_sm = VALUE #( BASE lt_sm ( objid = i_target_sm ) ).

    LOOP AT lt_sm INTO DATA(ls_sm).
      READ TABLE lt_acwork INTO DATA(ls_ac) WITH KEY awobjid = ls_sm-objid.
      IF sy-subrc = 0.
        APPEND ls_ac TO lt_acwork_re.
        CLEAR: ls_ac.
      ENDIF.
    ENDLOOP.

    SORT lt_acwork_re BY peryr DESCENDING perid DESCENDING.
    READ TABLE lt_acwork_re INTO DATA(ls_acwork_re) INDEX 1.

    IF ls_acwork_re IS INITIAL.
      RETURN.
    ENDIF.

*S성적은 재이수할 수 없습니다.
    IF ls_acwork_re-gradesym = 'S'.
      es_msg-type = 'E'.
      es_msg-message = zcmclk100a=>otr( 'ZDCM05/TX10000070' ).
      RETURN.
    ENDIF.

*재이수 가능과목 여부
    SELECT SINGLE objid, modrepeattype FROM hrp1746
      INTO @DATA(ls_1746)
      WHERE plvar = '01'
        AND otype = 'SM'
        AND istat = '1'
        AND objid = @i_target_sm
        AND begda <= @i_keydt
        AND endda >= @i_keydt.
    IF ls_1746-modrepeattype = '0005'.
*      es_msg-type = 'E'.
*      es_msg-message = zcmclk100a=>otr( 'ZDCM05/TX10000068' ).
      CLEAR es_msg.
      RETURN.
    ENDIF.

*재이수 요건
    SELECT SINGLE * FROM hrp9566
      INTO @DATA(ls_9566)
      WHERE plvar = '01'
        AND otype = 'O'
        AND objid = @i_oid
        AND istat = '1'
        AND begda <= @i_keydt
        AND endda >= @i_keydt.
    IF ls_9566 IS INITIAL.
      es_msg-type = 'E'.
      es_msg-message = zcmclk100a=>otr( 'ZDCM05/TX10000093' ).
      RETURN.
    ENDIF.

    IF i_orgcd = '0011' AND ( i_perid = '011' OR i_perid = '021' ).
      ls_9566-re_tot_cnt = '99'.
    ENDIF.
    IF i_perid = '011' OR i_perid = '021'.
      ls_9566-re_per_sm_cnt = '99'.
      ls_9566-re_same_sm_cnt = '99'.
    ENDIF.

*수강신청 과목
    SELECT  a~objid AS st_id, a~sobid AS sm_id, a~adatanr,
            b~smstatus, b~peryr, b~perid, b~id, b~packnumber, b~bookdate,
            b~reperyr, b~reperid, b~resmid, b~reid, b~repeatfg
        FROM hrp1001 AS a
   INNER JOIN hrpad506 AS b
      ON  a~adatanr = b~adatanr
      INTO TABLE @DATA(lt_506)
    WHERE a~plvar = '01'
      AND a~otype = 'ST'
      AND a~objid = @i_stid
      AND a~istat = '1'
      AND a~subty = 'A506'
      AND a~sclas = 'SM'
      AND b~smstatus IN ('1','2','3').
*정규 학기만
    DELETE lt_506 WHERE perid = '011'.
    DELETE lt_506 WHERE perid = '021'.

*전체 재수강
    DATA(lt_506_re_total) = lt_506[].
    DELETE lt_506_re_total WHERE reperyr  IS INITIAL
                             AND reperid  IS INITIAL
                             AND resmid   IS INITIAL.
    DELETE lt_506_re_total WHERE repeatfg IS INITIAL.
    DATA(lv_re_total) = lines( lt_506_re_total ).

*현재 재수강
    DATA(lt_506_re_n) = lt_506_re_total[].
    DELETE lt_506_re_n WHERE peryr <> i_peryr.
    DELETE lt_506_re_n WHERE perid <> i_perid.
    DATA(lv_re_n) = lines( lt_506_re_n ).

    SELECT * FROM dd07t
      INTO TABLE @DATA(lt_grade)
      WHERE domname = 'ZCMK_GRD_SYMB'
        AND ddlanguage = '3'.
    SORT lt_grade BY valpos.

*재이수 가능 성적
    READ TABLE lt_grade INTO DATA(ls_grade) WITH KEY domvalue_l = ls_9566-st_grd.
    IF sy-subrc = 0.
      DATA(lv_std_sort) = ls_grade-valpos.
    ENDIF.

*성적
    READ TABLE lt_grade INTO ls_grade WITH KEY domvalue_l = ls_acwork_re-gradesym.
    IF sy-subrc = 0.
      DATA(lv_re_sort) = ls_grade-valpos.
    ENDIF.

    IF ls_acwork_re-gradesym IS NOT INITIAL.
      IF lv_re_sort < lv_std_sort.
        es_msg-type = 'E'.
        es_msg-message = otr( EXPORTING alias = 'ZDCM05/TX10000076'
                                        v1    = ls_9566-st_grd ).
        RETURN.
      ENDIF.
    ENDIF.

*전체 재이수 횟수
    IF lv_re_total >= ls_9566-re_tot_cnt.
      es_msg-type = 'E'.
      es_msg-message = otr( EXPORTING alias = 'ZDCM05/TX10000078'
                                      v1    = ls_9566-re_tot_cnt ).
      RETURN.
    ENDIF.


*학기당 재이수 횟수
    IF lv_re_n >= ls_9566-re_per_sm_cnt.
      es_msg-type = 'E'.
      es_msg-message = otr( EXPORTING alias = 'ZDCM05/TX10000069'
                                      v1    = ls_9566-re_per_sm_cnt ).
      RETURN.
    ENDIF.

*재이수 과목 횟수
    DATA lv_sm_cnt TYPE i.
*    LOOP AT lt_506_re_total INTO DATA(ls_re).
*      IF ls_re-sm_id = i_target_sm OR ls_re-resmid = i_target_sm.
*        lv_sm_cnt = lv_sm_cnt + 1.
*      ENDIF.
*    ENDLOOP.
    LOOP AT lt_506 INTO DATA(ls_506) WHERE sm_id = i_target_sm.
      lv_sm_cnt = lv_sm_cnt + 1.
    ENDLOOP.
    lv_sm_cnt = lv_sm_cnt - 1.

    IF lv_sm_cnt >= ls_9566-re_same_sm_cnt.
      es_msg-type = 'E'.
      es_msg-message = otr( EXPORTING alias = 'ZDCM05/TX10000077'
                                      v1    = ls_9566-re_same_sm_cnt ).
      RETURN.
    ENDIF.

    es_rebook_info-rescale = ls_9566-re_scale. "재이수 성적 스케일
    IF ls_acwork_re-gradescale = 'KRSU' OR ls_acwork_re-gradescale = 'KRNP'.
      es_rebook_info-rescale = ls_acwork_re-gradescale.
    ENDIF.

    es_rebook_info-reperyr = ls_acwork_re-peryr.
    es_rebook_info-reperid = ls_acwork_re-perid.
    es_rebook_info-reid = ls_acwork_re-modreg_id.
    es_rebook_info-resmid = ls_acwork_re-awobjid.
    es_rebook_info-repeatfg = abap_true.

  ENDMETHOD.


  METHOD CHECK_SM_REBOOK_ADMIN.

    DATA lt_acwork TYPE TABLE OF zcmz200.
    DATA lt_acwork_re TYPE TABLE OF zcmz200.
    DATA lt_sm TYPE TABLE OF hrobject.
    DATA lv_target_sm TYPE piqsmobjid.

    CLEAR: es_msg, es_rebook_info.

    lv_target_sm = i_smid.
    lt_acwork[] = it_acwork[].
    IF i_book_id IS NOT INITIAL.
      DELETE lt_acwork WHERE modreg_id = i_book_id.
    ENDIF.

    IF i_book_re_id IS INITIAL. "일반 재이수
      SORT lt_acwork BY awobjid ASCENDING
                        peryr   DESCENDING
                        perid   DESCENDING.

* 대체과목
      SELECT otype, objid, sclas, sobid FROM hrp1001
        WHERE plvar = '01'
        AND   otype = 'SM'
        AND   objid = @lv_target_sm
        AND   rsign = 'B'
        AND   relat = '511'
        AND   subty = 'B511'
        AND   sclas = 'SM'
        AND   begda <= @i_keydt
        AND   endda >= @i_keydt
        INTO TABLE @DATA(lt_same).

      lt_sm = CORRESPONDING #( lt_same MAPPING objid = sobid ).
      lt_sm = VALUE #( BASE lt_sm ( objid = lv_target_sm ) ).

      LOOP AT lt_sm INTO DATA(ls_sm).
        READ TABLE lt_acwork INTO DATA(ls_ac) WITH KEY awobjid = ls_sm-objid.
        IF sy-subrc = 0.
          APPEND ls_ac TO lt_acwork_re.
          CLEAR: ls_ac.
        ENDIF.
      ENDLOOP.

      SORT lt_acwork_re BY peryr DESCENDING perid DESCENDING.
      READ TABLE lt_acwork_re INTO DATA(ls_acwork_re) INDEX 1.

    ELSE. "대체 처리

      READ TABLE lt_acwork INTO ls_acwork_re WITH KEY modreg_id = i_book_re_id.
    ENDIF.

    IF ls_acwork_re IS INITIAL.
      RETURN.
    ENDIF.

*S성적은 재이수할 수 없습니다.
    IF ls_acwork_re-gradesym = 'S'.
      es_msg-type = 'E'.
      es_msg-message = zcmclk100a=>otr( 'ZDCM05/TX10000070' ).
      RETURN.
    ENDIF.

*재이수 가능과목 여부
    SELECT SINGLE objid, modrepeattype FROM hrp1746
      INTO @DATA(ls_1746)
      WHERE plvar = '01'
        AND otype = 'SM'
        AND istat = '1'
        AND objid = @lv_target_sm
        AND begda <= @i_keydt
        AND endda >= @i_keydt.
    IF ls_1746-modrepeattype = '0005'.
      es_msg-type = 'E'.
      es_msg-message = zcmclk100a=>otr( 'ZDCM05/TX10000068' ).
      RETURN.
    ENDIF.

*재이수 요건
    SELECT SINGLE * FROM hrp9566
      INTO @DATA(ls_9566)
      WHERE plvar = '01'
        AND otype = 'O'
        AND objid = @i_oid
        AND istat = '1'
        AND begda <= @i_keydt
        AND endda >= @i_keydt.
    IF ls_9566 IS INITIAL.
      es_msg-type = 'E'.
      es_msg-message = zcmclk100a=>otr( 'ZDCM05/TX10000093' ).
      RETURN.
    ENDIF.

    IF i_perid = '011' OR i_perid = '021'.
      ls_9566-re_tot_cnt = '99'.
      ls_9566-re_per_sm_cnt = '99'.
      ls_9566-re_same_sm_cnt = '99'.
    ENDIF.

*수강신청 과목
    SELECT  a~objid AS st_id, a~sobid AS sm_id, a~adatanr,
            b~smstatus, b~peryr, b~perid, b~id, b~packnumber, b~bookdate,
            b~reperyr, b~reperid, b~resmid, b~reid, b~repeatfg
        FROM hrp1001 AS a
   INNER JOIN hrpad506 AS b
      ON  a~adatanr = b~adatanr
      INTO TABLE @DATA(lt_506)
    WHERE a~plvar = '01'
      AND a~otype = 'ST'
      AND a~objid = @i_stid
      AND a~istat = '1'
      AND a~subty = 'A506'
      AND a~sclas = 'SM'
      AND b~smstatus IN ('1','2','3').
    DELETE lt_506 WHERE id = i_book_id.
*정규 학기만
    DELETE lt_506 WHERE perid = '011'.
    DELETE lt_506 WHERE perid = '021'.

*전체 재수강
    DATA(lt_506_re_total) = lt_506[].
    DELETE lt_506_re_total WHERE reperyr  IS INITIAL
                             AND reperid  IS INITIAL
                             AND resmid   IS INITIAL.
    DELETE lt_506_re_total WHERE repeatfg IS INITIAL.
    DATA(lv_re_total) = lines( lt_506_re_total ).

*현재 재수강
    DATA(lt_506_re_n) = lt_506_re_total[].
    DELETE lt_506_re_n WHERE peryr <> i_peryr.
    DELETE lt_506_re_n WHERE perid <> i_perid.
    DATA(lv_re_n) = lines( lt_506_re_n ).

    SELECT * FROM dd07t
      INTO TABLE @DATA(lt_grade)
      WHERE domname = 'ZCMK_GRD_SYMB'
        AND ddlanguage = '3'.
    SORT lt_grade BY valpos.

*재이수 가능 성적
    READ TABLE lt_grade INTO DATA(ls_grade) WITH KEY domvalue_l = ls_9566-st_grd.
    IF sy-subrc = 0.
      DATA(lv_std_sort) = ls_grade-valpos.
    ENDIF.

*성적
    READ TABLE lt_grade INTO ls_grade WITH KEY domvalue_l = ls_acwork_re-gradesym.
    IF sy-subrc = 0.
      DATA(lv_re_sort) = ls_grade-valpos.
    ENDIF.

    IF ls_acwork_re-gradesym IS NOT INITIAL.
      IF lv_re_sort < lv_std_sort.
        es_msg-type = 'E'.
        es_msg-message = otr( EXPORTING alias = 'ZDCM05/TX10000076'
                                        v1    = ls_9566-st_grd ).
        RETURN.
      ENDIF.
    ENDIF.

*전체 재이수 횟수
    IF lv_re_total >= ls_9566-re_tot_cnt.
      es_msg-type = 'E'.
      es_msg-message = otr( EXPORTING alias = 'ZDCM05/TX10000078'
                                      v1    = ls_9566-re_tot_cnt ).
      RETURN.
    ENDIF.


*학기당 재이수 횟수
    IF lv_re_n >= ls_9566-re_per_sm_cnt.
      es_msg-type = 'E'.
      es_msg-message = otr( EXPORTING alias = 'ZDCM05/TX10000069'
                                      v1    = ls_9566-re_per_sm_cnt ).
      RETURN.
    ENDIF.

*재이수 과목 횟수
    DATA lv_sm_cnt TYPE i.
*    LOOP AT lt_506_re_total INTO DATA(ls_re).
*      IF ls_re-sm_id = lv_target_sm OR ls_re-resmid = lv_target_sm.
*        lv_sm_cnt = lv_sm_cnt + 1.
*      ENDIF.
*    ENDLOOP.
    LOOP AT lt_506 INTO DATA(ls_506) WHERE sm_id = lv_target_sm.
      lv_sm_cnt = lv_sm_cnt + 1.
    ENDLOOP.
    lv_sm_cnt = lv_sm_cnt - 1.

    IF lv_sm_cnt >= ls_9566-re_same_sm_cnt.
      es_msg-type = 'E'.
      es_msg-message = otr( EXPORTING alias = 'ZDCM05/TX10000077'
                                      v1    = ls_9566-re_same_sm_cnt ).
      RETURN.
    ENDIF.

    es_rebook_info-alt_scaleid = ls_9566-re_scale. "재이수 성적 스케일
    es_rebook_info-reperyr = ls_acwork_re-peryr.
    es_rebook_info-reperid = ls_acwork_re-perid.
    es_rebook_info-reid = ls_acwork_re-modreg_id.
    es_rebook_info-resmid = ls_acwork_re-awobjid.
    es_rebook_info-repeatfg = abap_true.

  ENDMETHOD.


  METHOD CHECK_SM_SHARE.

    CLEAR es_msg.

    CHECK it_booked_sm IS NOT INITIAL.

    SELECT o_id,smgrp_id,sm_id,main_sm_fg,begda,endda FROM zcmt2410
      INTO TABLE @DATA(lt_2410)
      WHERE smgrp_id IN ( SELECT smgrp_id FROM zcmt2410 WHERE sm_id = @i_target_sm AND begda <= @i_keydt AND endda >= @i_keydt )
        AND begda <= @i_keydt
        AND endda >= @i_keydt.
    CHECK sy-subrc = 0.

    SORT lt_2410 BY sm_id.
    SORT it_booked_sm BY objid.

    LOOP AT lt_2410 INTO DATA(ls_2410).
      READ TABLE it_booked_sm WITH KEY objid = ls_2410-sm_id BINARY SEARCH TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        es_msg-type = 'E'.
        DATA(lv_otr) = otr( EXPORTING alias = 'ZDCM05/TX10000079' ).
        es_msg-message = lv_otr.
        RETURN.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.


  METHOD CHECK_TIMECONF_FOR_EVENT.

    DATA: lt_eobject TYPE piq_hrobject_t.
    DATA: ls_eobject TYPE hrobject.
    DATA: lt_conflict     TYPE piq_event_conflict_t.
    DATA: ls_conflict     TYPE piq_event_conflict.

    SELECT SINGLE overl FROM hrp9566
      INTO @DATA(lv_overl)
      WHERE plvar = '01'
        AND otype = 'O'
        AND istat = '1'
        AND objid = @i_oid
        AND begda <= @i_keydt
        AND endda >= @i_keydt.
    IF lv_overl IS INITIAL.
      RETURN.
    ENDIF.

    CLEAR: lt_eobject, ls_eobject, es_msg.
    CHECK it_booked_e IS NOT INITIAL.

    SORT it_booked_e BY objid.
    READ TABLE it_booked_e INTO DATA(ls_booked_e) WITH KEY objid = i_target_e BINARY SEARCH.
    IF sy-subrc = 0.
      DATA(lv_otr) = otr( EXPORTING alias = 'ZDCM05/TX10000048'
                                    v1    = |[{ ls_booked_e-short }] { ls_booked_e-stext }| ).
      es_msg-message = lv_otr.
      RETURN.
    ENDIF.

    ls_eobject-plvar = '01'.
    ls_eobject-otype =  'E'.
    ls_eobject-objid =  i_target_e.
    APPEND ls_eobject TO lt_eobject. CLEAR: ls_eobject.

    SORT it_booked_e BY objid.
    LOOP AT it_booked_e INTO ls_booked_e.
      ls_eobject-plvar = '01'.
      ls_eobject-otype =  'E'.
      ls_eobject-objid =  ls_booked_e-objid.
      APPEND ls_eobject TO lt_eobject. CLEAR: ls_eobject.
    ENDLOOP.

    CLEAR: lt_conflict, ls_conflict.
    CALL FUNCTION 'HRIQ_CHECK_TIMECONF_FOR_EVENT'
      EXPORTING
        e_object1     = lt_eobject
      IMPORTING
        e_conflict    = lt_conflict
      EXCEPTIONS
        no_event_data = 1
        wrong_data    = 2
        OTHERS        = 3.

    SORT lt_conflict BY objid1 objid2.
    DELETE ADJACENT DUPLICATES FROM lt_conflict COMPARING objid1 objid2.
*
    LOOP AT lt_conflict INTO ls_conflict.
      READ TABLE it_booked_e INTO ls_booked_e WITH KEY objid = ls_conflict-objid1 BINARY SEARCH.
      IF sy-subrc = 0.
        es_msg-type = 'E'.
        lv_otr = otr( EXPORTING alias = 'ZDCM05/TX10000048'
                                v1    = |[{ ls_booked_e-short }] { ls_booked_e-stext }| ).
        es_msg-message = lv_otr.
        RETURN.
      ENDIF.

      READ TABLE it_booked_e INTO ls_booked_e WITH KEY objid = ls_conflict-objid2 BINARY SEARCH.
      IF sy-subrc = 0.
        es_msg-type = 'E'.
        lv_otr = otr( EXPORTING alias = 'ZDCM05/TX10000048'
                                v1    = |[{ ls_booked_e-short }] { ls_booked_e-stext }| ).
        es_msg-message = lv_otr.
        RETURN.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.


  METHOD DECREASE_BOOKING_COUNT.

    DATA lv_booking_count TYPE int4.
    DATA lv_err.

    DO 100 TIMES.
      CLEAR: lv_err.
      lv_err = zcmclk100a=>enqueue_count_hrp9550( i_seid = i_seid i_keydt = i_keydt ).
      IF lv_err IS INITIAL.
        EXIT.
      ENDIF.
    ENDDO.

    IF lv_err = 'X'.
      zcmclk100a=>dequeue_count_hrp9550( i_seid = i_seid i_keydt = i_keydt ).
      es_msg-type = 'E'.
*      es_msg-message = |{ zcmclk100a=>msg( arbgb = 'ZMCCM01' msgnr = '556' ) }  |.
      es_msg-message = zcmclk100a=>otr( EXPORTING alias = 'ZDCM05/TX10000543' ).
      RETURN.
    ENDIF.

*{ 현재 수강 여석을 가져온다.
    lv_booking_count = zcmclk100a=>read_hrp9550_count( i_seid = i_seid i_keydt = i_keydt ).

    IF lv_booking_count  = 0.
      zcmclk100a=>dequeue_count_hrp9550( i_seid = i_seid i_keydt = i_keydt ).
      RETURN.
    ENDIF.

    lv_booking_count = lv_booking_count - 1.

    UPDATE hrp9550 SET book_cnt = lv_booking_count WHERE plvar = '01'
                                                   AND   otype = 'SE'
                                                   AND   objid = i_seid
                                                   AND   begda <= i_keydt
                                                   AND   endda >= i_keydt.

    IF sy-subrc <> 0.
      ROLLBACK WORK.
      RETURN.
    ELSE.
      COMMIT WORK.
    ENDIF.

    zcmclk100a=>dequeue_count_hrp9550( i_seid = i_seid i_keydt = i_keydt ).

  ENDMETHOD.


  METHOD DEQUEUE_COUNT_HRP9550.

    CALL FUNCTION 'DEQUEUE_EZ_HRP9550'
      EXPORTING
        mode_hrp9550 = 'E'
        mandt        = sy-mandt
        plvar        = '01'
        otype        = 'SE'
        objid        = i_seid
*       SUBTY        =
*       ISTAT        =
        begda        = i_keydt
*       ENDDA        =
*       VARYF        =
*       SEQNR        =
*       X_PLVAR      = ' '
*       X_OTYPE      = ' '
*       X_OBJID      = ' '
*       X_SUBTY      = ' '
*       X_ISTAT      = ' '
*       X_BEGDA      = ' '
*       X_ENDDA      = ' '
*       X_VARYF      = ' '
*       X_SEQNR      = ' '
        _scope       = '1' "sap권고
*       _SCOPE       = '3'
*       _SYNCHRON    = ' '
*       _COLLECT     = ' '
      .

  ENDMETHOD.


  METHOD ENQUEUE_COUNT_HRP9550.

    CALL FUNCTION 'ENQUEUE_EZ_HRP9550'
      EXPORTING
        mode_hrp9550   = 'E'
        mandt          = sy-mandt
        plvar          = '01'
        otype          = 'SE'
        objid          = i_seid
*       SUBTY          =
*       ISTAT          =
        begda          = i_keydt
*       ENDDA          =
*       VARYF          =
*       SEQNR          =
*       X_PLVAR        = ' '
*       X_OTYPE        = ' '
*       X_OBJID        = ' '
*       X_SUBTY        = ' '
*       X_ISTAT        = ' '
*       X_BEGDA        = ' '
*       X_ENDDA        = ' '
*       X_VARYF        = ' '
*       X_SEQNR        = ' '
*       _scope         = '2' "원본소스
        _scope         = '1' "SAP권고
*       _WAIT          = ''
*       _collect       = ' '
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.

    IF sy-subrc <> 0.
      r_err = 'X'.
      RETURN.
    ELSE.
      CLEAR r_err.
    ENDIF.

  ENDMETHOD.


  METHOD GET_APPLICATION_URL.

    DATA:lv_host     TYPE string,
         lv_port     TYPE string,
         lv_protocol TYPE string.

    DATA : ls_param TYPE ihttpnvp.

*~서버 host
    cl_http_server=>if_http_server~get_location(
      IMPORTING
        host         = lv_host
        port         = lv_port
        out_protocol = lv_protocol
    ).

    CONCATENATE lv_protocol '://'
                lv_host ':' lv_port '/zu4a/'
                im_appid
           INTO rm_url.

    CONCATENATE rm_url `?sap-client=` sy-mandt INTO rm_url.

    IF it_param[] IS NOT INITIAL.

      LOOP AT it_param INTO ls_param.
        CONCATENATE rm_url '&' ls_param-name '=' ls_param-value  INTO rm_url.
        CLEAR ls_param.
      ENDLOOP.
      SHIFT rm_url RIGHT DELETING TRAILING `&`.

    ENDIF.

    CONDENSE rm_url.

    IF im_show = 'X'.

**    zcmuicl0=>call_local_browser(
**      EXPORTING
**        iv_url     = rm_url
**        is_sync    = ''
**      IMPORTING
**        ev_msg     = DATA(lv_msg)
**    ).

    ENDIF.

  ENDMETHOD.


  METHOD GET_DDLB_ORG1.

    SELECT b~possb_oid FROM hrp9566 AS a
      INNER JOIN hrt9566 AS b
      ON a~tabnr = b~tabnr
      INTO TABLE @DATA(lt_pssb)
      WHERE a~plvar = '01'
        AND a~otype = 'O'
        AND a~objid IN ( SELECT map_cd2 FROM zcmt0101 WHERE grp_cd = '100' AND org_cd = @i_orgcd )
        AND a~istat = '1'
        AND a~begda <= @sy-datum
        AND a~endda >= @sy-datum.
    SORT lt_pssb BY possb_oid.

    CLEAR rt_org.
    SELECT * FROM zcmt0101
      INTO TABLE @DATA(lt_0101)
   WHERE grp_cd = '100'
     AND com_cd = '0011'
    ORDER BY remark.

    SELECT * FROM zcmt0101
      APPENDING TABLE lt_0101
   WHERE grp_cd = '100'
     AND com_cd <> '0011'
    ORDER BY remark.


    LOOP AT lt_0101 INTO DATA(ls_0101).

      IF sy-uname(4) = 'ASPN' OR
         sy-uname CP 'G*'.
      ELSE.
        IF lt_pssb IS NOT INITIAL.
          READ TABLE lt_pssb WITH KEY possb_oid = ls_0101-map_cd2 BINARY SEARCH TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDIF.

      IF sy-langu = 'E'.
        DATA(ls_value) = VALUE ihttpnvp( name = ls_0101-map_cd2 value = ls_0101-com_nm_en ).
      ELSE.
        ls_value = VALUE ihttpnvp( name = ls_0101-map_cd2 value = ls_0101-com_nm ).
      ENDIF.

      APPEND ls_value TO rt_org.
      CLEAR: ls_value.
    ENDLOOP.


  ENDMETHOD.


  METHOD GET_DDLB_ORG2.

    DATA: lt_result TYPE objec_t.

    CASE i_oid1.
      WHEN '30000002'.
        SELECT * FROM zcmt0101
          INTO TABLE @DATA(lt_0101)
             WHERE grp_cd = '109'
               AND com_cd <> '0000'
             ORDER BY remark.

        LOOP AT lt_0101 INTO DATA(ls_0101).
          IF sy-langu = 'E'.
            DATA(ls_value) = VALUE ihttpnvp( name = ls_0101-map_cd2 value = ls_0101-com_nm_en ).
          ELSE.
            ls_value = VALUE ihttpnvp( name = ls_0101-map_cd2 value = ls_0101-com_nm ).
          ENDIF.

          APPEND ls_value TO rt_org.
          CLEAR: ls_value.
        ENDLOOP.

      WHEN OTHERS.
        CALL FUNCTION 'ZCM_CG_FROM_ORG_GET'
          EXPORTING
            act_otype    = 'O'
            act_objid    = i_oid1
            act_wegid    = 'O-CG'
            act_plvar    = '01'
            act_begda    = sy-datum
            act_endda    = sy-datum
            act_tdepth   = 0
          TABLES
            result_objec = lt_result.

        rt_org = CORRESPONDING #( lt_result MAPPING name = objid value = stext ).

    ENDCASE.
    INSERT INITIAL LINE INTO rt_org INDEX 1.



  ENDMETHOD.


  METHOD GET_DDLB_ORG3.

    DATA: lt_result TYPE objec_t.

    CLEAR rt_org.

    CHECK i_oid1 = '30000002'.

    CALL FUNCTION 'ZCM_CG_FROM_ORG_GET'
      EXPORTING
        act_otype    = 'O'
        act_objid    = i_oid2
        act_wegid    = 'O-CG'
        act_plvar    = '01'
        act_begda    = sy-datum
        act_endda    = sy-datum
        act_tdepth   = 0
      TABLES
        result_objec = lt_result.

    rt_org = CORRESPONDING #( lt_result MAPPING name = objid value = stext ).


  ENDMETHOD.


  METHOD GET_KEY_DATE.

    DATA: lt_hrtimelimits TYPE piqtimelimits_tab.

    CLEAR gs_period.
    CHECK i_peryr IS NOT INITIAL AND i_perid IS NOT INITIAL.

    CASE i_perid.
      WHEN '010' OR '020'.
        DATA(lv_orgunit) = CONV hrobjid( '30000100' ).
      WHEN '011' OR '021'.
        lv_orgunit = '30000002'.
    ENDCASE.

    CALL FUNCTION 'ZCM_GET_TIMELIMITS'
      EXPORTING
        iv_o          = lv_orgunit
        iv_timelimit  = '0100'
        iv_peryr      = i_peryr
        iv_perid      = i_perid
      IMPORTING
        et_timelimits = lt_hrtimelimits.

    READ TABLE lt_hrtimelimits INTO DATA(ls_timelimits) INDEX 1.
    IF sy-subrc = 0.
      gs_period-begda = ls_timelimits-ca_lbegda.
      gs_period-endda = ls_timelimits-ca_lendda.
      gs_period-keyda = gs_period-begda + 15.
      gs_period-peryr = i_peryr.
      gs_period-perid = i_perid.
    ENDIF.

  ENDMETHOD.


  METHOD GET_LOGIN_ID.

    DATA ls_login TYPE zcmcl000=>ty_st_cmacbpst.

    CLEAR: es_login, es_auth, ev_timelimit_fg.

    SELECT SINGLE * FROM zcmtw1200
      INTO @DATA(ls_w1200)
      WHERE uname = @sy-uname.
    IF ls_w1200 IS INITIAL.
      IF sy-uname(4) = 'ASPN' OR sy-uname(3) = 'SIT' OR sy-uname = '113034' OR sy-uname = '302444'.
        SELECT SINGLE cname FROM zcmtk001
          INTO ls_login-st_no
          WHERE uname = sy-uname.
      ELSE.
        ls_login-st_no = sy-uname.
      ENDIF.
    ELSE.
      DELETE FROM zcmtw1200 WHERE uname = sy-uname.
      COMMIT WORK.

      es_auth = ls_w1200.
      ls_login-st_no = ls_w1200-newid.
    ENDIF.
    IF es_auth-auth IS INITIAL.
      es_auth-auth = 'STUDENT'.
    ENDIF.

    SELECT SINGLE timelimit_fg FROM zcmt2024_auth
      INTO ev_timelimit_fg
      WHERE auth = es_auth-auth.
    CHECK sy-subrc = 0.

    SELECT SINGLE a~stobjid   AS st_id
                  a~student12 AS st_no
                  a~partner   AS st_bp
                  b~stext     AS st_nm
      INTO ls_login
      FROM cmacbpst AS a
      JOIN hrp1000 AS b ON a~stobjid = b~objid
     WHERE a~student12 =  ls_login-st_no
       AND b~plvar = '01'
       AND b~otype = 'ST'
       AND b~istat = '1'
       AND b~begda <= sy-datum
       AND b~endda >= sy-datum
       AND b~langu = '3'.

    es_login = ls_login.

  ENDMETHOD.


  METHOD GET_LOGIN_PERSON.

    DATA ls_login TYPE zcmcl000=>ty_person.

    CLEAR: es_login, es_auth, ev_timelimit_fg.

    IF sy-uname(4) = 'ASPN' OR sy-uname(3) = 'SIT' OR sy-uname = '113034' OR sy-uname = '302444'.
      SELECT SINGLE cname FROM zcmtk001
        INTO @DATA(lv_cname)
        WHERE uname = @sy-uname.
      ls_login-pernr = lv_cname.
    ELSE.
      ls_login-pernr = sy-uname.
    ENDIF.

    IF es_auth-auth IS INITIAL.
      es_auth-auth = 'PERSON'.
    ENDIF.

    SELECT SINGLE pernr ename
      FROM pa0001 INTO ls_login
      WHERE pernr = ls_login-pernr
        AND begda <= sy-datum
        AND endda >= sy-datum.

  ENDMETHOD.


  METHOD GET_RANDOM_MACRO.

    DATA lv_ran TYPE i.

    CALL FUNCTION 'QF05_RANDOM_INTEGER'
      EXPORTING
        ran_int_max   = max
        ran_int_min   = min
      IMPORTING
        ran_int       = lv_ran
      EXCEPTIONS
        invalid_input = 1
        OTHERS        = 2.

    READ TABLE ct_int INTO DATA(lv_int) WITH KEY table_line = lv_ran.
    IF sy-subrc = 0.
      get_random_macro( EXPORTING max = max min = min CHANGING ct_int = ct_int ).
    ELSE.
      APPEND lv_ran TO ct_int.
    ENDIF.




  ENDMETHOD.


  METHOD GET_SE_DELAY_COUNT.

    DATA ls_cnt LIKE LINE OF et_delay_cnt.

    CLEAR et_delay_cnt.

    CHECK it_selist IS NOT INITIAL.

    SELECT * FROM zcmt2018_sync
      INTO TABLE @DATA(lt_2018)
     WHERE peryr = @i_peryr
       AND perid = @i_perid
       AND begda <= @sy-datum
       AND endda >= @sy-datum
       AND smstatus = '04'
       AND active = 'X'.
    CHECK sy-subrc = 0.
    LOOP AT lt_2018 INTO DATA(ls_2018).
      IF ls_2018-begda && ls_2018-begtime <= sy-datum && sy-uzeit AND sy-datum && sy-uzeit <= ls_2018-endda && ls_2018-endtime.
        DATA(lv_ok) = 'X'.
      ENDIF.
    ENDLOOP.
    CHECK lv_ok IS NOT INITIAL.

    SELECT se_id, sm_id, delay_begda, delay_begtm FROM zcmtk210
      INTO TABLE @DATA(lt_210)
      FOR ALL ENTRIES IN @it_selist
      WHERE peryr = @i_peryr
        AND perid = @i_perid
        AND se_id = @it_selist-objid
        AND delay_begda = @sy-datum.
    DELETE lt_210 WHERE delay_begtm <= sy-uzeit.

    LOOP AT lt_210 INTO DATA(ls_210).
      ls_cnt-se_id = ls_210-se_id.
      ls_cnt-cnt = 1.
      COLLECT ls_cnt INTO et_delay_cnt.
      CLEAR ls_cnt.
    ENDLOOP.

    SORT et_delay_cnt BY se_id.



  ENDMETHOD.


  METHOD GET_SE_FROM_CG.

    DATA lt_qstru TYPE TABLE OF qcat_stru.
    DATA lr_cg TYPE RANGE OF hrobjid.
    DATA lr_sm TYPE RANGE OF hrobjid.
    DATA lt_sm TYPE tt_obj.

    CHECK i_cgid IS NOT INITIAL.
    CALL FUNCTION 'RHPH_STRUCTURE_READ'
      EXPORTING
        plvar    = '01'
        otype    = 'CG'
        objid    = i_cgid
        wegid    = 'O-CG'
        begda    = gs_period-keyda
        endda    = gs_period-keyda
      TABLES
        stru_tab = lt_qstru.

    DELETE lt_qstru WHERE otype <> 'CG'.
    lr_cg = VALUE #( FOR ls_qstru IN lt_qstru ( sign = 'I' option = 'EQ' low = ls_qstru-objid ) ).

    SELECT otype, objid, sclas, sobid FROM hrp1001
       INTO TABLE @DATA(lt_cgsm)
           WHERE plvar = '01'
             AND otype = 'CG'
             AND objid IN @lr_cg
             AND rsign = 'A'
             AND relat = '500'
             AND istat = '1'
             AND sclas = 'SM'
             AND begda <= @gs_period-keyda
             AND endda >= @gs_period-keyda.
    lt_sm = CORRESPONDING #( lt_cgsm ).
    CHECK lt_sm[] IS NOT INITIAL.

    SELECT otype, objid, sclas, sobid FROM hrp1001
      INTO TABLE @DATA(lt_smse)
      FOR ALL ENTRIES IN @lt_sm[]
       WHERE plvar = '01'
         AND otype = 'SM'
         AND objid = @lt_sm-sobid
         AND rsign = 'B'
         AND relat = '514'
         AND istat = '1'
         AND sclas = 'SE'
         AND begda <= @gs_period-keyda
         AND endda >= @gs_period-keyda.


    et_selist = VALUE #( FOR ls_smse IN lt_smse ( plvar = '01' otype = 'SE' objid = ls_smse-sobid ) ).



  ENDMETHOD.


  METHOD GET_SE_FROM_O.

    DATA lt_qstru TYPE TABLE OF qcat_stru.
    DATA lr_o TYPE RANGE OF hrobjid.
    DATA lr_sm TYPE RANGE OF hrobjid.
    DATA lt_sm TYPE tt_obj.

    CLEAR: et_selist[], et_smse[].

    CALL FUNCTION 'RHPH_STRUCTURE_READ'
      EXPORTING
        plvar             = '01'
        otype             = 'O'
        objid             = i_oid
        wegid             = 'ORGEH'
        begda             = gs_period-keyda
        endda             = gs_period-keyda
      TABLES
        stru_tab          = lt_qstru
      EXCEPTIONS
        catalogue_problem = 1
        root_not_found    = 2
        wegid_not_found   = 3
        OTHERS            = 4.

    lr_o = VALUE #( FOR ls_qstru IN lt_qstru ( sign = 'I' option = 'EQ' low = ls_qstru-objid ) ).

    SELECT otype, objid, sclas, sobid FROM hrp1001
       INTO TABLE @DATA(lt_osm)
     WHERE plvar = '01'
       AND otype = 'O'
       AND objid IN @lr_o
       AND rsign = 'A'
       AND relat = '501'
       AND istat = '1'
       AND sclas = 'SM'
       AND begda <= @gs_period-keyda
       AND endda >= @gs_period-keyda.

    lt_sm = CORRESPONDING #( lt_osm ).
    CHECK lt_sm[] IS NOT INITIAL.

    SELECT otype, objid, sclas, sobid FROM hrp1001
      INTO TABLE @DATA(lt_smse)
      FOR ALL ENTRIES IN @lt_sm[]
       WHERE plvar = '01'
         AND otype = 'SM'
         AND objid = @lt_sm-sobid
         AND rsign = 'B'
         AND relat = '514'
         AND istat = '1'
         AND sclas = 'SE'
         AND begda <= @gs_period-keyda
         AND endda >= @gs_period-keyda.

    et_selist = VALUE #( FOR ls_smse IN lt_smse ( plvar = '01' otype = 'SE' objid = ls_smse-sobid ) ).

  ENDMETHOD.


  METHOD GET_SE_FROM_O_CG.

    get_key_date( i_peryr = i_peryr i_perid = i_perid ).

    DATA lt_qstru_o TYPE TABLE OF qcat_stru.
    CALL FUNCTION 'RHPH_STRUCTURE_READ'
      EXPORTING
        plvar             = '01'
        otype             = 'O'
        objid             = i_oid
        wegid             = 'ORGEH'
        begda             = gs_period-keyda
        endda             = gs_period-keyda
      TABLES
        stru_tab          = lt_qstru_o
      EXCEPTIONS
        catalogue_problem = 1
        root_not_found    = 2
        wegid_not_found   = 3
        OTHERS            = 4.

    CHECK lt_qstru_o[] IS NOT INITIAL.

    DATA lt_qstru_cg TYPE TABLE OF qcat_stru.
    DATA lt_qstru TYPE TABLE OF qcat_stru.
    DATA lr_cg TYPE RANGE OF hrobjid.
    DATA lr_sm TYPE RANGE OF hrobjid.
    DATA lt_sm TYPE tt_obj.
    LOOP AT lt_qstru_o INTO DATA(ls_qstru_o).
      CLEAR lt_qstru.
      CALL FUNCTION 'RHPH_STRUCTURE_READ'
        EXPORTING
          plvar          = '01'
          otype          = 'O'
          objid          = ls_qstru_o-objid
          wegid          = 'O-CG'
          begda          = gs_period-keyda
          endda          = gs_period-keyda
        TABLES
          stru_tab       = lt_qstru
        EXCEPTIONS
          root_not_found = 1
          OTHERS         = 2.

      CHECK lt_qstru IS NOT INITIAL.
      APPEND LINES OF lt_qstru TO lt_qstru_cg.

    ENDLOOP.

    CHECK lt_qstru_cg[] IS NOT INITIAL.

    DELETE lt_qstru_cg WHERE otype <> 'CG'.
    lr_cg = VALUE #( FOR ls_qstru_cg IN lt_qstru_cg ( sign = 'I' option = 'EQ' low = ls_qstru_cg-objid ) ).

    SELECT otype, objid, sclas, sobid FROM hrp1001
       INTO TABLE @DATA(lt_cgsm)
           WHERE plvar = '01'
             AND otype = 'CG'
             AND objid IN @lr_cg
             AND rsign = 'A'
             AND relat = '500'
             AND istat = '1'
             AND sclas = 'SM'
             AND begda <= @gs_period-keyda
             AND endda >= @gs_period-keyda.
    lt_sm = CORRESPONDING #( lt_cgsm ).
    CHECK lt_sm[] IS NOT INITIAL.

    SELECT otype, objid, sclas, sobid FROM hrp1001
      INTO TABLE @DATA(lt_smse)
      FOR ALL ENTRIES IN @lt_sm[]
       WHERE plvar = '01'
         AND otype = 'SM'
         AND objid = @lt_sm-sobid
         AND rsign = 'B'
         AND relat = '514'
         AND istat = '1'
         AND sclas = 'SE'
         AND begda <= @gs_period-keyda
         AND endda >= @gs_period-keyda.

    DATA lt_se TYPE hrobject_t.
    lt_se = VALUE #( FOR ls_smse IN lt_smse ( plvar = '01' otype = 'SE' objid = ls_smse-sobid ) ).

    CHECK lt_se[] IS NOT INITIAL.

*   개설분반 필터
    check_se_hrp1739( EXPORTING it_se    = lt_se
                      IMPORTING et_sesme = DATA(lt_sesme) ).

    et_selist = VALUE #( FOR ls_sesm IN lt_sesme ( plvar = '01' otype = 'SE' objid = ls_sesm-objid ) ).
    SORT et_selist.
    DELETE ADJACENT DUPLICATES FROM et_selist COMPARING ALL FIELDS.

  ENDMETHOD.


  METHOD GET_SE_FROM_SM.

    DATA lt_sm TYPE TABLE OF hrobject.

    CLEAR: et_selist[], et_smse[].

    IF i_smsht IS NOT INITIAL.
      DATA(lr_short) = VALUE rsdsselopt_t( ( sign = 'I' option = 'CP' low = |*{ i_smsht }*| ) ).

      SELECT plvar, otype, objid FROM hrp1000
        INTO TABLE @lt_sm
       WHERE plvar = '01'
         AND otype IN ('SM','SE')
         AND short IN @lr_short
         AND langu = '3'
         AND begda <= @gs_period-keyda
         AND endda >= @gs_period-keyda.

      DATA(lt_ses) = lt_sm.
      DELETE lt_sm WHERE otype = 'SE'.
      DELETE lt_ses WHERE otype = 'SM'.
    ENDIF.

    IF i_smtxt IS NOT INITIAL.
      DATA(lr_stext) = VALUE rsdsselopt_t( ( sign = 'I' option = 'CP' low = |*{ i_smtxt }*| ) ).

      SELECT plvar, otype, objid FROM hrp1000
        INTO TABLE @lt_sm
       WHERE plvar = '01'
         AND otype = 'SM'
         AND stext IN @lr_stext
         AND langu = @sy-langu
         AND begda <= @gs_period-keyda
         AND endda >= @gs_period-keyda.
      IF sy-langu = 'E'.
        SELECT plvar, otype, objid FROM hrp9450
          APPENDING TABLE @lt_sm
         WHERE plvar = '01'
           AND otype = 'SM'
           AND ltext IN @lr_stext
           AND langu = 'E'
           AND begda <= @gs_period-keyda
           AND endda >= @gs_period-keyda.
      ENDIF.
      SORT lt_sm BY plvar otype objid.
      DELETE ADJACENT DUPLICATES FROM lt_sm COMPARING ALL FIELDS.
    ENDIF.

    IF lt_sm[] IS NOT INITIAL.
      SELECT a~plvar AS plvar, a~sclas AS otype, a~sobid AS objid FROM hrp1001 AS a
        INNER JOIN @lt_sm AS b
        ON a~objid = b~objid
        WHERE a~plvar = '01'
          AND a~otype = 'SM'
          AND a~rsign = 'B'
          AND a~relat = '514'
          AND a~istat = '1'
          AND a~sclas = 'SE'
          AND a~begda <= @gs_period-keyda
          AND a~endda >= @gs_period-keyda
         INTO TABLE @DATA(lt_se).
    ENDIF.

    et_selist = CORRESPONDING #( lt_se ).
    et_selist = CORRESPONDING #( BASE ( et_selist ) lt_ses ).
    SORT et_selist BY plvar otype objid.
    DELETE ADJACENT DUPLICATES FROM et_selist COMPARING ALL FIELDS.

  ENDMETHOD.


  METHOD GET_SE_LIST.

    CLEAR : et_detail[], et_selist[].

*KEY DATE
    get_key_date( i_peryr = i_peryr i_perid = i_perid ).

*소속 => SE
    IF i_oid IS NOT INITIAL.
      get_se_from_o( EXPORTING i_oid     = i_oid
                     IMPORTING et_selist = DATA(lt_se) ).
    ELSEIF i_cgid IS NOT INITIAL.
      get_se_from_cg( EXPORTING i_cgid    = i_cgid
                      IMPORTING et_selist = lt_se ).
    ELSEIF it_se IS NOT INITIAL.
      lt_se = it_se.
    ELSE.
*SM => SE
      get_se_from_sm( EXPORTING i_smsht   = i_smsht
                                i_smtxt   = i_smtxt
                      IMPORTING et_selist = lt_se ).
    ENDIF.

    CHECK lt_se[] IS NOT INITIAL.

*개설분반 필터
    check_se_hrp1739( EXPORTING it_se    = lt_se
                      IMPORTING et_sesme = DATA(lt_sesme) ).

    et_selist = VALUE #( FOR ls_sesm IN lt_sesme ( plvar = '01' otype = 'SE' objid = ls_sesm-objid ) ).
    SORT et_selist.
    DELETE ADJACENT DUPLICATES FROM et_selist COMPARING ALL FIELDS.

*SE 세부정보
    CHECK et_selist[] IS NOT INITIAL.
    se_detail( EXPORTING it_sesme  = lt_sesme
                         it_selist = et_selist
                         i_langu   = i_langu
               IMPORTING et_detail = et_detail ).


  ENDMETHOD.


  METHOD GET_SE_QUOTA_COUNT.

    DATA ls_cnt LIKE LINE OF et_cnt.
    DATA lr_regwin TYPE RANGE OF hrpad506-regwindow.

    CLEAR et_cnt.

    CHECK it_selist IS NOT INITIAL.

    CASE i_st_regwindow.
      WHEN 'G'.
        lr_regwin = VALUE #( ( sign = 'I' option = 'EQ' low = 'G' ) ).
      WHEN ''.
        lr_regwin = VALUE #( ( sign = 'I' option = 'EQ' low = '' ) ).
      WHEN OTHERS.
        lr_regwin = VALUE #( sign = 'I' option = 'EQ' ( low = '1' ) ( low = '2' ) ( low = '3' ) ( low = '4' ) ).
    ENDCASE.

    SELECT * FROM hrp9551
      INTO TABLE @DATA(lt_9551)
      FOR ALL ENTRIES IN @it_selist
      WHERE plvar = '01'
        AND otype = 'SE'
        AND istat = '1'
        AND objid = @it_selist-objid
        AND begda <= @i_keydt
        AND endda >= @i_keydt.
    SORT lt_9551 BY objid.

    IF i_quota_only IS INITIAL. "정원만
      IF i_real_506 IS NOT INITIAL.
        SELECT a~packnumber AS se_id, COUNT(*) AS cnt FROM hrpad506 AS a
          INNER JOIN @it_selist AS b
          ON a~packnumber = b~objid
          WHERE peryr = @i_peryr
            AND perid = @i_perid
            AND smstatus IN ('01','02','03')
            AND regwindow IN @lr_regwin
            GROUP BY packnumber
            INTO TABLE @DATA(lt_book_cnt).
        SORT lt_book_cnt BY se_id.
      ELSE.
        SELECT objid, book_cnt FROM hrp9550
          INTO TABLE @DATA(lt_9550)
         FOR ALL ENTRIES IN @it_selist
         WHERE plvar = '01'
           AND otype = 'SE'
           AND istat = '1'
           AND objid = @it_selist-objid
           AND begda <= @i_keydt
           AND endda >= @i_keydt.
        SORT lt_9550 BY objid.
      ENDIF.

      get_se_delay_count(
        EXPORTING
          i_peryr      = i_peryr
          i_perid      = i_perid
          it_selist    = it_selist
        IMPORTING
          et_delay_cnt = DATA(lt_delay)
      ).
    ENDIF.

    LOOP AT it_selist INTO DATA(ls_se).
      ls_cnt-se_id = ls_se-objid.

      READ TABLE lt_9551 INTO DATA(ls_9551) WITH KEY objid = ls_cnt-se_id BINARY SEARCH.
      IF sy-subrc = 0.
        CASE i_st_regwindow.
          WHEN '1'.
            ls_cnt-limit_kapz = ls_9551-book_kapz1_r.
          WHEN '2'.
            ls_cnt-limit_kapz = ls_9551-book_kapz2_r.
          WHEN '3'.
            ls_cnt-limit_kapz = ls_9551-book_kapz3_r.
          WHEN '4'.
            ls_cnt-limit_kapz = ls_9551-book_kapz4_r.
          WHEN 'G'.
            ls_cnt-limit_kapz = ls_9551-book_kapzg.
          WHEN OTHERS.
            ls_cnt-limit_kapz = ls_9551-book_kapz.
        ENDCASE.
      ENDIF.

      IF i_real_506 IS NOT INITIAL.
        READ TABLE lt_book_cnt INTO DATA(ls_book_cnt) WITH KEY se_id = ls_cnt-se_id BINARY SEARCH.
        IF sy-subrc = 0.
          ls_cnt-book_cnt = ls_book_cnt-cnt.
        ENDIF.
      ELSE.
        READ TABLE lt_9550 INTO DATA(ls_9550) WITH KEY objid = ls_cnt-se_id BINARY SEARCH.
        IF sy-subrc = 0.
          ls_cnt-book_cnt = ls_9550-book_cnt.
        ENDIF.
      ENDIF.

      READ TABLE lt_delay INTO DATA(ls_delay) WITH KEY se_id = ls_cnt-se_id BINARY SEARCH.
      IF sy-subrc = 0.
        ls_cnt-book_cnt = ls_cnt-book_cnt + ls_delay-cnt.
      ENDIF.

      APPEND ls_cnt TO et_cnt.
      CLEAR: ls_cnt.
    ENDLOOP.

    SORT et_cnt BY se_id.


  ENDMETHOD.


  METHOD GET_STGRP.

    CLEAR ev_regwindow.

    SELECT SINGLE * FROM hrp1705
      INTO @DATA(ls_p1705)
      WHERE plvar = '01'
        AND otype = 'ST'
        AND istat = '1'
        AND objid = @i_stid
        AND begda <= @i_keydt
        AND endda >= @i_keydt.

    IF ls_p1705-stgrp = '0003' AND ls_p1705-regwindow = 'G'.
      ev_regwindow = 'G'.
    ELSE.
      ev_regwindow = ls_p1705-regwindow.
    ENDIF.




  ENDMETHOD.


  METHOD MSG.

    CLEAR text.

    SELECT SINGLE text FROM t100
      INTO text
      WHERE arbgb = arbgb
        AND msgnr = msgnr.


  ENDMETHOD.


  METHOD OTR.

    DATA lv_alias TYPE sotr_alias.
    DATA lv_txt TYPE sotr_txt.
    DATA lv_v1 TYPE string.
    DATA lv_v2 TYPE string.

    lv_alias = alias.

    CLEAR atext.
    CALL FUNCTION 'SOTR_GET_TEXT_KEY'
      EXPORTING
        alias           = lv_alias
      IMPORTING
        e_text          = lv_txt
      EXCEPTIONS
        no_entry_found  = 1
        parameter_error = 2
        OTHERS          = 3.

    IF v1 IS NOT INITIAL.
      lv_v1 = v1.
      REPLACE ALL OCCURENCES OF '&1' IN lv_txt WITH lv_v1.
    ENDIF.
    IF v2 IS NOT INITIAL.
      lv_v2 = v2.
      REPLACE ALL OCCURENCES OF '&2' IN lv_txt WITH lv_v2.
    ENDIF.

    atext = lv_txt.


  ENDMETHOD.


  METHOD READ_HRP9550_COUNT.

    DATA: lv_otjid TYPE hrp9550-otjid.

    CONCATENATE 'SE' i_seid INTO lv_otjid.
    CONDENSE lv_otjid NO-GAPS.

    CLEAR r_cnt.
    SELECT SINGLE book_cnt FROM hrp9550
                             INTO (r_cnt)
                             WHERE otjid = lv_otjid
                             AND   plvar = '01'
                             AND   begda <= i_keydt
                             AND   endda >= i_keydt.

  ENDMETHOD.


  METHOD REBOOKED_LIST.

    DATA lt_stlist TYPE TABLE OF hrobject.
    DATA lt_sm_re TYPE TABLE OF hrobject.
    DATA ls_list TYPE zcmsk550.
    DATA ls_cnt TYPE zcmsk551.
    DATA lr_peryr TYPE RANGE OF piqperyr.
    DATA lr_perid TYPE RANGE OF piqperid.

    CLEAR : et_list[], et_cnt[].

    CHECK it_st[] IS NOT INITIAL.

    lt_stlist = it_st.
    SORT lt_stlist.
    DELETE ADJACENT DUPLICATES FROM lt_stlist COMPARING objid.

    IF i_peryr IS NOT INITIAL.
      lr_peryr = VALUE #( ( sign = 'I' option = 'EQ' low = i_peryr ) ).
    ENDIF.
    IF i_perid IS NOT INITIAL.
      lr_perid = VALUE #( ( sign = 'I' option = 'EQ' low = i_perid ) ).
    ENDIF.

*재이수 과목
    SELECT  a~objid, a~sobid, a~adatanr,
            b~smstatus, b~peryr, b~perid, b~id, b~packnumber, b~bookdate,
            b~reperyr, b~reperid, b~resmid, b~reid, b~repeatfg
        FROM hrp1001 AS a
   INNER JOIN hrpad506 AS b
      ON  a~adatanr = b~adatanr
      INTO TABLE @DATA(lt_506_re)
      FOR ALL ENTRIES IN @lt_stlist
    WHERE a~plvar = '01'
      AND a~otype = 'ST'
      AND a~objid = @lt_stlist-objid
      AND a~istat = '1'
      AND a~subty = 'A506'
      AND a~sclas = 'SM'
      AND b~smstatus IN ('1','2','3')
      AND b~peryr IN @lr_peryr
      AND b~perid IN @lr_perid.
    DELETE lt_506_re WHERE reperyr IS INITIAL AND reperid IS INITIAL AND resmid IS INITIAL.
    SORT lt_506_re BY objid.
    CHECK lt_506_re[] IS NOT INITIAL.

    IF i_only_ad506 IS NOT INITIAL.

    ENDIF.

*학번, 성명
    SELECT objid, short, stext FROM hrp1000
      INTO TABLE @DATA(lt_stno)
      FOR ALL ENTRIES IN @lt_stlist
      WHERE objid = @lt_stlist-objid
        AND plvar = '01'
        AND istat = '1'
        AND otype = 'ST'
        AND begda <= @sy-datum
        AND endda >= @sy-datum
        AND langu = @sy-langu.
    SORT lt_stno BY objid.

*학생 소속
    zcmcl000=>get_st_orgcd(
      EXPORTING
        it_stobj = lt_stlist
      IMPORTING
        et_storg = DATA(lt_org)
    ).

*재이수 요건 관리
    SELECT * FROM hrp9566
      INTO TABLE @DATA(lt_9566)
      WHERE plvar = '01'
        AND otype = 'O'
        AND istat = '1'
        AND begda <= @sy-datum
        AND endda >= @sy-datum.
    SORT lt_9566 BY objid.

    SELECT * FROM t7piqperiodt
      INTO TABLE @DATA(lt_perit)
      WHERE spras = @sy-langu.
    SORT lt_perit BY perid.

**원수강 정보
*    SELECT  a~objid, a~sobid, a~adatanr,
*            b~smstatus, b~peryr, b~perid, b~id, b~packnumber, b~bookdate
*        FROM hrp1001 AS a
*   INNER JOIN hrpad506 AS b
*      ON  a~adatanr = b~adatanr
*      INTO TABLE @DATA(lt_506)
*      FOR ALL ENTRIES IN @lt_506_re
*    WHERE a~plvar = '01'
*      AND a~otype = 'ST'
*      AND a~objid = @lt_506_re-objid
*      AND a~istat = '1'
*      AND a~subty = 'A506'
*      AND a~sclas = 'SM'
*      AND b~id = @lt_506_re-reid.
*    SORT lt_506 BY id.
*    CHECK lt_506[] IS NOT INITIAL.

*재이수 성적
    SELECT  a~modreg_id, a~agrid, b~gradescale, b~gradesym FROM piqdbagr_assignm AS a
       INNER JOIN piqdbagr_gen AS b
        ON a~agrid = b~agrid
      INTO TABLE @DATA(lt_grd)
      FOR ALL ENTRIES IN @lt_506_re
      WHERE a~modreg_id = @lt_506_re-reid.
    SORT lt_grd BY modreg_id.

*원수강 성적
    SELECT  a~modreg_id, a~agrid, b~gradescale, b~gradesym FROM piqdbagr_assignm AS a
       INNER JOIN piqdbagr_gen AS b
        ON a~agrid = b~agrid
      APPENDING TABLE @lt_grd
      FOR ALL ENTRIES IN @lt_506_re
      WHERE a~modreg_id = @lt_506_re-id.
    SORT lt_grd BY modreg_id.

*과목 SHORT, STEXT
    SELECT a~objid, a~short, a~stext FROM hrp1000 AS a
      INNER JOIN @lt_506_re AS b
      ON a~objid = b~sobid
      WHERE a~plvar = '01'
        AND a~otype = 'SM'
        AND a~istat = '1'
        AND a~begda <= b~bookdate
        AND a~endda >= b~bookdate
        AND a~langu = @sy-langu
      INTO TABLE @DATA(lt_1000).

    SELECT a~objid, a~short, a~stext FROM hrp1000 AS a
      INNER JOIN @lt_506_re AS b
      ON a~objid = b~resmid
      WHERE a~plvar = '01'
        AND a~otype = 'SM'
        AND a~istat = '1'
        AND a~begda <= b~bookdate
        AND a~endda >= b~bookdate
        AND a~langu = @sy-langu
      APPENDING TABLE @lt_1000.
    SORT lt_1000 BY objid.

*입학일자
    SELECT * FROM hrp9710
      INTO TABLE @DATA(lt_9710)
      FOR ALL ENTRIES IN @lt_stlist
    WHERE plvar = '01'
      AND otype = 'ST'
      AND istat = '1'
      AND objid = @lt_stlist-objid
      AND begda <= @sy-datum
      AND endda >= @sy-datum.
    SORT lt_9710 BY objid.

    LOOP AT lt_stlist INTO DATA(ls_stlist).

      READ TABLE lt_stno INTO DATA(ls_stno) WITH KEY objid = ls_stlist-objid BINARY SEARCH.

      READ TABLE lt_506_re WITH KEY objid = ls_stlist-objid BINARY SEARCH TRANSPORTING NO FIELDS.
      CHECK sy-subrc = 0.

      LOOP AT lt_506_re INTO DATA(ls_506_re) FROM sy-tabix.
        IF ls_506_re-objid <> ls_stlist-objid.
          EXIT.
        ENDIF.

        ls_list-st_id = ls_stlist-objid.
        ls_list-st_no = ls_stno-short.
        ls_list-st_name = ls_stno-stext.

        ls_list-reperyr = ls_506_re-reperyr.
        ls_list-reperid = ls_506_re-reperid.
        ls_list-resmid = ls_506_re-resmid.
        READ TABLE lt_perit INTO DATA(ls_perit) WITH KEY perid = ls_list-reperid BINARY SEARCH.
        IF sy-subrc = 0.
          ls_list-reperit = ls_perit-perit.
        ENDIF.
        READ TABLE lt_1000 INTO DATA(ls_1000) WITH KEY objid = ls_list-resmid BINARY SEARCH.
        IF sy-subrc = 0.
          ls_list-resm_short = ls_1000-short.
          ls_list-resm_stext = ls_1000-stext.
        ENDIF.

        READ TABLE lt_grd INTO DATA(ls_grd) WITH KEY modreg_id = ls_506_re-reid BINARY SEARCH.
        IF sy-subrc = 0.
          ls_list-regradescale = ls_grd-gradescale.
          ls_list-regradesym = ls_grd-gradesym.
        ENDIF.

        ls_list-peryr = ls_506_re-peryr.
        ls_list-perid = ls_506_re-perid.
        ls_list-smid = ls_506_re-sobid.
        READ TABLE lt_perit INTO ls_perit WITH KEY perid = ls_list-perid BINARY SEARCH.
        IF sy-subrc = 0.
          ls_list-perit = ls_perit-perit.
        ENDIF.
        READ TABLE lt_1000 INTO ls_1000 WITH KEY objid = ls_list-smid BINARY SEARCH.
        IF sy-subrc = 0.
          ls_list-sm_short = ls_1000-short.
          ls_list-sm_stext = ls_1000-stext.
        ENDIF.

        READ TABLE lt_grd INTO ls_grd WITH KEY modreg_id = ls_506_re-id BINARY SEARCH.
        IF sy-subrc = 0.
          ls_list-gradescale = ls_grd-gradescale.
          ls_list-gradesym = ls_grd-gradesym.
        ENDIF.

        APPEND ls_list TO et_list.
        CLEAR ls_list.

        CASE ls_506_re-perid.
          WHEN '010' OR '020'.
            ls_cnt-re_cnt_1020 = ls_cnt-re_cnt_1020 + 1.
            IF ls_506_re-repeatfg = 'X'.
              ls_cnt-re_cnt_repeatfg = ls_cnt-re_cnt_repeatfg + 1.
            ENDIF.
          WHEN '011' OR '021'.
            ls_cnt-re_cnt_1121 = ls_cnt-re_cnt_1121 + 1.
          WHEN OTHERS.
        ENDCASE.

        APPEND VALUE #( objid = ls_506_re-resmid ) TO lt_sm_re.
      ENDLOOP.

      READ TABLE lt_org INTO DATA(ls_org) WITH KEY st_id = ls_stlist-objid BINARY SEARCH.

*입학일
      READ TABLE lt_9710 INTO DATA(ls_9710) WITH KEY objid = ls_stlist-objid BINARY SEARCH.

      LOOP AT lt_9566 INTO DATA(ls_9566) WHERE objid = ls_org-org_id.
*        IF ls_9566-begda <= ls_9710-begda AND ls_9710-begda <= ls_9566-endda.
        ls_cnt-re_tot_cnt = ls_9566-re_tot_cnt.
        EXIT.
*        ENDIF.
      ENDLOOP.

      ls_cnt-st_id = ls_stlist-objid.
      ls_cnt-re_b_cnt = CONV i( lines( lt_sm_re ) ).  "재이수 횟수
      ls_cnt-re_b_cnt_t = |{ CONV i( ls_cnt-re_b_cnt ) } / { CONV i( ls_cnt-re_tot_cnt ) }|.  "재이수 횟수 Long

      DATA(lv_pcnt) = ls_cnt-re_tot_cnt - ls_cnt-re_cnt_repeatfg .  "재이수 가능 횟수
      IF lv_pcnt <= 0.
        ls_cnt-re_possb_cnt = 0.
      ELSE.
        ls_cnt-re_possb_cnt = lv_pcnt.
      ENDIF.

      SORT lt_sm_re.
      DELETE ADJACENT DUPLICATES FROM lt_sm_re COMPARING objid.
      ls_cnt-re_b_sm_cnt = CONV i( lines( lt_sm_re ) ). "재이수 과목수
      ls_cnt-re_b_sm_cnt_t = |{ CONV i( ls_cnt-re_b_sm_cnt ) } 과목|. "재이수 과목수

      APPEND ls_cnt TO et_cnt.
      CLEAR: ls_cnt, lt_sm_re, ls_org, ls_9710, ls_stno.
    ENDLOOP.

    SORT et_list BY st_id ASCENDING peryr DESCENDING perid DESCENDING sm_short ASCENDING.
    SORT et_cnt BY st_id.


  ENDMETHOD.


  METHOD RETURN_MSG.
    CLEAR rv_err.

    IF is_msg IS NOT INITIAL.
      IF i_mode = 'WISH'. "담아놓기
        CASE sy-langu.
          WHEN 'E'.
          WHEN OTHERS.
            FIND '수강신청' IN is_msg-message.
            IF sy-subrc = 0.
              REPLACE ALL OCCURRENCES OF '수강신청' IN is_msg-message WITH `담아놓기`.
            ENDIF.
        ENDCASE.
      ENDIF.

      is_msg-message = |[{ i_short }] { i_stext } - { is_msg-message }|.

      APPEND is_msg TO ct_msg.

      rv_err = 'X'.
    ENDIF.
  ENDMETHOD.


  METHOD SCHEDULE_TEXT.

    DATA lt_week TYPE TABLE OF stext.
    DATA lt_txt TYPE TABLE OF stext.
    DATA lv_time TYPE stext.

    CLEAR rv_txt.

    lt_week = VALUE #( ( 'MONDAY' ) ( 'TUESDAY' ) ( 'WEDNESDAY' ) ( 'THURSDAY' ) ( 'FRIDAY' ) ( 'SATURDAY' ) ( 'SUNDAY' ) ).

    LOOP AT lt_week INTO DATA(lv_day).

      ASSIGN COMPONENT lv_day OF STRUCTURE is_t1716 TO FIELD-SYMBOL(<fs>).
      CHECK sy-subrc = 0.

      IF <fs> IS NOT INITIAL.
        DATA(lv_day_v) = |zcmclk100a=>DAYS_{ lv_day }_{ i_langu }|.
        ASSIGN (lv_day_v) TO FIELD-SYMBOL(<fsv>).
        CHECK sy-subrc = 0.
        APPEND <fsv> TO lt_txt.
      ENDIF.
    ENDLOOP.

    CONCATENATE LINES OF lt_txt INTO DATA(lv_long) SEPARATED BY ','.
    lv_time = |{ is_t1716-beguz+0(2) }:{ is_t1716-beguz+2(2) }~{ is_t1716-enduz+0(2) }:{ is_t1716-enduz+2(2) }|.

    rv_txt = |{ lv_long } { lv_time }|.

    CLEAR : lt_txt, lv_long, lv_time.

  ENDMETHOD.


  METHOD SESSION_MANAGE.
    DATA: th_opcode(1) TYPE x.
    DATA ls_log TYPE zcmt2024_userlog.

    CONSTANTS: th_plugin_protocol_http  TYPE i VALUE 1,
               th_plugin_protocol_https TYPE i VALUE 2,
               opcode_usr_attr          LIKE th_opcode VALUE 5,
               opcode_delete_usr        LIKE th_opcode VALUE 25.

    DATA: my_opcode_usr_attr(1) TYPE x VALUE 5,
          my_user               TYPE usr41-termid,
          my_tid                TYPE usr41-termid,
          my_uid                TYPE usr41-termid.
    DATA: my_servername       TYPE msxxlist-name.
    DATA: sessions TYPE TABLE OF uinfo.
    DATA: logon_id TYPE  ssi_logon_id.
    DATA: lv_taskname TYPE string,
          lv_seqnr(1) TYPE n,
          lv_int      TYPE i.

*    " get terminal id of this session
*    CALL 'ThUsrInfo' ID 'OPCODE' FIELD my_opcode_usr_attr
*          ID 'TID' FIELD my_tid.                          "#EC CI_CCALL

    CALL 'ThUsrInfo' ID 'OPCODE' FIELD opcode_usr_attr
      ID 'TID' FIELD my_tid
      ID 'UID' FIELD my_uid.
**
**    " get name of this (local) application server
    CALL 'C_SAPGPARAM'   ID 'NAME' FIELD 'rdisp/myname'
                         ID 'VALUE' FIELD my_servername.  "#EC CI_CCALL

    SELECT SINGLE *
      INTO @DATA(ls_zcmt2024_user)
      FROM zcmt2024_user
     WHERE uname = @sy-uname
       AND datestamp = @sy-datum.
    IF sy-subrc = 0.
      IF ls_zcmt2024_user-host NE sy-host.

        CLEAR lv_seqnr.
        CALL FUNCTION 'QF05_RANDOM_INTEGER'
          EXPORTING
            ran_int_max   = 9
            ran_int_min   = 1
          IMPORTING
            ran_int       = lv_int
          EXCEPTIONS
            invalid_input = 1
            OTHERS        = 2.

        lv_seqnr = lv_int.
        CLEAR lv_taskname.
        CONCATENATE ls_zcmt2024_user-server_name '_' lv_seqnr INTO lv_taskname.

        CALL FUNCTION 'ZCMK_SESSION_DELETE' DESTINATION ls_zcmt2024_user-server_name
          STARTING NEW TASK lv_taskname " 'mytask'
          EXPORTING
            user            = sy-uname
            client          = sy-mandt
*           only_pooled_user = ' '
            tid             = ls_zcmt2024_user-terid
            loginid         = ls_zcmt2024_user-loginid
          EXCEPTIONS
            authority_error = 1
            OTHERS          = 2.

      ELSE.

        CALL FUNCTION 'ZCMK_SESSION_DELETE'
          EXPORTING
            user            = sy-uname
            client          = sy-mandt
*           only_pooled_user = ' '
            tid             = ls_zcmt2024_user-terid
            loginid         = ls_zcmt2024_user-loginid
          EXCEPTIONS
            authority_error = 1
            OTHERS          = 2.


      ENDIF.

*로그
      MOVE-CORRESPONDING ls_zcmt2024_user TO ls_log.
      ls_log-n_datum = sy-datum.
      ls_log-n_uname = sy-uname.
      ls_log-n_uzeit = sy-uzeit.
      ls_log-n_terid = my_tid.
      MODIFY zcmt2024_userlog FROM ls_log.

    ENDIF.

    CLEAR ls_zcmt2024_user.
    ls_zcmt2024_user-uname     = sy-uname.
    ls_zcmt2024_user-sysid     = sy-sysid.
    ls_zcmt2024_user-host      = sy-host.
    ls_zcmt2024_user-terid     = my_tid.
    ls_zcmt2024_user-loginid     = my_uid.
    ls_zcmt2024_user-server_name  = my_servername.
    ls_zcmt2024_user-datestamp    = sy-datum.
    ls_zcmt2024_user-timestamp    = sy-uzeit.

    MODIFY zcmt2024_user FROM ls_zcmt2024_user.
    COMMIT WORK.


  ENDMETHOD.


  METHOD SET_DELAY_SE.

    DATA ls_zcmtk210 TYPE zcmtk210.
    DATA lv_ran TYPE i.
    DATA lv_max TYPE i.
    DATA lv_min TYPE i.
    DATA lv_time TYPE sy-uzeit.

    r_now = 'X'.

    SELECT * FROM zcmt2018_sync
      INTO TABLE @DATA(lt_2018)
     WHERE peryr = @i_peryr
       AND perid = @i_perid
       AND begda <= @sy-datum
       AND endda >= @sy-datum
       AND smstatus = '04'
       AND active = 'X'.
    CHECK sy-subrc = 0.
    LOOP AT lt_2018 INTO DATA(ls_2018).
      IF ls_2018-begda && ls_2018-begtime <= sy-datum && sy-uzeit AND sy-datum && sy-uzeit <= ls_2018-endda && ls_2018-endtime.
        DATA(lv_ok) = 'X'.
        r_now = ''.
      ENDIF.
    ENDLOOP.
    CHECK lv_ok IS NOT INITIAL.

    lv_max = ls_2018-cycle_max * 60.
    lv_min = ls_2018-cycle_min * 60.

    CALL FUNCTION 'QF05_RANDOM_INTEGER'
      EXPORTING
        ran_int_max   = lv_max
        ran_int_min   = lv_min
      IMPORTING
        ran_int       = lv_ran
      EXCEPTIONS
        invalid_input = 1
        OTHERS        = 2.
    lv_time = sy-uzeit.
    ls_zcmtk210-tmstp = sy-datum && lv_time.

    ls_zcmtk210-peryr    = i_peryr.
    ls_zcmtk210-perid    = i_perid.
    ls_zcmtk210-se_id    = i_seid.
    ls_zcmtk210-st_id    = i_stid.
    ls_zcmtk210-sm_id    = i_smid.


    ls_zcmtk210-delay_begda = sy-datum.
    ls_zcmtk210-delay_begtm = lv_time + lv_ran.

    ls_zcmtk210-ernam    = sy-uname.
    ls_zcmtk210-erdat    = sy-datum.
    ls_zcmtk210-ertim    = lv_time.
    ls_zcmtk210-aenam    = sy-uname.
    ls_zcmtk210-aedat    = sy-datum.
    ls_zcmtk210-aetim    = lv_time.

    MODIFY zcmtk210 FROM ls_zcmtk210 .
    IF sy-subrc EQ 0.
      COMMIT WORK.

      CALL FUNCTION 'ZCM_BACKUP_ZCMTK210'
        EXPORTING
          is_data  = ls_zcmtk210
          iv_keydt = sy-datum
          iv_mode  = 'I'.
    ENDIF.

  ENDMETHOD.


  METHOD SET_MACRO_BLOCK.

    DATA ls_block TYPE zcmt2024_block.

    ls_block-stobj = i_stid.
    ls_block-block_date = sy-datum.
    ls_block-block_time = sy-uzeit + block_time.

    MODIFY zcmt2024_block FROM ls_block.
    COMMIT WORK.

  ENDMETHOD.


  METHOD SE_DETAIL.

    DATA lr_o TYPE RANGE OF hrobjid.
    DATA lt_detail TYPE TABLE OF zcmsk_course.
    DATA ls_detail TYPE zcmsk_course.
    DATA lt_txt TYPE TABLE OF ddtext.
    DATA lv_priox TYPE priox.
    DATA lt_sm_tmp TYPE tt_obj.
    DATA lt_sm TYPE TABLE OF hrobject.

    CLEAR et_detail[].
    CHECK it_sesme[] IS NOT INITIAL.

*SM => O
    SELECT otype, objid, sclas, sobid FROM hrp1001
      INTO TABLE @DATA(lt_smo)
      FOR ALL ENTRIES IN @it_sesme
     WHERE plvar = '01'
       AND otype = 'SM'
       AND objid = @it_sesme-sobid
       AND rsign = 'B'
       AND relat = '501'
       AND sclas = 'O'
       AND istat = '1'
       AND begda <= @gs_period-keyda
       AND endda >= @gs_period-keyda.
    SORT lt_smo BY otype objid sclas sobid.

    SELECT com_cd, com_nm, com_nm_en, org_cd, short, map_cd2 FROM zcmt0101
      INTO TABLE @DATA(lt_0101)
      WHERE grp_cd = '100'.
    SORT lt_0101 BY org_cd.

    lr_o = VALUE #( FOR ls_ooo IN lt_smo ( sign = 'I' option = 'EQ' low = ls_ooo-sobid ) ).
    SORT lr_o BY sign option low.
    DELETE ADJACENT DUPLICATES FROM lr_o COMPARING ALL FIELDS.

*O => ORG
    IF lt_smo IS NOT INITIAL.
      SELECT otype, objid, org FROM hrp9500
        INTO TABLE @DATA(lt_9500)
       WHERE plvar = '01'
         AND otype = 'O'
         AND objid IN @lr_o
         AND begda <= @gs_period-keyda
         AND endda >= @gs_period-keyda.
      SORT lt_9500 BY otype objid.
    ENDIF.

*학점
    SELECT otype, objid, cpopt, cpunit FROM hrp1741
      INTO TABLE @DATA(lt_p1741)
      FOR ALL ENTRIES IN @it_sesme
     WHERE plvar = '01'
       AND otype = 'SM'
       AND objid = @it_sesme-sobid
       AND begda <= @gs_period-keyda
       AND endda >= @gs_period-keyda.
    SORT lt_p1741 BY otype objid.

    SELECT objid, scaleid, scaleid_pf FROM hrp1710
      INTO TABLE @DATA(lt_p1710)
      FOR ALL ENTRIES IN @it_sesme
     WHERE plvar = '01'
       AND otype = 'SM'
       AND objid = @it_sesme-sobid
       AND begda <= @gs_period-keyda
       AND endda >= @gs_period-keyda.
    SORT lt_p1710 BY objid.


*E => G, P
    SELECT DISTINCT otype, objid, sclas, sobid FROM hrp1001
       INTO TABLE @DATA(lt_egp)
       FOR ALL ENTRIES IN @it_sesme
      WHERE plvar = '01'
        AND otype = 'E'
        AND objid = @it_sesme-sobid
        AND rsign = 'A'
        AND relat = '023'
        AND istat = '1'
        AND sclas IN ('G','P').
    SORT lt_egp BY otype objid sclas sobid.

*P TEXT
    SELECT DISTINCT a~pernr, a~begda, a~ename,
                    a~zztitl1,
                    concat( b~vorna, b~nachn ) AS ename_e FROM pa0001 AS a
       INNER JOIN pa0002 AS b
        ON b~pernr = a~pernr
       INNER JOIN @lt_egp AS c
        ON a~pernr = c~sobid
       AND c~sclas = 'P'
     WHERE b~begda <= a~begda
       AND b~endda >= a~begda
      INTO TABLE @DATA(lt_ename).
    SORT lt_ename BY pernr ASCENDING begda DESCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_ename COMPARING pernr begda.

*EVENT
    SELECT objid, tabnr FROM hrp1716
      INTO TABLE @DATA(lt_p1716)
      FOR ALL ENTRIES IN @it_sesme
     WHERE plvar = '01'
       AND otype = 'E'
       AND objid = @it_sesme-sobid.
    DELETE lt_p1716 WHERE tabnr = ''.
    SORT lt_p1716 BY objid.

    IF NOT lt_p1716[] IS INITIAL.
      SELECT * FROM hrt1716
         INTO TABLE @DATA(lt_t1716)
        FOR ALL ENTRIES IN @lt_p1716
       WHERE tabnr = @lt_p1716-tabnr.

      SORT lt_t1716 BY tabnr     ASCENDING
                       monday    DESCENDING
                       tuesday   DESCENDING
                       wednesday DESCENDING
                       thursday  DESCENDING
                       friday    DESCENDING
                       saturday  DESCENDING
                       sunday    DESCENDING
                       beguz     ASCENDING
                       enduz     ASCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_t1716 COMPARING ALL FIELDS.
    ENDIF.

*개설 시작일, 종료일
    SELECT objid, begda, endda, peryr, perid FROM hrp1739
      INTO TABLE @DATA(lt_1739)
        FOR ALL ENTRIES IN @it_sesme
        WHERE plvar = '01'
          AND otype = 'SE'
          AND objid = @it_sesme-objid
          AND peryr = @gs_period-peryr
          AND perid = @gs_period-perid.
    SORT lt_1739 BY objid.

*SE TEXT
    SELECT otype, objid, short, stext FROM hrp1000
      INTO TABLE @DATA(lt_1000)
      FOR ALL ENTRIES IN @it_sesme
      WHERE plvar = '01'
        AND otype = 'SE'
        AND objid = @it_sesme-objid
        AND istat = '1'
        AND begda <= @gs_period-keyda
        AND endda >= @gs_period-keyda
        AND langu = @i_langu.

*SM TEXT
    lt_sm_tmp = it_sesme.
    DELETE lt_sm_tmp WHERE sclas <> 'SM'.
    lt_sm = CORRESPONDING #( lt_sm_tmp MAPPING objid = sobid ).
    zcmclk100a=>sm_stext(
      EXPORTING
        it_sm   = lt_sm
        i_keydt = gs_period-keyda
      IMPORTING
        et_sm_stext = DATA(lt_sm_stext)
    ).

*O TEXT
    SELECT otype, objid, short, stext FROM hrp1000
      APPENDING TABLE @lt_1000
      WHERE plvar = '01'
        AND otype = 'O'
        AND objid IN @lr_o
        AND istat = '1'
        AND begda <= @gs_period-keyda
        AND endda >= @gs_period-keyda
        AND langu = @i_langu.

    SELECT otype, objid, short, stext FROM hrp1000
      APPENDING TABLE @lt_1000
      FOR ALL ENTRIES IN @lt_t1716
      WHERE plvar = '01'
        AND otype = 'G'
        AND objid = @lt_t1716-room_objid
        AND istat = '1'
        AND begda <= @gs_period-keyda
        AND endda >= @gs_period-keyda
        AND langu = @i_langu.
    SORT lt_1000 BY otype objid.

*    CALL FUNCTION 'HRIQ_WAITL_LIMITS_GET'
*      IMPORTING
*        ev_normal_priox = lv_priox
*      EXCEPTIONS
*        OTHERS          = 0.

    LOOP AT it_selist INTO DATA(ls_se).
      ls_detail-peryr = gs_period-peryr.
      ls_detail-perid = gs_period-perid.

      ls_detail-seobjid = ls_se-objid.

*SE SHORT, 시작일, 종료일
      READ TABLE lt_1000 INTO DATA(ls_1000) WITH KEY otype = 'SE' objid = ls_detail-seobjid BINARY SEARCH.
      IF sy-subrc = 0.
        ls_detail-seshort = ls_1000-short.
      ENDIF.
      READ TABLE lt_1739 INTO DATA(ls_1739) WITH KEY objid = ls_detail-seobjid BINARY SEARCH.
      IF sy-subrc = 0.
        ls_detail-begda = ls_1739-begda.
        ls_detail-endda = ls_1739-endda.
      ENDIF.

*SM SHORT, STEXT, 학점, UNIT
      READ TABLE it_sesme INTO DATA(ls_sesme) WITH KEY otype = 'SE' objid = ls_detail-seobjid sclas = 'SM' BINARY SEARCH.
      IF sy-subrc = 0.
        ls_detail-smobjid = ls_sesme-sobid.

        READ TABLE lt_1000 INTO ls_1000 WITH KEY otype = 'SM' objid = ls_detail-smobjid BINARY SEARCH.
        IF sy-subrc = 0.
          ls_detail-smshort = ls_1000-short.
        ENDIF.

        READ TABLE lt_sm_stext INTO DATA(ls_sm_stext) WITH KEY objid = ls_detail-smobjid BINARY SEARCH.
        IF sy-subrc = 0.
          ls_detail-smshort = ls_sm_stext-short.
          ls_detail-smstext = ls_sm_stext-stext.
        ENDIF.

        READ TABLE lt_p1741 INTO DATA(ls_p1741) WITH KEY otype = 'SM' objid = ls_detail-smobjid BINARY SEARCH.
        IF sy-subrc = 0.
          ls_detail-cpopt = ls_p1741-cpopt.
          ls_detail-cpunit = ls_p1741-cpunit.
        ENDIF.
        READ TABLE lt_p1710 INTO DATA(ls_p1710) WITH KEY objid = ls_detail-smobjid BINARY SEARCH.
        IF sy-subrc = 0.
          ls_detail-scaleid = ls_p1710-scaleid.
        ENDIF.

*소속
        READ TABLE lt_smo INTO DATA(ls_smo) WITH KEY otype = 'SM' objid = ls_detail-smobjid sclas = 'O' BINARY SEARCH.
        IF sy-subrc = 0.
          ls_detail-oobjid = ls_smo-sobid.

          READ TABLE lt_9500 INTO DATA(ls_9500) WITH KEY otype = 'O' objid = ls_detail-oobjid BINARY SEARCH.
          IF sy-subrc = 0.
            ls_detail-orgcd = ls_9500-org.
            READ TABLE lt_0101 INTO DATA(ls_0101) WITH KEY org_cd = ls_detail-orgcd BINARY SEARCH.
            IF sy-subrc = 0.
              ls_detail-orgid = ls_0101-map_cd2.
              CASE i_langu.
                WHEN 'E'.
                  ls_detail-orgtxt = ls_0101-com_nm_en.
                WHEN OTHERS.
                  ls_detail-orgtxt = ls_0101-com_nm.
              ENDCASE.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

*강의실, 교수
      READ TABLE it_sesme INTO ls_sesme WITH KEY otype = 'SE' objid = ls_detail-seobjid sclas = 'E' BINARY SEARCH.
      IF sy-subrc = 0.
        ls_detail-eobjid = ls_sesme-sobid.

        READ TABLE lt_egp INTO DATA(ls_egp) WITH KEY  otype = 'E' objid = ls_detail-eobjid sclas = 'G' BINARY SEARCH.
        IF sy-subrc = 0.
          ls_detail-gobjid = ls_egp-sobid.
          READ TABLE lt_1000 INTO ls_1000 WITH KEY otype = 'G' objid = ls_detail-gobjid BINARY SEARCH.
          IF sy-subrc = 0.
            ls_detail-gshort = ls_1000-short.
          ENDIF.
        ENDIF.
        READ TABLE lt_egp INTO ls_egp WITH KEY  otype = 'E' objid = ls_detail-eobjid sclas = 'P' BINARY SEARCH.
        IF sy-subrc = 0.
          ls_detail-pobjid = ls_egp-sobid.

          READ TABLE lt_ename INTO DATA(ls_ename) WITH KEY pernr = ls_detail-pobjid BINARY SEARCH.
          IF sy-subrc = 0.
            CASE i_langu.
              WHEN 'E'.
                ls_detail-ename = ls_ename-ename_e.
              WHEN OTHERS.
                ls_detail-ename = ls_ename-ename.
            ENDCASE.
          ENDIF.
        ENDIF.

*강의시간
        READ TABLE lt_p1716 INTO DATA(ls_p1716) WITH KEY objid = ls_detail-eobjid BINARY SEARCH.
        IF sy-subrc = 0.
          READ TABLE lt_t1716 WITH KEY tabnr = ls_p1716-tabnr BINARY SEARCH TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            LOOP AT lt_t1716 INTO DATA(ls_t1716) FROM sy-tabix.
              IF ls_t1716-tabnr <> ls_p1716-tabnr.
                EXIT.
              ENDIF.
              IF ls_t1716-beguz+0(2) = '00' OR ls_t1716-beguz+0(2) = '24' OR ls_t1716-enduz+0(2) = '00' OR ls_t1716-enduz+0(2) = '24'.
                CONTINUE.
              ENDIF.

              APPEND schedule_text( EXPORTING is_t1716 = ls_t1716 i_langu = i_langu ) TO lt_txt.
            ENDLOOP.

            CONCATENATE LINES OF lt_txt INTO ls_detail-time_place SEPARATED BY ` / `.
            CLEAR lt_txt.
          ENDIF.
        ENDIF.
      ENDIF.

      IF ls_detail-gshort IS NOT INITIAL.
        ls_detail-time_place = |{ ls_detail-time_place } [{ ls_detail-gshort }]|.
      ENDIF.
      ls_detail-priox = '50'.
      ls_detail-norm_val = cl_hrpiq00scale_base=>c_norm_value_null.


      APPEND ls_detail TO lt_detail.
      CLEAR: ls_detail.
    ENDLOOP.

    et_detail = lt_detail.

  ENDMETHOD.


  METHOD SE_LOCK.

    DATA lv_t1 TYPE sy-uzeit.
    DATA lv_qtt TYPE sy-uzeit.
    DATA lv_do_cnt TYPE i.
    DATA ls_ret TYPE zcmt2024_retlock.

    CLEAR: es_msg, rv_err.

    SELECT SINGLE do_cnt, do_cnt_sec FROM zcmtk222
      INTO ( @DATA(lv_do), @DATA(lv_do_cnt_sec) ).
    IF lv_do IS INITIAL.
      lv_do = 3.
    ENDIF.

    CLEAR lv_do_cnt.

    DO lv_do TIMES.
      lv_do_cnt = lv_do_cnt + 1.
      CALL FUNCTION 'ENQUEUE_EZCMK100'
        EXPORTING
          mode_hrikey    = 'E'
          mandt          = sy-mandt
          plvar          = '01'
          otype          = 'SE'
          objid          = i_seid
          _collect       = ''
          _scope         = '1'
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.

      IF sy-subrc = 0.
        ls_ret-stobj = i_stid.
        ls_ret-sdate = sy-datum.
        ls_ret-uzeit = sy-uzeit.
        ls_ret-uname = sy-uname.
        ls_ret-do_cnt = lv_do_cnt.
        ls_ret-mtype = 'S'.
        GET TIME STAMP FIELD ls_ret-stime.
        MODIFY zcmt2024_retlock FROM ls_ret.

        RETURN.
      ENDIF.

      IF lv_do_cnt_sec IS NOT INITIAL.
        WAIT UP TO lv_do_cnt_sec SECONDS.
      ENDIF.

      zcmclk100a=>check_se_quota(
        EXPORTING
          i_st_regwindow = i_st_regwindow
          i_keydt        = i_keydt
          i_peryr        = i_peryr
          i_perid        = i_perid
          i_se           = i_seid
        IMPORTING
          es_msg         = DATA(ls_msg)
      ).
      IF ls_msg IS NOT INITIAL.
        es_msg = ls_msg.
        RETURN.
      ENDIF.
*

    ENDDO.

    es_msg-type = 'E'.
    es_msg-message = |{ zcmclk100a=>msg( arbgb = 'ZMCCM01' msgnr = '556' ) }  |.

    CLEAR ls_ret.
    ls_ret-stobj = i_stid.
    ls_ret-sdate = sy-datum.
    ls_ret-uzeit = sy-uzeit.
    ls_ret-uname = sy-uname.
    ls_ret-do_cnt = lv_do_cnt.
    ls_ret-mtype = 'E'.
    GET TIME STAMP FIELD ls_ret-stime.
    MODIFY zcmt2024_retlock FROM ls_ret.
    COMMIT WORK.

  ENDMETHOD.


  METHOD SE_LOCK_LOG.

    DATA ls_zcmt2024_lockchk TYPE zcmt2024_lockchk.

    GET TIME STAMP FIELD ls_zcmt2024_lockchk-stime.

    ls_zcmt2024_lockchk-peryr = i_peryr.
    ls_zcmt2024_lockchk-perid = i_perid.
    ls_zcmt2024_lockchk-stobj = i_stid.
    ls_zcmt2024_lockchk-smobj = i_smid.
    ls_zcmt2024_lockchk-seobj = i_seid.
    ls_zcmt2024_lockchk-sdate = sy-datum.
    ls_zcmt2024_lockchk-uzeit = sy-uzeit.
    ls_zcmt2024_lockchk-uname = sy-uname.
    ls_zcmt2024_lockchk-message = zcmclk100a=>msg( arbgb = 'ZMCCM01' msgnr = '556' ).
    ls_zcmt2024_lockchk-type = 'E'.

    MODIFY zcmt2024_lockchk FROM ls_zcmt2024_lockchk.

  ENDMETHOD.


  METHOD SE_UNLOCK.

  CALL FUNCTION 'DEQUEUE_ALL'.

  ENDMETHOD.


  METHOD SM_STEXT.

    DATA lv_smt TYPE string.
    DATA ls_sm_stext LIKE LINE OF et_sm_stext.

    CLEAR et_sm_stext.

    CASE i_langu.
      WHEN 'E'.

        SELECT a~objid, a~short, a~stext, b~ltext FROM hrp1000 AS a
          INNER JOIN hrp9450 AS b
          ON a~objid = b~objid
          INTO TABLE @DATA(lt_sm_e)
        FOR ALL ENTRIES IN @it_sm
       WHERE a~plvar = '01'
         AND a~otype = 'SM'
         AND a~objid = @it_sm-objid
         AND a~langu = 'E'
         AND a~begda <= @i_keydt
         AND a~endda >= @i_keydt
         AND b~plvar = '01'
         AND b~otype = 'SM'
         AND b~langu = 'E'
         AND b~begda <= @i_keydt
         AND b~endda >= @i_keydt.
        LOOP AT lt_sm_e INTO DATA(ls_sm_e).

          ls_sm_stext-objid = ls_sm_e-objid.
          ls_sm_stext-short = ls_sm_e-short.

          lv_smt = ls_sm_e-stext && '*'.
          IF ls_sm_e-ltext CP lv_smt.
            ls_sm_stext-stext = ls_sm_e-ltext.
          ELSE.
            ls_sm_stext-stext = ls_sm_e-stext.
          ENDIF.
          APPEND ls_sm_stext TO et_sm_stext.
          CLEAR: ls_sm_stext.
        ENDLOOP.

      WHEN OTHERS.

        SELECT objid, short, stext FROM hrp1000
          INTO CORRESPONDING FIELDS OF TABLE @et_sm_stext
        FOR ALL ENTRIES IN @it_sm
       WHERE plvar = '01'
         AND otype = 'SM'
         AND objid = @it_sm-objid
         AND langu = '3'
         AND begda <= @i_keydt
         AND endda >= @i_keydt.
    ENDCASE.

    SORT et_sm_stext BY objid.

  ENDMETHOD.


  METHOD TIMELIMIT_TO_TEXT.

    CLEAR rv_msg.

    IF iv_tlt IS INITIAL.
      CASE is_time-ca_timelimit.
        WHEN '0300'.
          DATA(lv_tit) = zcmclk100a=>otr( 'ZDCM05/TX10000071' ).
        WHEN '0310'.
          lv_tit = zcmclk100a=>otr( 'ZDCM05/TX10000072' ).
        WHEN '0320'.
          lv_tit = zcmclk100a=>otr( 'ZDCM05/TX10000073' ).
        WHEN '0330'.
          lv_tit = zcmclk100a=>otr( 'ZDCM05/TX10000074' ).
      ENDCASE.
    ENDIF.

    rv_msg = |{ is_time-ca_lbegda(4) }.{ is_time-ca_lbegda+4(2) }.{ is_time-ca_lbegda+6(2) } { is_time-ca_lbegtime(2) }:{ is_time-ca_lbegtime+2(2) }|.
    rv_msg = |{ rv_msg } ~ { is_time-ca_lendda(4) }.{ is_time-ca_lendda+4(2) }.{ is_time-ca_lendda+6(2) } { is_time-ca_lendtime(2) }:{ is_time-ca_lendtime+2(2) }|.

    rv_msg = |{ lv_tit } : { rv_msg }|.


  ENDMETHOD.
ENDCLASS.
