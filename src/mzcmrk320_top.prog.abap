*&---------------------------------------------------------------------*
*& Include          MZCMRK990_TOP
*&---------------------------------------------------------------------*
TABLES : hrp1000, hrp9552, hrt9552, sscrfields.

CLASS lcl_alv_grid DEFINITION DEFERRED.
DATA go_grid TYPE REF TO lcl_alv_grid.
DATA go_item TYPE REF TO lcl_alv_grid.
DATA go_xls TYPE REF TO lcl_alv_grid.
CONSTANTS gc_separator TYPE text4 VALUE ` || `.

DATA : BEGIN OF gt_data OCCURS 0,
         cflag    TYPE flag,
         review   TYPE hrp9552-review,
         o_id     TYPE hrp9552-objid,
         o_stext  TYPE hrp1000-stext,
         smobjid  TYPE piqsmobjid,
         objid    TYPE hrp9552-objid,
         short    TYPE hrp1000-short,
         stext    TYPE hrp1000-stext,
         begda    TYPE hrp9552-begda,
         endda    TYPE hrp9552-endda,
         recog_fg TYPE hrp9550-recog_fg,
         cu_fg    TYPE hrp9550-cu_fg,
         smltext  TYPE zcmscourse-smltext,
         bigo     TYPE zcmt2381-bigo,
         apply_fg TYPE hrp9552-apply_fg,
         remark   TYPE hrp9552-remark,
         tabnr    TYPE hrp9552-tabnr,
         objid_t1 TYPE text1024,
         stext_t1 TYPE text1024,
         objid_t2 TYPE text1024,
         stext_t2 TYPE text1024,
         objid_t3 TYPE text1024,
         stext_t3 TYPE text1024,
         objid_t4 TYPE text1024,
         stext_t4 TYPE text1024,

         item     TYPE TABLE OF pt9552,
       END OF gt_data.
DATA gt_1000 TYPE TABLE OF hrp1000.
DATA gt_rows TYPE TABLE OF lvc_s_row.
DATA gt_authobj TYPE TABLE OF hrview.
DATA gv_keydt TYPE datum.
DATA gv_begda TYPE datum.
DATA gv_endda TYPE datum.
DATA gt_evob TYPE zcmscourse OCCURS 0 WITH HEADER LINE.
DATA ok_code TYPE sy-ucomm.
DATA gv_book_fg TYPE hrt9552-book_fg.
DATA : BEGIN OF gt_item OCCURS 0,
         tabnr   TYPE hrp9552-tabnr,
         book_fg TYPE hrt9552-book_fg,
         otype   TYPE hrt9552-otype,
         objid   TYPE hrt9552-objid,
         stext   TYPE hrp1000-stext,
         del,
       END OF gt_item.

DATA : BEGIN OF gt_xls OCCURS 0,
         type     LIKE bapiret2-type,
         msg      LIKE bapiret2-message,
         objid    TYPE hrp9552-objid,
         short    TYPE hrp1000-short,
         stext    TYPE hrp1000-stext,
         apply_fg TYPE hrp9552-apply_fg,
         book_fg  TYPE hrt9552-book_fg,
         otype    TYPE hrt9552-otype,
         o_id     TYPE hrp9552-objid,
         o_stext  TYPE hrp1000-stext,
       END OF gt_xls.
