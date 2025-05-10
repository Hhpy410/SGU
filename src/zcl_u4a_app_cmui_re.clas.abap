class ZCL_U4A_APP_CMUI_RE definition
  public
  final
  create public .

public section.

  interfaces /U4A/IF_SERVER .

  data GS_MAJOR type ZCMSC .
  data GS_STPROG type ZCMZ100 .
  data GS_STSTATUS type ZCMCL000=>TY_ST_STATUS_CD .
  data GS_PERSON type ZCMCL000=>TY_ST_PERSON .
  data GS_ORG type ZCMCL000=>TY_ST_ORGCD .
  data GS_LOGIN type ZCMCL000=>TY_ST_CMACBPST .
  data GV_KEYDT type DATUM .
  data:
    BEGIN OF gs_etc ,
        img_url TYPE string,
        pernr   TYPE ddtext,
        expand  TYPE flag,
      END OF gs_etc .
  data GV_STNO type PIQSTUDENT12 .
  data GS_ST_INFO type ZCMS004 .

  methods CONSTRUCTOR .
  methods GET_ST_INFO .
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
ENDCLASS.



CLASS ZCL_U4A_APP_CMUI_RE IMPLEMENTATION.


  method /U4A/IF_SERVER~HANDL_ON_EXIT  ##NEEDED.
    "Define it if necessary.
  endmethod.


  method /U4A/IF_SERVER~HANDL_ON_HASHCHANGE  ##NEEDED.
    "Define it if necessary.
  endmethod.


  METHOD /u4a/if_server~handl_on_init  ##NEEDED.
    "Define it if necessary.

    get_st_info(  ).
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


  METHOD get_st_info.

    IF gv_keydt IS INITIAL.
      gv_keydt = sy-datum.
    ENDIF.
    IF gv_stno IS INITIAL AND sy-uname(4) = 'ASPN'.
      gv_stno = '20220001'.
    ENDIF.

    READ TABLE as_server_req_info-t_form_fields WITH KEY name = 'PHONE' value = 'X' TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      gs_etc-expand = ''.
    ENDIF.

    SELECT SINGLE a~stobjid   AS st_id
                  a~student12 AS st_no
                  a~partner   AS st_bp
                  b~stext     AS st_nm
      INTO gs_login
      FROM cmacbpst AS a
      JOIN hrp1000 AS b ON a~stobjid = b~objid
     WHERE a~student12 =  gv_stno
       AND b~plvar = '01'
       AND b~otype = 'ST'
       AND b~istat = '1'
       AND b~begda <= gv_keydt
       AND b~endda >= gv_keydt
       AND b~langu = '3'.

    DATA lo_wd TYPE REF TO zcl_wd_common.
    lo_wd = NEW #( ).

    lo_wd->get_student_detail(
      EXPORTING
        im_objid  = gs_login-st_id
        im_datum  = gv_keydt
        im_photo  = 'X'
      IMPORTING
        ex_result = DATA(ls_result)
    ).

    gs_st_info = ls_result.

    SELECT SINGLE * FROM zcmta446
      INTO @DATA(ls_446)
      WHERE stobjid = @gs_login-st_id.
    CASE sy-langu.
      WHEN 'E'.
        SELECT SINGLE ltext FROM hrp9450
          INTO gs_st_info-assigned_orgt
          WHERE plvar = '01'
            AND otype = 'SC'
            AND objid = ls_446-sc_objid1
            AND istat = '1'
            AND langu = 'E'
            AND begda <= gv_keydt
            AND endda >= gv_keydt.
      WHEN OTHERS.
        gs_st_info-assigned_orgt = ls_446-sc_stext1.
    ENDCASE.

**전공
*    CLEAR gs_major.
*    zcmcl000=>get_st_major(
*      EXPORTING
*        it_stobj   = VALUE hrobject_t( ( objid = gs_login-st_id ) )
*        iv_keydate = gv_keydt
*      IMPORTING
*        et_stmajor = DATA(lt_major)
*    ).
*    IF lt_major IS NOT INITIAL.
*      gs_major = lt_major[ 1 ].
*    ENDIF.


  ENDMETHOD.
ENDCLASS.
