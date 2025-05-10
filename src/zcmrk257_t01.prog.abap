*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_T01
*&---------------------------------------------------------------------*
TYPE-POOLS: slis, vrm.
CONSTANTS: gc_set    TYPE c VALUE 'X'.
CONSTANTS: gc_extension   TYPE i VALUE 3000.  "Docking size

TABLES: hrp1000, hrp9551, hrp9552, sscrfields.
DATA: gt_authobj  LIKE hrview    OCCURS 0 WITH HEADER LINE.
DATA: gt_qstru    LIKE qcat_stru OCCURS 0 WITH HEADER LINE.
DATA functxt TYPE smp_dyntxt.

DATA: gt_1000 TYPE hrp1000    OCCURS 0 WITH HEADER LINE.
DATA: gt_9551 TYPE hrp9551    OCCURS 0 WITH HEADER LINE. "수강가능인원 설정

* 소속제한
DATA: BEGIN OF gt_9552 OCCURS 0.
        INCLUDE STRUCTURE hrp9552.
DATA:   book_fg TYPE hrt9552-book_fg,
        bookorg TYPE hrt9552-objid,
      END OF gt_9552.

DATA: gt_evob TYPE zcmscourse OCCURS 0 WITH HEADER LINE.
DATA: gt_vrm  TYPE vrm_values WITH HEADER LINE.

DATA: BEGIN OF gt_data OCCURS 0,
        edit       TYPE c,
        peryr      LIKE zcmscourse-peryr,
        perid      LIKE zcmscourse-perid,
        orgeh      LIKE hrp1000-objid,
        orgtx      LIKE hrp1000-stext,
        objid      LIKE hrp1000-objid,
        short      LIKE hrp1000-short,
        stext      LIKE hrp1000-stext,
        seqnr(2)   TYPE n, "순번
        book_kapz4 LIKE hrp9551-book_kapz4,
        book_kapz3 LIKE hrp9551-book_kapz3,
        book_kapz2 LIKE hrp9551-book_kapz2,
        book_kapz1 LIKE hrp9551-book_kapz1,
        book_kapzg LIKE hrp9551-book_kapzg,
        book_kapz  LIKE hrp9551-book_kapz,

        apply_fg   LIKE hrp9552-apply_fg,
        book_fg    LIKE hrt9552-book_fg,
        book_org   LIKE hrt9552-objid,
        book_orgtx LIKE hrp1000-stext,
        type       LIKE zcmt9902-type,
        message    LIKE zcmt9902-message,
        celltab    TYPE lvc_t_styl,
      END OF gt_data.
DATA: lt_data LIKE gt_data OCCURS 0 WITH HEADER LINE. "gt_data

DATA: BEGIN OF gt_cart OCCURS 0,
        edit       TYPE c,
        book_fg    LIKE hrt9552-book_fg,
        book_org   LIKE zcms3140_alv_i-book_org01,
        book_orgtx LIKE hrp1000-stext,
        celltab    TYPE lvc_t_styl,
      END OF gt_cart.
DATA: lt_cart LIKE gt_cart OCCURS 0 WITH HEADER LINE. "gt_cart

DATA: BEGIN OF gt_selx OCCURS 0, "선택분반
        short TYPE short_d,
      END OF gt_selx.
DATA: r_objid TYPE RANGE OF hrobjid WITH HEADER LINE.

DATA : gv_answer(1),
       gc_answer TYPE c  VALUE 'J' .

DATA: gv_mode     TYPE flag     VALUE 'D'.
DATA: gv_comm     TYPE sy-ucomm VALUE 'LIST'.

FIELD-SYMBOLS : <f4tab> TYPE lvc_t_modi.
DATA : ls_f4     TYPE ddshretval.

DATA: sc_group1 TYPE c,
      sc_group2 TYPE c.

DEFINE copy_row.
*  IF gt_9552-book_fg&1  IS NOT INITIAL OR
*     gt_9552-book_org&1 IS NOT INITIAL.
*    CLEAR: lt_cart.
*    lt_cart-book_fg    = gt_9551-book_fg&1.
*    lt_cart-book_org   = gt_9551-book_org&1.
*    APPEND lt_cart.
**(날짜체크: 2020.01.17
*    IF sy-datum NOT BETWEEN gt_9551-book_st_dt&1 AND gt_9551-book_ed_dt&1 OR
*       gt_9551-book_ed_dt&1 <> '99991231'.
*      gt_data-type    = 'E'.
*      gt_data-message = '날짜확인'.
*    ENDIF.
**)
*  ENDIF.
  END-OF-DEFINITION.

  DEFINE ini_fields.
*    CLEAR hrp9551-book_fg&1.
*    CLEAR hrp9551-book_org&1.
*    CLEAR hrp9551-book_st_dt&1.
*    CLEAR hrp9551-book_ed_dt&1.
    END-OF-DEFINITION.

    DEFINE set_fields.
      IF gt_data-seqnr = &1.
*        hrp9551-book_fg&1    = gt_data-book_fg.
*        hrp9551-book_org&1   = gt_data-book_org.
*        hrp9551-book_st_dt&1 = '19000101'.
*        hrp9551-book_ed_dt&1 = '99991231'.
      ENDIF.
    END-OF-DEFINITION.
