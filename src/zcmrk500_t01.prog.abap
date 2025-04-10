*&---------------------------------------------------------------------*
*&  Include           ZTEST0320_T01
*&---------------------------------------------------------------------*
TYPE-POOLS: slis, vrm.
CONSTANTS: gc_set    TYPE c VALUE 'X'.
CONSTANTS: gc_extension   TYPE i VALUE 3000.  "Docking size

TABLES : hrpad506, sscrfields.
DATA : gt_authobj  LIKE hrview    OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_data OCCURS 0,
        bookdate LIKE hrpad506-bookdate, "수강일자
*       booktime LIKE hrpad506-booktime, "최초저장
        ugreg    TYPE c,
        beguz    LIKE hrpad506-booktime, "피크시작
        enduz    LIKE hrpad506-booktime, "피크종료
        totsm    TYPE i,
        totst    TYPE i,
        t0000    TYPE i,
        t0010    TYPE i,
        t0020    TYPE i,
        t0030    TYPE i,
        t0040    TYPE i,
        t0050    TYPE i,
        t0100    TYPE i,
        t0110    TYPE i,
        t0120    TYPE i,
        t0130    TYPE i,
        t0140    TYPE i,
        t0150    TYPE i,
        t0200    TYPE i,
        t0210    TYPE i,
        t0220    TYPE i,
        t0230    TYPE i,
        t0240    TYPE i,
        t0250    TYPE i,
        t0300    TYPE i,
        t0310    TYPE i,
        t0320    TYPE i,
        t0330    TYPE i,
        t0340    TYPE i,
        t0350    TYPE i,
        t0400    TYPE i,
        t0410    TYPE i,
        t0420    TYPE i,
        t0430    TYPE i,
        t0440    TYPE i,
        t0450    TYPE i,
        t0500    TYPE i,
        t0510    TYPE i,
        t0520    TYPE i,
        t0530    TYPE i,
        t0540    TYPE i,
        t0550    TYPE i,
        t0600    TYPE i,
        t0610    TYPE i,
        t0620    TYPE i,
        t0630    TYPE i,
        t0640    TYPE i,
        t0650    TYPE i,
        t0700    TYPE i,
        t0710    TYPE i,
        t0720    TYPE i,
        t0730    TYPE i,
        t0740    TYPE i,
        t0750    TYPE i,
        t0800    TYPE i,
        t0810    TYPE i,
        t0820    TYPE i,
        t0830    TYPE i,
        t0840    TYPE i,
        t0850    TYPE i,
        t0900    TYPE i,
        t0910    TYPE i,
        t0920    TYPE i,
        t0930    TYPE i,
        t0940    TYPE i,
        t0950    TYPE i,
        t1000    TYPE i,
        celltab  TYPE lvc_t_styl,
      END OF gt_data.

DATA: s_smstt TYPE RANGE OF piqsmstatus WITH HEADER LINE.
DATA: s_stobj TYPE RANGE OF hrobjid WITH HEADER LINE.
DATA: s_bookd TYPE RANGE OF datum WITH HEADER LINE.

DATA: gt_time LIKE zcmt2018_time OCCURS 0 WITH HEADER LINE.
DATA: gt_1702 LIKE hrp1702 OCCURS 0 WITH HEADER LINE.
DATA: gt_1705 LIKE hrp1705 OCCURS 0 WITH HEADER LINE.
DATA: gt_9530 LIKE hrp9530 OCCURS 0 WITH HEADER LINE.
DATA: gt_wish LIKE zcmt2018_wish OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_a506 OCCURS 0,
        id        LIKE hrpad506-id,
        objid     LIKE hrp1000-objid,
        namzu     LIKE hrp1702-namzu,
        titel     LIKE hrp1702-titel,
        sts_cd    LIKE hrp9530-sts_cd,
        regwindow LIKE hrp1705-regwindow,
        smstatus  LIKE hrpad506-smstatus,
        bookdate  LIKE hrpad506-bookdate,
        booktime  LIKE hrpad506-booktime,
        stordate  LIKE hrpad506-stordate,
      END OF gt_a506.
DATA: gt_copy LIKE gt_a506 OCCURS 0 WITH HEADER LINE.

DATA: z_answer,
      z_return,
      z_text(100),
      l_message(100).

DATA: gv_mode(1) VALUE '4'.
DATA: gv_tot TYPE i,
      gv_cnt TYPE i.
DATA : BEGIN OF gt_menu OCCURS 0,
         fcode LIKE sy-ucomm,
       END OF gt_menu .

DATA: gv_datum TYPE datum, "조회일자
      gv_uzeit TYPE uzeit. "조회시간

DATA: BEGIN OF dat OCCURS 0,
        cot TYPE string,
      END OF dat.

DATA: BEGIN OF gt_stat OCCURS 0,
        regwindow LIKE hrp1705-regwindow,
        keyda     LIKE hrp1705-begda, "기준일자
        tost      TYPE i, "수강대상
        reg1      TYPE i, "정규재학
        reg2      TYPE i, "정규휴학
        wish      TYPE i, "담기인원
        wism      TYPE i, "담기과목
        st13      TYPE i, "신청자
        st14      TYPE i, "신청자+취소자
        book      TYPE i, "신청건
        trnc      TYPE i, "전체건
        canc      TYPE i, "취소건
      END OF gt_stat.

DATA: BEGIN OF gt_awcd OCCURS 0,
        modreg_id LIKE hrpad506-id,
        key_date  TYPE datum,
        key_time  TYPE uzeit,
      END OF gt_awcd.

DATA: "ok_code      TYPE sy-ucomm,
  "first_call   TYPE i,
  values       TYPE TABLE OF gprval WITH HEADER LINE,
  column_texts TYPE TABLE OF gprtxt WITH HEADER LINE,
  gv_ans1      TYPE c, "범주
  gv_ans2      TYPE c. "차트종류
DATA: gt_vrm  TYPE vrm_values WITH HEADER LINE.
DATA: gt_sels TYPE lvc_t_row,
      gs_sels TYPE lvc_s_row.
*&---------------------------------------------------------------------*
*&  SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN FUNCTION KEY 1.
SELECTION-SCREEN FUNCTION KEY 2.
SELECTION-SCREEN FUNCTION KEY 3.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-b01.

  PARAMETERS: p_peryr LIKE piqstregper-peryr OBLIGATORY USER-COMMAND uc
                        AS LISTBOX VISIBLE LENGTH 24.
  PARAMETERS: p_perid LIKE piqstregper-perid OBLIGATORY USER-COMMAND uc
                        AS LISTBOX VISIBLE LENGTH 24.
  PARAMETERS: p_keyda TYPE datum.
  PARAMETERS: p_bookd TYPE datum.
  PARAMETERS: p_bookt TYPE uzeit.

*SELECT-OPTIONS: p_datum FOR hrpad506-bookdate NO-EXTENSION.

  SELECTION-SCREEN SKIP 1.

  PARAMETERS: p_sel1 RADIOBUTTON GROUP gp1 USER-COMMAND uc.
  PARAMETERS: p_sel2 RADIOBUTTON GROUP gp1 DEFAULT 'X'.

  SELECTION-SCREEN SKIP 1.

  PARAMETERS: p_namzu AS CHECKBOX DEFAULT 'X'.
  PARAMETERS: p_titel AS CHECKBOX. "DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT 1(83) t_001.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT 1(83) t_002.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT 1(83) t_003.
