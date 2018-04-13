*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 01/04/2018 at 10:12:43
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZXXV_ENHPT_TCODE................................*
TABLES: ZXXV_ENHPT_TCODE, *ZXXV_ENHPT_TCODE. "view work areas
CONTROLS: TCTRL_ZXXV_ENHPT_TCODE
TYPE TABLEVIEW USING SCREEN '0006'.
DATA: BEGIN OF STATUS_ZXXV_ENHPT_TCODE. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZXXV_ENHPT_TCODE.
* Table for entries selected to show on screen
DATA: BEGIN OF ZXXV_ENHPT_TCODE_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZXXV_ENHPT_TCODE.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZXXV_ENHPT_TCODE_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZXXV_ENHPT_TCODE_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZXXV_ENHPT_TCODE.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZXXV_ENHPT_TCODE_TOTAL.

*.........table declarations:.................................*
TABLES: ZXXT_ENHPT_TCODE               .
