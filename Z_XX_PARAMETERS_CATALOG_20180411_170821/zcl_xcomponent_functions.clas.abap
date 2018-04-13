class ZCL_XCOMPONENT_FUNCTIONS definition
  public
  final
  create public .

public section.

  constants GC_PARAM_BIR_FOOTER type ZDE_PARAMETER_ID value 'BIR_FOOTER' ##NO_TEXT.
  constants GC_PARAM_COMP_HDR_OVERRIDE type ZDE_PARAMETER_ID value 'COMP_HDR_OVRIDE' ##NO_TEXT.
  constants GC_APPID_GENERAL type ZDE_APPLICATION_ID value 'GENERAL' ##NO_TEXT.
  constants GC_MSGTYP_ERROR type MSGTY value 'E' ##NO_TEXT.
  constants GC_MSGTYP_ABORT type MSGTY value 'A' ##NO_TEXT.
  constants GC_MSGTYP_SUCCESS type MSGTY value 'S' ##NO_TEXT.
  constants GC_MSGTYP_INFORMATION type MSGTY value 'I' ##NO_TEXT.
  constants GC_SIGN_I type CHAR1 value 'I' ##NO_TEXT.
  constants GC_OPTION_BT type CHAR2 value 'BT' ##NO_TEXT.
  constants GC_OPTION_EQ type CHAR2 value 'EQ' ##NO_TEXT.

*  types:
*    tt_param_value TYPE STANDARD TABLE OF zxxt_param_value .
  class-methods GET_PARAM_VALUE_SINGLE
    importing
      value(APP_ID) type ZDE_APPLICATION_ID
      value(PARAM_ID) type ZDE_PARAMETER_ID
      !PARAM_GRP type ANY optional
    exporting
      value(VALUE1) type ANY
      value(VALUE2) type ANY .
  class-methods GET_PARAM_VALUE_MULTI
    importing
      value(APP_ID) type ZDE_APPLICATION_ID
      value(PARAM_ID) type ANY
      value(PARAM_GRP) type ANY optional
    returning
      value(PARAM_VALUES) type ZXX_TT_PARAM_VALUE .
  class-methods GET_ENH_FUNCTION_NAME
    importing
      value(APP_ID) type ANY
      value(ENHPNT_ID) type ANY
      value(ORG_UNIT) type ANY optional
    returning
      value(FUNCTION_NAME) type RS38L_FNAM
    raising
      CX_ENH_NOT_FOUND
      CX_ENH_INACTIVE_VERSION_EXISTS .
  class-methods CHECK_PARAM_VALUE
    importing
      value(APP_ID) type ANY
      value(PARAM_ID) type ANY
      value(PARAM_GRP) type ANY
      value(VALUE) type ANY optional
      value(CHECK_IN_RANGE) type ANY optional
    returning
      value(ISEXIST) type ABAP_BOOL .
  class-methods SEND_EMAIL_HTM
    importing
      !I_RECIPIENT type ZXX_TT_RECIPIENT_LIST
      !I_BODY type SOLI_TAB
      !I_ATTACHMENT type ZXX_TT_ATTACHMENT optional
      !I_SUBJECT type SO_OBJ_DES
      !I_SUBJECT_LONG type STRING .
  class-methods GET_PARAMETER_RANGE
    importing
      !APP_ID type ANY
      !PARAM_ID type ANY
      !PARAM_GRP type ANY optional
      !NO_CONVERSION type ABAP_BOOL optional
    changing
      !CT_RANGE type TABLE .
  class-methods GET_LOGO_URL
    importing
      !I_BUKRS type BUKRS
      !I_WITH_COLOR type MARK optional
    returning
      value(R_URL) type STRING .
  class-methods GET_LOGO_GRAPHIC_NAME
    importing
      !I_BUKRS type BUKRS
      !I_COLORED type CHAR1
    returning
      value(R_COL_GRAPHIC) type CHAR9 .
  class-methods GET_COMP_ADDRESS_TEXT_MODULE
    importing
      !I_BUKRS type BUKRS
      !I_SUFFIX type CHAR20 optional
    returning
      value(R_TEXT_NAME) type TDTXTNAME .
  class-methods GET_FORM_BIR_FOOTER_INPUT
    importing
      !I_DOC_NAME type ZXX_ST_BIR_FOOTER_INPUT-DOC_NAME
      !I_SERIES_FROM type ZXX_ST_BIR_FOOTER_INPUT-SERIES_FROM
      !I_SERIES_TO type ZXX_ST_BIR_FOOTER_INPUT-SERIES_TO
      !I_COMP_CODE type BUKRS optional
      !I_SUFFIX type CHAR20 optional
    returning
      value(R_STRUCTURE) type ZXX_ST_BIR_FOOTER_INPUT .
  class-methods ADD_COMP_HEADER_TO_SALV_TOP
    importing
      !I_COMP_CODE type BUKRS
      !I_REPORT_TITLE type ANY
      !I_REPORT_SUBTITLE type ANY optional .
  PROTECTED SECTION.
