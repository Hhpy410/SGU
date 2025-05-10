*&---------------------------------------------------------------------*
*& Include          MZCMRK410_TOP
*&---------------------------------------------------------------------*
TABLES: cmacbpst, hrp1000, sscrfields.
CLASS lcl_alv_grid DEFINITION DEFERRED.
DATA go_grid TYPE REF TO lcl_alv_grid.

DATA gt_authobj  LIKE hrview    OCCURS 0 WITH HEADER LINE.
DATA gv_nolimit      TYPE c.
DATA gt_vrm  TYPE vrm_values WITH HEADER LINE.
DATA gs_auth TYPE zcmt2024_auth.

DATA : BEGIN OF gt_data OCCURS 0,
         type      TYPE bapiret2-type,
         message   TYPE bapiret2-message,
         st_no     TYPE cmacbpst-student12,
         st_nm     TYPE hrp1000-stext,
         st_id     TYPE cmacbpst-stobjid,
         max(4)    TYPE p DECIMALS 1,
         se_detail TYPE zcmsk_course,
         reperyr   TYPE hrpad506-reperyr,
         reperid   TYPE hrpad506-reperid,
         resmid    TYPE hrpad506-resmid,
         reid      TYPE hrpad506-reid,
         regwindow TYPE hrpad506-regwindow,
       END OF gt_data.

DATA : BEGIN OF gt_xls OCCURS 0,
         st_no    TYPE cmacbpst-student12,
         sm_short TYPE hrp1000-short,
         se_short TYPE hrp1000-short,
       END OF gt_xls.

DATA : BEGIN OF gt_stse OCCURS 0,
         st_no    TYPE cmacbpst-student12,
         se_short TYPE hrp1000-short,
       END OF gt_stse.

DATA gt_stlist TYPE TABLE OF hrobject.
DATA gv_keydt TYPE datum.
DATA gv_check.

DATA gt_org TYPE TABLE OF zcmcl000=>ty_st_orgcd.
DATA gt_major TYPE TABLE OF zcmsc.
DATA gt_person TYPE TABLE OF zcmcl000=>ty_st_person.
DATA gt_acwork TYPE zcmz200_t.
DATA gt_st1000 TYPE TABLE OF hrp1000.
DATA gr_stno TYPE RANGE OF cmacbpst-student12.

DATA gt_agr_users TYPE TABLE OF agr_users.

DATA: BEGIN OF gt_0101 OCCURS 0,
        grp_cd TYPE zcmt0101-grp_cd,
        key    TYPE vrm_value-key,
        text   TYPE vrm_value-text,
        org_cd TYPE zcmt0101-org_cd,
      END OF gt_0101.

DATA gt_role TYPE TABLE OF zcmt2024_role WITH HEADER LINE.
