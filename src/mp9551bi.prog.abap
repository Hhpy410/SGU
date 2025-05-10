*&---------------------------------------------------------------------*
*& Report  MP9551BI                                                    *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM mp9551bi.

TABLES: p9551.

FORM batch_input USING VALUE(bi_fcode)
                       VALUE(bi_wplog).

  FIELD-SYMBOLS: <bi_wplog> TYPE p9551.
  ASSIGN bi_wplog TO <bi_wplog> CASTING.
  DATA: dec_help_char(50) TYPE c.
  p9551 = <bi_wplog>.
  PERFORM fill_field(rhaltd00) USING
  'P9551-REMARK'
  p9551-remark.
  PERFORM fill_field(rhaltd00) USING
  'P9551-QT_TP'
  p9551-qt_tp.
  PERFORM fill_field(rhaltd00) USING
  'P9551-UG_BOOK_SEQ_TXT'
  p9551-ug_book_seq_txt.
  WRITE p9551-book_kapz1_r
   TO dec_help_char LEFT-JUSTIFIED.
  PERFORM fill_field(rhaltd00) USING
  'P9551-BOOK_KAPZ1_R'
  dec_help_char.
  WRITE p9551-book_kapz2_r
   TO dec_help_char LEFT-JUSTIFIED.
  PERFORM fill_field(rhaltd00) USING
  'P9551-BOOK_KAPZ2_R'
  dec_help_char.
  WRITE p9551-book_kapz3_r
   TO dec_help_char LEFT-JUSTIFIED.
  PERFORM fill_field(rhaltd00) USING
  'P9551-BOOK_KAPZ3_R'
  dec_help_char.
  WRITE p9551-book_kapz4_r
   TO dec_help_char LEFT-JUSTIFIED.
  PERFORM fill_field(rhaltd00) USING
  'P9551-BOOK_KAPZ4_R'
  dec_help_char.
  WRITE p9551-book_kapz
   TO dec_help_char LEFT-JUSTIFIED.
  PERFORM fill_field(rhaltd00) USING
  'P9551-BOOK_KAPZ'
  dec_help_char.
  WRITE p9551-book_kapz1
   TO dec_help_char LEFT-JUSTIFIED.
  PERFORM fill_field(rhaltd00) USING
  'P9551-BOOK_KAPZ1'
  dec_help_char.
  WRITE p9551-book_kapz2
   TO dec_help_char LEFT-JUSTIFIED.
  PERFORM fill_field(rhaltd00) USING
  'P9551-BOOK_KAPZ2'
  dec_help_char.
  WRITE p9551-book_kapz3
   TO dec_help_char LEFT-JUSTIFIED.
  PERFORM fill_field(rhaltd00) USING
  'P9551-BOOK_KAPZ3'
  dec_help_char.
  WRITE p9551-book_kapz4
   TO dec_help_char LEFT-JUSTIFIED.
  PERFORM fill_field(rhaltd00) USING
  'P9551-BOOK_KAPZ4'
  dec_help_char.
  WRITE p9551-book_kapzg
   TO dec_help_char LEFT-JUSTIFIED.
  PERFORM fill_field(rhaltd00) USING
  'P9551-BOOK_KAPZG'
  dec_help_char.
**PERFORM FILL_FIELD(RHALTD00) USING 'P9551-DUMMY' P9551-DUMMY.

  PERFORM fill_okcode(rhaltd00) USING 'U'.

ENDFORM.
