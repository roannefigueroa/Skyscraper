*---------------------------------------------------------------------*
*    view related FORM routines
*   generation date: 01/04/2018 at 10:10:56
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZXXV_ENHPT_REPO.................................*
FORM GET_DATA_ZXXV_ENHPT_REPO.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZXXT_ENHPT_REPO WHERE
(VIM_WHERETAB) .
    CLEAR ZXXV_ENHPT_REPO .
ZXXV_ENHPT_REPO-MANDT =
ZXXT_ENHPT_REPO-MANDT .
ZXXV_ENHPT_REPO-ENHPNT_ID =
ZXXT_ENHPT_REPO-ENHPNT_ID .
ZXXV_ENHPT_REPO-APP_ID =
ZXXT_ENHPT_REPO-APP_ID .
ZXXV_ENHPT_REPO-ZDESC =
ZXXT_ENHPT_REPO-ZDESC .
ZXXV_ENHPT_REPO-FM_TEMPLATE =
ZXXT_ENHPT_REPO-FM_TEMPLATE .
    SELECT SINGLE * FROM ZXXT_PARAM_APP WHERE
APP_ID = ZXXT_ENHPT_REPO-APP_ID .
    IF SY-SUBRC EQ 0.
    ENDIF.
<VIM_TOTAL_STRUC> = ZXXV_ENHPT_REPO.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZXXV_ENHPT_REPO .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZXXV_ENHPT_REPO.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZXXV_ENHPT_REPO-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZXXT_ENHPT_REPO WHERE
  ENHPNT_ID = ZXXV_ENHPT_REPO-ENHPNT_ID AND
  APP_ID = ZXXV_ENHPT_REPO-APP_ID .
    IF SY-SUBRC = 0.
    DELETE ZXXT_ENHPT_REPO .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZXXT_ENHPT_REPO WHERE
  ENHPNT_ID = ZXXV_ENHPT_REPO-ENHPNT_ID AND
  APP_ID = ZXXV_ENHPT_REPO-APP_ID .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZXXT_ENHPT_REPO.
    ENDIF.
ZXXT_ENHPT_REPO-MANDT =
ZXXV_ENHPT_REPO-MANDT .
ZXXT_ENHPT_REPO-ENHPNT_ID =
ZXXV_ENHPT_REPO-ENHPNT_ID .
ZXXT_ENHPT_REPO-APP_ID =
ZXXV_ENHPT_REPO-APP_ID .
ZXXT_ENHPT_REPO-ZDESC =
ZXXV_ENHPT_REPO-ZDESC .
ZXXT_ENHPT_REPO-FM_TEMPLATE =
ZXXV_ENHPT_REPO-FM_TEMPLATE .
    IF SY-SUBRC = 0.
    UPDATE ZXXT_ENHPT_REPO .
    ELSE.
    INSERT ZXXT_ENHPT_REPO .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZXXV_ENHPT_REPO-UPD_FLAG,
STATUS_ZXXV_ENHPT_REPO-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZXXV_ENHPT_REPO.
  SELECT SINGLE * FROM ZXXT_ENHPT_REPO WHERE
ENHPNT_ID = ZXXV_ENHPT_REPO-ENHPNT_ID AND
APP_ID = ZXXV_ENHPT_REPO-APP_ID .
ZXXV_ENHPT_REPO-MANDT =
ZXXT_ENHPT_REPO-MANDT .
ZXXV_ENHPT_REPO-ENHPNT_ID =
ZXXT_ENHPT_REPO-ENHPNT_ID .
ZXXV_ENHPT_REPO-APP_ID =
ZXXT_ENHPT_REPO-APP_ID .
ZXXV_ENHPT_REPO-ZDESC =
ZXXT_ENHPT_REPO-ZDESC .
ZXXV_ENHPT_REPO-FM_TEMPLATE =
ZXXT_ENHPT_REPO-FM_TEMPLATE .
    SELECT SINGLE * FROM ZXXT_PARAM_APP WHERE
APP_ID = ZXXT_ENHPT_REPO-APP_ID .
    IF SY-SUBRC EQ 0.
    ELSE.
      CLEAR SY-SUBRC.
    ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZXXV_ENHPT_REPO USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZXXV_ENHPT_REPO-ENHPNT_ID TO
ZXXT_ENHPT_REPO-ENHPNT_ID .
MOVE ZXXV_ENHPT_REPO-APP_ID TO
ZXXT_ENHPT_REPO-APP_ID .
MOVE ZXXV_ENHPT_REPO-MANDT TO
ZXXT_ENHPT_REPO-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZXXT_ENHPT_REPO'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZXXT_ENHPT_REPO TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZXXT_ENHPT_REPO'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
FORM COMPL_ZXXV_ENHPT_REPO USING WORKAREA.
*      provides (read-only) fields from secondary tables related
*      to primary tables by foreignkey relationships
ZXXT_ENHPT_REPO-MANDT =
ZXXV_ENHPT_REPO-MANDT .
ZXXT_ENHPT_REPO-ENHPNT_ID =
ZXXV_ENHPT_REPO-ENHPNT_ID .
ZXXT_ENHPT_REPO-APP_ID =
ZXXV_ENHPT_REPO-APP_ID .
ZXXT_ENHPT_REPO-ZDESC =
ZXXV_ENHPT_REPO-ZDESC .
ZXXT_ENHPT_REPO-FM_TEMPLATE =
ZXXV_ENHPT_REPO-FM_TEMPLATE .
    SELECT SINGLE * FROM ZXXT_PARAM_APP WHERE
APP_ID = ZXXT_ENHPT_REPO-APP_ID .
    IF SY-SUBRC EQ 0.
    ELSE.
      CLEAR SY-SUBRC.
    ENDIF.
ENDFORM.
