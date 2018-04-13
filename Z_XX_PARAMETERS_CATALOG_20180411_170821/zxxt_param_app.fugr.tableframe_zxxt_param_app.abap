*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZXXT_PARAM_APP
*   generation date: 12/06/2017 at 10:52:48
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZXXT_PARAM_APP     .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