private section.

  class-methods GET_SSF_TEXTS
    importing
      !I_TEXTNAME type ANY
    changing
      !C_STRING type STRING optional
    returning
      value(RT_LINES) type TSFTEXT .
ENDCLASS.



CLASS ZCL_XCOMPONENT_FUNCTIONS IMPLEMENTATION.


  METHOD add_comp_header_to_salv_top.

    DATA: lv_comp_name    TYPE string,
          lv_comp_printed TYPE abap_bool,
          lv_details      TYPE string,
          lv_index        TYPE i,
          lv_row          TYPE i.

    DATA: lt_list_header TYPE slis_t_listheader.

*---Get text module name
    DATA(lv_textname) = zcl_xcomponent_functions=>get_comp_address_text_module(
                             EXPORTING
                               i_bukrs     =  i_comp_code    ).

    DATA lv_text_in_string TYPE string.
    DATA(lt_lines) = get_ssf_texts( EXPORTING i_textname = lv_textname
                                    CHANGING  c_string   = lv_text_in_string ).

*---Get_company details
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN lv_text_in_string WITH cl_abap_char_utilities=>newline.
    SPLIT lv_text_in_string AT cl_abap_char_utilities=>newline
        INTO TABLE DATA(lt_split_text).
    LOOP AT lt_lines INTO DATA(ls_line).
      ADD 1 TO lv_index.
      CASE ls_line-tdformat.
        WHEN 'HD'.
          CONCATENATE lv_comp_name ls_line-tdline INTO lv_comp_name SEPARATED BY space.
          REPLACE ALL OCCURRENCES OF REGEX '(<(\<.*\>)>)|(</>)' IN lv_comp_name WITH space.
          CONDENSE lv_comp_name.
        WHEN OTHERS.
          IF lv_comp_printed EQ abap_false.
*-----------Set report title text
            APPEND INITIAL LINE TO lt_list_header ASSIGNING FIELD-SYMBOL(<l_list>).
            <l_list>-typ  = 'H'.
            <l_list>-info = lv_comp_name.
            APPEND INITIAL LINE TO lt_list_header ASSIGNING <l_list>.
            <l_list>-typ  = 'H'.
            lv_comp_printed = abap_true.
          ENDIF.

          lv_details = lt_split_text[ lv_index ].
**---------Set report title text
          APPEND INITIAL LINE TO lt_list_header ASSIGNING <l_list>.
          REPLACE ALL OCCURRENCES OF REGEX '(<(\<.*\>)>)|(</>)' IN lv_details WITH space.
          <l_list>-typ  = 'H'.
          <l_list>-info = lv_details.
      ENDCASE.
    ENDLOOP.

    DATA: lv_suffix TYPE char20.
    DO 2 TIMES.
      IF sy-index EQ 1.
        lv_suffix = 'L1'.
      ELSE.
        lv_suffix = 'L2'.
      ENDIF.

      DATA(ls_footer_input) = zcl_xcomponent_functions=>get_form_bir_footer_input(
                                  EXPORTING
                                    i_doc_name    =     space
                                    i_series_from =     space
                                    i_series_to   =     space
                                    i_comp_code   =     i_comp_code
                                    i_suffix      =     lv_suffix ).

      lt_lines = get_ssf_texts( EXPORTING i_textname = ls_footer_input-text_module
                               CHANGING   c_string   = lv_text_in_string ).

