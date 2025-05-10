*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_ALV
*&---------------------------------------------------------------------*
DATA: gt_grid_fcat  TYPE lvc_t_fcat.
DATA: g_container TYPE REF TO cl_gui_container.
DATA: g_docking_container   TYPE REF TO cl_gui_docking_container.
DATA: g_grid       TYPE REF TO cl_gui_alv_grid.
DATA: g_splitter   TYPE REF TO cl_gui_splitter_container.
DATA: gs_layout    TYPE lvc_s_layo.
DATA: gt_sort      TYPE lvc_t_sort.
DATA: gs_sort      TYPE lvc_s_sort.
DATA: gs_scroll TYPE lvc_s_stbl.
DATA: ok_code LIKE sy-ucomm.        " SCREEN OK_CODE
data  gv_count type i.
