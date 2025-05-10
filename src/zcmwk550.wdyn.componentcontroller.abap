METHOD get_data_list .

  DATA lt_st TYPE hrobject_t.

  lt_st = VALUE #( ( objid = wd_this->ms_st-objid ) ).

  zcmclk100=>rebooked_list(
    EXPORTING
      it_st   = lt_st
    IMPORTING
      et_list = DATA(lt_list)
      et_cnt  = DATA(lt_cnt)
  ).

  DATA lo_nd_re_list TYPE REF TO if_wd_context_node.
  lo_nd_re_list = wd_context->get_child_node( name = wd_this->wdctx_re_list ).

  lo_nd_re_list->bind_table( new_items = lt_list ).

  DATA lo_nd_re_cnt TYPE REF TO if_wd_context_node.
  DATA lo_el_re_cnt TYPE REF TO if_wd_context_element.
  DATA ls_re_cnt TYPE wd_this->element_re_cnt.
  lo_nd_re_cnt = wd_context->get_child_node( name = wd_this->wdctx_re_cnt ).
  lo_el_re_cnt = lo_nd_re_cnt->get_element( ).

  READ TABLE lt_cnt INTO ls_re_cnt INDEX 1.

  lo_el_re_cnt->set_static_attributes(
    static_attributes = ls_re_cnt ).

  wd_this->mt_relist = lt_list.



ENDMETHOD.

METHOD pop_msg .

  DATA : lv_msg_text       TYPE string.
  DATA : lv_msg_text_tab   TYPE string_table.
  DATA : lv_popup_msg_type TYPE wdr_popup_msg_type.
  DATA : lv_btn_type  TYPE wdr_popup_button_kind  VALUE '1'.
  DATA lr_msg_window TYPE REF TO if_wd_window.
  DATA lr_msg_manager TYPE REF TO if_wd_window_manager.

  lr_msg_manager = wd_this->wd_get_api( )->get_window_manager( ).

  APPEND wd_this->mv_msg TO lv_msg_text_tab.
  IF wd_this->mv_msgt IS NOT INITIAL.
    lv_msg_text_tab = wd_this->mv_msgt.
  ENDIF.

  CASE msg_type.
    WHEN 'S'.
      lv_popup_msg_type = 1.
    WHEN OTHERS.
      lv_popup_msg_type = 3.
  ENDCASE.

  IF action_yes IS NOT INITIAL.
    lv_btn_type = '4'.
    lv_popup_msg_type = 2.
  ENDIF.

  IF action_ok IS NOT INITIAL.
    lv_btn_type = '3'.
    lv_popup_msg_type = 1.
  ENDIF.

  lr_msg_window = lr_msg_manager->create_popup_to_confirm(
    text            = lv_msg_text_tab
    button_kind     = lv_btn_type
    message_type    = lv_popup_msg_type
*   close_button    = abap_false
    window_title    = '메시지'
    window_position = 'CENTER'
*   window_width    = '400'
*   window_height   = '220'
  ).

  IF action_yes IS NOT INITIAL.
    lr_msg_window->subscribe_to_button_event(
      EXPORTING
        button            = '7' "YES
        action_name       = action_yes
        action_view       = wd_this->mv_msg_api
        is_default_button = abap_true ).
  ENDIF.

  IF action_no IS NOT INITIAL.
    lr_msg_window->subscribe_to_button_event(
      EXPORTING
        button            = '8' "NO
        action_name       = action_no
        action_view       = wd_this->mv_msg_api
        is_default_button = abap_false ).
  ENDIF.

  IF action_ok IS NOT INITIAL.
    lr_msg_window->subscribe_to_button_event(
      EXPORTING
        button            = '4' "ok
        action_name       = action_ok
        action_view       = wd_this->mv_msg_api
        is_default_button = abap_true ).
  ENDIF.

  lr_msg_window->open( ).
  CLEAR wd_this->mv_msgt.

ENDMETHOD.

METHOD set_logoninfo .
  DATA: node_logoninfo TYPE REF TO if_wd_context_node,
        stru_logoninfo TYPE if_componentcontroller=>element_ex_cslogoninfo.

  node_logoninfo = wd_context->get_child_node(
    name = if_componentcontroller=>wdctx_ex_cslogoninfo ).

