"! This is demo for FALV full screen with partly dynamic GUI STATUS
"! done by Lukasz Pegiel for http://abapblog.com
report zdemo_falv03.

data: sflight type standard table of sflight.

class lcl_test definition inheriting from zcl_falv.
  public section.

  protected section.
    "redefinition of event handler
    methods evf_user_command redefinition.
  private section.

endclass.

class lcl_test implementation.

  method evf_user_command.
    case e_ucomm.
      when zcl_falv_dynamic_status=>b_01.
        call function 'POPUP_DISPLAY_MESSAGE'
          exporting
            titel = 'Popup'   " Title
            msgid = '00'
            msgty = 'S'
            msgno = '001'
            msgv1 = 'Button 1 clicked'.
      when zcl_falv_dynamic_status=>b_02.
        call function 'POPUP_DISPLAY_MESSAGE'
          exporting
            titel = 'Popup'   " Title
            msgid = '00'
            msgty = 'S'
            msgno = '001'
            msgv1 = 'Button 2 clicked'.
      when others.
        super->evf_user_command( e_ucomm ).
    endcase.
  endmethod.
endclass.

start-of-selection.


  select * up to 100 rows
  into corresponding fields of table @sflight
  from sflight. "#EC CI_NOWHERE

  "creation of falv with local redefinition
  data falv type ref to lcl_test.
  falv ?= lcl_test=>create( changing ct_table = sflight ) .

  "Add title variable
  falv->title_v1 = 'ZDEMO_FALV03'.

  "Add button into GUI status at for function F01 (in partial dynamic GUI Status we can have up to 19 buttons)
  falv->gui_status->add_button(
    exporting
      iv_button              = zcl_falv_dynamic_status=>b_01
      iv_text                = 'POPUP 01'
      iv_icon                = icon_abc
  )->add_button(
    exporting
      iv_button              = zcl_falv_dynamic_status=>b_02
      iv_text                = 'POPUP 02'
      iv_icon                = icon_address
  ).

  "Display full screen grid
  falv->display( ).
