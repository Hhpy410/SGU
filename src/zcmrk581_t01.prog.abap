*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_T01
*&---------------------------------------------------------------------*
TYPE-POOLS: slis, vrm.
CONSTANTS: gc_set    TYPE c VALUE 'X'.
CONSTANTS: gc_extension   TYPE i VALUE 3000.  "Docking size

TABLES: hrp1000, hrpad506, sscrfields.
DATA: gt_authobj  LIKE hrview    OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_data OCCURS 0,
        uname       LIKE zcmt2024_login-uname,
        datum       LIKE zcmt2024_login-datum,
        uzeit       LIKE zcmt2024_login-uzeit,
        logtp       LIKE hrp1000-stext, "로그타입
        logno       TYPE i,             "로그연번
        shost       LIKE zcmt2024_login-shost,
        ipaddr      LIKE zcmt2024_login-ipaddr,
        natio       LIKE zept0005-natio,
        saint(20)   TYPE c, "LIKE zcmt2024_cookie-saint,
        os(20)      TYPE c,
        browser(20) TYPE c,
        user_agent  LIKE zcmt2024_login-user_agent,
        cookie      LIKE zcmt2024_cookie-cookie,
        msgid       LIKE zcmt2024_wdlog-msgid,
        msgno       LIKE zcmt2024_wdlog-msgno,
        mpa01       LIKE zcmt2024_wdlog-mpa01,
        mpa02       LIKE zcmt2024_wdlog-mpa02,
        mpa03       LIKE zcmt2024_wdlog-mpa03,
        mpa04       LIKE zcmt2024_wdlog-mpa04,
        objid       LIKE hrp1000-objid, "ST
        seq         TYPE i,
        type        LIKE zcmt9902-type,
        message     LIKE zcmt9902-message,
        color       TYPE lvc_t_scol,
        celltab     TYPE lvc_t_styl,
      END OF gt_data.
*DATA: gt_copy LIKE gt_data OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_book OCCURS 0,
        objid      LIKE hrp1000-objid,
        uname      LIKE hrp1000-short,
        datum      LIKE hrpad506-bookdate,
        uzeit      LIKE hrpad506-booktime,
        smstatus   LIKE hrpad506-smstatus,
        packnumber LIKE hrpad506-packnumber,
        aname      LIKE hrp1001-uname,
      END OF gt_book.

DATA: BEGIN OF gt_logno OCCURS 0,
        uname LIKE hrp1000-short,
        datum LIKE hrpad506-bookdate,
        login TYPE i, "로그인
        smain TYPE i, "메인접속
        nc200 TYPE i, "(쿠키존재)
        mbook TYPE i, "수강신청
        input TYPE i, "6개입력
        error TYPE i, "저장에러
        xpage TYPE i, "오류내역
        xe617 TYPE i, "(617오류)
      END OF gt_logno.

CONSTANTS: gv_epl_login TYPE string VALUE 'EP Login',
           gv_bsp_login TYPE string VALUE 'Login',
           gv_req_unlck TYPE string VALUE 'REQ Unlock',
           gv_wdp_smain TYPE string VALUE 'WD Main',
           gv_wdp_mbook TYPE string VALUE 'WD Booking',
           gv_wdp_input TYPE string VALUE 'WD 6-Input',
           gv_wdp_error TYPE string VALUE 'WD Error',
           gv_bsp_xpage TYPE string VALUE 'X Page'.

DATA: gt_login  LIKE zcmt2024_login  OCCURS 0 WITH HEADER LINE,
      gt_cookie LIKE zcmt2024_cookie OCCURS 0 WITH HEADER LINE,
      gt_wdlog  LIKE zcmt2024_wdlog  OCCURS 0 WITH HEADER LINE,
      gt_input  LIKE zcmt2024_input  OCCURS 0 WITH HEADER LINE,
      gt_error  LIKE zcmt2024_error  OCCURS 0 WITH HEADER LINE,
      gt_p1000  LIKE hrp1000         OCCURS 0 WITH HEADER LINE.
*     gt_ipnat  LIKE zept0005        OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_eplog OCCURS 0,
        uname  TYPE uname,
        datum  TYPE datum,
        uzeit  TYPE uzeit,
        shost  LIKE zcmt2024_login-shost,
        ipaddr LIKE zcmt2024_login-ipaddr,
      END OF gt_eplog.

