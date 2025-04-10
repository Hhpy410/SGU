*&---------------------------------------------------------------------*
*& Include          ZCMR1050_T01
*&---------------------------------------------------------------------*
TYPE-POOLS: vrm.

TABLES : sscrfields, cmacbpst, hrp1000.

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


DATA gt_auth_root   TYPE TABLE OF hrview WITH HEADER LINE.
DATA gt_auth_object TYPE TABLE OF zcmcl000=>ty_auth_object WITH HEADER LINE.


DATA: gt_log TYPE zcmslog OCCURS 0 WITH HEADER LINE.

DATA gv_answer TYPE char01.
DATA gv_error TYPE flag.

DATA: BEGIN OF gt_menu OCCURS 0,
        fcode LIKE sy-ucomm,
      END OF gt_menu .

DATA gs_timelimits TYPE piqtimelimits.
DATA gt_perit      TYPE TABLE OF t7piqperiodt WITH HEADER LINE.
DATA gs_perit      LIKE LINE OF gt_perit.
DATA gv_begda TYPE begda.
DATA gv_endda TYPE endda.

DATA gt_visatypet     TYPE TABLE OF t7piqvisatypet WITH HEADER LINE.
DATA gt_zcmt0101      TYPE TABLE OF zcmt0101       WITH HEADER LINE.
DATA gt_dd07t         TYPE TABLE OF dd07t       WITH HEADER LINE.
DATA gt_hrp1000       TYPE TABLE OF hrp1000       WITH HEADER LINE.
DATA gt_t685t         TYPE TABLE OF t685t          WITH HEADER LINE.
DATA gt_t7piqsmstatt  TYPE TABLE OF t7piqsmstatt          WITH HEADER LINE.
DATA gt_orgcd_list    TYPE tihttpnvp2 .

DATA gv_mode     TYPE char01.


CONSTANTS gc_org204 TYPE hrobjid VALUE '30000204'. " 경영전문대학원

DATA gt_stlist        TYPE TABLE OF hrobject          WITH HEADER LINE.


DATA: BEGIN OF gt_data1 OCCURS 0,
        target_fg     TYPE flag,  " 처리대상
        msgty         TYPE msgty, " 처리결과
        msgtx         TYPE msgtx, " 메세지

        orgcd         TYPE hrp1000-objid,
        orgcd_t       TYPE hrp1000-stext,

        o_objid       TYPE zcmsc-o_objid,
        o_short       TYPE zcmsc-o_short,

        st_no         TYPE cmacbpst-student12,
        st_id         TYPE cmacbpst-stobjid,
        st_nm         TYPE hrp1000-stext,

        sts_cd        TYPE hrp9530-sts_cd,
        sts_cd_t      TYPE dd07t-ddtext,

        regwindow     TYPE hrp1705-regwindow,

        repeatfg      LIKE hrpad506-repeatfg, " 재이수 확정여부

        peryr         LIKE hrpad506-peryr,
        perid         LIKE hrpad506-perid,
        sm_id         TYPE hrp1000-objid,
        sm_short      TYPE hrp1000-short,
        sm_stext      TYPE hrp1000-stext,
        smstatus      TYPE hrpad506-smstatus,
        smstatus_t    TYPE t7piqsmstatt-smstatust,
        alt_scaleid   LIKE hrpad506-alt_scaleid,   "스케일
        gradesym      LIKE piqdbagr_gen-gradesym,   "성적기호
        cpattempfu    LIKE piqdbagr_foll_up-cpattempfu, "신청학점
        cpearnedfu    LIKE piqdbagr_foll_up-cpearnedfu, "취득학점
        modreg_id     TYPE hrpad506-id,
        adatanr       TYPE hrpad506-adatanr,

        " 과거
        reperyr       LIKE hrpad506-reperyr,
        reperid       LIKE hrpad506-reperid,
        resmid        LIKE hrpad506-resmid,
        resm_short    TYPE hrp1000-short,
        resm_stext    TYPE hrp1000-stext,
        resmstatus    TYPE hrpad506-smstatus,
        resmstatus_t  TYPE t7piqsmstatt-smstatust,

        re_gradesym   LIKE piqdbagr_gen-gradesym,   "성적기호
        re_cpearnedfu LIKE piqdbagr_foll_up-cpearnedfu, "취득학점

        repexcept     TYPE hrpad506-repexcept, " 대체 예외처리

        reid          LIKE hrpad506-reid,

        agrid         LIKE piqdbagr_gen-agrid,
        reagrid       LIKE piqdbagr_gen-agrid,

        proc_gb(1), "

        change_fg(1), "
        exec_fg(1), " 처리할 라인
        row_color(4),
        styles        TYPE lvc_t_styl,
      END OF gt_data1.

DATA gs_maxper LIKE gt_data1.

***********************************************************************
DATA label_p_chk01(30).
