*&---------------------------------------------------------------------*
*&  Include           MZCMR5060TOP
*&---------------------------------------------------------------------*
TABLES: zcmt0501,hrp9540,hrp9580,zcmt9590,cmacbpst,ztrtgwhdr,hrp9600 .

TYPE-POOLS: zcm01, vrm.
DATA: lcl_common TYPE REF TO zcl_wd_common.

DATA: gt_authobj LIKE hrview OCCURS 0 WITH HEADER LINE.

DATA: gv_begda TYPE  sy-datum,
      gv_endda TYPE  sy-datum.
DATA: gv_same(1) .
*
DATA : gv_orgcd LIKE zcmt0700-orgcd .

DATA: gv_yeartxt LIKE sy-msgv1,
      gv_sesstxt LIKE sy-msgv1.
*
DATA : BEGIN OF gt_error OCCURS 0 ,
         code1(20),
         code2(20),
         etext(100),
       END OF gt_error .
*
DATA: gt_qcat LIKE qcat_stru OCCURS 0 WITH HEADER LINE .
*
DATA: gt_stru LIKE TABLE OF qcat_stru WITH HEADER LINE.

DATA: gt_zcmt0700 LIKE zcmt0700 OCCURS 0 WITH HEADER LINE .
*
DATA: gv_zblart LIKE hrp9580-zblart VALUE 'DG' .
DATA: gv_bperyr TYPE piqperyr,      "이전학년
      gv_bperid TYPE piqperid.      "이전학년
*
DATA: BEGIN OF gt_data  OCCURS 0,
        objid LIKE hrp9580-objid,
      END OF gt_data .
*
DATA: gt_p9580 LIKE TABLE OF p9580 WITH HEADER LINE.
DATA: gt_zcms9590 LIKE zcms9590 OCCURS 0 WITH HEADER LINE.
*
DATA: BEGIN OF gt_grid  OCCURS 0,
        status(5),
        student12       LIKE cmacbpst-student12,
        name1           LIKE hrp1000-short,

        o_objid         LIKE hrp9580-objid,
        otext(40),

        st_objid        LIKE hrp9580-objid,
        cs_objid        LIKE hrp9580-objid,    "SCID
        sc_objid        LIKE hrp9580-objid, "TYPE piqscobjid,    "CSID
        sctext(40),
        group_category  LIKE piqrfc_study_spec_txt-modulegroup_category, "전공구분
        group_categoryt LIKE t7piqmodgrpcatt-categoryt,
        priority        LIKE piqrfc_sess_regists-study_priority, " 우선순위
        peryr           LIKE piqstreg_p-peryr,
        perid           LIKE piqstreg_p-perid,
        regdate         LIKE sy-datum, "TYPE piqregperdate, "등록일자

        enrcateg        LIKE piqstreg_p-enrcateg, "등록유형
        enrcategt       LIKE t7piqenrcategt-enrcategt, "등록유형

        pr_status       LIKE piqstreg_p-pr_status, "상태
        prs_state       LIKE piqstreg_p-prs_state, "전공상태

        crsnmko         LIKE zcms60-crsnmko,  "학위과정
        acad_year       LIKE zcms60-acad_year, "현학년
        acad_session    LIKE zcms60-acad_session, "현학기
        statnmko        LIKE zcms60-statnmko, "학적상태

        regclass        LIKE piqstreg_p-regclass, "등록분류
        cancprocess     LIKE piqstreg_p-cancprocess, "취소 액티비티(등록)

        sts_cd          LIKE hrp9530-sts_cd,
        zcolg           LIKE hrp1000-objid,            "단과대학
        zcolgnm         LIKE hrp1000-stext,

        zrealwr         LIKE hrp9580-zrealwr,
        zwaers          LIKE hrp9580-zwaers,
        tepeatid        LIKE zcmt0511-tepeatid,        "이수학기
        grade           LIKE zcmt0511-grade,           "학년
        msgty           LIKE sy-msgty,
        msg(100),

        check(1),
      END OF gt_grid .

DATA: BEGIN OF gs_regst,
        st_objid    TYPE hrobjid,
        sc_objid    TYPE hrobjid,
        cs_objid    TYPE hrobjid,
        cs_begda    TYPE datum,
        short       TYPE short_d,
        stext       TYPE stext,
        enrcateg    TYPE piqenrcateg,
        cg_objid    TYPE hrobjid,
        cg_category TYPE piqmodgrpcat,
        o_objid     TYPE sobid,
        o_short     TYPE short_d,
        priox       TYPE  hrp1001-priox,
        student12   TYPE piqstudent12,
        name1       TYPE hrp1000-stext.
        INCLUDE     STRUCTURE hri1771.
DATA: END OF gs_regst.
DATA: gt_regst LIKE TABLE OF gs_regst.

*-SMS
TABLES: zxit0010.
DATA : gv_username LIKE t527x-orgtx,
       gv_return.

DATA : BEGIN OF gt_log OCCURS 0,
         zstatus(4),
         student12   TYPE piqstudent12,
         ename       TYPE piqstdtx,
         mob_number  LIKE zcms006-mob_number,
         message(40) TYPE c,
       END OF gt_log.
DATA : z_answer,
       z_return.
DATA : zflag.
DATA : BEGIN OF result_itab OCCURS 0,
         mark,
         zled(20),
         stdid     LIKE zcms6350_alv-stdid,
         name      LIKE zcms6350_alv-name,
         caller_no LIKE zcms6350_alv-caller_no,
         text(50),
         celltab   TYPE lvc_t_styl,
       END OF result_itab.


DATA: BEGIN OF gt_domain OCCURS 0,
        domname TYPE dd07t-domname,
        key     TYPE dd07t-domvalue_l,
        text    TYPE dd07t-ddtext,
      END OF gt_domain.

DATA: gv_tot TYPE i.
DATA: gv_cur TYPE i.
