*&---------------------------------------------------------------------*
*& Include          MZCMRK990_TOP
*&---------------------------------------------------------------------*
TABLES : hrp9566, hrp1000.

CLASS lcl_alv_grid DEFINITION DEFERRED.
DATA go_grid TYPE REF TO lcl_alv_grid.

DATA : BEGIN OF gt_data OCCURS 0,
         prize1_rank(4),
         prize1(20),
         prize2_rank(4),
         prize2(20),
         effort(1),
         prize3_rank(4), "coffee
         prize3(20),
         min_time            TYPE timestampl,
         stno                TYPE zcmt2024_input-uname,
         stobjid             TYPE piqstudent,
         name                TYPE stext,
         sdate               TYPE zcmt2024_input-sdate, "일자
         time(20),
         uzeit               TYPE zcmt2024_input-uzeit,
         stime               TYPE zcmt2024_input-stime,
         stscd               TYPE zcmta446-st_stscd,
         stscd_txt(4),
         o_short             TYPE zcmta446-o_short,
         cacst               TYPE piqprog_gr_acst, "현재학기

         mobile(16),
         pre_registration(1),
         test1_date          TYPE zcmt2024_input-sdate, "일자
         test1_time(20),
         test1_uzeit         TYPE zcmt2024_input-uzeit,
         test1_stime         TYPE zcmt2024_input-stime,
         test2_date          TYPE zcmt2024_input-sdate, "일자
         test2_time(20),
         test2_uzeit         TYPE zcmt2024_input-uzeit,
         test2_stime         TYPE zcmt2024_input-stime,
         test3_date          TYPE zcmt2024_input-sdate, "일자
         test3_time(20),
         test3_uzeit         TYPE zcmt2024_input-uzeit,
         test3_stime         TYPE zcmt2024_input-stime,

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
