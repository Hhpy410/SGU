*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_T01
*&---------------------------------------------------------------------*
TYPE-POOLS: slis, vrm.
CONSTANTS: gc_set    TYPE c VALUE 'X'.
CONSTANTS: gc_extension   TYPE i VALUE 3000.  "Docking size

TABLES : hrp1000, hrp9530, sscrfields, zxit0010.
DATA : gt_authobj  LIKE hrview    OCCURS 0 WITH HEADER LINE.
DATA: gv_username LIKE t527x-orgtx.
DATA: BEGIN OF gt_data OCCURS 0,
        orgcd         LIKE hrp9500-org,
        orgcx         LIKE hrp1000-stext,
        objid         LIKE hrp1000-objid,
        short         LIKE hrp1000-short,
        stext         LIKE hrp1000-stext,
        sc1tx         LIKE hrp1000-short,
        sc2tx         LIKE hrp1000-short,
        sc3tx         LIKE hrp1000-short,
        sc1id         LIKE hrp1000-objid,
        sc2id         LIKE hrp1000-objid,
        sc3id         LIKE hrp1000-objid,
        stscd         LIKE hrp9530-sts_cd,
        stat2         LIKE hrp1000-stext,
        namzu         LIKE hrp1702-namzu,
        titel         LIKE hrp1702-titel,
        natio         LIKE hrp1702-natio,
        apply_qual_cd LIKE hrp9710-apply_qual_cd,
        regwindow     LIKE hrp1705-regwindow,
        regsemstr     LIKE hrp1705-regsemstr,
        book_cdt      LIKE hrp1705-book_cdt,
        regi_cdt      LIKE hrp1705-book_cdt, "zcmt2040-status2, "학점등록:2019.09.03
*
        peryr         LIKE hrpad506-peryr,
        perid         LIKE hrpad506-perid,
        packnumber    LIKE hrpad506-packnumber,
        smobjid       LIKE zcmscourse-smobjid,
        smshort       LIKE zcmscourse-smshort,
        smstext       LIKE zcmscourse-smstext,
        cpattemp      LIKE hrpad506-cpattemp,
        cufg          LIKE zcmscourse-cufg,
        smstatus      LIKE hrpad506-smstatus,
        scaleid       LIKE hrp1710-scaleid,
        alt_scaleid   LIKE hrpad506-alt_scaleid,
        gradesym      LIKE piqdbagr_gen-gradesym,
        grade         LIKE piqdbagr_gen-grade,
        gradescale    LIKE piqdbagr_gen-gradescale,
        earn_crd      LIKE hrp9565-earn_crd,
        cgpa          LIKE hrp9565-cgpa,
        category      LIKE hrp1746-category,
        modrepeattype LIKE hrp1746-modrepeattype,
        transferflag  LIKE hrpad506-transferflag,
        lockflag      LIKE hrpad506-lockflag, "변경잠금: 2019.09.09
        agrnotrated   LIKE piqdbagr_gen-agrnotrated,
        bookdate      LIKE hrpad506-bookdate,
        booktime      LIKE hrpad506-booktime,
        book_cnt      TYPE i,
*
        fg_zeroc      TYPE i, "Sum
        fg_trans      LIKE hrp1705-book_cdt, "Sum
        fg_cexcn      LIKE hrp1705-book_cdt, "Sum
        fg_cu         LIKE hrp1705-book_cdt, "Sum
        fg_dummy      LIKE hrp1705-book_cdt, "Sum
*
        aedtm         LIKE hrp1001-aedtm,
        uname         LIKE hrp1001-uname,
        pernr         LIKE pa0001-pernr,
        id            LIKE hrpad506-id,
        agrid         LIKE piqdbagr_assignm-agrid,
        sobid         LIKE piqdbagr_assignm-sobid, "SM
*
        objid1        LIKE hrp1000-objid, "대체과목
        objid2        LIKE hrp1000-objid,
        objid3        LIKE hrp1000-objid,
        objid4        LIKE hrp1000-objid,
        objid5        LIKE hrp1000-objid,
*
        retake(1)     TYPE c,
        pexct(1)      TYPE c,
