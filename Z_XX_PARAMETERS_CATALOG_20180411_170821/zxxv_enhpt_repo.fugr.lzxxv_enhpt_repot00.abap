*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 01/04/2018 at 10:10:56
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZXXV_ENHPT_REPO.................................*
TABLES: ZXXV_ENHPT_REPO, *ZXXV_ENHPT_REPO. "view work areas
CONTROLS: TCTRL_ZXXV_ENHPT_REPO
TYPE TABLEVIEW USING SCREEN '0004'.
DATA: BEGIN OF STATUS_ZXXV_ENHPT_REPO. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZXXV_ENHPT_REPO.
* Table for entries selected to show on screen
DATA: BEGIN OF ZXXV_ENHPT_REPO_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZXXV_ENHPT_REPO.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZXXV_ENHPT_REPO_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZXXV_ENHPT_REPO_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZXXV_ENHPT_REPO.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZXXV_ENHPT_REPO_TOTAL.

*.........table declarations:.................................*
TABLES: ZXXT_ENHPT_REPO                .
TABLES: ZXXT_PARAM_APP                 .
