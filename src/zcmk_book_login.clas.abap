class ZCMK_BOOK_LOGIN definition
  public
  inheriting from CL_ICF_BASIC_LOGIN
  create public .

public section.

  methods HTM_LOGIN
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCMK_BOOK_LOGIN IMPLEMENTATION.


  METHOD htm_login.

    DATA lv_html TYPE string.

    CONCATENATE
`           <!DOCTYPE html>`
`           <html lang="en">`
`             <head>`
`               <meta charset="UTF-8" />`
`               <meta name="viewport" content="width=device-width, initial-scale=1.0" />`
`               <title>서강대학교 - 수강신청</title>`
`               <style>`
`                 @font-face {`
`                   font-family: "sogang";`
`                   src: url("/sap/bc/webdynpro/sap/zcmwk000/SOGANG_UNIVERSITY_for_windows.ttf");`
`                 }`
``
`                 /* @font-face {`
`                   font-family: "Pretendard Variable";`
`                   font-weight: 45 920;`
`                   font-style: normal;`
`                   font-display: swap;`
`                   src: url("font/woff2/PretendardVariable.woff2")`
`                     format("woff2-variations");`
`                 } */`
`                 * {`
`                   font-family: "sogang";`
`                   /* font-family: "Pretendard Variable"; */`
`                   margin: 0;`
`                   padding: 0;`
`                   box-sizing: border-box;`
`                 }`
`                 input:-webkit-autofill,`
`                 input:-webkit-autofill:hover,`
`                 input:-webkit-autofill:focus,`
`                 input:-webkit-autofill:active {`
`                   transition: background-color 5000s ease-in-out 0s;`
`                   -webkit-transition: background-color 9999s ease-out;`
`                   -webkit-box-shadow: 0 0 0px 1000px white inset !important;`
`                 }`
`                 .sgbBody {`
`                   width: 100%;`
`                   height: 100%;`
`                   display: flex;`
`                   justify-content: center;`
`                   background: #dddddd url("/sap/bc/webdynpro/sap/zcmwk000/sgBg.jpg");`
`                   background-size: cover;`
`                 }`
`                 .sgbLoginLayer {`
`                   width: 500px;`
`                   min-height: 450px;`
`                   background-color: white;`
`                   border-radius: 10px;`
`                   margin-top: 100px;`
`                 }`
`                 .sgbLogo {`
`                   width: 100%;`
`                   text-align: center;`
`                   margin-top: 50px;`
`                 }`
`                 .sgbAppTitle {`
`                   font-size: 18px;`
`                 }`
`                 .sgbLoginForm {`
`                   width: 80%;`
`                   margin: 30px auto 0 auto;`
`                   box-sizing: border-box;`
`                 }`
`                 .sgbLoginForm .userBox {`
`                   height: 50px;`
`                   width: 100%;`
`                   border: 2px solid #cccccc;`
`                   margin-bottom: 20px;`
`                   border-radius: 5px;`
`                   box-sizing: border-box;`
`                   padding: 0 10px;`
`                 }`
`                 .sgbLoginForm .userBox {`
`                   height: 50px;`
`                   width: 100%;`
`                   border: 2px solid #cccccc;`
`                   margin-bottom: 20px;`
`                   border-radius: 5px;`
`                   box-sizing: border-box;`
`                   padding: 0 10px;`
`                 }`
`                 .sgbLoginForm .userBox input {`
`                   width: 100%;`
`                   height: 27px;`
`                   border: none;`
`                   font-size: 15px;`
`                   caret-color: #7d0000;`
`                 }`
`                 .sgbLoginForm .userBox input:focus {`
`                   outline: none;`
`                 }`
`                 .sgbLoginForm .userBox label {`
`                   font-size: 12px;`
`                   color: #808080;`
`                 }`
`                 .formLoginBtn input {`
`                   width: 100%;`
`                   height: 45px;`
`                   font-size: 16px;`
`                   border: none;`
`                   background-color: #7d0000;`
`                   color: white;`
`                   border-radius: 5px;`
`                 }`
`                 .formLoginBtn input:hover {`
`                   background-color: #b30000;`
`                   cursor: pointer;`
`                 }`
`                 .sgbList {`
`                   margin-top: 20px;`
`                   margin-left: 20px;`
`                   margin-right: 20px;`
`                   margin-bottom: 20px;`
`                 }`
`                 .sgbList li {`
`                   list-style: none;`
`                   font-size: 13px;`
`                   line-height: 20px;`
`                   margin-bottom: 10px;`
`                 }`
`                 .sgbLangu {`
`                   text-align: right;`
`                   margin-bottom: 15px;`
`                   font-size: 15px;`
`                 }`
`                 .sgbLangu [type="radio"] {`
`                   vertical-align: middle;`
`                   appearance: none;`
`                   border: max(2px, 0.1em) solid #cccccc;`
`                   border-radius: 50%;`
`                   width: 1.25em;`
`                   height: 1.25em;`
`                   margin-left: 10px;`
`                   padding-bottom: 3px;`
`                 }`
`                 .sgbLangu [type="radio"]:checked {`
`                   border: 0.4em solid #7d0000;`
`                 }`
`                 .sgbLangu [type="radio"]:hover {`
`                   /* box-shadow: 0 0 0 max(4px, 0.2em) lightgray; */`
`                   cursor: pointer;`
`                 }`
`                 .sgbLangu [type="radio"]:hover + label {`
`                   cursor: pointer;`
`                 }`
`               </style>`

