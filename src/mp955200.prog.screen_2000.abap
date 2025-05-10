PROCESS BEFORE OUTPUT.
* Verarbeitung vor der Ausgabe
  MODULE init.

  MODULE init_ptsub.

  MODULE initialize_dyn_tab.

  MODULE initialize_tc_dyn_tab.

  LOOP AT dyn_tab WITH CONTROL tc_dyn_tab
                  CURSOR dyn_tab_index.
    MODULE show_dyn_tab.
*      <.....>
  ENDLOOP.
  MODULE page_numbers.
*
PROCESS AFTER INPUT.
* Verarbeitung nach der Eingabe

  MODULE exit AT EXIT-COMMAND.

  MODULE leave.

  FIELD pphdx-record_nr MODULE set_record_nr ON REQUEST.

  CHAIN.
    FIELD p9552-objid.
    MODULE exist_object  ON CHAIN-REQUEST.
    MODULE fuelle_buffer ON CHAIN-REQUEST.
  ENDCHAIN.

  CHAIN.
    FIELD p9552-begda.
    FIELD p9552-endda.
    MODULE check_date.
    MODULE insert_ok.
  ENDCHAIN.

  LOOP AT dyn_tab.
    CHAIN.
      FIELD pt9552-objid.
      FIELD pt9552-otype.
      FIELD pt9552-book_fg.
      MODULE input_done     ON CHAIN-REQUEST.
    ENDCHAIN.
    MODULE fuelle_dyn_tab_tab.              "Fuellen der DYN_TAB
  ENDLOOP.

  MODULE tab_line_del.

  CHAIN.
    FIELD p9552-objid.
    FIELD p9552-begda.
    FIELD p9552-endda.
    MODULE check_zb0.
    MODULE check_timco.
    MODULE input_done ON CHAIN-REQUEST.
  ENDCHAIN.

  MODULE tc_entry_idx_get.
  FIELD pphdx-entry_idx MODULE entry_idx ON REQUEST.

  MODULE table_okcode.

  MODULE check_empty.
  MODULE ok-code.
*
PROCESS ON VALUE-REQUEST.           "Infgotypspezifisches F4
* FIELD PTyyyy-<.....> MODULE <...>.
