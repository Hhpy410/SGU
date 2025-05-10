*&---------------------------------------------------------------------*
*&  Include           MZCMR6294C01
*&---------------------------------------------------------------------*
DATA g_event_receiver TYPE REF TO lcl_event.

*학부/대학원 수강신청 점검
DATA go_cancel_course_model TYPE REF TO cancel_course_facade_model.
*DATA go_cancel_course_mng   TYPE REF TO cancel_course_mng.

**신규등록
*DATA go_regist_model TYPE REF TO regist_facade_model.
*DATA go_regist_view  TYPE REF TO regist_view.
*DATA go_regist_ctrl  TYPE REF TO regist_ctrl.
DATA: g_event_receiver_grid   TYPE REF TO lcl_event_receiver_grid .