DATA: BEGIN OF gt_unlock OCCURS 0,
        user_id  TYPE uname,
        reg_date TYPE datum,
        reg_time TYPE uzeit,
        prc_date TYPE datum,
        prc_time TYPE uzeit,
        flag     TYPE c,
      END OF gt_unlock.

DATA: BEGIN OF gt_e617 OCCURS 0,
        uname TYPE uname,
        datum TYPE datum,
      END OF gt_e617.

DATA: BEGIN OF gt_stat OCCURS 0,
        logtp LIKE hrp1000-stext,
        count TYPE i,
      END OF gt_stat.

DATA: BEGIN OF gt_devi OCCURS 0,
        os(20)      TYPE c,
        browser(20) TYPE c,
        count       TYPE i,
      END OF gt_devi.

DATA: BEGIN OF gt_nati OCCURS 0,
        natio LIKE zept0005-natio,
        count TYPE i,
      END OF gt_nati.

*DATA: gt_dept LIKE hrp1000  OCCURS 0 WITH HEADER LINE.

DATA:
  con_name   TYPE dbcon-con_name VALUE 'SIPSSTEST',
  exc_ref    TYPE REF TO cx_sy_native_sql_error,
  sqlerr_ref TYPE REF TO cx_sql_exception,
  error_text TYPE string.
*&---------------------------------------------------------------------*
*&  SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN FUNCTION KEY 1.
SELECTION-SCREEN FUNCTION KEY 2.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-b01.

  PARAMETERS: p_peryr LIKE piqstregper-peryr OBLIGATORY
                        AS LISTBOX VISIBLE LENGTH 24.
  PARAMETERS: p_perid LIKE piqstregper-perid OBLIGATORY
                        AS LISTBOX VISIBLE LENGTH 24.

  SELECTION-SCREEN SKIP 1.

*PARAMETERS p_datum TYPE datum DEFAULT sy-datum OBLIGATORY.
*PARAMETERS p_uzeit TYPE uzeit.
  SELECT-OPTIONS: p_datum FOR hrpad506-bookdate OBLIGATORY NO-EXTENSION.
  SELECT-OPTIONS: p_uzeit FOR hrpad506-booktime OBLIGATORY NO-EXTENSION.
  SELECT-OPTIONS: p_objid FOR hrp1000-objid NO-DISPLAY.
  SELECT-OPTIONS: p_short FOR hrp1000-short NO-DISPLAY.
  SELECT-OPTIONS: p_stnum FOR hrp1000-short NO INTERVALS.

  SELECTION-SCREEN SKIP 1.

*PARAMETERS: p_check AS CHECKBOX.
  PARAMETERS p_step1 RADIOBUTTON GROUP gp1 DEFAULT 'X' USER-COMMAND uc.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_step2 RADIOBUTTON GROUP gp1.
    SELECTION-SCREEN COMMENT (29)  FOR FIELD p_step2.
    PARAMETERS p_xe617 TYPE numc2 DEFAULT 1.
    SELECTION-SCREEN COMMENT (8)  FOR FIELD p_xe617.
  SELECTION-SCREEN END OF LINE.

  PARAMETERS p_step3 RADIOBUTTON GROUP gp1.
  PARAMETERS p_step4 RADIOBUTTON GROUP gp1.

SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-b02.

  PARAMETERS: p_chk1 AS CHECKBOX DEFAULT 'X'. "EP Login
  PARAMETERS: p_chk2 AS CHECKBOX DEFAULT 'X'. "BSP Login
  PARAMETERS: p_chk3 AS CHECKBOX DEFAULT 'X'. "REQ Unlock
  PARAMETERS: p_chk4 AS CHECKBOX DEFAULT 'X'. "WD Main
  PARAMETERS: p_chk5 AS CHECKBOX DEFAULT 'X'. "WD Booking
  PARAMETERS: p_chk6 AS CHECKBOX DEFAULT 'X'. "WD 6-Input
  PARAMETERS: p_chk7 AS CHECKBOX DEFAULT 'X'. "WD Error
  PARAMETERS: p_chk8 AS CHECKBOX DEFAULT 'X'. "X Page

SELECTION-SCREEN END OF BLOCK bl2.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT 1(80) t_001.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT 1(80) t_002.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT 1(80) t_003.
