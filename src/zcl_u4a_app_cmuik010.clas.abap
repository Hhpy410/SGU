class ZCL_U4A_APP_CMUIK010 definition
  public
  final
  create public .

public section.

  interfaces /U4A/IF_SERVER .

  data:
    BEGIN OF gs_cond,
        appid   TYPE zcmtk010-appid,
        appnm   TYPE /u4a/t0010-appnm,
        seqno   TYPE zcmtk010-seqno,
        ddtext  TYPE zcmtk010-ddtext,
        code_ty TYPE zcmtk010-code_ty,
        code    TYPE zcmtk010-code,
      END OF gs_cond .
  data:
    gt_list LIKE TABLE OF gs_cond .
  data GS_NEW like GS_COND .
  data AT_CODE_TY type TIHTTPNVP .
  data GV_INDEX type INT4 .

  methods CONSTRUCTOR .
  methods EV_APP_ID
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_NEW
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_NEW_OK
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_SAVE
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods MSG_TOAST
    importing
      !I_MSG type STRING .
  methods EV_DELETE_OK
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_DELETE
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
  methods EV_DETAIL
    importing
      value(IO_SERVER) type ref to IF_HTTP_SERVER
      value(IO_UIOBJ) type ref to /U4A/CL_UI_ELEMENT
      value(IT_FILES) type /U4A/Y0006
      value(IT_FORM_DATA) type TIHTTPNVP
      !I_EVENT_NAME type STRING
      value(I_FDATA) type DATA optional
      !I_ID type ANY .
protected section.
private section.

  aliases AR_PARENT_CONTROL
    for /U4A/IF_SERVER~AR_PARENT_CONTROL .
  aliases AR_VIEW
    for /U4A/IF_SERVER~AR_VIEW .
  aliases AS_SERVER_REQ_INFO
    for /U4A/IF_SERVER~AS_SERVER_REQ_INFO .
  aliases AT_APP_USAGE
    for /U4A/IF_SERVER~AT_APP_USAGE .
  aliases AT_SESSIONS
    for /U4A/IF_SERVER~AT_SESSIONS .

  methods GET_DATA_LIST .
  methods SET_TITLE
    importing
      !I_CLEAR type FLAG optional
      !I_TXT type STRING optional .
ENDCLASS.



