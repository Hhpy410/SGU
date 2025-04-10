*&---------------------------------------------------------------------*
*&  Include           ZCMR2200_SEL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN FUNCTION KEY 1.
SELECTION-SCREEN FUNCTION KEY 2.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-b01.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 1.
    SELECTION-SCREEN COMMENT (31) FOR FIELD f_peryr.
    PARAMETERS: f_peryr LIKE piqstregper-peryr OBLIGATORY
                          AS LISTBOX VISIBLE LENGTH 20.
    SELECTION-SCREEN COMMENT (1)  FOR FIELD f_perid.
    PARAMETERS: f_perid LIKE piqstregper-perid OBLIGATORY
                          AS LISTBOX VISIBLE LENGTH 12.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 1.
    SELECTION-SCREEN COMMENT (31) FOR FIELD t_peryr.
    PARAMETERS: t_peryr LIKE piqstregper-peryr OBLIGATORY
                          AS LISTBOX VISIBLE LENGTH 20.
    SELECTION-SCREEN COMMENT (1)  FOR FIELD t_perid.
    PARAMETERS: t_perid LIKE piqstregper-perid OBLIGATORY
                          AS LISTBOX VISIBLE LENGTH 12.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN SKIP 1.

  SELECT-OPTIONS: p_stno FOR hrp1000-mc_short NO INTERVALS. "학번.
  SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT 1(80) t_001.
