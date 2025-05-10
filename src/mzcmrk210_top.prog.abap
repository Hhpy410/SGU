*&---------------------------------------------------------------------*
*& Include          MZCMRK_DEMO1_TOP
*&---------------------------------------------------------------------*

CLASS lcl_alv_grid DEFINITION DEFERRED.
DATA go_grid TYPE REF TO lcl_alv_grid.

TABLES: hrp1000, sscrfields, pa0001.

DATA : BEGIN OF gt_data OCCURS 0,
         peryr        LIKE  zcmtk210-peryr,
         perid        LIKE  zcmtk210-perid,
         oobjid       LIKE  zcmscourse_n-oobjid,
         ostext       LIKE  zcmscourse_n-ostext,
         setext       LIKE  zcmscourse_n-setext,
         smobjid      LIKE  zcmscourse_n-smobjid,
         seobjid      LIKE  zcmscourse_n-seobjid,
         stobjid      LIKE  cmacbpst-stobjid,
         tmstp        TYPE  zcmtk210-tmstp,
         smstext      LIKE  zcmscourse_n-smstext,
         lec_pernr    LIKE  zcmscourse_n-smetext,
         lec_name     LIKE  zcmscourse_n-smetext,
         bookcnt      LIKE  zcmscourse_n-bookcnt,
         seats_remain LIKE  zcmscourse_n-kapz4,
         delay_begda  LIKE  zcmtk210-delay_begda,
         delay_begtm  LIKE  zcmtk210-delay_begtm,
         ernam        LIKE  zcmtk210-ernam,
         erdat        LIKE  zcmtk210-erdat,
         ertim        LIKE  zcmtk210-ertim,
         aenam        LIKE  zcmtk210-aenam,
         aedat        LIKE  zcmtk210-aedat,
         aetim        LIKE  zcmtk210-aetim,
         xflag,
       END OF gt_data.

DATA: gt_selist      TYPE hrobject_t,
      gt_selist_temp TYPE hrobject_t,
      gs_selist      LIKE LINE OF gt_selist.

DATA: gt_course TYPE TABLE OF zcmscourse_n WITH HEADER LINE.

"소속구분 하위 'O'
DATA: gt_orgs  TYPE TABLE OF objec WITH HEADER LINE.
DATA: gt_objec TYPE TABLE OF objec WITH HEADER LINE.

DATA: gv_begda TYPE d.
DATA: gv_endda TYPE d.

*- SCRREN 100
DATA: BEGIN OF gs_s100,
        peryr       TYPE piqperyr,
        perid       TYPE piqperid,
        seobjid     TYPE hrp1000-objid,
        smobjid     TYPE hrp1000-objid,
        seshort     TYPE hrp1000-short,
        delay_begda TYPE zcmtk210-delay_begda,
        delay_begtm TYPE zcmtk210-delay_begtm,
      END OF gs_s100.

*- screen 200
DATA: BEGIN OF gs_s200,
        delay_begda TYPE zcmtk210-delay_begda,
        delay_begtm TYPE zcmtk210-delay_begtm,
      END OF gs_s200.
