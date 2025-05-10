*&---------------------------------------------------------------------*
*& Include          MZCMRK990_TOP
*&---------------------------------------------------------------------*
TABLES : hrp9566, hrp1000.

CLASS lcl_alv_grid DEFINITION DEFERRED.
DATA go_grid TYPE REF TO lcl_alv_grid.

DATA : BEGIN OF gt_data OCCURS 0.
         INCLUDE STRUCTURE zcmtk310.
DATA:    short      LIKE hrp1000-short,
         stext      LIKE hrp1000-stext,
         rgwin      LIKE hrp1705-regwindow,
         rgsem      LIKE hrp1705-regsemstr,
         bkcdt      LIKE hrp1705-book_cdt, "학점
         r_seobjid  LIKE hrpad506-packnumber,
         r_short    LIKE zcmtk310-se_short,


*         short1     LIKE zcmtk310-se_short,
*         short2     LIKE zcmtk310-se_short,
*         short3     LIKE zcmtk310-se_short,
*         short4     LIKE zcmtk310-se_short,
*         short5     LIKE zcmtk310-se_short,
*         short6     LIKE zcmtk310-se_short,
*         r_seobjid1 LIKE hrpad506-packnumber,
*         r_seobjid2 LIKE hrpad506-packnumber,
*         r_seobjid3 LIKE hrpad506-packnumber,
*         r_seobjid4 LIKE hrpad506-packnumber,
*         r_seobjid5 LIKE hrpad506-packnumber,
*         r_seobjid6 LIKE hrpad506-packnumber,
*         r_short1   LIKE zcmtk310-se_short,
*         r_short2   LIKE zcmtk310-se_short,
*         r_short3   LIKE zcmtk310-se_short,
*         r_short4   LIKE zcmtk310-se_short,
*         r_short5   LIKE zcmtk310-se_short,
*         r_short6   LIKE zcmtk310-se_short,


         sts_cd     LIKE zcms2717n-sts_cd,     "학적상태
         sts_cd_txt LIKE zcms2717n-sts_cd_txt, "학적상태명

         color      TYPE lvc_t_scol,
         celltab    TYPE lvc_t_styl,
         xflag,

       END OF gt_data.

*       CALL METHOD zcmcl000=>get_st_progression
*    EXPORTING
*      it_stobj   = lt_stobj[]
*      iv_keydate = gs_timelimits-ca_lendda
*    IMPORTING
*      et_stprog  = DATA(et_stprog).

TYPES: BEGIN OF ty_pre_applicants,
         user_id(10),
         user_name(32),
         mobile(16),
         email(128),
         privacy_agree(1),
         ip(16),
         reg_date(8),
         reg_time(6),
       END OF ty_pre_applicants.
DATA gt_pre_applicants TYPE TABLE OF ty_pre_applicants.

DATA gs_timelimits TYPE piqtimelimits.

DATA: gv_endtime1 TYPE syuzeit,
      gv_endtime2 TYPE syuzeit,
      gv_endtime3 TYPE syuzeit.

DATA gt_input TYPE TABLE OF zcmt2024_input WITH HEADER LINE.
DATA gt_wish LIKE zcmtk310 OCCURS 0 WITH HEADER LINE.
DATA gt_save TYPE hrpad506 OCCURS 0 WITH HEADER LINE.
DATA gt_temp LIKE gt_data  OCCURS 0 WITH HEADER LINE.
DATA gv_status_txt TYPE string.
DATA: gv_cnt      TYPE i,
      gv_100_cnt  TYPE i,
      gv_1000_cnt TYPE i,
      gv_tot      TYPE i VALUE 0.
DATA gv_begda TYPE begda.

*{공통코드 설정
DATA : BEGIN OF gt_0101 OCCURS 0,
         grp_cd LIKE zcmt0101-grp_cd,
         com_cd LIKE zcmt0101-com_cd,
         com_nm LIKE zcmt0101-com_nm,
       END OF gt_0101.
*}

CONSTANTS: gc_set TYPE c VALUE 'X'.
DATA: s_stobj TYPE RANGE OF hrobjid WITH HEADER LINE.
DATA: gt_evob TYPE TABLE OF zcmscourse,
      gs_evob TYPE zcmscourse.

DATA gt_hrpad506 TYPE TABLE OF hrpad506 WITH HEADER LINE.
