*&---------------------------------------------------------------------*
*& Report  MP9566BI                                                    *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM mp9566bi.

TABLES: p9566.
TABLES: pt9566.

FORM batch_input TABLES bi_table
                 USING VALUE(bi_fcode)
                       VALUE(bi_wplog).

  DATA: bi_table_count TYPE p.

  FIELD-SYMBOLS: <bi_wplog> TYPE p9566,
                 <bi_table> TYPE pt9566.
  ASSIGN bi_wplog TO <bi_wplog> CASTING.
  p9566 = <bi_wplog>.
  PERFORM fill_field(rhaltd00) USING
  'P9566-REMARK'
  p9566-remark.
  PERFORM fill_field(rhaltd00) USING
  'P9566-OVERL'
  p9566-overl.
  PERFORM fill_field(rhaltd00) USING
  'P9566-PRECD'
  p9566-precd.
  PERFORM fill_field(rhaltd00) USING
  'P9566-RE_GRD_PRC'
  p9566-re_grd_prc.
  PERFORM fill_field(rhaltd00) USING
  'P9566-RE_SAME_SM_CNT'
  p9566-re_same_sm_cnt.
  PERFORM fill_field(rhaltd00) USING
  'P9566-RE_TOT_CNT'
  p9566-re_tot_cnt.
  PERFORM fill_field(rhaltd00) USING
  'P9566-RE_PER_SM_CNT'
  p9566-re_per_sm_cnt.
  PERFORM fill_field(rhaltd00) USING
  'P9566-RE_MAX_GRD'
  p9566-re_max_grd.
  PERFORM fill_field(rhaltd00) USING
  'P9566-RE_SCALE'
  p9566-re_scale.
  PERFORM fill_field(rhaltd00) USING
  'P9566-ST_GRD'
  p9566-st_grd.
**PERFORM FILL_FIELD(RHALTD00) USING 'P9566-DUMMY' P9566-DUMMY.

  DESCRIBE TABLE bi_table LINES bi_table_count.
  ASSIGN bi_table TO <bi_table> CASTING.
  DO bi_table_count TIMES.
    READ TABLE bi_table INDEX sy-index.
    IF sy-subrc = 0.
      CLEAR pt9566.
      pt9566 = <bi_table>.
      IF sy-index = 1.
        PERFORM fill_field(rhaltd00) USING
        'PT9566-POSSB_OID(1)'
        pt9566-possb_oid.
*       ersten Eintrag direkt in Zeile 1 ...
      ELSE.
        PERFORM fill_field(rhaltd00) USING
        'PT9566-POSSB_OID(2)'
        pt9566-possb_oid.
*       ... alle folgenden über "Neue Einträge" in Zeile 2
      ENDIF.
*     Neue Einträge
      PERFORM fill_okcode(rhaltd00) USING 'NEWE'.
      PERFORM start_dynpro(rhaltd00) USING 'MP956600' '2000'.
    ELSE.
      EXIT.
    ENDIF.
  ENDDO.
  PERFORM fill_okcode(rhaltd00) USING 'U'.

ENDFORM.
