FUNCTION zcmk_session_delete.
*"----------------------------------------------------------------------
*"*"로컬 인터페이스:
*"  IMPORTING
*"     VALUE(USER) LIKE  SY-UNAME
*"     VALUE(CLIENT) LIKE  SY-MANDT
*"     VALUE(ONLY_POOLED_USER) LIKE  SM04DIC-FLAG DEFAULT ' '
*"     VALUE(TID) LIKE  SY-INDEX DEFAULT -1
*"     VALUE(LOGINID) TYPE  SY-INDEX OPTIONAL
*"----------------------------------------------------------------------

  DATA: BEGIN OF usr_tabl OCCURS 10.
          INCLUDE STRUCTURE usrinfo.
  DATA: END OF usr_tabl.
  DATA: th_opcode(1) TYPE x,
        th_int       LIKE sy-index.

  CONSTANTS: opcode_list       LIKE th_opcode VALUE 2,
             opcode_delete_usr LIKE th_opcode VALUE 25,
             usr_stat_pooled   LIKE th_int    VALUE 6.

  CALL 'ThUsrInfo' ID 'OPCODE' FIELD opcode_delete_usr
    ID 'TID' FIELD tid
    ID 'LOGON_ID' FIELD loginid.





ENDFUNCTION.
