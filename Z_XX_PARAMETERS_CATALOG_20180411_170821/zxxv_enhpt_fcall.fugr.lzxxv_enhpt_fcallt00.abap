*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 01/04/2018 at 10:11:52
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZXXV_ENHPT_FCALL................................*
TABLES: ZXXV_ENHPT_FCALL, *ZXXV_ENHPT_FCALL. "view work areas
CONTROLS: TCTRL_ZXXV_ENHPT_FCALL
TYPE TABLEVIEW USING SCREEN '0005'.
DATA: BEGIN OF STATUS_ZXXV_ENHPT_FCALL. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZXXV_ENHPT_FCALL.
* Table for entries selected to show on screen
DATA: BEGIN OF ZXXV_ENHPT_FCALL_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZXXV_ENHPT_FCALL.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZXXV_ENHPT_FCALL_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZXXV_ENHPT_FCALL_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZXXV_ENHPT_FCALL.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZXXV_ENHPT_FCALL_TOTAL.

*.........table declarations:.................................*
TABLES: ZXXT_ENHPT_FCALL               .
