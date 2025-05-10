*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_T01
*&---------------------------------------------------------------------*
TYPE-POOLS: slis, vrm.
CONSTANTS: gc_set    TYPE c VALUE 'X'.
CONSTANTS: gc_extension   TYPE i VALUE 3000.  "Docking size

TABLES: sscrfields, hrp1000.

* st_info
DATA: BEGIN OF gt_st_info OCCURS 0,
        st_objid TYPE hrobjid,
        st_num   LIKE hrp1000-short, "학번
        st_name  LIKE hrp1000-stext, "이름
      END OF gt_st_info.

*  sm_info
DATA: BEGIN OF gt_se_info OCCURS 0,
        se_objid TYPE hrobjid,
        se_short LIKE hrp1000-short, "과목코드
        se_stext LIKE hrp1000-stext, "과목명
      END OF gt_se_info.

DATA: BEGIN OF gt_data_create OCCURS 0.
        INCLUDE STRUCTURE zcmta491_regist. "학년도,학기,학번,과목코드
DATA:
        new(1),                         "신규
        type     LIKE zcmt9902-type,    "오류
        emsg     LIKE zcmt9902-message, "비고(remark)
        se_objid LIKE hrp1000-objid,
        se_txt   LIKE hrp1000-stext,    "과목명
*              o_sobid  LIKE hrp1001-sobid,    "개설학과
*              o_txt    LIKE hrp1000-stext,    "개설학과명
*              cpopt    LIKE hrp1741-cpopt,    "과목학점
      END OF gt_data_create.

DATA BEGIN OF gt_apply_data  OCCURS 0.
*학년도,학기,stobjid,선택1,선택2,시간
INCLUDE STRUCTURE zcmt2200.
DATA:
* 학생정보(ST)
  st_num    LIKE hrp1000-short, "학번
  st_name   LIKE hrp1000-stext, "이름

* 선택1,과목정보(SM)
  sm_objid1 LIKE hrp1000-objid, "sm objid
  sm_stext1 LIKE hrp1000-stext, "과목명

* 선택2,과목정보(SM)
  sm_objid2 LIKE hrp1000-objid, "sm objid
  sm_stext2 LIKE hrp1000-stext, "과목명

  color     TYPE lvc_t_scol,
  END OF gt_apply_data .



DATA: gv_filename LIKE rlgrap-filename. "업로드할 파일명

FIELD-SYMBOLS: <fs_tab>  TYPE table,
               <fs_line>.

DATA  z_answer.
DATA: lt_tinfo TYPE zcms023_tab,
      ls_tinfo TYPE zcms023,
      lv_keyda TYPE datum.

DATA : BEGIN OF gt_menu OCCURS 0,
         fcode LIKE sy-ucomm,
       END OF gt_menu .

DATA  gv_tname(30). "layout table name

TYPES ty_r_hrobjid TYPE RANGE OF hrobjid.




*--------------------------------------------------------------------*
* # 19.08.2024 10:57:10 # Change Version
*--------------------------------------------------------------------*
" 추가


CLASS lcl_alv_grid DEFINITION DEFERRED.
DATA go_grid  TYPE REF TO lcl_alv_grid.
DATA go_grid2 TYPE REF TO lcl_alv_grid.
DATA go_grid_log TYPE REF TO lcl_alv_grid.

DATA: gt_log TYPE zcmslog OCCURS 0 WITH HEADER LINE.

DATA gs_timelimits TYPE piqtimelimits.
DATA gs_perit TYPE t7piqperiodt .

DATA gv_answer(1).


DATA: BEGIN OF gt_form OCCURS 0,
        stno    LIKE zcmta491_regist-stno, "학번
        ssshort TYPE short_d, "분반코드
      END OF gt_form.

