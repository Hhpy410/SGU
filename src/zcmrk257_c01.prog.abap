*&---------------------------------------------------------------------*
*&  Include           ZCMRA210_C01
*&---------------------------------------------------------------------*
CLASS: lcl_event_receiver_grid DEFINITION DEFERRED.

DATA: g_event_receiver_grid   TYPE REF TO lcl_event_receiver_grid .
*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVER_GRID_DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_event_receiver_grid DEFINITION.

  PUBLIC SECTION.
    METHODS: handle_data_changed
                FOR EVENT data_changed  OF cl_gui_alv_grid
      IMPORTING er_data_changed e_onf4 .
    METHODS: handle_hotspot_click
                FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING e_row_id e_column_id es_row_no .
    METHODS: handle_toolbar1
                FOR EVENT toolbar       OF cl_gui_alv_grid
      IMPORTING e_object e_interactive.
    METHODS: handle_toolbar2
                FOR EVENT toolbar       OF cl_gui_alv_grid
      IMPORTING e_object e_interactive.
    METHODS: handle_onf4
                FOR EVENT onf4          OF cl_gui_alv_grid
      IMPORTING sender
                e_fieldname
                e_fieldvalue
                es_row_no
                er_event_data
                et_bad_cells
                e_display.
    METHODS: handle_user_command
                FOR EVENT user_command  OF cl_gui_alv_grid
      IMPORTING e_ucomm.
ENDCLASS.                    "LCL_EVENT_RECEIVER__GRID DEFINITION
*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVER_GRID IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_event_receiver_grid IMPLEMENTATION.

* Data 변경시 처리
  METHOD handle_data_changed.
    PERFORM grid_data_changed USING er_data_changed
                                    e_onf4.
  ENDMETHOD.

* Hotspot시...
  METHOD handle_hotspot_click.
    PERFORM display_hotspot_click USING e_row_id-index
                                        e_column_id-fieldname .
  ENDMETHOD.                    "handle_DOUBLE_CLICK

* 툴바
  METHOD handle_toolbar1.
    IF p_limit = 'X'.
      DATA: ls_toolbar  TYPE stb_button.
      ls_toolbar-function  = 'CKDAT'.
      ls_toolbar-text      = '선택'.
      ls_toolbar-quickinfo = ls_toolbar-text.
      ls_toolbar-icon      = icon_checkbox.
      APPEND ls_toolbar TO e_object->mt_toolbar.

      ls_toolbar-function  = 'UCDAT'.
      ls_toolbar-text      = '해제'.
      ls_toolbar-quickinfo = ls_toolbar-text.
      ls_toolbar-icon      = icon_wd_iframe.
      APPEND ls_toolbar TO e_object->mt_toolbar.

      ls_toolbar-function  = 'M2CRT'.
      ls_toolbar-text      = '담아놓기'.
      ls_toolbar-quickinfo = ls_toolbar-text.
      ls_toolbar-icon      = icon_page_right.
      APPEND ls_toolbar TO e_object->mt_toolbar.

      ls_toolbar-function  = 'RMDAT'.
      ls_toolbar-text      = '삭제'.
      ls_toolbar-quickinfo = ls_toolbar-text.
      ls_toolbar-icon      = icon_delete.
      APPEND ls_toolbar TO e_object->mt_toolbar.
    ENDIF.
  ENDMETHOD.                    "HANDLE_TOOLBAR1
  METHOD handle_toolbar2.
    IF p_limit = 'X'.
      DATA: ls_toolbar  TYPE stb_button.
      ls_toolbar-function  = 'M2DAT'.
      ls_toolbar-text      = '분반적용'.
      ls_toolbar-quickinfo = ls_toolbar-text.
      ls_toolbar-icon      = icon_page_left.
      APPEND ls_toolbar TO e_object->mt_toolbar.

      ls_toolbar-function  = 'ADCRT'.
      ls_toolbar-text      = '추가'.
      ls_toolbar-quickinfo = ls_toolbar-text.
      ls_toolbar-icon      = icon_insert_row.
      APPEND ls_toolbar TO e_object->mt_toolbar.

      ls_toolbar-function  = 'CLCRT'.
      ls_toolbar-text      = '삭제'.
      ls_toolbar-quickinfo = ls_toolbar-text.
      ls_toolbar-icon      = icon_delete.
      APPEND ls_toolbar TO e_object->mt_toolbar.
    ENDIF.
  ENDMETHOD.                    "HANDLE_TOOLBAR2

  METHOD handle_onf4.
    PERFORM on_f4 USING sender
                        e_fieldname
                        e_fieldvalue
                        es_row_no
                        er_event_data
                        et_bad_cells
                        e_display.
  ENDMETHOD.    " handle_onf4

  METHOD handle_user_command.
    PERFORM  handle_user_command USING e_ucomm.
  ENDMETHOD.                    "HANDLE_USER_COMMAND

ENDCLASS.                    "LCL_EVENT_RECEIVER__GRID IMPLEMENTATION