*{관리자권한 임의id로 호출하기: 2012.03.30
  CALL FUNCTION 'ZCM_GET_DEBUGGING_ID'
    CHANGING
      cv_uname = sy-uname
      cv_attrb = wd_this->mv_uname.
*}
  stru_logoninfo-otype = 'ST'.
  stru_logoninfo-uname = sy-uname.

  node_logoninfo->bind_structure(
    EXPORTING
      new_item             = stru_logoninfo
      set_initial_elements = abap_true
  ).


  DATA: lr_cmp_usage TYPE REF TO if_wd_component_usage.
  lr_cmp_usage = wd_this->wd_cpuse_logon_usage( ).

  IF lr_cmp_usage->has_active_component( ) IS INITIAL.
    lr_cmp_usage->create_component( ).
  ENDIF.

  DATA: node_cslogon TYPE REF TO if_wd_context_node,
        stru_cslogon TYPE if_componentcontroller=>element_cslogon.

  node_cslogon = wd_context->get_child_node(
    name = if_componentcontroller=>wdctx_cslogon
  ).

  node_cslogon->get_static_attributes(
    IMPORTING
      static_attributes = stru_cslogon
  ).

  IF stru_cslogon-error IS NOT INITIAL.
*(EP권한관리 메시지: 2017.08.28 김상현
    IF stru_cslogon-emesg IS NOT INITIAL.
      wd_assist->show_message(
        EXPORTING
          ir_controller = CONV #( wd_this->wd_get_api( ) )
          im_msgid      = wd_assist->co_msg_class
          im_msgno      = '000'
          im_msgty      = 'E'
          im_msgv1      = stru_cslogon-emesg
      ).
      RETURN.
    ENDIF.
*)
    wd_assist->show_message(
      EXPORTING
        ir_controller = CONV #( wd_this->wd_get_api( ) )
        im_msgid      = 'ZMCCM01'
        im_msgno      = '004'
        im_msgty      = 'E'
        im_msgv1      = sy-uname
        im_msgv2      = 'Student'
    ).
    RETURN.
  ENDIF.

  DATA: node_student TYPE REF TO if_wd_context_node,
        stru_student TYPE if_componentcontroller=>element_student.

  node_student = node_cslogon->get_child_node(
    name = if_componentcontroller=>wdctx_student
  ).
  node_student->get_static_attributes(
    IMPORTING
      static_attributes = stru_student
  ).

  wd_this->ms_st = stru_student.


ENDMETHOD.

METHOD set_title .

  DATA lo_nd_csheader TYPE REF TO if_wd_context_node.
  DATA lo_el_csheader TYPE REF TO if_wd_context_element.
  DATA ls_csheader TYPE wd_this->element_csheader.

  DATA lv_phname TYPE wd_this->element_csheader-phname.
  DATA api_component  TYPE REF TO if_wd_component.
  DATA web_name TYPE REF TO if_wd_application.
  DATA rp TYPE REF TO if_wd_rr_application.
  DATA lv_name TYPE string.

  api_component = wd_this->wd_get_api( ).
  web_name = api_component->get_application( ).
  rp = web_name->get_application_info( ).
  lv_name = rp->get_name( ).

  SELECT SINGLE description FROM wdy_applicationt
    INTO lv_phname
    WHERE application_name = lv_name
      AND langu = sy-langu.
  REPLACE '[CM]' WITH '' INTO lv_phname.

  lo_nd_csheader = wd_context->get_child_node( name = wd_this->wdctx_csheader ).
  lo_el_csheader = lo_nd_csheader->get_element( ).
  lo_el_csheader->set_attribute(
    name  = `PHNAME`
    value = lv_phname ).


ENDMETHOD.

method WDDOAPPLICATIONSTATECHANGE .
endmethod.

method WDDOBEFORENAVIGATION .
endmethod.

method WDDOEXIT .
endmethod.

METHOD wddoinit .

  set_logoninfo( ).
  set_title( ).

  get_data_list( ).



ENDMETHOD.

method WDDOPOSTPROCESSING .
endmethod.

