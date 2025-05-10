*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_ALV
*&---------------------------------------------------------------------*

DATA: gt_xls_fcat   TYPE lvc_t_fcat.
DATA: gt_grid_fcat  TYPE lvc_t_fcat.

DATA: g_custom_container TYPE REF TO cl_gui_custom_container.
DATA: g_container  TYPE REF TO cl_gui_container,
      g_container2 TYPE REF TO cl_gui_container,
      g_container3 TYPE REF TO cl_gui_container,
      g_container4 TYPE REF TO cl_gui_container.
DATA: g_docking_container   TYPE REF TO cl_gui_docking_container.
DATA: g_grid  TYPE REF TO cl_gui_alv_grid,
      g_grid2 TYPE REF TO cl_gui_alv_grid.
DATA: g_splitter  TYPE REF TO cl_gui_splitter_container,
      g_splitter2 TYPE REF TO cl_gui_splitter_container.
DATA: g_tree       TYPE REF TO cl_gui_alv_tree.
DATA: g_toolbar    TYPE REF TO cl_gui_toolbar.
DATA: gs_layout    TYPE lvc_s_layo.
DATA: gt_sort      TYPE lvc_t_sort.
DATA: gs_sort      TYPE lvc_s_sort.
DATA: gt_fcode     TYPE ui_functions.
DATA: gs_scroll TYPE lvc_s_stbl.
DATA: g_return    TYPE i.
DATA: gt_tree_fcat TYPE lvc_t_fcat.
DATA: gs_tree_head TYPE treev_hhdr.
DATA: gt_item_layout TYPE lvc_t_layi WITH HEADER LINE .
*
DATA: gs_hierarchy_header TYPE treev_hhdr,
      gs_node_layout      TYPE lvc_s_layn,
      gs_item_layout      TYPE lvc_s_laci.
DATA: ok_code LIKE sy-ucomm.        " SCREEN OK_CODE
DATA: g_conta TYPE REF TO cl_gui_custom_container.
DATA: gt_rows TYPE lvc_t_row,
      gs_rows TYPE lvc_s_row.

DATA: gv_title TYPE text.
*     gv_count TYPE i.

DATA: gf_time1     TYPE i,
      gf_time2     TYPE i,
      gf_runtime   TYPE i,
      gf_starttime LIKE sy-uzeit,
      gf_endtime   LIKE sy-uzeit.

DATA: gt_filt TYPE lvc_t_filt,
      gs_filt TYPE lvc_s_filt.
