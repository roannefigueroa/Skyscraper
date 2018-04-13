*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 12/06/2017 at 10:52:48
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZXXT_PARAM_APP..................................*
DATA:  BEGIN OF STATUS_ZXXT_PARAM_APP                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZXXT_PARAM_APP                .
CONTROLS: TCTRL_ZXXT_PARAM_APP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZXXT_PARAM_APP                .
TABLES: ZXXT_PARAM_APP                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