*---Get Field names
      DATA lt_fields TYPE ddfields.
      CALL FUNCTION 'CATSXT_GET_DDIC_FIELDINFO'
        EXPORTING
          im_structure_name = 'ZXX_ST_BIR_FOOTER_INPUT'
        IMPORTING
          ex_ddic_info      = lt_fields
        EXCEPTIONS
          failed            = 1
          OTHERS            = 2.


      LOOP AT lt_lines ASSIGNING FIELD-SYMBOL(<l_line>).
        LOOP AT lt_fields ASSIGNING FIELD-SYMBOL(<l_field>).

          ASSIGN COMPONENT <l_field>-fieldname OF STRUCTURE ls_footer_input TO FIELD-SYMBOL(<l_value>).
          REPLACE ALL OCCURRENCES OF |&IS_BIR_FOOTER-{ <l_field>-fieldname }&| IN <l_line>-tdline
                WITH <l_value>.

        ENDLOOP.
      ENDLOOP.

      CALL FUNCTION 'IDMX_DI_TLINE_INTO_STRING'
        EXPORTING
          it_tline       = lt_lines
        IMPORTING
          ev_text_string = lv_text_in_string.


      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN lv_text_in_string WITH cl_abap_char_utilities=>newline.
      SPLIT lv_text_in_string AT cl_abap_char_utilities=>newline
          INTO TABLE lt_split_text.



      APPEND INITIAL LINE TO lt_list_header ASSIGNING <l_list>.
      LOOP AT lt_split_text INTO lv_details.
**----Set report title text
        APPEND INITIAL LINE TO lt_list_header ASSIGNING <l_list>.
        LOOP AT lt_fields ASSIGNING <l_field>.

          ASSIGN COMPONENT <l_field>-fieldname OF STRUCTURE ls_footer_input TO <l_value>.
          REPLACE ALL OCCURRENCES OF |&IS_BIR_FOOTER-{ <l_field>-fieldname } &| IN lv_details
                WITH <l_value>.

        ENDLOOP.
        REPLACE ALL OCCURRENCES OF REGEX '(<(\<.*\>)>)|(</>)' IN lv_details WITH space.
        <l_list>-typ  = 'H'.
        <l_list>-info = lv_details.
      ENDLOOP.
    ENDDO.

    APPEND INITIAL LINE TO lt_list_header ASSIGNING <l_list>.
    APPEND INITIAL LINE TO lt_list_header ASSIGNING <l_list>.
    <l_list>-typ  = 'H'.
    <l_list>-info = i_report_title.
    IF i_report_subtitle IS NOT INITIAL.
      APPEND INITIAL LINE TO lt_list_header ASSIGNING <l_list>.
      <l_list>-typ  = 'H'.
      <l_list>-info = i_report_subtitle.
    ENDIF.

    FREE MEMORY ID 'DYNDOS_FOR_ALV_EXCEL'.
    EXPORT it_list_commentary FROM lt_list_header TO MEMORY ID 'DYNDOS_FOR_ALV_EXCEL'.

  ENDMETHOD.


  METHOD check_param_value.

    " $. retrieve header using SQL (using app_id, param_id).
    " $. build needed ranges for selection (if any)
    " $. search result of previous SQL using provided options
    " $. set value of isexist -> X if hit found, space otherwise.

    " $. retrieve header using SQL (using app_id, param_id).
    SELECT app~app_id       ,
           names~param_id   ,
           values~param_ctr ,
           values~param_grp ,
           values~param_val1,
           values~param_val2

      FROM zxxt_param_app AS app

      INNER JOIN zxxt_param_names AS names
        ON app~app_id = names~app_id

      INNER JOIN zxxt_param_value AS values
        ON values~app_id   = names~app_id
       AND values~param_id = names~param_id

      INTO TABLE @DATA(lt_param_values)

      WHERE app~app_id          =  @app_id
        AND names~param_id      =  @param_id
*        and values~param_grp    =  @param_grp
      ORDER BY app~app_id        ,
               names~param_id    ,
               values~param_ctr  ,
               values~param_grp  ,
               values~param_val1 ,
               values~param_val2 .

    IF sy-subrc IS NOT INITIAL.
      isexist = abap_false.
      RETURN.
    ENDIF.

    " $. build needed ranges for selection (if any)
    DATA lt_value_range TYPE RANGE OF zde_parameter_val1.
    FIELD-SYMBOLS <value_range> LIKE LINE OF lt_value_range.
    APPEND INITIAL LINE TO lt_value_range ASSIGNING <value_range>. "!important

    " $. search result of previous SQL using provided options
    FIELD-SYMBOLS <param_values> LIKE LINE OF lt_param_values.

    IF check_in_range = abap_true.
      LOOP AT lt_param_values ASSIGNING <param_values>
      WHERE app_id     = app_id
        AND param_id   = param_id
        AND param_grp  CP param_grp.

        "since we'll be using single line of the range table only,
        "we have referenced lt_value_range[1] to <value_range> previously.
        "just change value of reference then check using lt_value_range

        <value_range>-sign    = 'I'.
        <value_range>-option  = 'BT'.
        <value_range>-low     = <param_values>-param_val1.
        <value_range>-high    = <param_values>-param_val2.

        IF <value_range>-high IS INITIAL.
          <value_range>-option = 'EQ'.
        ENDIF.

        IF value IN lt_value_range.
          isexist = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

    ELSE.
      LOOP AT lt_param_values ASSIGNING <param_values>
      WHERE app_id     = app_id
        AND param_id   = param_id
        AND param_grp  CP param_grp
        AND param_val1 = value     .  "single

        "match found if this statement is reached. return X as result
        isexist = abap_true.
        EXIT.
      ENDLOOP.

      IF sy-subrc = 4.
        isexist = abap_false.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_comp_address_text_module.

    data(lv_bukrs) = i_bukrs.

    DATA(lt_param) = zcl_xcomponent_functions=>get_param_value_multi(
      EXPORTING
        app_id       =     gc_appid_general
        param_id     =     gc_param_comp_hdr_override
        param_grp    =     lv_bukrs ).

    READ TABLE lt_param WITH KEY param_val1 = i_suffix
        TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      r_text_name = |ZXXST_COMP_ADDRESS_{ lv_bukrs }{ i_suffix }|.
    ELSE.
      r_text_name = |ZXXST_COMP_ADDRESS_{ lv_bukrs }|.
    ENDIF.

  ENDMETHOD.


  METHOD get_enh_function_name.
    " $. retrieve header from database (app_id, enhpt_id)
    " $. check for active function calls using org_unit and the deactivation flag
    " $. check for tcode and user authorizations
    " $. return FM name as a result, blank if none passed.

*ideas: change handling to raise exeption for NOT_FOUND, NO_USER_AUTH, NO_TCODE_AUTH, NOT_ACTIVE.
*
    TYPES: BEGIN OF t_fcalls,
             app_id       TYPE zxxt_param_app-app_id,
             enhpnt_id    TYPE zxxt_enhpt_repo-enhpnt_id,
             org_unit     TYPE zxxt_enhpt_fcall-org_unit,
             fm_name      TYPE zxxt_enhpt_fcall-fm_name,
             deactivated  TYPE zxxt_enhpt_fcall-deactivated,
             isuser_auth  TYPE c LENGTH 1,
             istcode_auth TYPE c LENGTH 1,
           END OF t_fcalls.

    DATA: lt_enh_users TYPE STANDARD TABLE OF zxxt_enhpt_users,
          ls_fcalls    TYPE t_fcalls.

    SELECT SINGLE
      app~app_id
      repo~enhpnt_id
      fcalls~org_unit
      fcalls~fm_name
      fcalls~deactivated
      FROM zxxt_param_app AS app
      INNER JOIN zxxt_enhpt_repo AS repo
        ON app~app_id = repo~app_id
      INNER JOIN zxxt_enhpt_fcall AS fcalls
        ON fcalls~app_id   = app~app_id
       AND fcalls~enhpnt_id = repo~enhpnt_id
      INTO ls_fcalls
      WHERE app~app_id      = app_id
        AND repo~enhpnt_id  = enhpnt_id
        AND fcalls~org_unit = org_unit.

    IF sy-subrc IS NOT INITIAL.
      RAISE EXCEPTION TYPE cx_enh_not_found.
    ENDIF.

    " $. user check
    FIELD-SYMBOLS: <lfs_user> LIKE LINE OF lt_enh_users.

    SELECT *
      FROM zxxt_enhpt_users AS users
      INTO TABLE lt_enh_users
      WHERE enhpnt_id = ls_fcalls-enhpnt_id
        AND org_unit  = ls_fcalls-org_unit
        AND app_id    = ls_fcalls-app_id
      ORDER BY enhpnt_id
               org_unit
               app_id
               username
    .

    IF sy-subrc IS INITIAL.
      "search USER from enhancement id search result.
      LOOP AT lt_enh_users ASSIGNING <lfs_user> FROM sy-tabix
      WHERE enhpnt_id  =  ls_fcalls-enhpnt_id
        AND org_unit   =  ls_fcalls-org_unit
        AND app_id     =  ls_fcalls-app_id
        AND username   CP sy-uname.

        ls_fcalls-isuser_auth = abap_true.
        EXIT.
      ENDLOOP.

    ELSE.
      "no users maintianed in table, which means, all users are authorized.
      ls_fcalls-isuser_auth = abap_true.
    ENDIF.

    " $. tcode check
    DATA: lt_enh_tcodes TYPE STANDARD TABLE OF zxxt_enhpt_tcode.
    FIELD-SYMBOLS: <lfs_tcode> LIKE LINE OF lt_enh_tcodes.

    "check tcode authorization.
    SELECT *
      FROM zxxt_enhpt_tcode
      INTO TABLE lt_enh_tcodes
      WHERE enhpnt_id = ls_fcalls-enhpnt_id
        AND org_unit  = ls_fcalls-org_unit
        AND app_id    = ls_fcalls-app_id
      ORDER BY enhpnt_id
               org_unit
               app_id
               tcode.

    IF sy-subrc IS INITIAL.
      "search USER from enhancement id search result.
      LOOP AT lt_enh_tcodes ASSIGNING <lfs_tcode> FROM sy-tabix
      WHERE enhpnt_id  =  ls_fcalls-enhpnt_id
        AND org_unit   =  ls_fcalls-org_unit
        AND app_id     =  ls_fcalls-app_id
        AND tcode      CP sy-tcode.

        ls_fcalls-istcode_auth = abap_true.
        EXIT.
      ENDLOOP.

    ELSE.
      "no tcode maintianed in table, which means, all tcodes are authorized.
      ls_fcalls-istcode_auth = abap_true.
    ENDIF.

    "return function with tcode and user authorization.
    IF ls_fcalls-deactivated = abap_true.
      RAISE EXCEPTION TYPE cx_enh_inactive_version_exists.
    ENDIF.

    IF  ls_fcalls-isuser_auth  = abap_true
    AND ls_fcalls-istcode_auth = abap_true.
      function_name = ls_fcalls-fm_name.
    ELSE.
      "raise authorization failed.
      RAISE EXCEPTION TYPE cx_enh_not_found.
    ENDIF.
  ENDMETHOD.


  METHOD get_form_bir_footer_input.

    DATA: lc_text_module TYPE c LENGTH 60 VALUE 'ZXXST_BIR_REQ_FOOTER'.

    r_structure-text_module = |{ lc_text_module }{ i_suffix }|.
    r_structure-date        = |{ sy-datum DATE = ENVIRONMENT }|.
    r_structure-time        = |{ sy-uzeit TIME = ISO }|.
    r_structure-version     = |{ sy-datum }_{ sy-uzeit(4) }|.
    r_structure-doc_name    = i_doc_name.
    r_structure-series_from = i_series_from.
    r_structure-series_to   = i_series_to.
    r_structure-system_used = |{ sy-sysid } { sy-mandt }|.

    zcl_xcomponent_functions=>get_param_value_single(
      EXPORTING
        app_id    =     gc_appid_general
        param_id  =     gc_param_bir_footer
        param_grp =     i_comp_code
      IMPORTING
        value1    =     r_structure-bir_permit
        value2    =     r_structure-date_issued
    ).


    TRANSLATE r_structure-doc_name TO UPPER CASE.

  ENDMETHOD.


  method GET_LOGO_GRAPHIC_NAME.
    IF i_colored EQ 'X'.
      zcl_xcomponent_functions=>get_param_value_single(
        EXPORTING
          app_id    = 'LOGO'
          param_id  = 'FORM'
          param_grp = i_bukrs
        IMPORTING
          value2    = r_col_graphic ).
    ELSE.
      zcl_xcomponent_functions=>get_param_value_single(
        EXPORTING
          app_id    = 'LOGO'
          param_id  = 'FORM'
          param_grp = i_bukrs
        IMPORTING
          value1    = r_col_graphic ).
    ENDIF.

  endmethod.


  METHOD get_logo_url.
    DATA: lv_hostname  TYPE string,
          lv_port      TYPE string,
          lv_bcol_logo TYPE string,
          lv_bmon_logo TYPE string.

