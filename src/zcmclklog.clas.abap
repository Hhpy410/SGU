class ZCMCLKLOG definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !I_STID type PIQSTUDENT
      !IO_VIEW type ref to /U4A/CL_UI_ELEMENT .
  methods SAVE
    importing
      !I_CATEG type ZCMK_CATEG .
protected section.
private section.

  data GV_UNAME type UNAME .
  data GV_STID type PIQSTUDENT .
  data GO_VIEW type ref to /U4A/CL_UI_ELEMENT .
ENDCLASS.



CLASS ZCMCLKLOG IMPLEMENTATION.


  METHOD constructor.

    gv_uname = sy-uname.
    gv_stid = i_stid.

    go_view = io_view.


  ENDMETHOD.


  METHOD save.

    DATA : ls_cookie TYPE zcmt2024_cookie,
           ls_error  TYPE zcmt2024_error,
           ls_wdlog  TYPE zcmt2024_wdlog,
           ls_input  TYPE zcmt2024_input,
           ls_login  TYPE zcmt2024_login.
    DATA lo_ui100 TYPE REF TO zcl_u4a_app_cmuik100.
    DATA lv_tstmp TYPE timestampl.

    lo_ui100 ?= go_view->control.
    GET TIME STAMP FIELD lv_tstmp.

    CASE i_categ.
      WHEN 'C'.
        ls_cookie-stobj = gv_stid.
        ls_cookie-uname = gv_uname.
        ls_cookie-datum = sy-datum.
        ls_cookie-uzeit = sy-uzeit.
        ls_cookie-stime = lv_tstmp.
        ls_cookie-shost = sy-host.
        ls_cookie-ipaddr = go_view->control->as_server_req_info-remote_addr.
        ls_cookie-cookie = lo_ui100->gv_nfkey.

        MODIFY zcmt2024_cookie FROM ls_cookie.

      WHEN 'M'.
        ls_wdlog-stobj = gv_stid.
        ls_wdlog-uname = gv_uname.
        ls_wdlog-datum = sy-datum.
        ls_wdlog-uzeit = sy-uzeit.
        ls_wdlog-stime = lv_tstmp.
        ls_wdlog-shost = sy-host.
        ls_wdlog-ipaddr = go_view->control->as_server_req_info-remote_addr.
        ls_wdlog-message = lo_ui100->gs_msg-message.
        ls_wdlog-mtype = lo_ui100->gs_msg-type.

        MODIFY zcmt2024_wdlog FROM ls_wdlog.

      WHEN 'E'.


        ls_error-stobj = gv_stid.
        ls_error-uname = gv_uname.
        ls_error-sdate = sy-datum.
        ls_error-stime = lv_tstmp.
        ls_error-uzeit = sy-uzeit.
        ls_error-eid = lo_ui100->gs_msg-id.
        ls_error-enumber = lo_ui100->gs_msg-number.
        ls_error-emessage = lo_ui100->gs_msg-message.
        ls_error-etype = lo_ui100->gs_msg-type.

        MODIFY zcmt2024_error FROM ls_error.

      WHEN 'I'.

        DO 6 TIMES.
          DATA(lv_fname) = |STR{ sy-index }|.
          READ TABLE lo_ui100->gt_cart INTO DATA(ls_cart) INDEX sy-index.
          IF sy-subrc = 0.
            ASSIGN COMPONENT lv_fname OF STRUCTURE ls_input TO FIELD-SYMBOL(<fs>).
            CHECK sy-subrc = 0.
            <fs> = ls_cart-se_short.
          ENDIF.
        ENDDO.


        ls_input-stobj = gv_stid.
        ls_input-uname = gv_uname.
        ls_input-sdate = sy-datum.
        ls_input-stime = lv_tstmp.
        ls_input-uzeit = sy-uzeit.

        MODIFY zcmt2024_input FROM ls_input.

      WHEN 'L'.

        ls_login-stobj = gv_stid.
        ls_login-uname = gv_uname.
        ls_login-datum = sy-datum.
        ls_login-uzeit = sy-uzeit.
        ls_login-stime = lv_tstmp.
        ls_login-shost = sy-host.
        ls_login-ipaddr = go_view->control->as_server_req_info-remote_addr.
        ls_login-user_agent = go_view->control->as_server_req_info-user_agent.
        ls_login-referer = ''.

        MODIFY zcmt2024_login FROM ls_login.

    ENDCASE.

    COMMIT WORK.

  ENDMETHOD.
ENDCLASS.
