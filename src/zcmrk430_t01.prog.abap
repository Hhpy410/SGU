*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_T01
*&---------------------------------------------------------------------*
TYPE-POOLS: slis, vrm.
CONSTANTS: gc_set    TYPE c VALUE 'X'.
CONSTANTS: gc_extension   TYPE i VALUE 3000.  "Docking size

TABLES: usr02, hrp1000, sscrfields.
DATA: gt_authobj  LIKE hrview    OCCURS 0 WITH HEADER LINE.
DATA: gt_qstru    LIKE qcat_stru OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_data OCCURS 0,
        piqperyr     LIKE hrpad506-peryr,
        piqperid     LIKE hrpad506-perid,
        sm_id        LIKE hrpad506-smobjid,
        reperyr      LIKE hrpad506-reperyr,
        reperid      LIKE hrpad506-reperid,
        resmid       LIKE hrpad506-resmid,
        reid         LIKE hrpad506-reid,
        repeatfg     LIKE hrpad506-repeatfg,

        type         LIKE zcmt9902-type,
        message      LIKE zcmt9902-message,
        objid        LIKE hrp9562-objid,
        short        LIKE hrp1000-short,
        stext        LIKE hrp1000-stext,
        sc_objid1    LIKE zcmsc-sc_objid1,
        sc_short1    LIKE zcmsc-sc_short1,
        o_objid      LIKE zcmsc-o_objid,
        sts_cd       LIKE hrp9530-sts_cd,
        sts_cdt      LIKE hrp1000-stext,
        begda        LIKE hrp9530-begda,
        natio        LIKE hrp1702-natio,
        readmit      TYPE c,
        regwindow    LIKE hrp1705-regwindow,
        regsemstr    LIKE hrp1705-regsemstr,
        book_cdt     LIKE hrp1705-book_cdt,
        seqno        TYPE i, "연번
        seqno2       TYPE i, "연번(조정)
        cc_update    TYPE i, "조정대상
        cc_recommend TYPE i, "권장횟수
        cc_remain    TYPE i, "잔여횟수
        cc_exceed    TYPE i, "초과횟수
        cc_expired   TYPE c, "만료
        rc_total     TYPE i, "전체
        rc_s1020     TYPE i, "정규
        rc_s1121     TYPE i, "계절
        rc_nocnt     TYPE i, "제외
        rx_now       TYPE i, "금학기
        p01(10)      TYPE c,
        p02(10)      TYPE c,
        p03(10)      TYPE c,
        p04(10)      TYPE c,
        p05(10)      TYPE c,
        p06(10)      TYPE c,
        p07(10)      TYPE c,
        p08(10)      TYPE c,
        p09(10)      TYPE c,
        p10(10)      TYPE c,
        p11(10)      TYPE c,
        p12(10)      TYPE c,
        p13(10)      TYPE c,
        p14(10)      TYPE c,
        p15(10)      TYPE c,
        p16(10)      TYPE c,
        p17(10)      TYPE c,
        p18(10)      TYPE c,
        p19(10)      TYPE c,
        p20(10)      TYPE c,
        sm_idt       LIKE hrp1000-short,
        sm_idx       LIKE hrp1000-stext,
        rep_modulet  LIKE hrp1000-short,
        rep_modulex  LIKE hrp1000-stext,
        peryr        LIKE zcmta261-peryr, "처리당시
        perid        LIKE zcmta261-perid, "처리당시
        erdat        LIKE zcmta261-erdat, "처리당시
        ertim        LIKE zcmta261-ertim, "처리당시
        sobid        TYPE sobid, "SM:변환(임시)
        celltab      TYPE lvc_t_styl,
      END OF gt_data.

DATA: gt_copy  LIKE gt_data  OCCURS 0 WITH HEADER LINE.
DATA: gt_ta261 LIKE zcmta261 OCCURS 0 WITH HEADER LINE.
DATA: gt_t9562 LIKE zcmt9562 OCCURS 0 WITH HEADER LINE,
      gs_ta261 LIKE zcmta261.

