*&---------------------------------------------------------------------*
*& Include          ZCMRK900_SEL
*&---------------------------------------------------------------------*

PARAMETERS : p_paket TYPE sotr_head-paket OBLIGATORY DEFAULT 'ZDCM05'.

SELECT-OPTIONS : s_alias FOR sotr_head-alias_name.

PARAMETERS : p_text TYPE sotr_text-text.

SELECT-OPTIONS : s_cnam FOR sotr_text-chan_name.
