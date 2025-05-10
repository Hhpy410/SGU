class ZCL_FALV_DYNAMIC_STATUS definition
  public
  final
  create public .

public section.

  interfaces IF_OS_CLONE .

  types:
    BEGIN OF t_buttons,
        f01 TYPE rsfunc_txt,
        f02 TYPE rsfunc_txt,
        f03 TYPE rsfunc_txt,
        f04 TYPE rsfunc_txt,
        f05 TYPE rsfunc_txt,
        f06 TYPE rsfunc_txt,
        f07 TYPE rsfunc_txt,
        f08 TYPE rsfunc_txt,
        f09 TYPE rsfunc_txt,
        f10 TYPE rsfunc_txt,
        f11 TYPE rsfunc_txt,
        f12 TYPE rsfunc_txt,
        f13 TYPE rsfunc_txt,
        f14 TYPE rsfunc_txt,
        f15 TYPE rsfunc_txt,
        f16 TYPE rsfunc_txt,
        f17 TYPE rsfunc_txt,
        f18 TYPE rsfunc_txt,
        f19 TYPE rsfunc_txt,
        f20 TYPE rsfunc_txt,
        f21 TYPE rsfunc_txt,
        f22 TYPE rsfunc_txt,
        f23 TYPE rsfunc_txt,
        f24 TYPE rsfunc_txt,
        f25 TYPE rsfunc_txt,
        f26 TYPE rsfunc_txt,
        f27 TYPE rsfunc_txt,
        f28 TYPE rsfunc_txt,
        f29 TYPE rsfunc_txt,
        f30 TYPE rsfunc_txt,
        f31 TYPE rsfunc_txt,
        f32 TYPE rsfunc_txt,
        f33 TYPE rsfunc_txt,
        f34 TYPE rsfunc_txt,
        f35 TYPE rsfunc_txt,
      END OF t_buttons .
  types:
    BEGIN OF t_allowed_but,
        function TYPE sy-ucomm,
      END OF t_allowed_but .
  types:
    tt_excluded_but TYPE STANDARD TABLE OF sy-ucomm .
  types:
    tt_allowed_but  TYPE STANDARD TABLE OF t_allowed_but .

  constants B_01 type SY-UCOMM value 'F01' ##NO_TEXT.
  constants B_02 type SY-UCOMM value 'F02' ##NO_TEXT.
  constants B_03 type SY-UCOMM value 'F03' ##NO_TEXT.
  constants B_04 type SY-UCOMM value 'F04' ##NO_TEXT.
  constants B_05 type SY-UCOMM value 'F05' ##NO_TEXT.
  constants B_06 type SY-UCOMM value 'F06' ##NO_TEXT.
  constants B_07 type SY-UCOMM value 'F07' ##NO_TEXT.
  constants B_08 type SY-UCOMM value 'F08' ##NO_TEXT.
  constants B_09 type SY-UCOMM value 'F09' ##NO_TEXT.
  constants B_10 type SY-UCOMM value 'F10' ##NO_TEXT.
  constants B_11 type SY-UCOMM value 'F11' ##NO_TEXT.
  constants B_12 type SY-UCOMM value 'F12' ##NO_TEXT.
  constants B_13 type SY-UCOMM value 'F13' ##NO_TEXT.
  constants B_14 type SY-UCOMM value 'F14' ##NO_TEXT.
  constants B_15 type SY-UCOMM value 'F15' ##NO_TEXT.
  constants B_16 type SY-UCOMM value 'F16' ##NO_TEXT.
  constants B_17 type SY-UCOMM value 'F17' ##NO_TEXT.
  constants B_18 type SY-UCOMM value 'F18' ##NO_TEXT.
  constants B_19 type SY-UCOMM value 'F19' ##NO_TEXT.
  constants B_20 type SY-UCOMM value 'F20' ##NO_TEXT.
  constants B_21 type SY-UCOMM value 'F21' ##NO_TEXT.
  constants B_22 type SY-UCOMM value 'F22' ##NO_TEXT.
  constants B_23 type SY-UCOMM value 'F23' ##NO_TEXT.
  constants B_24 type SY-UCOMM value 'F24' ##NO_TEXT.
  constants B_25 type SY-UCOMM value 'F25' ##NO_TEXT.
  constants B_26 type SY-UCOMM value 'F26' ##NO_TEXT.
  constants B_27 type SY-UCOMM value 'F27' ##NO_TEXT.
  constants B_28 type SY-UCOMM value 'F28' ##NO_TEXT.
  constants B_29 type SY-UCOMM value 'F29' ##NO_TEXT.
  constants B_30 type SY-UCOMM value 'F30' ##NO_TEXT.
  constants B_31 type SY-UCOMM value 'F31' ##NO_TEXT.
  constants B_32 type SY-UCOMM value 'F32' ##NO_TEXT.
  constants B_33 type SY-UCOMM value 'F33' ##NO_TEXT.
  constants B_34 type SY-UCOMM value 'F34' ##NO_TEXT.
  constants B_35 type SY-UCOMM value 'F35' ##NO_TEXT.
  data FULLY_DYNAMIC type ABAP_BOOL .
  data EXCLUDED_BUTTONS type TT_EXCLUDED_BUT .
  data BUTTONS type T_BUTTONS .

  methods CONSTRUCTOR .
  methods ADD_BUTTON
    importing
      value(IV_BUTTON) type SY-UCOMM
      value(IV_TEXT) type SMP_DYNTXT-TEXT optional
      value(IV_ICON) type SMP_DYNTXT-ICON_ID optional
      value(IV_QINFO) type SMP_DYNTXT-QUICKINFO optional
      value(IV_ALLOWED) type ABAP_BOOL default ABAP_TRUE
    returning
      value(R_STATUS) type ref to ZCL_FALV_DYNAMIC_STATUS
    exceptions
      BUTTON_ALREADY_FILLED
      BUTTON_DOES_NOT_EXISTS
      ICON_AND_TEXT_EMPTY .
  methods HIDE_BUTTON
    importing
      value(IV_BUTTON) type SY-UCOMM
    returning
      value(R_STATUS) type ref to ZCL_FALV_DYNAMIC_STATUS .
  methods SHOW_BUTTON
    importing
      value(IV_BUTTON) type SY-UCOMM
    returning
      value(R_STATUS) type ref to ZCL_FALV_DYNAMIC_STATUS .
  methods GET_TOOLBAR
    exporting
      !E_TOOLBAR type T_BUTTONS .
  methods ADD_SEPARATOR
    importing
      value(IV_BUTTON) type SY-UCOMM
    returning
      value(R_STATUS) type ref to ZCL_FALV_DYNAMIC_STATUS .
  methods SHOW_TITLE
    importing
      value(IV_TEXT1) type STRING
      value(IV_TEXT2) type STRING optional
      value(IV_TEXT3) type STRING optional
      value(IV_TEXT4) type STRING optional
      value(IV_TEXT5) type STRING optional .
  methods SHOW_GUI_STATUS .
  methods EDIT_BUTTONS
    returning
      value(RT_BUTTONS) type UI_FUNCTIONS .
  PROTECTED SECTION.
    DATA allowed_buttons TYPE tt_allowed_but.
