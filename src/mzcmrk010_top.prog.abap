*&---------------------------------------------------------------------*
*& Include          MZCMRK010_TOP
*&---------------------------------------------------------------------*
TABLES : cmacbpst, hrp1705, hrp1739, hrp1000, hrpad506, sscrfields.

CLASS lcl_alv_grid DEFINITION DEFERRED.
DATA g_splitter TYPE REF TO cl_gui_splitter_container.
DATA g_grid1 TYPE REF TO lcl_alv_grid.
DATA g_grid2 TYPE REF TO lcl_alv_grid.
DATA g_grid3 TYPE REF TO lcl_alv_grid.
DATA g_grid4 TYPE REF TO lcl_alv_grid.
DATA g_grid5 TYPE REF TO lcl_alv_grid.

FIELD-SYMBOLS :  <fs_grid> TYPE REF TO lcl_alv_grid.

DATA ok_code TYPE syucomm.

CONSTANTS gc_falv(20) VALUE 'LCL_ALV_GRID'.
CONSTANTS gc_tabpatt(20) VALUE 'GT_DATA'.
CONSTANTS gc_g_grid(20) VALUE 'G_GRID'.

DATA gv_keydt TYPE datum.
DATA gv_begda TYPE datum.
DATA gv_endda TYPE datum.

*학생별 수강정보
DATA: BEGIN OF gt_data1 OCCURS 0,
        st_id   LIKE cmacbpst-stobjid,
        st_no   LIKE cmacbpst-student12,
        se01    LIKE hrp1000-short,
        se02    LIKE hrp1000-short,
        se03    LIKE hrp1000-short,
        se04    LIKE hrp1000-short,
        se05    LIKE hrp1000-short,
        se06    LIKE hrp1000-short,
        se07    LIKE hrp1000-short,
        se08    LIKE hrp1000-short,
        se09    LIKE hrp1000-short,
        se10    LIKE hrp1000-short,
        se11    LIKE hrp1000-short,
        se12    LIKE hrp1000-short,
        sts_cd  LIKE hrp9530-sts_cd,
        sts_cdt LIKE dd07t-ddtext,
      END OF gt_data1.

* TPS정보
DATA: BEGIN OF gt_data2 OCCURS 0,
        bookdt  TYPE sy-datum,
        booktm  TYPE hrp1000-infty,
        bookcnt TYPE i,
        booktps TYPE p DECIMALS 3,
      END OF gt_data2.

* OverBooking
DATA: BEGIN OF gt_data3 OCCURS 0,
        se_id        TYPE piqseobjid,
        short        TYPE hrp1000-short,
        stext        TYPE zcmsk_course-smstext,
        book_cnt     TYPE zcmsk_course-book_cnt,
        book_kapza   TYPE hrp9551-book_kapzg,
        book_kapz1_r TYPE hrp9551-book_kapz1,
        book_kapz2_r TYPE hrp9551-book_kapz2,
        book_kapz3_r TYPE hrp9551-book_kapz3,
        book_kapz4_r TYPE hrp9551-book_kapz4,
        book_kapzg   TYPE hrp9551-book_kapzg,
        book_kapz    TYPE hrp9551-book_kapz,
      END OF gt_data3.

DATA gv_tps TYPE p DECIMALS 3.
DATA gv_cnt TYPE i .

DATA gs_222 TYPE zcmtk222.
