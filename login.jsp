<%@ page language="java" import="java.util.*,java.sql.*,java.net.*" contentType="text/html; charset=utf-8"%>

<%@ page language="java" %>
<% request.setCharacterEncoding("utf-8");

	String email=request.getParameter("email");
	String pwd=request.getParameter("password");
	String verify=request.getParameter("verify");
	String msg = "";
	String fmt = "";
  String fmtselect="";
  String url = "";
  String words="";
  String test="";
	if(request.getMethod().equalsIgnoreCase("post"))
	{
  try{
	String connectString = "jdbc:mysql://localhost:3306/web" + "?autoReconnect=true&useUnicode=true&characterEncoding=UTF-8";
              Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
              Connection con = DriverManager.getConnection(connectString, "root", "666666");  Statement stmt = con.createStatement();
  fmtselect="select * from user where user_email='%s'";
  String sqls=String.format(fmtselect,email);
  ResultSet rss=stmt.executeQuery(sqls);
  if(rss.next()==false)
  {
    msg="邮箱未注册，请注册";
  }
  else
	{
    fmt="select password from user where user_email='%s'";
    String sql = String.format(fmt,email);
    ResultSet rs = stmt.executeQuery(sql);
    String passwd="";
    while(rs.next())
    {
      passwd=rs.getString("password");
    }
    test=passwd;
    if(passwd.equals(pwd))
    {
      msg = "登录成功!"; url=String.format(url,email);
      String username = URLEncoder.encode(email,"utf-8");
      String password = URLEncoder.encode(pwd,"utf-8");
      Cookie usernameCookie = new Cookie("user_email",username);
      Cookie passwordCookie = new Cookie("password",password);
      usernameCookie.setMaxAge(864000);
      passwordCookie.setMaxAge(864000);//设置最大生存期限为10天
      response.addCookie(usernameCookie);
      response.addCookie(passwordCookie);
      response.sendRedirect("index.jsp?indexid=0");

    }
    else
    {
      msg="密码错误";
    }

  }
	stmt.close();
	con.close();
	}
catch (Exception e){
	msg = "登录失败";
	}
}
%>
<!DOCTYPE html>
<!-- saved from url=(0025)http://www.bystudent.com/ -->
<html class="uk-touch">
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <title>中大论坛</title>
  <link rel="stylesheet" id="qzhai-css" href="./ByStudent_files/style_o.css" type="text/css" media="all" />
  <link rel="stylesheet" id="qzhai_icont-css" href="./ByStudent_files/font_ph8abo6zeqoxbt9.css" type="text/css" media="all" />
  <script type="text/javascript" src="./ByStudent_files/jquery.min.js"></script>
  <script type="text/javascript" src="./ByStudent_files/si_captcha.js"></script>
 </head>
 <body class="uk-height-1-1" style="margin: auto;">
  <div id="main" class="wp uk-grid uk-grid-collapse" style="max-width:660px ;">
 <!--content-->
   <div id="content" class="uk-width-small-1-1 uk-width-medium-3-4 uk-width-large-4-5 uk-grid uk-grid-collapse" style="margin: auto;">
    <div class=" uk-width-1-1" >
     <div id="index" class="bs uk-text-break">
        <link rel="stylesheet" type="text/css" href="register-login.css">
        <h4><div class="index-tab" style="margin:0;padding: 0">
            <div class="index-slide-nav" style="margin: 0;padding: 0;">
              <a href="login.html" class="active">登录</a>
         <a href="register.html" >注册</a>
            </div>
          </div></h4>
        <div class="cent-box" style="height: 250px;">
          <div class="cont-main clearfix">
          <form action="login.jsp" method="post" onsubmit="return check()">
            <div class="login form">
              <div class="group">
                <div class="group-ipt email">
                  <input type="text" name="email" id="email" class="ipt" placeholder="账号" required="">
                </div>
                <div class="group-ipt password">
                  <input type="password" name="password" id="password" class="ipt" placeholder="密码" required="">
                </div>
              </div>
            </div>
            <div class="button">
              <button type="submit" class="login-btn register-btn" id="button" >登录</button>
            </div>
            </form>
            <div class="remember clearfix">
              <label class="remember-me"><span class="icon"><span class="zt"></span></span><input type="checkbox" name="remember-me" id="remember-me" class="remember-mecheck" checked="">记住我</label>
              <label class="forgot-password">
                <a href="findpassword.html">忘记密码？</a>
              </label>
            </div>

          </div>
        </div><p><%=msg%><%=test%></p>
       </div>
     </div>
    </div>
   </div>

   <script type="text/javascript">
     function check(){
        {
          if(form.username.value == "")//如果用户名为空
          {
            alert("您还没有填写用户名！");
            form.username.focus();
            return false;
          }
          if(form.pass.value == "")//如果密码为空
          {
            alert("您还没有填写密码！");
            myform.pass.focus();
            return false;
          }
        }
   </script>

   <script type="text/javascript" color="0,191,255" zindex="-1" opacity="100" count="99" src="./ByStudent_files/canvas-nest.min.js"></script>
   <script type="text/javascript" src="./ByStudent_files/wp-embed.min.js"></script>
   <script type="text/javascript" src="./ByStudent_files/app.js"></script>
   <a href="http://www.bystudent.com/#" class="top" data-uk-smooth-scroll="" style="display:none"><i class="uk-icon-angle-up"></i></a>
  <canvas id="c_n8" width="1280" height="589" style="position: fixed; top: 0px; left: 0px; z-index: -1; opacity: 20;"></canvas>
  <audio controls="controls" style="display: none;"></audio>

 </body>
</html>
