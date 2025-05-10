*&---------------------------------------------------------------------*
*&  Include           MZCMR6294C01
*&---------------------------------------------------------------------*
CLASS: lcl_event_receiver_grid   DEFINITION DEFERRED.

DATA: g_event_receiver_grid   TYPE REF TO lcl_event_receiver_grid .
*---------------------------------------------------------------------*
*       CLASS lcl_event_receiver_std DEFINITION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_event_receiver_grid DEFINITION.
  PUBLIC SECTION.
    METHODS: handle_hotspot_click
                FOR EVENT hotspot_click OF cl_gui_alv_grid
                IMPORTING e_row_id
                          e_column_id
                          es_row_no .
  PRIVATE SECTION.
ENDCLASS.                    "lcl_event_receiver DEFINITION
*&---------------------------------------------------------------------*
*&       Class LCL_EVENT_RECEIVER_STD
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS lcl_event_receiver_grid IMPLEMENTATION.
* Hotspot시...
  METHOD handle_hotspot_click.
    PERFORM display_hotspot_click USING e_row_id-index
                                        e_column_id-fieldname .
  ENDMETHOD.                    "handle_DOUBLE_CLICK
ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION
