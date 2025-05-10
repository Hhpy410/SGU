*&---------------------------------------------------------------------*
*& Report  MP9553BI                                                    *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM mp9553bi.

TABLES: p9553.

FORM batch_input USING VALUE(bi_fcode)
                       VALUE(bi_wplog).

  FIELD-SYMBOLS: <bi_wplog> TYPE p9553.
  ASSIGN bi_wplog TO <bi_wplog> CASTING.
  p9553 = <bi_wplog>.
  PERFORM fill_field(rhaltd00) USING
  'P9553-BOOKCNT_G'
  p9553-bookcnt_g.
  PERFORM fill_field(rhaltd00) USING
  'P9553-BOOKCNT'
  p9553-bookcnt.
**PERFORM FILL_FIELD(RHALTD00) USING 'P9553-DUMMY' P9553-DUMMY.

  PERFORM fill_okcode(rhaltd00) USING 'U'.

ENDFORM.
