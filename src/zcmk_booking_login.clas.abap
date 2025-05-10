class ZCMK_BOOKING_LOGIN definition
  public
  inheriting from CL_ICF_BASIC_LOGIN
  create public .

public section.

  methods HTM_LOGIN
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCMK_BOOKING_LOGIN IMPLEMENTATION.


  METHOD htm_login.

    DATA lv_html TYPE string.
    DATA lv_script TYPE string.

    DATA(lv_dd) = CONV char10( |{ sy-datum(4) }.{ sy-datum+4(2) }.{ sy-datum+6(2) }| ).
    DATA(lv_tt) = CONV char10( |{ sy-uzeit(2) }:{ sy-uzeit+2(2) }:{ sy-uzeit+4(2) }| ).

    SELECT SINGLE code FROM zcmtk010
      INTO lv_html
      WHERE appid = 'ZCMUIK100'
        AND seqno = '1'.

    REPLACE `@javascript@` IN lv_html WITH iv_javascript.
    REPLACE `@hidden_fields@` IN lv_html WITH iv_hidden_fields.
    REPLACE `@action@` IN lv_html WITH me->m_sap_application.
    REPLACE `@serverTime@` IN lv_html WITH |{ lv_dd } { lv_tt }|.

    READ TABLE me->m_logmessages INTO DATA(ls_msg) WITH KEY severity = ifur_d2=>messagetype_error.
    IF sy-subrc = 0.
      DATA(lv_login_error) = abap_true.
      lv_script = |alert("{ TEXT-009 }");|.
*      window.location.href = location.href
    ELSE.
      CLEAR lv_script.
    ENDIF.
    REPLACE `@errorMsg@` IN lv_html WITH lv_script.

    rv_html = lv_html.


  ENDMETHOD.
ENDCLASS.