DATA: gt_zbooked LIKE zv_piqmodbooked2 OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_ad506 OCCURS 0,
        objid TYPE hrobjid,
        peryr TYPE piqperyr,
        perid TYPE piqperid,
        smobj TYPE sobid, "hrobjid,
        seobj TYPE hrobjid,
      END OF gt_ad506.

DATA: gv_begda TYPE begda,
      gv_endda TYPE endda,
      gv_tot   TYPE i,
      gv_cnt   TYPE i,
      gv_sel   TYPE i.

DATA: BEGIN OF gt_stats OCCURS 0,
        regsemstr LIKE hrp1705-regsemstr,
        r0        TYPE i, "만료
        r1        TYPE i,
        r2        TYPE i,
        r3        TYPE i,
        r4        TYPE i,
        r5        TYPE i,
        r6        TYPE i,
        r7        TYPE i,
        r8        TYPE i,
        rt        TYPE i, "소계
      END OF gt_stats.

DATA: BEGIN OF gt_stats2 OCCURS 0,
        type    LIKE zcmt9902-type,
        message LIKE zcmt9902-message,
        cnt1    TYPE i, "미연장
        cnt2    TYPE i, "연장완료
        count   TYPE i, "소계
      END OF gt_stats2.

DATA: gt_stob LIKE zcmsobjid OCCURS 0 WITH HEADER LINE,
      gt_majr LIKE zcmsc     OCCURS 0 WITH HEADER LINE.

DATA: gt_1000 LIKE hrp1000 OCCURS 0 WITH HEADER LINE,
      gt_1705 LIKE hrp1705 OCCURS 0 WITH HEADER LINE,
      gt_9530 LIKE hrp9530 OCCURS 0 WITH HEADER LINE,
      mt_1000 LIKE hrp1000 OCCURS 0 WITH HEADER LINE.

DATA: gt_filt TYPE lvc_t_filt,
      gs_filt TYPE lvc_s_filt.

DATA: session_name TYPE string.
DATA: bdcdata LIKE bdcdata OCCURS 0 WITH HEADER LINE.
DATA: messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.

*DATA: gv_processed TYPE c. "기처리여부
DATA: gv_answer(1),
      gc_answer TYPE c VALUE 'J'.
*&---------------------------------------------------------------------*
*&  SELECTION-SCREEN
*&---------------------------------------------------------------------*
*SELECTION-SCREEN FUNCTION KEY 1.
*SELECTION-SCREEN FUNCTION KEY 2.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-b01.

  PARAMETERS: p_keyda TYPE datum DEFAULT sy-datum.

  SELECT-OPTIONS : p_stobj FOR hrp1000-objid NO-DISPLAY.
  SELECT-OPTIONS : p_stnum FOR hrp1000-short NO INTERVALS.

  SELECTION-SCREEN SKIP 1.

  PARAMETERS: p_peryr LIKE piqstregper-peryr OBLIGATORY
                        AS LISTBOX VISIBLE LENGTH 25.
  PARAMETERS: p_perid LIKE piqstregper-perid OBLIGATORY
                        AS LISTBOX VISIBLE LENGTH 25.

  SELECTION-SCREEN SKIP 1.

  PARAMETERS: p_sel1 RADIOBUTTON GROUP gp2 USER-COMMAND uc.
  PARAMETERS: p_sel2 RADIOBUTTON GROUP gp2 DEFAULT 'X'.

  SELECTION-SCREEN SKIP 1.

  PARAMETERS: p_exp AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT 1(80) t_001.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT 1(80) t_002.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT 1(80) t_003.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT 1(80) t_004.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT 1(80) t_005.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT 1(80) t_011.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT 1(80) t_012.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT 1(80) t_013.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT 1(80) t_014.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT 1(80) t_015.
