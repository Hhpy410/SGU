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
*    METHODS: handle_data_changed
*             FOR EVENT data_changed OF cl_gui_alv_grid
*             IMPORTING er_data_changed
*                       e_onf4 .

    METHODS: handle_hotspot_click
                FOR EVENT hotspot_click OF cl_gui_alv_grid
                IMPORTING e_row_id
                          e_column_id
                          es_row_no .

ENDCLASS.                    "LCL_EVENT_RECEIVER__GRID DEFINITION
*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVER_GRID IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_event_receiver_grid IMPLEMENTATION.

* Data 변경시 처리
*  METHOD handle_data_changed.
*    PERFORM grid_data_changed USING er_data_changed e_onf4.
*  ENDMETHOD.

* Hotspot시...
  METHOD handle_hotspot_click.
    PERFORM display_hotspot_click USING e_row_id-index e_column_id-fieldname .
  ENDMETHOD.                    "handle_DOUBLE_CLICK

ENDCLASS.                    "LCL_EVENT_RECEIVER__GRID IMPLEMENTATION