DATA: BEGIN OF gt_data OCCURS 0,
        migration1(1),
        migration2(1),
        save(1),
        peryr         TYPE zcmt9562-piqperyr, "수강신청학년도
        perid         TYPE zcmt9562-piqperid, "수강신청학기
        objid         TYPE hrp9562-objid,     "student objid
        sobid         TYPE hrp1001-sobid,
        student12     TYPE zcmta446-student12, "학번
        stnm          TYPE hrp1000-stext,
        st_stscd      TYPE zcmta446-st_stscd, "학적상태
        st_stscdt     TYPE zcmt0101-com_nm,
        o_objid       TYPE zcmta446-o_objid,
        o_short       TYPE zcmta446-o_short,
        sc_objid1     TYPE zcmta446-sc_objid1, "1전공  objid
        sc_short1     TYPE zcmta446-sc_short1, "1전공명
        adatanr       TYPE zcmt9562-adatanr,
        sm_id         TYPE zcmt9562-sm_id,
        repeatyr      TYPE zcmt9562-repeatyr,
        repeatid      TYPE zcmt9562-repeatid,
        rep_module    TYPE zcmt9562-rep_module,
        con_grd       TYPE zcmt9562-con_grd,
        credit        TYPE zcmt9562-credit,
        repeat_cd     TYPE zcmt9562-repeat_cd,
        no_cnt        TYPE zcmt9562-no_cnt,

        h506_adatanr  TYPE hrpad506-adatanr,
        h506_reperyr  TYPE hrpad506-reperyr,
        h506_reperid  TYPE hrpad506-reperid,
        h506_resmid   TYPE hrpad506-resmid,
        h506_reid     TYPE hrpad506-reid,
        h506_repeatfg TYPE hrpad506-repeatfg,
        h506_smobjid  TYPE hrpad506-smobjid,
        h506_stobjid  TYPE hrpad506-stobjid,

        row_color     TYPE char4,
        cell_color    TYPE lvc_t_scol,

      END OF gt_data.

DATA: BEGIN OF gt_hrpad506_retake,
        peryr       TYPE zcmt9562-piqperyr, "수강신청학년도
        perid       TYPE zcmt9562-piqperid, "수강신청학기
        objid       TYPE hrp9562-objid,     "student objid
        h506_resmid TYPE hrpad506-resmid,
        h506_reid   TYPE hrpad506-reid,

      END OF gt_hrpad506_retake.

DATA gt_h1001    TYPE TABLE OF hrp1001 WITH HEADER LINE.
DATA gt_hrpad506 TYPE TABLE OF hrpad506 WITH HEADER LINE.

DATA gv_mode(1).

DATA : BEGIN OF gs_s200 ,
         stno LIKE zcmta491_regist-stno,
         stid LIKE hrp1000-objid,
         stnm LIKE hrp1000-stext,
       END OF gs_s200.

DATA : BEGIN OF gt_stsm  OCCURS 0,
         stno      LIKE zcmta491_regist-stno,
         stid      LIKE hrp1000-objid,
         stnm      LIKE hrp1000-stext,
         peryr     LIKE zcmta491_regist-peryr,
         perid     LIKE zcmta491_regist-perid,
         perit     LIKE t7piqperiodt-perit,
         ssshort   LIKE zcmta491_regist-ssshort,
         ssobjid   LIKE hrp1000-objid,
         ssostext  LIKE hrp1000-stext,
         ernam     LIKE zcmta491_regist-ernam,
         erdat     LIKE zcmta491_regist-erdat,
         ertim     LIKE zcmta491_regist-ertim,
         check     TYPE flag,
         change_fg TYPE flag,
       END OF   gt_stsm.
*--------------------------------------------------------------------*
TYPES: BEGIN OF ty_period,
         peryr LIKE hrpad506-peryr,
         perid LIKE hrpad506-perid,
         keyda LIKE hrp1000-begda,
       END OF ty_period.
DATA gt_period TYPE TABLE OF ty_period.

DATA: gt_row TYPE lvc_t_row,
      gs_row TYPE lvc_s_row.

DATA: gv_selected_num  TYPE numc10,
      gv_update_record TYPE numc10,
      gv_msg           TYPE string.
*--------------------------------------------------------------------*
DATA gr_stobjid TYPE RANGE OF hrobjid WITH HEADER LINE.
*--------------------------------------------------------------------*
DATA: gv_tot      TYPE i,
      gv_cnt      TYPE i,
      gv_100_cnt  TYPE i,
      gv_1000_cnt TYPE i.