* Get hostname and port
    CALL FUNCTION 'TH_GET_VIRT_HOST_DATA'
      EXPORTING
        virt_idx       = 0
      IMPORTING
        hostname       = lv_hostname
        port           = lv_port
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    IF sy-subrc NE 0.
      CALL FUNCTION 'TH_GET_VIRT_HOST_DATA'
        EXPORTING
          protocol       = 2
          virt_idx       = 0
        IMPORTING
          hostname       = lv_hostname
          port           = lv_port
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.
      IF sy-subrc  EQ 0.
        r_url = 'HTTPS'.
      ELSE.
        RETURN.
      ENDIF.
    ELSE.
      r_url = 'HTTP'.
    ENDIF.

* Get file name for logo
    zcl_xcomponent_functions=>get_param_value_single(
      EXPORTING
        app_id    = 'GENERAL'
        param_id  = 'LOGO'
        param_grp = i_bukrs
      IMPORTING
        value1    = lv_bcol_logo
        value2    = lv_bmon_logo ).
* Get ID
    IF i_with_color EQ 'X'.
      SELECT SINGLE loio_id
        FROM smimloio
        INTO @DATA(lv_loio_id)
        WHERE lo_class EQ 'M_IMAGE_L'
          AND prop09 EQ @lv_bcol_logo.
    ELSE.
      SELECT SINGLE loio_id
        FROM smimloio
        INTO @lv_loio_id
        WHERE lo_class EQ 'M_IMAGE_L'
          AND prop09 EQ @lv_bmon_logo.
    ENDIF.
* Get ID URL
    DATA(lo_mime) = cl_mime_repository_api=>get_api( ).
    lo_mime->get_url_for_io(
      EXPORTING
        i_loio            =    lv_loio_id
      IMPORTING
        e_url             =     DATA(lv_url)
      EXCEPTIONS
        parameter_missing = 1
        error_occured     = 2
        not_found         = 3
        OTHERS            = 4 ).
* URL
    IF sy-subrc EQ 0.
      r_url = |{ r_url }://{ lv_hostname }:{ lv_port }{ lv_url }|.
    ENDIF.

  ENDMETHOD.


  METHOD get_parameter_range.

    DATA: lo_structure TYPE REF TO cl_abap_structdescr,
          lo_datatype  TYPE REF TO cl_abap_elemdescr.

    IF param_grp IS SUPPLIED.
      SELECT *
        FROM zxxt_param_value
        INTO TABLE @DATA(lt_values)
        WHERE app_id    = @app_id   AND
              param_id  = @param_id AND
              param_grp = @param_grp.
    ELSE.
      SELECT *
        FROM zxxt_param_value
        INTO TABLE @lt_values
        WHERE app_id    = @app_id   AND
              param_id  = @param_id.
    ENDIF.

    CHECK lt_values IS NOT INITIAL.

    LOOP AT lt_values ASSIGNING FIELD-SYMBOL(<l_value>).

*-----at least 1 value should be populated
      IF <l_value>-param_val1 IS INITIAL AND
         <l_value>-param_val2 IS INITIAL.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO ct_range ASSIGNING FIELD-SYMBOL(<l_range>).

*-----Get reference component for edit mask
      IF lo_datatype IS INITIAL.
        lo_structure ?= cl_abap_typedescr=>describe_by_data( <l_range> ).
        DATA(lt_components) = lo_structure->get_components( ).
        lo_datatype ?= lt_components[ name = 'LOW' ]-type.
        DATA(lv_edit_mask)  = lo_datatype->edit_mask.
        SHIFT lv_edit_mask LEFT BY 2 PLACES.
        DATA(lv_fm_convert) = |CONVERSION_EXIT_{ lv_edit_mask }_INPUT|.

      ENDIF.

      ASSIGN COMPONENT 'SIGN'   OF STRUCTURE <l_range> TO FIELD-SYMBOL(<l_sign>).
      ASSIGN COMPONENT 'OPTION' OF STRUCTURE <l_range> TO FIELD-SYMBOL(<l_option>).
      ASSIGN COMPONENT 'LOW'    OF STRUCTURE <l_range> TO FIELD-SYMBOL(<l_low>).
      ASSIGN COMPONENT 'HIGH'   OF STRUCTURE <l_range> TO FIELD-SYMBOL(<l_high>).

