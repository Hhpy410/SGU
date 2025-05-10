FUNCTION-POOL zcmfgk110.                    "MESSAGE-ID ..

* INCLUDE LZCMFGK110D...                     " Local class definition


CLASS lcl_alv_grid DEFINITION DEFERRED.
DATA go_grid TYPE REF TO lcl_alv_grid.


DATA : BEGIN OF gt_data OCCURS 0,
         icon      TYPE icon-id,
         otype2    LIKE hrp1000-otype,
         objid2    LIKE hrp1000-objid,
         stext2    LIKE hrp1000-stext,
         org_cd2   LIKE zcmt0101-org_cd,
         short2    LIKE hrp1000-short,
         otype3    LIKE hrp1000-otype,
         objid3    LIKE hrp1000-objid,
         stext3    LIKE hrp1000-stext,
         otype4    LIKE hrp1000-otype,
         objid4    LIKE hrp1000-objid,
         stext4    LIKE hrp1000-stext,
         cnt       TYPE hrp1000-short,
         seqnr     TYPE qcat_stru-seqnr,
         level     TYPE qcat_stru-level,
         pup       TYPE qcat_stru-pup,
         pup_objid TYPE qcat_stru-pup_objid,
         row_color TYPE char4,
       END OF gt_data.

DATA gt_data_all LIKE TABLE OF gt_data.

DATA gt_orgeh TYPE TABLE OF objec.
DATA gv_multi.
