*&---------------------------------------------------------------------*
*& Include          ZCMR1050_CLS
*&---------------------------------------------------------------------*


CLASS lcl_falv DEFINITION INHERITING FROM zcl_falv.
  PUBLIC SECTION.


  PROTECTED SECTION.
    "redefinition of event handler
    METHODS evf_top_of_page REDEFINITION.

    METHODS evf_data_changed REDEFINITION .

    METHODS evf_user_command REDEFINITION .

    METHODS evf_hotspot_click REDEFINITION.

    METHODS evf_double_click REDEFINITION.

    METHODS evf_btn_click REDEFINITION.

  PRIVATE SECTION.

ENDCLASS.
CLASS lcl_falv IMPLEMENTATION.

  METHOD evf_top_of_page.

    e_dyndoc_id->add_text( text = 'Top Of Page' sap_style = cl_dd_area=>heading ).

    e_dyndoc_id->new_line( repeat = 1 ).


  ENDMETHOD.

  METHOD evf_data_changed.

    PERFORM grid_data_changed USING me  er_data_changed e_onf4 e_ucomm.

  ENDMETHOD.

  METHOD evf_user_command.
    CASE e_ucomm.
      WHEN zcl_falv_dynamic_status=>b_03.
*        me->delete_button( zcl_falv_dynamic_status=>b_03 ).

      WHEN 'REFRESH'.
        PERFORM get_data_select.



      WHEN OTHERS.
*        super->evf_user_command( e_ucomm ).


    ENDCASE.

    me->soft_refresh( ).

  ENDMETHOD.
  METHOD evf_hotspot_click.

*    PERFORM hotspot_click USING me
*                                e_row_id
*                                e_column_id
*                                es_row_no.

  ENDMETHOD.

  METHOD evf_double_click.

*    PERFORM line_double_click USING me
*                                    e_row
*                                    e_column
*                                    es_row_no.

  ENDMETHOD.

  METHOD evf_btn_click.

    PERFORM button_click USING me es_col_id es_row_no.
    me->soft_refresh( ).

  ENDMETHOD.

ENDCLASS.