*(재이수횟수관련 로직변경: 2020.08.11 김상현
        session       TYPE i, "학기당
        module        TYPE i, "과목당
        total12       TYPE i, "정규합산(추가함)
*)
        2peryr        LIKE hrpad506-peryr,
        2perid        LIKE hrpad506-perid,
        2smobjid      LIKE zcmscourse-smobjid,
        2smshort      LIKE zcmscourse-smshort,
        2smstext      LIKE zcmscourse-smstext,
        2cpattemp     LIKE hrpad506-cpattemp,
        2gradesym     LIKE piqdbagr_gen-gradesym,
        2grade        LIKE piqdbagr_gen-grade,
        2gradescale   LIKE piqdbagr_gen-gradescale,
        2transferflag LIKE hrpad506-transferflag,
        2agrnotrated  LIKE piqdbagr_gen-agrnotrated,
*
        email         LIKE zcms0640-email, "추가함
        cell          LIKE zcms0640-cell,  "추가함
*
        type          LIKE zcmt9902-type,
        message       LIKE zcmt9902-message,
        bapiret2      TYPE bapiret2_tab, "추가함
        celltab       TYPE lvc_t_styl,
      END OF gt_data.

DATA: gt_code LIKE zcmt0101 OCCURS 0 WITH HEADER LINE.
DATA: BEGIN OF gt_rule OCCURS 0,
        orgcd      LIKE hrp9500-org, "소속
        module     TYPE i,           "SM4:과목당 허용수
        gradesym   TYPE piqgradesym, "SM5:가능성적
        gradescale TYPE piqscale_id, "SM6:스케일(허용성적)
        session    TYPE i,           "ST1:학기당 허용수
        peryr      TYPE piqperyr,    "ST2:허용수 시작년도
        method(1)  TYPE c,           "ST3:처리방법(H:높은,F:최종)
        notallow1  TYPE string,      "이전불가능성적
        notallow2  TYPE string,      "신규불가능성적
        regular    TYPE i,           "정규학기학점
        season     TYPE i,           "계절학기학점
        presubj    TYPE c,           "선수과목적용
        timedup    TYPE c,           "시간중복금지
      END OF gt_rule.

DATA: BEGIN OF gt_stno OCCURS 0,
        objid LIKE hrp1000-objid,
        short LIKE hrp1000-short,
        stext LIKE hrp1000-stext,
        stscd LIKE hrp9530-sts_cd,
        orgeh LIKE hrp1001-objid,
        sobid LIKE hrp1001-sobid,
        orgcd LIKE hrp9500-org,
        orgcx LIKE hrp1000-stext,
      END OF gt_stno.

*DATA: BEGIN OF gt_reno OCCURS 0,
*        objid  TYPE hrobjid,
*        module TYPE hrobjid,
*        cnt    TYPE i,
*      END OF gt_reno.

DATA: BEGIN OF gt_sugang OCCURS 0,
        objid      TYPE hrobjid,
        packnumber TYPE hrobjid,
        sobid      TYPE sobid,
      END OF gt_sugang.

DATA: BEGIN OF gt_sum OCCURS 0,
        objid    TYPE hrobjid,
        cpattemp TYPE piqcpattemp,
        book_cnt TYPE i,
        fg_zeroc TYPE i, "Sum
        fg_trans LIKE hrp1705-book_cdt, "Sum
        fg_cexcn LIKE hrp1705-book_cdt, "Sum
        fg_cu    LIKE hrp1705-book_cdt, "Sum
        fg_dummy LIKE hrp1705-book_cdt, "Sum
      END OF gt_sum.

DATA: BEGIN OF gt_yuye OCCURS 0,
        objid      TYPE hrobjid,
        peryr      TYPE piqperyr,
        perid      TYPE piqperid,
        warning_cd LIKE hrp9565-warning_cd,
      END OF gt_yuye.

