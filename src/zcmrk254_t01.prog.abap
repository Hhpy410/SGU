*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_T01
*&---------------------------------------------------------------------*
TYPE-POOLS: slis, vrm.
CONSTANTS: gc_set    TYPE c VALUE 'X'.
CONSTANTS: gc_extension   TYPE i VALUE 3000.  "Docking size

TABLES : hrp1000, hrpad506.
DATA : gt_authobj  LIKE hrview    OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_data OCCURS 0.
        INCLUDE STRUCTURE hrpad506.
DATA: stobj    LIKE hrpad506-packnumber,
        stnum    LIKE hrp1000-short,
        stnam    LIKE hrp1000-stext,
        smobj    LIKE hrpad506-packnumber,
        smnum    LIKE hrp1000-short,
        smnam    LIKE hrp1000-stext,
        sobid    LIKE hrp1001-sobid,
        tui_a    LIKE hrp9565-cgpa,
        tui4a(4) TYPE i,
        zreal    LIKE hrp9580-zrealwr,
        zrea1    LIKE hrp9580-zrealwr1,
        cpt_a    LIKE hrp9565-cgpa,
        cpt4a(4) TYPE i,
        cpt_b    LIKE hrp9565-cgpa,
        cpt4b(4) TYPE i,
        cpt_c    LIKE hrp9565-cgpa,
        cpt4c(4) TYPE i,
        storl    LIKE hrpad506-stordate,
        amt_b    LIKE hrp9540-amount,
        remrk    LIKE hrp1000-stext,
        celltab  TYPE lvc_t_styl,
      END OF gt_data.

DATA: BEGIN OF gt_sumz OCCURS 0,
        stobj    LIKE hrpad506-packnumber,
        cpt_a    LIKE hrp9565-cgpa,
        cpt4a(4) TYPE i,
        cpt_b    LIKE hrp9565-cgpa,
        cpt4b(4) TYPE i,
        cpt_c    LIKE hrp9565-cgpa,
        cpt4c(4) TYPE i,
        storl    LIKE hrpad506-stordate,
        amt_b    LIKE hrp9540-amount,
      END OF gt_sumz.

DATA: gt_copy     LIKE gt_data      OCCURS 0 WITH HEADER LINE.
DATA: gt_course   LIKE zcmscourse   OCCURS 0 WITH HEADER LINE.
DATA: gt_tuit     LIKE hrp9580      OCCURS 0 WITH HEADER LINE.
DATA: gv_begda TYPE datum,
      gv_endda TYPE datum.

DATA: s_stobj TYPE RANGE OF hrobjid WITH HEADER LINE.
DATA: gv_storr LIKE hrpad506-storreason VALUE 'SWCL'.
DATA: gv_amtpc LIKE konp-kbetr.

*DATA: gv_orgcd TYPE hrobjid.
