*&---------------------------------------------------------------------*
*& Include          MZCMRK990_TOP
*&---------------------------------------------------------------------*
TABLES : tstct.

CLASS lcl_alv_grid DEFINITION DEFERRED.
DATA go_grid TYPE REF TO lcl_alv_grid.

DATA : BEGIN OF gt_data OCCURS 0,
         obj_id   TYPE zcmtk990-obj_id,
         obj_nm   TYPE zcmtk990-obj_id,
         log_desc TYPE zcmtk990-log_desc,
         uname    TYPE zcmtk990-uname,
         datum    TYPE zcmtk990-datum,
         uzeit    TYPE zcmtk990-uzeit,
         type     TYPE zcmtk990-type,
         msg      TYPE zcmtk990-msg,
         data_str TYPE zcmtk990-data_str,
         btn1     TYPE zcmtk990-uname,
       END OF gt_data.