DATA: BEGIN OF gt_time OCCURS 0,
        objid      TYPE hrobjid,
        packnumber LIKE hrpad506-packnumber,
        beguz      LIKE hrt1716-beguz,
        enduz      LIKE hrt1716-enduz,
        monday     LIKE hrt1716-monday,
        tuesday    LIKE hrt1716-tuesday,
        wednesday  LIKE hrt1716-wednesday,
        thursday   LIKE hrt1716-thursday,
        friday     LIKE hrt1716-friday,
        saturday   LIKE hrt1716-saturday,
        sunday     LIKE hrt1716-sunday,
        timedup    TYPE c,
      END OF gt_time.

DATA: BEGIN OF gt_stat OCCURS 0,
        check   TYPE c,
        type    LIKE zcmt9902-type,
        message LIKE zcmt9902-message,
        count   TYPE i,
      END OF gt_stat.

DATA: BEGIN OF gt_stat2 OCCURS 0,
        objid LIKE hrp1000-objid,
        seqnr LIKE hrp1000-seqnr,
        short LIKE hrp1000-short,
        stext LIKE hrp1000-stext,
      END OF gt_stat2.

DATA: BEGIN OF dat OCCURS 0,
        cot TYPE string,
      END OF dat.

DATA: gv_keyda TYPE datum,
      gx_keyda TYPE datum,
      gv_orgcd LIKE hrp9500-org.
DATA: gt_orgeh  TYPE RANGE OF hrobjid          WITH HEADER LINE. "소속학과
DATA: gt_stobj  TYPE RANGE OF hrobjid          WITH HEADER LINE. "대상학생
DATA: gt_smobj  TYPE RANGE OF hrobjid          WITH HEADER LINE. "대상과목(재이수)
DATA: gt_stru   LIKE qcat_stru        OCCURS 0 WITH HEADER LINE. "하위소속
DATA: s_sobid   TYPE RANGE OF sobid            WITH HEADER LINE. "하위소속

DATA: gt_copy LIKE gt_data OCCURS 0 WITH HEADER LINE.
DATA: gs_bapiret2 TYPE bapiret2.

DATA: gt_acwk   LIKE gt_data          OCCURS 0 WITH HEADER LINE. "이수과목(과거)
DATA: gt_dupl   LIKE gt_time          OCCURS 0 WITH HEADER LINE. "시간중복
DATA: gt_evob   LIKE zcmscourse       OCCURS 0 WITH HEADER LINE. "개설과목
DATA: gt_1000   LIKE hrp1000          OCCURS 0 WITH HEADER LINE. "과목코드
DATA: gt_101a   LIKE hrp1001          OCCURS 0 WITH HEADER LINE. "과목정보(선수)
DATA: gt_101b   LIKE hrp1001          OCCURS 0 WITH HEADER LINE. "과목정보(대체,선택)
DATA: gt_1746   LIKE hrp1746          OCCURS 0 WITH HEADER LINE. "카테고리
DATA: gt_1710   LIKE hrp1710          OCCURS 0 WITH HEADER LINE. "과목평가
DATA: gt_1716   LIKE hrt1716          OCCURS 0 WITH HEADER LINE. "분반일정
DATA: gt_1702   LIKE hrp1702          OCCURS 0 WITH HEADER LINE. "개인정보
DATA: gt_1705   LIKE hrp1705          OCCURS 0 WITH HEADER LINE. "수강학점(학부,정통대)
DATA: gt_2040   LIKE zcmt2040         OCCURS 0 WITH HEADER LINE. "학점등록: 2019.09.03
DATA: gt_9550   LIKE hrp9550          OCCURS 0 WITH HEADER LINE. "수강정보
DATA: gt_9565   LIKE hrp9565          OCCURS 0 WITH HEADER LINE. "성적집계
DATA: gt_9710   LIKE hrp9710          OCCURS 0 WITH HEADER LINE. "입학정보
DATA: gt_recs   TYPE piqdbcmprrecords OCCURS 0 WITH HEADER LINE. "졸업예정
DATA: gt_pgen   LIKE piqdbagr_gen     OCCURS 0 WITH HEADER LINE. "과목성적
DATA: gt_pa20   LIKE pa0001           OCCURS 0 WITH HEADER LINE. "처리사번
DATA: gt_majr   LIKE zcmsc            OCCURS 0 WITH HEADER LINE. "학생전공
DATA: gt_addr   LIKE zcms0640         OCCURS 0 WITH HEADER LINE. "학생주소

