*&---------------------------------------------------------------------*
*& Report  MP9552BI                                                    *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM mp9552bi.

TABLES: p9552.
TABLES: pt9552.

FORM batch_input TABLES bi_table
                 USING VALUE(bi_fcode)
                       VALUE(bi_wplog).

  DATA: bi_table_count TYPE p.

  FIELD-SYMBOLS: <bi_wplog> TYPE p9552,
                 <bi_table> TYPE pt9552.
  ASSIGN bi_wplog TO <bi_wplog> CASTING.
  p9552 = <bi_wplog>.
  PERFORM fill_field(rhaltd00) USING
  'P9552-REMARK'
  p9552-remark.
  PERFORM fill_field(rhaltd00) USING
  'P9552-APPLY_FG'
  p9552-apply_fg.
**PERFORM FILL_FIELD(RHALTD00) USING 'P9552-DUMMY' P9552-DUMMY.

  DESCRIBE TABLE bi_table LINES bi_table_count.
  ASSIGN bi_table TO <bi_table> CASTING.
  DO bi_table_count TIMES.
    READ TABLE bi_table INDEX sy-index.
    IF sy-subrc = 0.
      CLEAR pt9552.
      pt9552 = <bi_table>.
      IF sy-index = 1.
        PERFORM fill_field(rhaltd00) USING
        'PT9552-OBJID(1)'
        pt9552-objid.
        PERFORM fill_field(rhaltd00) USING
        'PT9552-OTYPE(1)'
        pt9552-otype.
        PERFORM fill_field(rhaltd00) USING
        'PT9552-BOOK_FG(1)'
        pt9552-book_fg.
*       ersten Eintrag direkt in Zeile 1 ...
      ELSE.
        PERFORM fill_field(rhaltd00) USING
        'PT9552-OBJID(2)'
        pt9552-objid.
        PERFORM fill_field(rhaltd00) USING
        'PT9552-OTYPE(2)'
        pt9552-otype.
        PERFORM fill_field(rhaltd00) USING
        'PT9552-BOOK_FG(2)'
        pt9552-book_fg.
*       ... alle folgenden über "Neue Einträge" in Zeile 2
      ENDIF.
*     Neue Einträge
      PERFORM fill_okcode(rhaltd00) USING 'NEWE'.
      PERFORM start_dynpro(rhaltd00) USING 'MP955200' '2000'.
    ELSE.
      EXIT.
    ENDIF.
  ENDDO.
  PERFORM fill_okcode(rhaltd00) USING 'U'.

ENDFORM.
