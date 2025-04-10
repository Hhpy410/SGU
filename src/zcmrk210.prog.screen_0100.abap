
PROCESS BEFORE OUTPUT.
  MODULE status_0100.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.
  MODULE user_command_100.

PROCESS ON VALUE-REQUEST.
  FIELD gs_s100-peryr      MODULE f4_peryr.
  FIELD gs_s100-perid      MODULE f4_perid.
  FIELD gs_s100-seshort    MODULE f4_se_short.