*DATA: gx_9562   LIKE zcmt9562         OCCURS 0 WITH HEADER LINE. "재이수탭(전체)
DATA: BEGIN OF gt_506_re OCCURS 0,
        objid   TYPE hrobjid,
*        adatanr TYPE hrpad506-adatanr,
        peryr   TYPE hrpad506-peryr,
        perid   TYPE hrpad506-perid,
        sm_id   TYPE sobid,
        reperyr TYPE hrpad506-reperyr,
        reperid TYPE hrpad506-reperid,
        resmid  TYPE hrpad506-resmid,
        no_cnt  TYPE hrpad506-repeatfg,
      END OF gt_506_re.

*(재이수횟수관련 로직변경: 2020.08.11 김상현
*DATA: gt_9562   LIKE zcmt9562        OCCURS 0 WITH HEADER LINE. "재이수탭(현재)
DATA: BEGIN OF gt_506_re_cur OCCURS 0.
        INCLUDE STRUCTURE gt_506_re.
DATA:   session TYPE i, "학기당
        module  TYPE i, "과목당
        total12 TYPE i, "정규합산(추가함)
      END OF gt_506_re_cur.
*)

DATA: gv_garbage TYPE string.
DATA: gv_keywd TYPE stext.
DATA: gv_msg   TYPE string.
DATA: z_answer,
      z_return,
      z_text(100),
      l_message(100).
DATA: gv_userlev TYPE c. "A:관리자,R:학사지원팀,G:대학원행정팀,U:학부행정팀

DATA: session_name TYPE string.
DATA: bdcdata LIKE bdcdata OCCURS 0 WITH HEADER LINE.
DATA: messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.

*(
DATA: repid LIKE sy-repid.
DATA: file_name LIKE sapb-sapfiles,
      file_type LIKE bdn_con-mimetype.
DATA: docking           TYPE REF TO cl_gui_docking_container,
      url               TYPE cndp_url,
      picture_control_1 TYPE REF TO cl_gui_picture.
*)

DATA: gt_cexcn  TYPE RANGE OF hrobjid WITH HEADER LINE. "초과제외과목: 2019.03.07


TYPES: BEGIN OF ty_cancel_course.
TYPES:
  peryr         LIKE zcmt2018_sync-peryr,
  perid         LIKE zcmt2018_sync-perid,
  smstatus      LIKE zcmt2018_sync-smstatus,
  smstatust     LIKE zcmt2018_sync-smstatust,
  smstatusx(20),
*  timelimit      LIKE zcmt2018_sync-timelimit,
*  timelimitx(20),

  active        LIKE zcmt2018_sync-active,
  status        LIKE icon-name, "상태
  statux(20)    TYPE c,         "상태구분

  begda         LIKE zcmt2018_sync-begda,
  begtime       LIKE zcmt2018_sync-begtime,
  endda         LIKE zcmt2018_sync-endda,
  endtime       LIKE zcmt2018_sync-endtime,
  cycle_min     LIKE zcmt2018_sync-cycle_min,
  cycle_max     LIKE zcmt2018_sync-cycle_max,
  note          LIKE zcmt2018_sync-note,      "비고
  sys_message   LIKE zcmt2018_sync-sys_message,

  ernam         LIKE zcmt2018_sync-ernam,
  erdat         LIKE zcmt2018_sync-erdat,
  ertim         LIKE zcmt2018_sync-ertim,

  aenam         LIKE zcmt2018_sync-aenam,
  aedat         LIKE zcmt2018_sync-aedat,
  aetim         LIKE zcmt2018_sync-aetim,

  t_color       TYPE lvc_t_scol,
  celltab       TYPE lvc_t_styl,
  t_dropdown    TYPE salv_t_int4_column,

  END OF ty_cancel_course.


DATA: gv_begda TYPE datum,
      gv_endda TYPE datum.
DATA gs_timelimits TYPE piqtimelimits.
