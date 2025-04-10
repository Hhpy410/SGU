
PROCESS BEFORE OUTPUT.
  MODULE status_0200.
  MODULE get_orgeh .
  MODULE set_screen.

PROCESS AFTER INPUT.
  MODULE exitpop AT EXIT-COMMAND.
  "//__ASPN09 2024.04.25 :: zxit0010-callback_no 주석 : BEGIN
*  CHAIN.
*    FIELD: zxit0010-callback_no .
*    MODULE check_telno ON CHAIN-REQUEST.
*  ENDCHAIN.
  "//__ASPN09 2024.04.25 :: zxit0010-callback_no 주석 : END

  MODULE user_command_0200.
