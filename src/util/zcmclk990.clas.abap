class ZCMCLK990 definition
  public
  final
  create public .

public section.

  class-methods LOG_ADD
    importing
      !OBJNM type ANY optional
      !DESC type ANY
      !CONT type ANY optional
      !TYPE type BAPI_MTYPE optional
      !MSG type ANY optional .
protected section.
private section.
ENDCLASS.



CLASS ZCMCLK990 IMPLEMENTATION.


  METHOD log_add.

    DATA ls_log TYPE zcmtk990.
    DATA lv_xml TYPE string.

    TRY.
        ls_log-guid = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error INTO DATA(lo_error).
        RETURN.
    ENDTRY.

    IF cont IS NOT INITIAL.
      TRY.
          CALL TRANSFORMATION id SOURCE item = cont RESULT XML lv_xml.

        CATCH cx_root INTO DATA(lo_root).
          lv_xml = 'XML Conversion Error'.
      ENDTRY.
    ENDIF.

    IF objnm IS NOT INITIAL.
      ls_log-obj_id = objnm.
    ELSE.
      IF wdr_task=>application_name IS NOT INITIAL.
        ls_log-obj_id = wdr_task=>application_name.
      ELSEIF sy-tcode IS NOT INITIAL.
        ls_log-obj_id = sy-tcode.
      ELSE.
        ls_log-obj_id = 'DUMMY'.
      ENDIF.
    ENDIF.

    ls_log-type = type.
    ls_log-msg = msg.
    ls_log-log_desc = desc.
    ls_log-datum = sy-datum.
    ls_log-uzeit = sy-uzeit.
    ls_log-uname = sy-uname.
    ls_log-data_str = lv_xml.

    MODIFY zcmtk990 FROM ls_log.

  ENDMETHOD.
ENDCLASS.
