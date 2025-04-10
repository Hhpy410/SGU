*&---------------------------------------------------------------------*
*&  Include           ZCMRA121_C_VIEW
*&---------------------------------------------------------------------*
CLASS lcl_event_receiver_grid DEFINITION DEFERRED.
CLASS lcl_event               DEFINITION DEFERRED.
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
*----------------------------------------------------------------------*
* CLASS lcl_event DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_event DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS:
*     Hotspot Handler
      on_hotspot_click ABSTRACT FOR EVENT link_click
        OF cl_salv_events_table IMPORTING row column,

      call_transaction_piqst00 IMPORTING pv_stobjid TYPE hrp1000-objid.

ENDCLASS.
*----------------------------------------------------------------------*
* CLASS lcl_event IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_event IMPLEMENTATION.

  METHOD call_transaction_piqst00.

    IF pv_stobjid IS INITIAL.
      MESSAGE s398(00) WITH '학번이 부정확합니다.'.
      EXIT.
    ENDIF.

    SET PARAMETER ID: 'STUDENT' FIELD pv_stobjid.   "오브젝트 id
    CALL TRANSACTION 'PIQST00'.

  ENDMETHOD.

ENDCLASS.
