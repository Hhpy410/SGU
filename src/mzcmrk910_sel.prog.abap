*&---------------------------------------------------------------------*
*& Include          MZCMRK990_SEL
*&---------------------------------------------------------------------*

PARAMETERS : p_paket TYPE sotr_head-paket OBLIGATORY DEFAULT 'ZDCM05'.

SELECT-OPTIONS : s_appid FOR /u4a/t0010-appid.

SELECT-OPTIONS : s_uikey FOR sotr_head-alias_name.
