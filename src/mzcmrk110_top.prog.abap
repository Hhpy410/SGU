*&---------------------------------------------------------------------*
*& Include          MZCMRK990_TOP
*&---------------------------------------------------------------------*
TABLES : hrp9566.

CLASS lcl_alv_grid DEFINITION DEFERRED.
DATA go_grid TYPE REF TO lcl_alv_grid.

DATA : BEGIN OF gt_data OCCURS 0,
         objid          TYPE hrp9566-objid,
         o_stext        TYPE hrp1000-stext,
         begda          TYPE hrp9566-begda,
         endda          TYPE hrp9566-endda,
         st_grd         TYPE hrp9566-st_grd,
         re_scale       TYPE hrp9566-re_scale,
         re_scalet      TYPE dd07t-ddtext,
         re_max_grd     TYPE hrp9566-re_max_grd,
         re_per_sm_cnt  TYPE hrp9566-re_per_sm_cnt,
         re_tot_cnt     TYPE hrp9566-re_tot_cnt,
         re_same_sm_cnt TYPE hrp9566-re_same_sm_cnt,
         re_grd_prc     TYPE hrp9566-re_grd_prc,
         re_grd_prct    TYPE dd07t-ddtext,
         remark         TYPE hrp9566-remark,
         precd          TYPE hrp9566-precd,
         overl          TYPE hrp9566-overl,
         possb          TYPE text1000,
       END OF gt_data.