private section.
ENDCLASS.



CLASS ZCL_FALV_DYNAMIC_STATUS IMPLEMENTATION.


  METHOD add_button.
    r_status = me.
    DATA button TYPE smp_dyntxt.
    CHECK iv_button IS NOT INITIAL.

    IF iv_text IS INITIAL AND iv_icon IS INITIAL.
      RAISE icon_and_text_empty.
      RETURN.
    ENDIF.

    button-icon_id   = iv_icon.
    button-icon_text = iv_text.
    button-text      = iv_text.
    button-quickinfo = iv_qinfo.

    ASSIGN COMPONENT iv_button OF STRUCTURE buttons TO FIELD-SYMBOL(<bt>).
    IF <bt> IS ASSIGNED.
      IF <bt> IS INITIAL.
        <bt> = button.
        IF iv_allowed = abap_true.
          show_button( iv_button = iv_button ).
        ENDIF.
      ELSE.
        RAISE button_already_filled.
      ENDIF.
    ELSE.
      RAISE button_does_not_exists.
    ENDIF.
  ENDMETHOD.


  METHOD add_separator.
    r_status = me.
    add_button( EXPORTING  iv_button  = iv_button
                           iv_text    = |{ cl_abap_char_utilities=>minchar }|
                           iv_allowed = abap_true
                EXCEPTIONS OTHERS     = 0 ).
  ENDMETHOD.


  METHOD constructor.
    excluded_buttons = VALUE #( ( b_01 )
                                ( b_02 )
                                ( b_03 )
                                ( b_04 )
                                ( b_05 )
                                ( b_06 )
                                ( b_07 )
                                ( b_08 )
                                ( b_09 )
                                ( b_10 )
                                ( b_11 )
                                ( b_12 )
                                ( b_13 )
                                ( b_14 )
                                ( b_15 )
                                ( b_16 )
                                ( b_17 )
                                ( b_18 )
                                ( b_19 )
                                ( b_20 )
                                ( b_21 )
                                ( b_22 )
                                ( b_23 )
                                ( b_24 )
                                ( b_25 )
                                ( b_26 )
                                ( b_27 )
                                ( b_28 )
                                ( b_29 )
                                ( b_30 )
                                ( b_31 )
                                ( b_32 )
                                ( b_33 )
                                ( b_34 )
                                ( b_35 )
                                ( zcl_falv=>mc_fc_data_save )
                                ( zcl_falv=>fc_first_page )
                                ( zcl_falv=>fc_last_page )
                                ( zcl_falv=>fc_next_page )
                                ( zcl_falv=>fc_previous_page )
                                ( zcl_falv=>fc_print ) ).
  ENDMETHOD.


  METHOD get_toolbar.
    e_toolbar = buttons.
  ENDMETHOD.


  METHOD hide_button.
    r_status = me.
    IF iv_button IS INITIAL.
      RETURN.
    ENDIF.

    DELETE allowed_buttons WHERE function = iv_button.
    APPEND iv_button TO excluded_buttons.
  ENDMETHOD.


  METHOD if_os_clone~clone.
    SYSTEM-CALL OBJMGR CLONE me TO result.
  ENDMETHOD.


  METHOD show_button.
    r_status = me.
    IF iv_button IS INITIAL.
      RETURN.
    ENDIF.
    IF NOT line_exists( allowed_buttons[ function = iv_button ] ).
      DATA(allowed) = VALUE t_allowed_but( function = iv_button ).
      APPEND allowed TO allowed_buttons.
      DELETE excluded_buttons WHERE table_line = iv_button.
    ENDIF.
  ENDMETHOD.


  METHOD show_gui_status.
    IF sy-dynnr = zcl_falv=>c_screen_full AND fully_dynamic = abap_true.
      SET PF-STATUS 'DYNAMIC_STATUS' OF PROGRAM zcl_falv=>c_fscr_repid EXCLUDING excluded_buttons.
    ELSEIF sy-dynnr = zcl_falv=>c_screen_full.
      SET PF-STATUS 'DYNAMIC_STATUS_PART' OF PROGRAM zcl_falv=>c_fscr_repid EXCLUDING excluded_buttons.
    ELSE.
      SET PF-STATUS 'STATUS_0200' OF PROGRAM zcl_falv=>c_fscr_repid EXCLUDING excluded_buttons.
    ENDIF.
  ENDMETHOD.


  METHOD show_title.
    SET TITLEBAR 'TITLE' OF PROGRAM zcl_falv=>c_fscr_repid WITH iv_text1 iv_text2 iv_text3 iv_text4 iv_text5.
  ENDMETHOD.


  METHOD edit_buttons.

    DATA: ls_fcode TYPE ui_func.
    DATA: lt_fcode              TYPE ui_functions.

    CLEAR: lt_fcode, lt_fcode[].
    ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_undo.
    APPEND ls_fcode TO lt_fcode.
    ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_copy.
    APPEND ls_fcode TO lt_fcode.
    ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_copy_row.
    APPEND ls_fcode TO lt_fcode.
    ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_cut.
    APPEND ls_fcode TO lt_fcode.
    ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_delete_row.
    APPEND ls_fcode TO lt_fcode.
    ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_insert_row.
    APPEND ls_fcode TO lt_fcode.
    ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_append_row.
    APPEND ls_fcode TO lt_fcode.
    ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_paste.
    APPEND ls_fcode TO lt_fcode.
    ls_fcode  = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
    APPEND ls_fcode TO lt_fcode.
    ls_fcode  = cl_gui_alv_grid=>mc_fc_refresh.
    APPEND ls_fcode TO lt_fcode.

    rt_buttons = lt_fcode.

  ENDMETHOD.
ENDCLASS.
