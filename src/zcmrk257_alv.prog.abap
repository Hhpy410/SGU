*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_ALV
*&---------------------------------------------------------------------*

DATA: gt_xls_fcat   TYPE lvc_t_fcat.
DATA: gt_grid_fcat  TYPE lvc_t_fcat,
      gt_grid_fcat2 TYPE lvc_t_fcat.

DATA: g_custom_container TYPE REF TO cl_gui_custom_container.
DATA: g_container  TYPE REF TO cl_gui_container,
      g_container2 TYPE REF TO cl_gui_container.
DATA: g_docking_container   TYPE REF TO cl_gui_docking_container.
DATA: g_grid  TYPE REF TO cl_gui_alv_grid,
      g_grid2 TYPE REF TO cl_gui_alv_grid.
DATA: g_splitter   TYPE REF TO cl_gui_splitter_container.
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

DATA: gv_tot TYPE i,
      gv_sel TYPE i,
      gv_cur TYPE i.

DATA: gv_title TYPE text,
      gv_keyda TYPE datum.

DATA: gf_time1     TYPE i,
      gf_time2     TYPE i,
      gf_runtime   TYPE i,
      gf_starttime LIKE sy-uzeit,
      gf_endtime   LIKE sy-uzeit.

DATA : BEGIN OF gt_menu OCCURS 0,
         fcode LIKE sy-ucomm,
       END OF gt_menu .
DATA: gs_mod_cells TYPE lvc_s_modi.

*-----------------------------------------------------------------------

*DATA: gv_username LIKE t527x-orgtx ,
*      gv_return.
DATA : z_msg    TYPE string,
       z_answer,
       z_return.
DATA : zflag.

DATA : g_custom_container2 TYPE REF TO cl_gui_custom_container,
       g_container21       TYPE scrfname VALUE 'CTRL_ALV2',
*      g_grid2             TYPE REF TO cl_gui_alv_grid,
       it_fieldcat_main    TYPE lvc_t_fcat.
DATA : gs_layout_lvc   TYPE lvc_s_layo,
       gs_gsetting     TYPE lvc_s_glay,
       gs_print_lvc    TYPE lvc_s_prnt,
       gs_fieldcat_lvc TYPE lvc_s_fcat,
       gt_fieldcat_lvc TYPE lvc_t_fcat,
       it_fieldcat_lvc TYPE slis_t_fieldcat_alv,
       wa_fieldcat_lvc TYPE slis_fieldcat_alv,
       gs_sort_lvc     TYPE lvc_s_sort,
       gt_sort_lvc     TYPE lvc_t_sort,
       gs_modi_cell    TYPE lvc_s_modi,
       gt_modi_cell    TYPE lvc_t_modi,
       gs_exclude      TYPE ui_func,
       gt_exclude      TYPE ui_functions,
       gs_dropdown     TYPE lvc_s_drop,
       gt_dropdown     TYPE lvc_t_drop,
       gt_scoltab      TYPE lvc_t_scol,
       gs_scoltab      TYPE lvc_s_scol,
       gt_celltab      TYPE lvc_t_styl,
       gs_celltab      TYPE lvc_s_styl,
       gt_sels         TYPE lvc_t_row,
       gs_sels         TYPE lvc_s_row,
       gs_f4           TYPE lvc_s_f4,
       gt_f4           TYPE lvc_t_f4,
       gt_qinfo_lvc    TYPE lvc_t_qinf.
DATA:  gs_stable           TYPE lvc_s_stbl.
DATA:  gs_fcat             TYPE lvc_s_fcat.
DATA:  gs_variant          LIKE disvariant.
