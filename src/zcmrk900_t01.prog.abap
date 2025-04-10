*&---------------------------------------------------------------------*
*& Include          ZCMRK900_T01
*&---------------------------------------------------------------------*
TYPE-POOLS: vrm.

TABLES : sscrfields, sotr_head, sotr_text.

CLASS lcl_falv DEFINITION DEFERRED.

DATA g_splitter1 TYPE REF TO cl_gui_splitter_container.
DATA g_splitter2 TYPE REF TO cl_gui_splitter_container.
DATA g_splitter3 TYPE REF TO cl_gui_splitter_container.
DATA g_splitter4 TYPE REF TO cl_gui_splitter_container.
DATA g_splitter5 TYPE REF TO cl_gui_splitter_container.

DATA g_grid1 TYPE REF TO lcl_falv.
DATA g_grid2 TYPE REF TO lcl_falv.
DATA g_grid3 TYPE REF TO lcl_falv.
DATA g_grid4 TYPE REF TO lcl_falv.
DATA g_grid5 TYPE REF TO lcl_falv.

FIELD-SYMBOLS :  <fs_grid> TYPE REF TO lcl_falv.
FIELD-SYMBOLS :  <fs_splitter> TYPE REF TO cl_gui_splitter_container.

DATA ok_code TYPE syucomm.

CONSTANTS gc_falv(20)         VALUE 'LCL_FALV'.
CONSTANTS gc_tabpatt(20)      VALUE 'GT_DATA'.
CONSTANTS gc_g_grid(20)       VALUE 'G_GRID'.
CONSTANTS gc_g_splitter(30)   VALUE 'G_SPLITTER'.
*--------------------------------------------------------------------*
DATA: gt_log TYPE zcmslog OCCURS 0 WITH HEADER LINE.

DATA gv_answer TYPE char01.
DATA gv_error TYPE flag.

DATA gv_trkorr   TYPE trkorr.

DATA gv_usegb   TYPE char30.

DATA: BEGIN OF gt_menu OCCURS 0,
        fcode LIKE sy-ucomm,
      END OF gt_menu .


DATA: BEGIN OF gt_data1 OCCURS 0,
        change_fg(1),
        paket        LIKE    sotr_head-paket,
        alias_name   LIKE    sotr_head-alias_name,
        otr_key      LIKE    hrp1000-stext, "$OTR:ZCM_MAIN/ZHANG
        length_ko    LIKE    sotr_text-length,
        text_ko      LIKE    sotr_text-text,
        length_en    LIKE    sotr_text-length,
        text_en      LIKE    sotr_text-text,
        length_cn    LIKE    sotr_text-length,
        text_cn      LIKE    sotr_text-text,
        btn_std(10),
        trkorr       LIKE    e070-trkorr,
        concept      LIKE    sotr_head-concept,
        chan_name    LIKE    sotr_text-chan_name,
        chan_tstut   LIKE    sotr_text-chan_tstut,

        styles       TYPE lvc_t_styl,
      END OF gt_data1.
