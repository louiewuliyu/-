<%@ page language="java" import="java.util.*,java.sql.*" contentType="text/html; charset=utf-8"%>

<%@ page language="java" %>   
<% request.setCharacterEncoding("utf-8"); 
  String email=request.getParameter("email"); 
  String name=request.getParameter("user");
  String pwd=request.getParameter("password");
  String verify=request.getParameter("verify"); 
  String msg = ""; 
  String fmt = "";
  String fmtselect="";
  String url = "";
  String words="";
  if(request.getMethod().equalsIgnoreCase("post"))
  { 
  try{
  String connectString = "jdbc:mysql://localhost:3306/web" + "?autoReconnect=true&useUnicode=true&characterEncoding=UTF-8";
              Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
              Connection con = DriverManager.getConnection(connectString, "root", "666666");  Statement stmt = con.createStatement();
  fmtselect="select * from user where user_email='%s'";
  String sqls=String.format(fmtselect,email);
  ResultSet rs=stmt.executeQuery(sqls);
  if(rs.next()==false)
  {
    msg="邮箱未注册，";
    String turl="register.html";
    url=String.format(url);
    words="注册";
  }
  else
  {
    String fmtv="select * from code_table where email='%s';";
    String sqlv=String.format(fmtv,email);
    ResultSet r=stmt.executeQuery(sqlv);
    if(r.next())
    {
      String code=r.getString("code");
      if(code.equals(verify))
      {
        fmt="update user set password='%s' where user_email='%s';"; 
        String sql = String.format(fmt,pwd,email); 
        int cnt = stmt.executeUpdate(sql); 
        if(cnt>0)
        {
          msg = "密码重置成功!"; 
          String turl="login.html";
          url=String.format(url,email);
          words="登录";
        }
        else
        {
          msg="验证码错误"；
          url="findpassword.html";
          words="重置密码";
        }
      }
    }
  }
  stmt.close();
  con.close();
  }
catch (Exception e){ 
  msg = "重置失败";
   url="findpassword.html";
   words="重置密码";
  } 
}
%> 
<!DOCTYPE html>
<!-- saved from url=(0025)http://www.bystudent.com/ -->
<html class="uk-touch">
 <head> 
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 
  <title>学生服务平台</title> 
  <link rel="stylesheet" id="qzhai-css" href="./ByStudent_files/style_o.css" type="text/css" media="all" /> 
  <link rel="stylesheet" id="qzhai_icont-css" href="./ByStudent_files/font_ph8abo6zeqoxbt9.css" type="text/css" media="all" /> 
  <script type="text/javascript" src="./ByStudent_files/jquery.min.js"></script> 
  <script type="text/javascript" src="./ByStudent_files/si_captcha.js"></script> 
 </head> 
 <body class="uk-height-1-1" style="margin: auto;"> 
  <div id="main" class="wp uk-grid uk-grid-collapse" style="max-width:660px ;"> 
   <!--content--> 
   <div id="content" class="uk-width-small-1-1 uk-width-medium-3-4 uk-width-large-4-5 uk-grid uk-grid-collapse" style="margin: auto;"> 
    <div class=" uk-width-1-1"> 
     <div id="index" class="bs uk-text-break" style="height: 400px"> 
      <link rel="stylesheet" type="text/css" href="register-login.css" /> 
      <h4>
       <div class="index-tab" style="margin:0;padding: 0"> 
        <div class="index-slide-nav" style="margin: 0;padding: 0;"> 
         <a href="login.html">登录</a> 
         <a href="register.html" class="active">注册</a> 
        </div> 
       </div>
      </h4> 
      <div class="cent-box" style="height: auto;position: absolute;"> 
       <div class="cont-main clearfix" style="padding-bottom: 20px;"> 
 <p style="color: blue;font-size: 20px;margin-left: 70px;font-weight: bold;"> <%=msg%>请<a href=<%=url%> > <%=words%> </a> </p>
      </div> 
     </div> 
    </div> 
   </div> 
  </div> 
  <script type="text/javascript" color="0,191,255" zindex="-1" opacity="100" count="99" src="./ByStudent_files/canvas-nest.min.js"></script> 
  <script type="text/javascript" src="./ByStudent_files/wp-embed.min.js"></script> 
  <script type="text/javascript">
    function check()  
        {  
           if(form.user.value.length<6 || form.user.value.length>16)  
           {  
           alert('用户名不合法！请输入6-16位用户名');  
           form.user.focus();  
           return false;  
           }  
           if(form.password.value.length<6 ||form.password.value.length>16)  
           {  
           alert('密码不合法！请输入6-16位密码');  
           form.username.focus();  
           return false;  
           }  
           if(form.password.value != form.password1.value)//判断两次输入的密码是否一致  
           {  
            alert("两次输入的密码不一致！");  
            form.pass.focus();  
            return false;  
           }  
        }  
  </script>
  <script type="text/javascript" src="./ByStudent_files/app.js"></script>
  <script type="text/javascript"> 
  var countdown=60; 
  function settime(obj) { 
    if (countdown == 0) { 
        obj.removeAttribute("disabled");    
        obj.value="免费获取验证码"; 
        countdown = 60; 
        return;
    } else { 
        obj.setAttribute("disabled", true); 
        obj.value="重新发送(" + countdown + ")"; 
        countdown--; 
    } 
  setTimeout(function() { 
    settime(obj) }
    ,1000) 
  }
  </script>
  <a href="http://www.bystudent.com/#" class="top" data-uk-smooth-scroll="" style="display:none"><i class="uk-icon-angle-up"></i></a> 
  <canvas id="c_n8" width="1280" height="589" style="position: fixed; top: 0px; left: 0px; z-index: -1; opacity: 20;"></canvas>  
 </body>
</html>