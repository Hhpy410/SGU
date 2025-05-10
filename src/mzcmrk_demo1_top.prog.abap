*&---------------------------------------------------------------------*
*& Include          MZCMRK_DEMO1_TOP
*&---------------------------------------------------------------------*

CLASS lcl_alv_grid DEFINITION DEFERRED.
DATA go_grid TYPE REF TO lcl_alv_grid.

DATA : BEGIN OF gt_data OCCURS 0,
         carrid     LIKE sflight-carrid,
         carrname   TYPE scarr-carrname,
         connid     TYPE sflight-connid,
         fldate     TYPE sflight-fldate,
         price      TYPE sflight-price,
         currency   TYPE sflight-currency,
         planetype  TYPE sflight-planetype,
         seatsmax   TYPE sflight-seatsmax,
         seatsocc   TYPE sflight-seatsocc,
         paymentsum TYPE sflight-paymentsum,
       END OF gt_data.

DATA : BEGIN OF gt_data2 OCCURS 0,
         carrid     TYPE sflight-carrid,
         connid     TYPE sflight-connid,
         fldate     TYPE sflight-fldate,
         price      TYPE sflight-price,
         currency   TYPE sflight-currency,
         planetype  TYPE sflight-planetype,
         seatsmax   TYPE sflight-seatsmax,
         seatsocc   TYPE sflight-seatsocc,
         paymentsum TYPE sflight-paymentsum,
       END OF gt_data2.
