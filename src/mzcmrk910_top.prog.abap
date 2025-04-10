*&---------------------------------------------------------------------*
*& Include          MZCMRK990_TOP
*&---------------------------------------------------------------------*
TABLES : tstct, sotr_head, /u4a/t0010.

CLASS lcl_alv_grid DEFINITION DEFERRED.
DATA go_grid TYPE REF TO lcl_alv_grid.

DATA : gv_guinr TYPE char30.
DATA : gv_error TYPE c.
DATA : BEGIN OF gt_data OCCURS 0,
         seqnr    LIKE hrp1001-seqnr,
         appid    LIKE /u4a/t0010-appid,
         appnm    LIKE /u4a/t0010-appnm,
         clsid    TYPE SEOCLSNAME,
         uiobj    TYPE text100,  " UI OBJECT ID
         uiotr    TYPE text100,  " OTR
         uiali    TYPE sotr_head-alias_name,  " alias_name
         uiotr_ko TYPE sotr_txt,  " OTR ko text
         uicat    TYPE text50,   " UI Category
         uiref    TYPE text50,   " UI Ref
       END OF gt_data.
