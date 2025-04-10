* modulpool infotype 9552
PROGRAM MP955200 MESSAGE-ID 5A.
INCLUDE MPH5ATOP.                      "Header
TABLES: WPLOG,
        PPPAR, PPHDR, PPHDX, PPSEL, PPENQ,
        T777O, T777P, T777S, T777T,
*        T77CD,                                       "PGE Sort T77CD
        P1000, P1001.

TABLES : P9552, PT9552.                               "infotypspezifisch

* PTSUB enthält als Wert die Tabellensubstruktur
DATA : PTSUB LIKE T777D-PTNNNN VALUE 'PT9552'.  "Value infotypspezifisch
* PT_TABNR enthält als Wert den Feldnamen des Verweises
DATA : PT_TABNR LIKE D021T-FLDN VALUE 'P9552-TABNR'.
                                                "Value infotypspezifisch
* in TDATA_SORT kann durch den Wert SPACE/X gesteuert werden,
* ob die Daten sortiert auf die DB geschrieben werden sollen
DATA : TDATA_SORT LIKE T77CD-TDATA_SORT VALUE ' '.
                                                "Value infotypspezifisch
* TDATA_DEL steuert, ob Leerzeilen beim Sichern gelöscht werden sollen
*  ' ' = Leerzeilen bleiben
*  'E' = Leerzeilen werden nur am Ende gelöscht
*  'A' = alle Leerzeilen gelöscht
DATA : TDATA_DEL LIKE T77CD-TDATA_DEL VALUE 'E'.
                                                "Value infotypspezifisch

INCLUDE MPHCOM00.                      "common-Bereich
INCLUDE FHVTAB00.                      "Update-Tabelle
INCLUDE FHVIEW00.                      "USER-VIEW
INCLUDE MPHFCOD0.                      "Fcode-Werte
INCLUDE MPHDAT00.                      "daten allg.
INCLUDE MPHPBO00.                      "Output
INCLUDE MPHPAI00.                      "Input
INCLUDE MPHTAB00.                      "Tabellenverarbeitung
INCLUDE MP955220.                      "PAI/PBO       "infotypspezifisch
