*&---------------------------------------------------------------------*
*& Include          MZCMRK_DEMO2_TOP
*&---------------------------------------------------------------------*
*--------------------------------------------------------------------*
* # 01.02.2024 13:34:30 # 데이터 오브젝트 선언
*--------------------------------------------------------------------*
CLASS lcl_alv_grid DEFINITION DEFERRED.
*DATA go_grid TYPE REF TO lcl_alv_grid.

DATA g_splitter TYPE REF TO cl_gui_splitter_container.
DATA g_grid1 TYPE REF TO lcl_alv_grid.
DATA g_grid2 TYPE REF TO lcl_alv_grid.
DATA g_grid3 TYPE REF TO lcl_alv_grid.
DATA g_grid4 TYPE REF TO lcl_alv_grid.
DATA g_grid5 TYPE REF TO lcl_alv_grid.

FIELD-SYMBOLS :  <fs_grid> TYPE REF TO lcl_alv_grid.

*--------------------------------------------------------------------*
* # 01.02.2024 13:41:44 # 데이터 선언
*--------------------------------------------------------------------*
DATA ok_code TYPE syucomm.

CONSTANTS gc_falv(20) VALUE 'LCL_ALV_GRID'.
CONSTANTS gc_tabpatt(20) VALUE 'GT_DATA'.
CONSTANTS gc_g_grid(20) VALUE 'G_GRID'.

TYPES: BEGIN OF t_spfli.
         INCLUDE TYPE spfli.
TYPES:   styles     TYPE lvc_t_styl,
         row_color  TYPE char4,
         cell_color TYPE lvc_t_scol,
         change_fg  TYPE flag,
       END OF t_spfli.

TYPES: BEGIN OF t_sflight.
         INCLUDE TYPE sflight.
TYPES:   styles    TYPE lvc_t_styl,
         change_fg TYPE flag,
       END OF t_sflight.

TYPES: BEGIN OF t_hrp1000.
         INCLUDE TYPE hrp1000.
TYPES:   styles    TYPE lvc_t_styl,
         change_fg TYPE flag,
       END OF t_hrp1000.

DATA: gt_data1 TYPE STANDARD TABLE OF t_spfli.
DATA: gt_data2 TYPE STANDARD TABLE OF t_sflight.
DATA: gt_data3 TYPE STANDARD TABLE OF t_hrp1000.
DATA: gt_data4 TYPE STANDARD TABLE OF t_sflight.
DATA: gt_data5 TYPE STANDARD TABLE OF t_sflight.
