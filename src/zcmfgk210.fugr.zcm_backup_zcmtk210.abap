FUNCTION zcm_backup_zcmtk210 .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DATA) TYPE  ZCMTK210
*"     REFERENCE(IV_MODE) TYPE  CHAR1
*"     REFERENCE(IV_KEYDT) TYPE  DATS DEFAULT SY-DATUM
*"  EXPORTING
*"     REFERENCE(EV_SUBRC) TYPE  SY-SUBRC
*"----------------------------------------------------------------------

  DATA ls_zcmtk211 TYPE zcmtk211.
  DATA lv_seq TYPE zcmtk211-seq.

  MOVE-CORRESPONDING is_data TO ls_zcmtk211.

  SELECT MAX( seq ) FROM zcmtk211 INTO lv_seq
    WHERE peryr = is_data-peryr
      AND perid = is_data-perid
      AND se_id = is_data-se_id
      AND st_id = is_data-st_id
      AND tmstp = is_data-tmstp.

  ls_zcmtk211-seq = lv_seq + 1.
  ls_zcmtk211-zmode = iv_mode.
  ls_zcmtk211-aenam = sy-uname.
  ls_zcmtk211-aedat = sy-datum.
  ls_zcmtk211-aetim = sy-uzeit.

  IF is_data-se_id IS NOT INITIAL.
    SELECT SINGLE short stext FROM hrp1000
      INTO (ls_zcmtk211-seshort, ls_zcmtk211-stext)
      WHERE plvar = '01'
        AND otype = 'SE'
        AND objid = is_data-se_id
        AND begda <= iv_keydt
        AND endda >= iv_keydt
        AND langu = '3'.
  ENDIF.

  INSERT zcmtk211 FROM ls_zcmtk211.

  ev_subrc = sy-subrc.

  IF ev_subrc EQ 0.
    COMMIT WORK.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFUNCTION.
