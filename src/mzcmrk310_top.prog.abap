*&---------------------------------------------------------------------*
*& Include          MZCMRK990_TOP
*&---------------------------------------------------------------------*
TABLES : hrp1000, hrp9551.

CLASS lcl_alv_grid DEFINITION DEFERRED.
DATA go_grid TYPE REF TO lcl_alv_grid.

DATA : BEGIN OF gt_data OCCURS 0,
         cflag           TYPE flag,
         review          TYPE hrp9551-review,
         o_id            TYPE hrp9551-objid,
         o_stext         TYPE hrp1000-stext,
         objid           TYPE hrp9551-objid,
         short           TYPE hrp1000-short,
         stext           TYPE hrp1000-stext,
         begda           TYPE hrp9551-begda,
         endda           TYPE hrp9551-endda,
         set_no          TYPE flag,
         recog_fg        TYPE hrp9550-recog_fg,
         cu_fg           TYPE hrp9550-cu_fg,
         bigo            TYPE zcmt2381-bigo,
         book_kapz1      TYPE hrp9551-book_kapz1,
         book_kapz2      TYPE hrp9551-book_kapz2,
         book_kapz3      TYPE hrp9551-book_kapz3,
         book_kapz4      TYPE hrp9551-book_kapz4,
         book_kapz1_r    TYPE hrp9551-book_kapz1_r,
         book_kapz2_r    TYPE hrp9551-book_kapz2_r,
         book_kapz3_r    TYPE hrp9551-book_kapz3_r,
         book_kapz4_r    TYPE hrp9551-book_kapz4_r,
         book_kapzg      TYPE hrp9551-book_kapzg,
         book_kapz       TYPE hrp9551-book_kapz,
         ug_book_seq_txt TYPE hrp9551-ug_book_seq_txt,
         qt_tp           TYPE hrp9551-qt_tp,
         qt_tpt          TYPE dd07t-ddtext,
         remark          TYPE hrp9551-remark,
         style           TYPE lvc_t_styl,
       END OF gt_data.
DATA gt_rows TYPE TABLE OF lvc_s_row.
DATA gt_authobj TYPE TABLE OF hrview.

DATA gt_evob TYPE zcmscourse OCCURS 0 WITH HEADER LINE.
DATA ok_code TYPE sy-ucomm.
*DATA: gv_vis1, gv_vis2.
DATA: gv_undergrad,
      gv_grad,
      gv_30000305. "AI·SW대학원

DATA gv_begda TYPE datum.
DATA gv_endda TYPE datum.
DATA gv_keydt TYPE datum.

DATA gv_err TYPE flag.
