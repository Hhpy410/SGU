FUNCTION zcmk_orgeh_request .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_KEYDT) TYPE  DATUM DEFAULT SY-DATUM
*"     VALUE(IV_FLAG) TYPE  FLAG OPTIONAL
*"     VALUE(IV_ORGCD) TYPE  PIQOOBJID DEFAULT '32000000'
*"     VALUE(IV_MULTI) TYPE  FLAG DEFAULT 'X'
*"     VALUE(IV_EXPAND) TYPE  PIQOOBJID OPTIONAL
*"  TABLES
*"      ET_ORGEH STRUCTURE  OBJEC
*"----------------------------------------------------------------------

  CLEAR: et_orgeh[].
  gv_multi = iv_multi.

  PERFORM get_data_select USING iv_keydt iv_orgcd iv_flag.

  PERFORM expand_orgcd USING iv_expand.

  CHECK gt_data[] IS NOT INITIAL.
  PERFORM grid_display_alv.

  et_orgeh[] = gt_orgeh[].


ENDFUNCTION.