CLASS ZCL_U4A_APP_CMUIK010 IMPLEMENTATION.


  method /U4A/IF_SERVER~HANDL_ON_EXIT  ##NEEDED.
    "Define it if necessary.
  endmethod.


  method /U4A/IF_SERVER~HANDL_ON_HASHCHANGE  ##NEEDED.
    "Define it if necessary.
  endmethod.


  METHOD /u4a/if_server~handl_on_init  ##NEEDED.
    "Define it if necessary.

    SELECT domvalue_l ddtext FROM dd07t
      INTO TABLE at_code_ty
      WHERE domname = 'ZCMK_CODE_TY'
        AND ddlanguage = sy-langu.

    INSERT INITIAL LINE INTO at_code_ty INDEX 1.

  ENDMETHOD.


  method /U4A/IF_SERVER~HANDL_ON_MESSAGE  ##NEEDED.
    "Define it if necessary.
  endmethod.


  method /U4A/IF_SERVER~HANDL_ON_REQUEST  ##NEEDED.
    "Define it if necessary.
  endmethod.


  method /U4A/IF_SERVER~HANDL_ON_RESPONSE  ##NEEDED.
    "Define it if necessary.
  endmethod.


  method CONSTRUCTOR.

  endmethod.


  METHOD ev_app_id.

    get_data_list( ).


  ENDMETHOD.


  METHOD ev_delete.

    CALL METHOD /u4a/cl_utilities=>get_selected_index
      EXPORTING
        i_event_name = i_event_name
      IMPORTING
        e_index      = gv_index.

    /u4a/cl_utilities=>m_messagebox(
      io_view          = ar_view
      i_msgtx          = '삭제하시겠습니까?'
      i_popup_type     = /u4a/cl_utilities=>cs_m_msg_box_tp-confirm
      i_callback_event = 'EV_DELETE_OK'
    ).


  ENDMETHOD.


  METHOD ev_delete_ok.

    CHECK i_event_name = 'OK'.

    READ TABLE gt_list INTO DATA(ls_list) INDEX gv_index.
    CHECK sy-subrc = 0.

    DELETE FROM zcmtk010 WHERE appid = ls_list-appid
                           AND seqno = ls_list-seqno.
    IF sy-subrc = 0.
      COMMIT WORK.
      msg_toast( '삭제되었습니다.' ).
      get_data_list( ).
    ENDIF.

    set_title( i_clear = 'X' ).


  ENDMETHOD.


  METHOD ev_detail.

    DATA lv_index TYPE i.

    CALL METHOD /u4a/cl_utilities=>get_selected_index
      EXPORTING
        i_event_name = i_event_name
      IMPORTING
        e_index      = lv_index.

    CLEAR gs_new.

    READ TABLE gt_list INTO gs_new INDEX lv_index.

    SET_TITLE( i_txt = | - [{ gs_new-seqno }] { gs_new-ddtext }| ).

  ENDMETHOD.


  METHOD ev_new.

    CLEAR : gs_new.

    IF gs_cond-appid IS INITIAL.
      msg_toast( 'App ID를 입력하세요.' ).
      RETURN.
    ENDIF.

    CHECK gs_cond-appid IS NOT INITIAL AND gs_cond-appnm IS NOT INITIAL.

    gs_new-appid = gs_cond-appid.
    gs_new-appnm = gs_cond-appnm.

    CALL METHOD /u4a/cl_utilities=>dialog_open
      EXPORTING
        io_view     = ar_view
        i_dialog_id = 'DIALOG1'.


  ENDMETHOD.


  METHOD ev_new_ok.

    CHECK gs_new-seqno IS NOT INITIAL.
    CHECK gs_new-ddtext IS NOT INITIAL.
    CHECK gs_new-code_ty IS NOT INITIAL.

    SELECT COUNT(*) FROM zcmtk010
      WHERE appid = gs_new-appid
        AND seqno = gs_new-seqno.
    IF sy-subrc = 0.
      msg_toast( '중복되는 순번입니다.' ).
      RETURN.
    ENDIF.

    CALL METHOD /u4a/cl_utilities=>dialog_close
      EXPORTING
        io_view     = ar_view
        i_dialog_id = 'DIALOG1'.


  ENDMETHOD.


  METHOD ev_save.

    DATA ls_010 TYPE zcmtk010.

    MOVE-CORRESPONDING gs_new TO ls_010.

    MODIFY zcmtk010 FROM ls_010.
    COMMIT WORK.

    msg_toast( '저장되었습니다.' ).

    CLEAR gs_new.

    get_data_list( ).

    set_title( i_clear = 'X' ).

  ENDMETHOD.


  METHOD get_data_list.
    set_title( i_clear = 'X' ).

    IF gs_cond-appid IS INITIAL.
      msg_toast( 'APP ID를 입력하세요.' ).
      RETURN.
    ENDIF.

    CLEAR: gt_list, gs_cond-appnm, gs_new.

    TRANSLATE gs_cond-appid TO UPPER CASE.
    SELECT SINGLE appnm FROM /u4a/t0010
      INTO gs_cond-appnm
      WHERE appid = gs_cond-appid.
    CHECK sy-subrc = 0.

    SELECT * FROM zcmtk010
      INTO TABLE @DATA(lt_010)
      WHERE appid = @gs_cond-appid.
    SORT lt_010 BY seqno.

    gt_list = CORRESPONDING #( lt_010 ).

  ENDMETHOD.


  METHOD msg_toast.

    CALL METHOD /u4a/cl_utilities=>m_messagetoast
      EXPORTING
        io_view = ar_view
        i_msgtx = i_msg.

  ENDMETHOD.


  METHOD set_title.

    DATA lv_text TYPE string.

    CASE i_clear.
      WHEN 'X'.
        lv_text = '코드 내역'.
      WHEN OTHERS.
        lv_text = '코드 내역' && i_txt.
    ENDCASE.

    DATA lo_title TYPE REF TO /u4a/cl_uo00458.
    lo_title ?= me->/u4a/if_server~ar_view->get_ui_instance( i_id = 'TITLE4' ).
    lo_title->settext( lv_text ).

  ENDMETHOD.
ENDCLASS.
