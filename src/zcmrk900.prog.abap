*&---------------------------------------------------------------------*
* Program ID  : ZCMRK900
* Title       : [CM]WEB OTR 번역
* Created By  : NEXPUS
* Created On  : 2024.09.09
* Frequency   : CM
* Category    :
* Description :
*&---------------------------------------------------------------------*
REPORT zcmrk900 NO STANDARD PAGE HEADING MESSAGE-ID zcm11.
*----------------------------------------------------------------------*
* INCLUDE
*----------------------------------------------------------------------*
INCLUDE zcmrk900_t01.
INCLUDE zcmrk900_cls.
INCLUDE zcmrk900_sel.
INCLUDE zcmrk900_alv.
INCLUDE zcmrk900_pbo.
INCLUDE zcmrk900_pai.
INCLUDE zcmrk900_f01.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

  s_cnam[] = VALUE #( sign = 'I' option = 'EQ' ( low = sy-uname ) ).

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM get_data_select.
  CALL SCREEN 100.