*-----Set Low
      IF <l_value>-param_val1 IS NOT INITIAL.
        IF lo_datatype->edit_mask IS NOT INITIAL AND
           no_conversion EQ abap_false.
          CALL FUNCTION lv_fm_convert
            EXPORTING
              input  = <l_value>-param_val1
            IMPORTING
              output = <l_low>.
        ELSE.
          <l_low> = <l_value>-param_val1.
        ENDIF.
      ENDIF.

*-----Set High
      IF <l_value>-param_val2 IS NOT INITIAL.
        IF lo_datatype->edit_mask IS NOT INITIAL AND
           no_conversion EQ abap_false.
          CALL FUNCTION lv_fm_convert
            EXPORTING
              input  = <l_value>-param_val2
            IMPORTING
              output = <l_high>.
        ELSE.
          <l_high> = <l_value>-param_val2.
        ENDIF.
        <l_option> = 'BT'.
      ELSE.
        <l_option> = 'EQ'.
      ENDIF.

      <l_sign> = 'I'.

    ENDLOOP.


  ENDMETHOD.


  METHOD get_param_value_multi.

    SELECT values~mandt
        values~app_id
        values~param_id
        values~param_ctr
        values~param_grp
        values~param_val1
        values~param_val2

   FROM zxxt_param_app AS app

   INNER JOIN zxxt_param_names AS names
     ON app~app_id = names~app_id

   INNER JOIN zxxt_param_value AS values
     ON values~app_id   = names~app_id
    AND values~param_id = names~param_id

   INTO TABLE param_values

   WHERE app~app_id          =  app_id
     AND names~param_id      =  param_id
   ORDER BY values~mandt
            values~app_id
            values~param_id
            values~param_ctr
            values~param_grp
            values~param_val1
            values~param_val2
   .

    IF param_grp IS SUPPLIED.
      DELETE param_values
      WHERE param_grp <> param_grp.
    ELSE.
      ...
    ENDIF.

  ENDMETHOD.


  METHOD get_param_value_single.

    SELECT
       values~param_val1
       values~param_val2

  FROM zxxt_param_app AS app

  INNER JOIN zxxt_param_names AS names
    ON app~app_id = names~app_id

  INNER JOIN zxxt_param_value AS values
    ON values~app_id   = names~app_id
   AND values~param_id = names~param_id

  INTO (value1, value2)
  UP TO 1 ROWS

  WHERE app~app_id        =  app_id
    AND names~param_id    =  param_id
    AND values~param_grp  =  param_grp
    ORDER BY app~app_id
             names~param_id
             values~param_ctr.

      ... "set select endselect to make sure of ordering

    ENDSELECT.
  ENDMETHOD.


  METHOD get_ssf_texts.

