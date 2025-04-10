*&---------------------------------------------------------------------*
*& Include          ZCMRK255_F00
*&---------------------------------------------------------------------*
 DEFINE set_se_short. "분반코드설정(예. COR1003-05 ...)
   gt_data-short&1 = &2.
 END-OF-DEFINITION.

* 부가정보
 DEFINE set_smtx. "과목명 검색
   READ TABLE gt_evob WITH KEY seshort = gt_data-short&1 BINARY SEARCH.
   IF sy-subrc = 0.
     gt_data-smtx&1 = gt_evob-smstext.
   ENDIF.
 END-OF-DEFINITION.