'<script type="text/javascript">'
           iv_javascript
'function go_submit() {'
'if (event.keyCode == 13)'
`callSubmitLogin('onLogin');`
'}'

'function displayExap(){'
  '' me->co_js_cookie_check '();'
'}'

'</script>'
`             </head>`
`             <body class="sgbBody">`
`               <div class="sgbLoginLayer">`
`                 <div class="sgbLogo">`
`                   <img src="/sap/bc/webdynpro/sap/zcmwk000/Signature.png" alt="서강대학교" width="200px" />`
`                   <p class="sgbAppTitle">수강신청<br />Course Registration</p>`
`                 </div>`
`                 <div class="sgbLoginForm">`
'                   <form name="' me->co_form_login '" action="' me->m_sap_application '" method="post" >'
                      iv_hidden_fields
`                     <div class="userBox" id="sgbUserBoxId">`
`                       <label for="sgbLoginId" id="sgbLabelId">학번(UserID)</label>`
`                       <input`
`                         type="text"`
'                         name="' me->co_sap_user '"'
'                         id="' me->co_sap_user '"'
`                         class="sgbLoginId"`
`                         required`
`                       />`
`                     </div>`
`                     <div class="userBox" id="userBoxPw">`
`                       <label for="sgbLoginPw" id="sgbLabelPw">비밀번호(Password)</label>`
`                       <input`
`                         type="password"`
'                         name="' me->co_sap_password '"'
'                         id="' me->co_sap_password '"'
`                         class="sgbLoginPw"`
`                         required  onkeyup="go_submit();"`

`                       />`
`                     </div>`
`                     <div class="sgbLangu">`
`                       <input type="radio" name="` me->co_sap_language `" id="languKo" checked />`
`                       <label for="languKo">한국어(Korean)</label>`
`                       <input type="radio" name="` me->co_sap_language `" id="languEn" />`
`                       <label for="languEn">영어(English)</label>`
`                     </div>`
`                     <div class="formLoginBtn">`
`                       <input type="button" value="Login" id="LoginBtn" onclick="callSubmitLogin('onLogin'); return false;" />`
`                     </div>`
`                   </form>`
`                 </div>`
`                 <ul class="sgbList">`
`                   <li>`
`                     ※ 수강신청과목 담아놓기는 SAINT PORTAL에서 로그인하여 하시기`
`                     바랍니다.<br />`
`                     ㅤ 메뉴 위치 : SAINT Portal 로그인 → 수업/성적 → 수강신청과목 담아놓기`
`                   </li>`
`                   <li>`
`                     ※ 정규학기 수강신청 시, 휴학생은 복학신청을 먼저 해야 합니다.<br />`
`                     ㅤ (Tel: 종합봉사실 02-705-8000)`
`                   </li>`
`                 </ul>`
`               </div>`
`               <script type="text/javascript">`
`                 const inputId = document.querySelector(".sgbLoginId");`
`                 const inputPw = document.querySelector(".sgbLoginPw");`
`                 const boxId = document.querySelector("#sgbUserBoxId");`
`                 const boxPw = document.querySelector("#userBoxPw");`
`                 const lebelId = document.querySelector("#sgbLabelId");`
`                 const sgbLabelPw = document.querySelector("#sgbLabelPw");`
`                 inputId.addEventListener("focus", () => {`
`                   boxId.style.borderColor = "#7d0000";`
`                   lebelId.style.color = "#7d0000";`
`                 });`
`                 inputId.addEventListener("blur", () => {`
`                   boxId.style.borderColor = "#cccccc";`
`                   lebelId.style.color = "#808080";`
`                 });`
`                 inputPw.addEventListener("focus", () => {`
`                   boxPw.style.borderColor = "#7d0000";`
`                   sgbLabelPw.style.color = "#7d0000";`
`                 });`
`                 inputPw.addEventListener("blur", () => {`
`                   boxPw.style.borderColor = "#cccccc";`
`                   sgbLabelPw.style.color = "#808080";`
`                 });`
`                 inputId.focus();`
`               </script>`
*`             </body>`
*`           </html>`

INTO rv_html.

    DATA: lv_mesg  TYPE string,
          lv_check,
          lv_sev   TYPE string.
    DATA: lv_msg_item   TYPE bspmsg.

    CLEAR lv_msg_item.
    DELETE me->m_logmessages WHERE severity <> '1'.

    IF me->m_logmessages IS NOT INITIAL.

      READ TABLE me->m_logmessages INDEX 1 INTO lv_msg_item.
      IF lv_msg_item-severity = 1.
        lv_msg_item-message = '이름 또는 비밀번호가 잘못되었습니다. 다시 로그인 하세요.'.
      ENDIF.

      CONCATENATE rv_html
*                  '<script type="text/javascript" src="/sap/bc/bsp/sap/zcm_netfunnel/nfn_1.js" charset="UTF-8"></script>'
                  '<script language="javascript">'
                  `var oMsg = "";`
                  `oMsg = '`
                  lv_msg_item-message
                  `' + '\n';`
                  `alert(oMsg);`
                  `</script>`
             INTO rv_html.

    ENDIF.

    CONCATENATE rv_html
                `</body>`
                `</html>`
           INTO rv_html.




  ENDMETHOD.
ENDCLASS.