*---Load smartform object
    DATA(lo_smartform_obj) = NEW cl_ssf_fb_smart_form( ).
    lo_smartform_obj->load(
              EXPORTING
                im_formname    =  CONV #( i_textname ) ).

    DATA lo_obj_item TYPE REF TO cl_ssf_fb_text_item.

*---Initialize item
    lo_obj_item ?= lo_smartform_obj->varheader[ 1 ]-pagetree->obj.

*---Get text
    rt_lines = lo_obj_item->text.

    CALL FUNCTION 'IDMX_DI_TLINE_INTO_STRING'
      EXPORTING
        it_tline       = rt_lines
      IMPORTING
        ev_text_string = c_string.

  ENDMETHOD.


  METHOD send_email_htm.

    DATA: lo_send_request TYPE REF TO cl_bcs,
          lo_sender       TYPE REF TO if_sender_bcs, "cl_sapuser_bcs,"
          lo_recipient    TYPE REF TO if_recipient_bcs,
          lo_document     TYPE REF TO cl_document_bcs,
          lo_document_bcs TYPE REF TO cx_document_bcs VALUE IS INITIAL,
          lo_mime_helper  TYPE REF TO cl_gbt_multirelated_service,
          ls_recipient    LIKE LINE OF i_recipient,
          ls_attachment   LIKE LINE OF i_attachment,
          content_type    TYPE mimetypes-type,
          sender_id       TYPE ad_smtpadr,
          sender_name     TYPE ad_smtpadr,
          lt_param        TYPE STANDARD TABLE OF zxxt_param_value,
          ls_param        LIKE LINE OF lt_param,
          lv_private      TYPE os_boolean,
          lt_member       TYPE STANDARD TABLE OF sodm1,
          lt_objpara      TYPE STANDARD TABLE OF selc,
          lt_objparb      TYPE STANDARD TABLE OF soop1,
          lv_send         TYPE mark VALUE 'X'.

    TRY.
* Create send request
        lo_send_request = cl_bcs=>create_persistent( ).
* Subject
        lo_send_request->set_message_subject( ip_subject = i_subject_long ).
* Email FROM...
        lt_param = zcl_xcomponent_functions=>get_param_value_multi(
                  EXPORTING
                    app_id       = 'GENERAL'
                    param_id     = 'EMAIL_SENDER'
                    param_grp    = '1000' ).

        READ TABLE lt_param INTO ls_param INDEX 1.
        sender_id   = ls_param-param_val1.
        sender_name = ls_param-param_val2.

        lo_sender = cl_cam_address_bcs=>create_internet_address( i_address_string = sender_id
                                                                 i_address_name = sender_name ).
* Add sender to send request
        lo_send_request->set_sender( i_sender = lo_sender ).
* Email TO...
        LOOP AT i_recipient INTO ls_recipient.
          CALL FUNCTION 'SO_DLI_READ'
            EXPORTING
              distributionlist           = ls_recipient-recipient
            TABLES
              member                     = lt_member
              objpara                    = lt_objpara
              objparb                    = lt_objparb
            EXCEPTIONS
              active_user_not_exist      = 1
              communication_failure      = 2
              component_not_available    = 3
              dl_name_not_exist          = 4
              folder_not_exist           = 5
              folder_no_authorization    = 6
              forwarder_not_exist        = 7
              object_not_exist           = 8
              object_no_authorization    = 9
              operation_no_authorization = 10
              owner_not_exist            = 11
              parameter_error            = 12
              substitute_not_active      = 13
              substitute_not_defined     = 14
              system_failure             = 15
              user_not_exist             = 16
              x_error                    = 17
              OTHERS                     = 18.
          IF lt_member[] IS NOT INITIAL.
            lv_private = 'X'.
          ELSE.
            lv_private = space.
          ENDIF.
          TRY.
              lo_recipient = cl_distributionlist_bcs=>getu_persistent( i_dliname = ls_recipient-recipient i_private = lv_private ).
            CATCH cx_address_bcs.
              lv_send = abap_false.
          ENDTRY.
* Add recipient to send request
          lo_send_request->add_recipient( i_recipient  = lo_recipient
                                          i_express    = ls_recipient-express
                                          i_copy       = ls_recipient-copy
                                          i_blind_copy = ls_recipient-blind_copy ).
        ENDLOOP.

        CHECK lv_send IS NOT INITIAL.
* Attachments
        CREATE OBJECT lo_mime_helper.
        LOOP AT i_attachment INTO ls_attachment.
* Get content type
          CALL FUNCTION 'SDOK_MIMETYPE_GET'
            EXPORTING
              extension = ls_attachment-extension
            IMPORTING
              mimetype  = content_type.

          IF ls_attachment-content_hex IS NOT INITIAL.
            TRY.
                lo_mime_helper->add_binary_part( content      = ls_attachment-content_hex
                                                 filename     = ls_attachment-filename
                                                 extension    = ls_attachment-extension
                                                 description  = ls_attachment-description
                                                 content_type = content_type
                                                 length       = ls_attachment-length
                                                 content_id   = ls_attachment-content_id ).
            ENDTRY.
          ENDIF.
          IF ls_attachment-content_text IS NOT INITIAL.
            TRY.
                lo_mime_helper->add_textual_part( content      = ls_attachment-content_text
                                                  filename     = ls_attachment-filename
                                                  content_type = content_type
                                                  length       = ls_attachment-length
                                                  content_id   = ls_attachment-content_id ).
            ENDTRY.
          ENDIF.
        ENDLOOP.

        lo_mime_helper->set_main_html( content     = i_body
                                       filename    = 'message.htm'      "filename for HMTL form
                                       description = 'Email message' ). "Title
        lo_document = cl_document_bcs=>create_from_multirelated( i_subject = i_subject
                                                                 i_multirel_service = lo_mime_helper ).
* Add document to send request
        lo_send_request->set_document( lo_document ).
* Send email
        lo_send_request->set_send_immediately( 'X' ).
        lo_send_request->send( i_with_error_screen = 'X' ).
* Commit to send email
        COMMIT WORK.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
