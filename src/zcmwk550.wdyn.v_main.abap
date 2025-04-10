METHOD onactionfliter .

  DATA lo_nd_filter TYPE REF TO if_wd_context_node.
  DATA lo_el_filter TYPE REF TO if_wd_context_element.
  DATA ls_filter TYPE wd_this->element_filter.
  lo_nd_filter = wd_context->get_child_node( name = wd_this->wdctx_filter ).
  lo_el_filter = lo_nd_filter->get_element( ).
  lo_el_filter->get_static_attributes( IMPORTING static_attributes = ls_filter ).


  DATA lo_nd_re_list TYPE REF TO if_wd_context_node.
  DATA lt_re_list TYPE wd_this->elements_re_list.
  lo_nd_re_list = wd_context->get_child_node( name = wd_this->wdctx_re_list ).
  lo_nd_re_list->get_static_attributes_table( IMPORTING table = lt_re_list ).

  CLEAR lt_re_list.
  lt_re_list = wd_comp_controller->mt_relist.

  CASE ls_filter-radio.
    WHEN ''.
    WHEN '2'.
      DELETE lt_re_list WHERE perid = '011' OR perid = '021'.
    WHEN '3'.
      DELETE lt_re_list WHERE perid = '010' OR perid = '020'.
  ENDCASE.

  lo_nd_re_list->bind_table( lt_re_list ).

ENDMETHOD.

method WDDOAFTERACTION .
endmethod.

method WDDOBEFOREACTION .
*  data lo_api_controller type ref to if_wd_view_controller.
*  data lo_action         type ref to if_wd_action.

*  lo_api_controller = wd_this->wd_get_api( ).
*  lo_action = lo_api_controller->get_current_action( ).

*  if lo_action is bound.
*    case lo_action->name.
*      when '...'.

*    endcase.
*  endif.
endmethod.

method WDDOEXIT .
endmethod.

METHOD wddoinit .
  wd_comp_controller->mv_msg_api = wd_this->wd_get_api( ).

ENDMETHOD.

method WDDOMODIFYVIEW .
endmethod.

method WDDOONCONTEXTMENU .
endmethod.

