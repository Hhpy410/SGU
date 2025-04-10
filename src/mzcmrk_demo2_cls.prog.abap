*&---------------------------------------------------------------------*
*& Include          MZCMRK_DEMO2_CLS
*&---------------------------------------------------------------------*
*--------------------------------------------------------------------*
* # 01.02.2024 13:40:29 # 로컬 ALV CLASS 선언
*--------------------------------------------------------------------*
CLASS lcl_alv_grid DEFINITION INHERITING FROM zcl_falv.
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
CLASS lcl_alv_grid IMPLEMENTATION.

  METHOD evf_top_of_page.

    e_dyndoc_id->add_text( text = 'Top Of Page' sap_style = cl_dd_area=>heading ).

    e_dyndoc_id->new_line( repeat = 1 ).

*    e_dyndoc_id->add_link(
*      EXPORTING
*        name                   =  'naver.com'   " Name (You Can Use Any Name You Choose)
*        url                    =   'https://www.naver.com'  " URL
*        tooltip                =  'naver.com'   " Tool Tip
*        text                   =  'naver.com'    " Text
*    ).


  ENDMETHOD.

  METHOD evf_data_changed.

    PERFORM grid_data_changed USING me  er_data_changed e_onf4 e_ucomm.
*        me->refresh_table_display(
*          EXPORTING
*            i_soft_refresh = ''                " Without Sort, Filter, etc.
*          EXCEPTIONS
*            finished       = 1                " Display was Ended (by Export)
*            OTHERS         = 2
*        ).
*    SUPPRESS DIALOG.

    cl_gui_cfw=>set_new_ok_code(
      EXPORTING
        new_code = '='                  " New OK_CODE
    ).

  ENDMETHOD.

  METHOD evf_user_command.
    CASE e_ucomm.
      WHEN zcl_falv_dynamic_status=>b_03.
        me->delete_button( zcl_falv_dynamic_status=>b_03 ).

      WHEN 'REFRESH'.
        PERFORM get_data_select.

      WHEN 'BALV1'.
        MESSAGE i001(zcm01) WITH 'Set Style g_grid1'.
        PERFORM set_style_grid1 USING me.

      WHEN 'BALV2'.
        MESSAGE i001(zcm01) WITH 'Add initial line g_grid2'.

        DO 10 TIMES.
          APPEND INITIAL LINE TO gt_data2.

        ENDDO.

      WHEN OTHERS.
        super->evf_user_command( e_ucomm ).


    ENDCASE.

    me->soft_refresh( ).

  ENDMETHOD.
  METHOD evf_hotspot_click.
    CASE e_column_id-fieldname.
      WHEN 'CONNID'.
        IF me = g_grid1.
          MESSAGE i001(zcm01) WITH 'g_grid1 OBJECT'.
        ENDIF.

      WHEN 'SEATSMAX'.
        CASE me.
          WHEN g_grid2.
*            MESSAGE i001(zcm01) WITH 'g_grid2 OBJECT'.

            g_grid2->set_cell_button(
              EXPORTING
                iv_fieldname = 'PRICE'
                iv_row       = es_row_no-row_id
            ).

          WHEN g_grid3.
            MESSAGE i001(zcm01) WITH 'g_grid3 OBJECT'.
            g_grid3->set_cell_disabled(
              EXPORTING
                iv_fieldname = e_column_id-fieldname
                iv_row       = es_row_no-row_id
            ).

          WHEN OTHERS.
        ENDCASE.
      WHEN OTHERS.

    ENDCASE.

    me->soft_refresh( ).

  ENDMETHOD.

  METHOD evf_double_click.

    PERFORM line_double_click USING me
                                    e_row
                                    e_column
                                    es_row_no.
  ENDMETHOD.

  METHOD evf_btn_click.
    PERFORM button_click USING me es_col_id es_row_no.
  ENDMETHOD.

ENDCLASS.
