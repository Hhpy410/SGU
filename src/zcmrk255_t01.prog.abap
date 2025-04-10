*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_T01
*&---------------------------------------------------------------------*
TYPE-POOLS: slis, vrm.
CONSTANTS: gc_set    TYPE c VALUE 'X'.
CONSTANTS: gc_extension   TYPE i VALUE 3000.  "Docking size

TABLES : hrp1000, hrp9530, sscrfields.
DATA : gt_authobj  LIKE hrview    OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_data OCCURS 0.
        INCLUDE STRUCTURE zcmtk310.
DATA:   short      LIKE hrp1000-short,
        stext      LIKE hrp1000-stext,
        rgwin      LIKE hrp1705-regwindow,
        rgsem      LIKE hrp1705-regsemstr,
        bkcdt      LIKE hrp1705-book_cdt, "학점
        short1     LIKE zcmtk310-se_short,
        short2     LIKE zcmtk310-se_short,
        short3     LIKE zcmtk310-se_short,
        short4     LIKE zcmtk310-se_short,
        short5     LIKE zcmtk310-se_short,
        short6     LIKE zcmtk310-se_short,
        smcnt      LIKE hrp1024-kapz1,
        smtx1      LIKE hrp1000-stext,
        smtx2      LIKE hrp1000-stext,
        smtx3      LIKE hrp1000-stext,
        smtx4      LIKE hrp1000-stext,
        smtx5      LIKE hrp1000-stext,
        smtx6      LIKE hrp1000-stext,

*       경쟁률
        ctype1     LIKE hrp1000-short,
        ratea      LIKE hrp1000-short,
        rate1      LIKE hrp1000-short,
        rate2      LIKE hrp1000-short,
        rate3      LIKE hrp1000-short,
        rate4      LIKE hrp1000-short,

*       신청수
        ctype2     LIKE hrp1000-short,
        appca      LIKE hrp9551-book_kapz,
        appc1      LIKE hrp9551-book_kapz,
        appc2      LIKE hrp9551-book_kapz,
        appc3      LIKE hrp9551-book_kapz,
        appc4      LIKE hrp9551-book_kapz,

*       정원
        ctype3     LIKE hrp1000-short,
        kapza      LIKE  hrp9551-book_kapz1, "전체
        kapz1      LIKE  hrp9551-book_kapz1,
        kapz2      LIKE  hrp9551-book_kapz2, "2학년
        kapz3      LIKE  hrp9551-book_kapz3, "3학년
        kapz4      LIKE  hrp9551-book_kapz4, "4학년

        sts_cd     LIKE zcms2717n-sts_cd,     "학적상태
        sts_cd_txt LIKE zcms2717n-sts_cd_txt, "학적상태명

        color      TYPE lvc_t_scol,
        celltab    TYPE lvc_t_styl,
        xflag,
      END OF gt_data.

DATA : gt_temp  LIKE gt_data  OCCURS 0 WITH HEADER LINE.
DATA : gt_wish  LIKE zcmtk310 OCCURS 0 WITH HEADER LINE.
DATA : gv_orgcd TYPE hrobjid,
       gv_keyda TYPE datum.
DATA : gt_orgcd LIKE qcat_stru OCCURS 0 WITH HEADER LINE.
DATA : gr_orgcd TYPE RANGE OF sobid     WITH HEADER LINE.

DATA : z_answer,
       z_return,
       z_text(100),
       l_message(100).

DATA : gv_cur TYPE i VALUE 0,
       gv_tot TYPE i VALUE 0.
DATA: gt_evob LIKE TABLE OF zcmscourse WITH HEADER LINE.
DATA: gt_save LIKE TABLE OF zcmt2024_input WITH HEADER LINE.
DATA: s_stobj TYPE RANGE OF hrobjid WITH HEADER LINE.

DATA: lt_tlmts TYPE piqtimelimits_tab,
      ls_tlmts TYPE piqtimelimits.
DATA: lt_tinfo TYPE zcms023_tab,
      ls_tinfo TYPE zcms023,
      lv_keyda TYPE datum.

DATA: gv_begda   TYPE begda,
      gv_endda   TYPE endda,
      gv_mode(1) VALUE '4'.

DATA : BEGIN OF gt_menu OCCURS 0,
         fcode LIKE sy-ucomm,
       END OF gt_menu .

DATA: BEGIN OF gt_stat OCCURS 0,
        rgwin LIKE hrp1705-regwindow,
        total TYPE i,
        stcnt TYPE i,
        smcnt TYPE i,
        svcnt TYPE i,
      END OF gt_stat.

DATA: g_appca TYPE zappc,
      g_appc1 TYPE zappc,
      g_appc2 TYPE zappc,
      g_appc3 TYPE zappc,
      g_appc4 TYPE zappc,
      g_kapza TYPE zkapz,
      g_kapz1 TYPE zkapz,
      g_kapz2 TYPE zkapz,
      g_kapz3 TYPE zkapz,
      g_kapz4 TYPE zkapz,
      g_ratea TYPE zrate,
      g_rate1 TYPE zrate,
      g_rate2 TYPE zrate,
      g_rate3 TYPE zrate,
      g_rate4 TYPE zrate.

*{공통코드 설정
DATA : BEGIN OF gt_0101 OCCURS 0,
         grp_cd LIKE zcmt0101-grp_cd,
         com_cd LIKE zcmt0101-com_cd,
         com_nm LIKE zcmt0101-com_nm,
       END OF gt_0101.
*}

*--------------------------------------------------------------------*
DATA: gv_cnt      TYPE i,
      gv_100_cnt  TYPE i,
      gv_1000_cnt TYPE i.
DATA  gv_status_txt TYPE string.
