class ZCMCLK050 definition
  public
  final
  create public .

public section.

  class-methods CALL_ST_HEAD
    importing
      !AR_VIEW type ref to /U4A/CL_UI_ELEMENT
      !CONTID type ANY
      !ST_NO type PIQSTUDENT12
      !KEYDATE type DATUM default SY-DATUM
      !EXPAND type FLAG default 'X' .
  class-methods OPEN_MANUAL
    importing
      !AR_VIEW type ref to /U4A/CL_UI_ELEMENT .
  class-methods HELP_BUTTON
    importing
      !AR_VIEW type ref to /U4A/CL_UI_ELEMENT
      !U_ID type STRING .
protected section.
private section.
ENDCLASS.



CLASS ZCMCLK050 IMPLEMENTATION.


  METHOD call_st_head.

    DATA lo_app TYPE REF TO zcl_u4a_app_cmui_re.
    DATA lo_obj TYPE REF TO object.

*-----------------------------------------------------------

    CALL METHOD /u4a/cl_utilities=>reset_usage_app
      EXPORTING
        io_view   = ar_view
        iv_app_nm = contid.

    CALL METHOD /u4a/cl_utilities=>rendering_usage_app
      EXPORTING
        io_view            = ar_view
        i_app_container_id = contid
        i_appid            = 'ZCMUI_RE'
      RECEIVING
        eo_controller      = lo_obj.

    lo_app ?= lo_obj.
    CHECK lo_app IS BOUND.

    lo_app->gv_keydt = keydate.
    lo_app->gv_stno  = st_no.
    lo_app->gs_etc-expand  = expand.


  ENDMETHOD.


  METHOD help_button.

    DATA lo_control TYPE REF TO /u4a/cl_uo00863.

    CHECK ar_view IS NOT INITIAL AND u_id IS NOT INITIAL.

    READ TABLE ar_view->control->as_server_req_info-t_form_fields WITH KEY name = 'PHONE' value = 'X' TRANSPORTING NO FIELDS.
    CHECK sy-subrc = 0.

    DATA(lo_btn) = ar_view->get_ui_instance( u_id ).
    CHECK lo_btn IS NOT INITIAL AND lo_btn->uiomd = 'sap.m.Button'.

    lo_control ?= lo_btn.
    CHECK lo_control IS NOT INITIAL.

    lo_control->setvisible( '' ).


  ENDMETHOD.


  METHOD open_manual.

    DATA lv_url TYPE string.

    CONCATENATE zcmcl_counsel=>c_manual_url
                ar_view->appid '.pdf'
           INTO lv_url.

    CALL METHOD /u4a/cl_utilities=>ext_win_open
      EXPORTING
        io_view = ar_view
        url     = lv_url.

  ENDMETHOD.
ENDCLASS.
