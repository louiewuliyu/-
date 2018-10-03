<%@ page language="java" import="java.util.*"
         contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.*"%>
<%@ page import="java.net.*"%>
<%@ page import="java.io.*, java.util.*,org.apache.commons.io.*"%> 
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.disk.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>

<%request.setCharacterEncoding("utf-8");%>
<%!
  //论坛帖子
  static class post {
    int postId;
    int posterId;
    String posterName;
    String postTitle;
    String postArticle;
    int replieNum;
    Date createTime;
    Date updateTime;
    LinkedList<postcomment> replies;
  }
  //论坛帖子回复
  static class postcomment{
    int postId;
    int replieId;
    int replierId;
    int repliedId;
    String replierName;
    String subComment;
    Date replieTime;
  }

// 数据库操作
/* --------------------------------------------------------------------------------- */

  private static Connection connect_db(StringBuffer log) {
    String connectString = "jdbc:mysql://localhost:3306/web" + "?autoReconnect=true&useUnicode=true&characterEncoding=UTF-8";
              
		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
      Connection con = DriverManager.getConnection(connectString, "root", "666666");
      log.append("Connect Database...\r\n");
      return con;
		}
    catch (Exception e) {
			log.append("error: "+ e.getMessage() + "\r\n");
		}
		return null;
  }

  private static ResultSet executeQuery(Connection conn, String sqlSentence, StringBuffer log) {
    Statement stat;
    ResultSet rs = null;

    try {
      stat = conn.createStatement();
      rs = stat.executeQuery(sqlSentence);
      log.append("Execute SQL Sentence...\r\n");
    }
    catch (Exception e) {
      log.append("error: "+ e.getMessage() + "\r\n");
    }
    return rs;
  }

  private static int executeUpdate(Connection conn, String sqlSentence, StringBuffer log) {
    Statement stat;
    int res = 0;

    try {
      stat = conn.createStatement();
      res = stat.executeUpdate(sqlSentence);
      log.append("Execute SQL Update Sentence...\r\n");
      log.append("Update " + res + " columns...\r\n");
    }
    catch (Exception e) {
      log.append("error: "+ e.getMessage() + "\r\n");
    }
    return res;
  }

  private static void close_db(Connection conn, StringBuffer log)
  {
    if(conn != null){
      try{
        conn.close();
        log.append("Close Database Connection...\r\n");
      }
      catch (Exception e) {
        log.append("error: "+ e.getMessage() + "\r\n");
      }
    }
  }

  //获取帖子摘要
  private static LinkedList<post> getPostAbs(Connection conn, StringBuffer log)
  {
    String sqlsen = "select postid, posterid, postername, posttitle, "
                    + "postarticle, replienum, postupdatetime "
                    + "from post order by postupdatetime desc "
                    + "limit 10";
    ResultSet executeres = executeQuery(conn, sqlsen, log);
    LinkedList<post> res = new LinkedList<post>();
    try{
      while(executeres.next()){
        post temppostabs = new post();
        temppostabs.postId = Integer.parseInt(executeres.getString("postid"));
        temppostabs.posterId = Integer.parseInt(executeres.getString("posterid"));
        temppostabs.posterName = executeres.getString("postername");
        temppostabs.postTitle = executeres.getString("posttitle");
        temppostabs.postArticle = executeres.getString("postarticle");
        temppostabs.replieNum = Integer.parseInt(executeres.getString("replienum"));
        temppostabs.updateTime = executeres.getTimestamp("postupdatetime");
        res.add(temppostabs);
      }
      log.append("Get PostAbs...\r\n");
      executeres.close();
    }
    catch(Exception e){
      log.append("error: "+ e.getMessage() + "\r\n");
    }
    return res;
  }

  //获取帖子信息
  private static post getPost(Connection conn, StringBuffer log, String postid)
  {
    String sqlsen = "select * from post where postid=" + postid;
    ResultSet executeres = executeQuery(conn, sqlsen, log);

    try{
      if(executeres.next()){
        post res = new post();
        res.postId = Integer.parseInt(executeres.getString("postid"));
        res.posterId = Integer.parseInt(executeres.getString("posterid"));
        res.posterName = executeres.getString("postername");
        res.postTitle = executeres.getString("posttitle");
        res.postArticle = executeres.getString("postarticle");
        res.replieNum = Integer.parseInt(executeres.getString("replienum"));
        res.updateTime = executeres.getTimestamp("postupdatetime");
        res.createTime = executeres.getTimestamp("postcreatetime");
        log.append("Get Post...\r\n");
        res.replies = getreplie(conn, log, postid);
        executeres.close();
        return res;
      }
    }
    catch(Exception e){
      log.append("error: "+ e.getMessage() + "\r\n");
    }
    return null;
  }

  //获取帖子回复
  private static LinkedList<postcomment> getreplie(Connection conn, StringBuffer log, String postid)
  {
    String sqlsen = "select * from postcomment where postid=" + postid + " order by replietime desc;";
    ResultSet executeres = executeQuery(conn, sqlsen, log);

    try{
      LinkedList<postcomment> res = new LinkedList<postcomment>();
      while(executeres.next()){
        postcomment tempcomm = new postcomment();
        tempcomm.postId = Integer.parseInt(executeres.getString("postid"));
        tempcomm.replieId = Integer.parseInt(executeres.getString("replieid"));
        tempcomm.replierId = Integer.parseInt(executeres.getString("replierid"));
        tempcomm.repliedId = Integer.parseInt(executeres.getString("repliedid"));
        tempcomm.replierName = executeres.getString("repliername");
        tempcomm.subComment = executeres.getString("subcomment");
        tempcomm.replieTime = executeres.getTimestamp("replietime");
        res.add(tempcomm);
      }
      log.append("Get Post Comment...\r\n");
      executeres.close();
      return res;
    }
    catch(Exception e){
      log.append("error: "+ e.getMessage() + "\r\n");
    }
    return null;
  }

  //发表帖子,返回发布的帖子的ID
  private static int publish_post(Connection conn, StringBuffer log, post pub_post){
    String sql_sen = "INSERT INTO post (posterid, postername, posttitle, postarticle)"
                     + "VALUES(" + pub_post.posterId + ", \'" + pub_post.posterName
                     + "\', \'" + pub_post.postTitle + "\', \'" + pub_post.postArticle
                     + "\')";
    log.append(sql_sen + "\r\n");
    executeUpdate(conn, sql_sen, log);
    log.append("Post Publish...\r\n");
    sql_sen = "select postid, postcreatetime from post where posterid = " + pub_post.posterId
              + " order by postcreatetime desc";
    ResultSet executeres = executeQuery(conn, sql_sen, log);
    try {
      if(executeres.next()){
        String pub_postid = executeres.getString("postid");
        log.append("Get pub_postid " + pub_postid +" ...\r\n");
        return Integer.parseInt(pub_postid);
      }
    }
    catch(Exception e){
      log.append("error: "+ e.getMessage() + "\r\n");
    }

    return 0;
  }

  //新增帖子回复
  private static void add_post_replie(Connection conn, StringBuffer log, postcomment comment)
  {
    String replie_sql = "INSERT INTO postcomment (postid, repliedid, replierid, repliername, subcomment)"
                        + "VALUES (" + comment.postId + ", " + comment.repliedId + ", "
                        + comment.replierId + ", \'" + comment.replierName
                        + "\', \'" + comment.subComment + "\')";

   executeUpdate(conn, replie_sql, log);
   log.append("Post replie...\r\n");
  }

/* --------------------------------------------------------------------------------- */

  private static String gettimedif(Date time)
  {
      Date now = new Date();
      long diff = now.getTime() - time.getTime();

      if(diff <= 60*1000){
        return String.valueOf(diff / 1000) + "秒前";
      }
      else if(diff <= 60*60*1000){
        return String.valueOf(diff/(60*1000)) + "分钟前";
      }
      else if(diff <= 24*60*60*1000){
        return String.valueOf(diff/(60*60*1000)) + "小时前";
      }
      else{
        return String.valueOf(diff/(24*60*60*1000)) + "天前";
      }
  }

%>

<%  //日志
  StringBuffer log = new StringBuffer("");
  String indexid = request.getParameter("indexid");
         indexid = indexid==null?"0":indexid;
   int userid = 23;
   String username = "Test";
   String image_url="src/image.jpeg";
   String user_email="";
   String password = "";
   String msgs="hehe";
   Cookie[] cookies = request.getCookies();
   if(cookies!=null&&cookies.length>0)
   {
      for(Cookie c:cookies)
      {
       if(c.getName().equals("user_email"))
       {
          user_email = URLDecoder.decode(c.getValue(),"utf-8");
       }
       if(c.getName().equals("password"))
       {
          password = URLDecoder.decode(c.getValue(),"utf-8");
       }
      }
      msgs=user_email+password;
      if(user_email==""||password=="")
      {
        msgs="emailhuopasswordkong";
        response.sendRedirect("login.html");
        return;
      }
      try{
          String connectString = "jdbc:mysql://localhost:3306/web" + "?autoReconnect=true&useUnicode=true&characterEncoding=UTF-8";
              Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
              Connection con = DriverManager.getConnection(connectString, "root", "666666");  Statement stmt = con.createStatement();
        String fmtselect="select * from user where user_email='%s'";
        String sqls=String.format(fmtselect,user_email);
        ResultSet rss=stmt.executeQuery(sqls);
        msgs="12345";
        {
          String passwd="";
          msgs="436";
          while(rss.next())
          {
            passwd=rss.getString("password");
            username=rss.getString("username");
            msgs=passwd;
            if(rss.getString("image_url")!=null)
            image_url=rss.getString("image_url");
            msgs="qert";
          }
          if(!passwd.equals(password))
          {
            msgs=password;
            response.sendRedirect("login.html");
            return;
          }
        }
      }
      catch(Exception e){
      msgs="weizhicuowu";
          response.sendRedirect("login.html");
          return;
      }
  }

  //时间格式
  SimpleDateFormat ymd_sdf = new SimpleDateFormat("yyyy-mm-dd");

  HashMap<String, String> title_str = new HashMap<String, String>();
  title_str.put("0", "个人");
  title_str.put("1", "头像");
  title_str.put("2", "课程");
  title_str.put("3", "论坛");
  title_str.put("4", "聊天");

%>

<!DOCTYPE html>
<html>

<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <title>中大论坛</title>
  <link rel="stylesheet" href="./src/style.css" type="text/css" media="all" />
  <link rel="stylesheet" href="./src/font-awesome/css/font-awesome.min.css" type="text/css"/>

</head>

<body>
  <div id="main">
    <div id="left_infor">
      <div id="user_infor">
        <div id="icon">
          <img src=<%=image_url%> />
        </div>
        <div id="user_name">
          <h1><%=username%></h1>
        </div>
        <div id="user_active_3">
          <div class="user_active">
            <span>0</span>
            <span><i class="fa fa-comment fa-lg"></i></span>
          </div>
          <div class="user_active">
            <span>0</span>
            <span><i class="fa fa-comment fa-lg"></i></span>
          </div>
          <div class="user_active">
            <span>0</span>
            <span><i class="fa fa-comment fa-lg"></i></span>
          </div>
        </div>
      </div>
      <div id="nav">
        <li class="left_nav"><a href="index.jsp?indexid=0" class="<%=indexid.equals("0")?"blue_bc":""%>"><%=title_str.get("0")%></a></li>
        <li class="left_nav"><a href="index.jsp?indexid=1" class="<%=indexid.equals("1")?"blue_bc":""%>"><%=title_str.get("1")%></a></li>
        <li class="left_nav"><a href="index.jsp?indexid=2" class="<%=indexid.equals("2")?"blue_bc":""%>"><%=title_str.get("2")%></a></li>
        <li class="left_nav"><a href="index.jsp?indexid=3" class="<%=indexid.equals("3")?"blue_bc":""%>"><%=title_str.get("3")%></a></li>
        <li class="left_nav"><a href="index.jsp?indexid=4" class="<%=indexid.equals("4")?"blue_bc":""%>"><%=title_str.get("4")%></a></li>

      </div>
    </div>
    <div id="content">
      <div id="content_main">
        <div id="content_title">
          <h4><%=title_str.get(indexid)%></h4>
          <div id="content_search" class="search">
            <form action="index.jsp?indexid=<%=indexid%>" method="post">

              <!--<input name="q" type="hidden" />-->
              <input name='qfront' class="search_input input_text" type="text" placeholder="搜索">
              <button class="search_btn input_btn" name="search">搜索</button>
            </form>
          </div>
        </div>
        <div id="content_article">
          <%
            Connection conn = connect_db(log);
            StringBuilder comment_table = new StringBuilder();
            if(indexid.equals("0")){
              String name="";
              String descript="";
              String sex="";
              String major="";
              String grade="";
              String msg = "";
              String fmt = "";
              String tip="";
              String connectString =  "jdbc:mysql://localhost:53306/boke15336189" + "?autoReconnect=true&useUnicode=true&characterEncoding=UTF-8";
              Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
              Connection con = DriverManager.getConnection(connectString,"user", "123");  Statement stmt = con.createStatement();
              if(request.getMethod().equalsIgnoreCase("post")){
                name=request.getParameter("name");
                descript=request.getParameter("descript");
                sex=request.getParameter("sex");
                grade=request.getParameter("grade");
                major=request.getParameter("major");
                  try{
                    fmt="update user set username='%s',descript='%s',sex='%s',grade='%s',major='%s' where user_email='%s'";
                    String sql = String.format(fmt,name,descript,sex,grade,major,user_email);
                    int cnt = stmt.executeUpdate(sql);
                    tip="456";
                    if(cnt>0)
                    {
                      msg = "修改成功!";
                    } 
                  }
                  catch (Exception e){
                  msg = "修改失败";
                   }
                   }
            else{
              try{ 
                    fmt="select * from user where user_email='%s'";
                    String sql = String.format(fmt,user_email);
                    ResultSet rs=stmt.executeQuery(sql);
                    tip="789";
                    while(rs.next())
                    {
                        name=rs.getString("username");
                        descript=rs.getString("descript");
                        sex=rs.getString("sex");
                        major=rs.getString("major");
                        grade=rs.getString("grade");
                    }
                  tip="qwr";
                  rs.close();
                  
                  msg="查询成功";
                  }
                catch (Exception e){
                  msg = "查询失败";
                }
            }
              %>
              <div id="content_article">
               <form method="post"  action="index.jsp?indexid=0" >
               <br>
                <p>
                   <lable for="user_email"> 昵 称：</label>
                      <input type="text" name="name" id="user_email" value="<%=name%>"></p><br>
                <p>
                  <lable for="introduce" > 心 情：</label>
                  <textarea style="vertical-align: top;height: 100px;" name="descript"  cols=60 rows=5   id="introduce" ><%=descript%>
                  </textarea></p>   <br>
                
                <p> 
                  性 别:<input type="radio" name="sex" value="man" <%=sex.equals("man")?"checked":""%> >男
                    <input type="radio" name="sex" value="woman" <%=sex.equals("woman")?"checked":""%> >女
                  </p><br>
                <p>
                   年 级：   <select name="grade">
                    <option value="grade_1" <%=grade.equals("grade_1")?"selected":"" %>>大学一年级</option>
                    <option value="grade_2" <%=grade.equals("grade_2")?"selected":"" %>>大学二年级</option>
                    <option value="grade_3" <%=grade.equals("grade_3")?"selected":"" %>>大学三年级</option>
                    <option value="grade_4" <%=grade.equals("grade_4")?"selected":"" %>>大学四年级</option>
                    </select></p>  <br>
                <p>
                   <lable for="major"> 专 业：</label>
                      <input type="text" name="major" id="major" value="<%=major%>"></p> <br>
                <p>
                <p>
                <div class="button">
                  <button type="submit" class="login-btn register-btn" id="button">提交</button>
                </div>
             </form>
             <p style="color: blue"><%=msg%></p>
              </div>
            <%
            }
            else if (indexid.equals("1")){ 
              if(!request.getMethod().equalsIgnoreCase("get")){
                 boolean isMultipart = ServletFileUpload.isMultipartContent(request);
                  String path="";
                  String fname="";
                  String msg="";
                  if (isMultipart) {
                    FileItemFactory factory = new DiskFileItemFactory(); 
                    ServletFileUpload upload = new ServletFileUpload(factory); 
                    List items = upload.parseRequest(request); 
                    for (int i = 0; i < items.size(); i++) 
                    { FileItem fi = (FileItem) items.get(i); 
                    if (fi.isFormField()) 
                    {
                      continue;
                    } 
                    else {
                    DiskFileItem dfi = (DiskFileItem) fi; 
                    if (!dfi.getName().trim().equals("")) {
                    fname=dfi.getName();        
                    String fileName=application.getRealPath(".")+ System.getProperty("file.separator") + fname; 
                     path=fname;
                     dfi.write(new File(fileName));
                    }
                    }
                    }
                    }
              String connectString = "jdbc:mysql://localhost:53306/boke15336189" + "?autoReconnect=true&useUnicode=true&characterEncoding=UTF-8";
              Class.forName("com.mysql.jdbc.Driver").newInstance();
              Connection con = DriverManager.getConnection(connectString,"user", "123");
              Statement stmt = con.createStatement();
                
                    if(path==null)
                    {path=image_url;}
                    String fmt="update user set image_url='%s'where user_email='%s'";
                    String sql = String.format(fmt,path,user_email);
                    int cnt = stmt.executeUpdate(sql);
                    if(cnt>0)
                    {
                      msg = "修改成功!请刷新";
                    }
                    else
                    {
                      msg="上传失败";
                    }
                    %>
                    <p><%=msg%></p>
                    <%
                }
                else{
                      %>
                      <form action="index.jsp?indexid=1" method="post" enctype="multipart/form-data">
                      <br>
                        <p>
                        <label for="head_image"> 头 像:   </label>
                        <input type="file" name="head_image" id="op_head">
                      </p>  <br>
                 
                      <p><input type=submit name="submit" value="提交"></p> 
                      </form>
                      <%
                    }

          }
            else if(indexid.equals("2")){
                  //評論处理
                  if(request.getMethod().equalsIgnoreCase("post") && request.getParameter("course_id") != null)
                  {
                    String id = "";
                    String comment = "";
                    id = request.getParameter("course_id");
                    comment = request.getParameter("course_comment");
                    //out.print(id + "  " + comment);
                    String exe = String.format("select evaluation from course2 where course_id=%s;", id);
                    ResultSet rs = executeQuery(conn, exe, log);
                    while(rs.next()){
                        comment_table.append(String.format("<article class=\"article class_3\">%s</article>", comment));
                        //String old_comment = rs.getString("evaluation");
                       // String new_comment = String.format("%s</table>", comment_table);
                        //comment = String.format("\"%s %s\"", old_comment, new_comment);
                        exe = String.format("UPDATE course2 SET evaluation=\'%s\' WHERE course_id=\'%s\';", comment_table, id);
                        int cnt = -1;
                        Statement stmt2 = conn.createStatement();
                        cnt = stmt2.executeUpdate(exe);

                    }
                  }
                if(!request.getMethod().equalsIgnoreCase("post")&& !(request.getParameter("course_id") != null)){%>
                  <p id="tips">Tips: 可搜索教师或课程关键词</p>
                  <%
                  StringBuilder all_table = new StringBuilder();
                  ResultSet rs = executeQuery(conn, "select * from course2 limit 10;", log);
                  all_table.append("<table>");
                  while(rs.next()){
                    all_table.append(String.format("<article class=\"article class_3\"><h1><a href=\"index.jsp?indexid=2&course_id=%s\">%s</a></h1><p id=\"course_info\">教师: %s, &nbsp;&nbsp;&nbsp;地点:%s, &nbsp;&nbsp;&nbsp;人数: %s</p></article>", rs.getString("course_id"), rs.getString("course_name"), rs.getString("teacher"), rs.getString("course_site"), rs.getString("course_stu_number")));
                }
              all_table.append("</table>");
                  %>
                  <%=all_table%>
                <%}
                else if (request.getMethod().equalsIgnoreCase("post")&& !(request.getParameter("course_id") != null)){

                  String s ="";
                  s = request.getParameter("qfront");
                  StringBuilder table = new StringBuilder();
                  if (request.getMethod().equalsIgnoreCase("post")&& !(request.getParameter("course_id") != null)){
                    String exe = String.format("SELECT * FROM course2 WHERE course_name LIKE \"%%%s%%\" OR teacher LIKE \"%%%s%%\" OR course_id LIKE \"%s\" ORDER BY course_id", s, s, s);
                    ResultSet rs = executeQuery(conn, exe, log);
                    table.append("<table>");
                    while(rs.next()){
                      table.append(String.format("<article class=\"article class_3\"><h1><a href=\"index.jsp?indexid=2&course_id=%s\">%s</a></h1><p id=\"course_info\">教师: %s, &nbsp;&nbsp;&nbsp;地点:%s, &nbsp;&nbsp;&nbsp;人数: %s</p></article>", rs.getString("course_id"), rs.getString("course_name"), rs.getString("teacher"), rs.getString("course_site"), rs.getString("course_stu_number")));
                    }
                    table.append("</table>");
                    rs.close();
                  }
                %>
                  <%=table%>
                <%}%>

                <%if (request.getParameter("course_id") != null) {%>
                    <%String link = "";
                      String comment = "";
                      String course = "";
                      String teacher = "";
                      String stu_number = "";
                      String course_site = "";
                      String id = request.getParameter("course_id");
                      String exe = String.format("select course_name, evaluation, teacher, course_site, course_stu_number from course2 where course_id = \"%s\"; ", id);
                      ResultSet rs = executeQuery(conn, exe, log);

                      while(rs.next()){
                        comment = rs.getString("evaluation");
                        course = rs.getString("course_name");
                        teacher = rs.getString("teacher");
                        stu_number = rs.getString("course_stu_number");
                        course_site = rs.getString("course_site");
                      }
                      String comment_target = String.format("<article class=\"article class_3\"><h1><a href=\"\">%s</a></h1><p id=\"course_info\">教师: %s, &nbsp;&nbsp;&nbsp;地点:%s, &nbsp;&nbsp;&nbsp;人数: %s</p></article>",course, teacher,course_site, stu_number);

                      rs.close();
                      link = String.format("\"index.jsp?indexid=2&comment=1&course_id=%s\"",id);
                    %>

                    <article class="article class_3">
                      <%=comment_target%>
                      <p><%if(comment != null){String new_comment = comment.replaceAll("null", "");%> <article class="article class_3"><%=new_comment%></article> <%}%></p>
                    </article>
                  <!--a id="add_comment" href=<%=link%>>添加评论</a-->
                    <div id="post_replie">
                    <form class="" action="index.jsp?indexid=2&course_id=<%=id%>" method="post">
                      <textarea class="input_text replie_input" name="course_comment" placeholder="评论内容"></textarea>
                      <input type="hidden" name="course_comment_id" value="">
                      <input type="submit" class="input_btn replie_btn" name="submit" value="评论">
                    </form>
                    </div>

                  <%} %>
                  <%

                  //Response.Write("<script language=javascript>window.location.href=window.location.href;</script>")
                  %>

              <%
            }
            else if(indexid.equals("4")){
            String url="http://localhost:8080/15336189_v5/servlet/Login?username="+username;
            response.sendRedirect(url);

          }
            else if(indexid.equals("3")){
              String postid = request.getParameter("postid");
              //论坛主页
              if(postid == null){
                // 发帖处理
                if(request.getMethod().equalsIgnoreCase("post") && !request.getParameter("add_posttitle").trim().equals("")
                   && !request.getParameter("add_postarticle").trim().equals("")){
                  post pub_post = new post();
                  pub_post.posterId = userid;
                  pub_post.posterName = username;
                  pub_post.postTitle = request.getParameter("add_posttitle");
                  pub_post.postArticle = request.getParameter("add_postarticle");
                  int pub_postid = publish_post(conn, log, pub_post);

                  //将网页跳转至刚发布的帖子
                  %>
                  <script language="javascript" type="text/javascript">
                    window.location.href='./index.jsp?indexid=3&postid=<%=pub_postid%>';
                  </script>
                  <%
                }

                LinkedList<post> postabs = getPostAbs(conn, log);
                Iterator<post> it_postabs = postabs.iterator();
                while(it_postabs.hasNext()){
                  post tempabs = it_postabs.next();%>
                  <article class="article">
                    <h1><a href="index.jsp?indexid=3&postid=<%=tempabs.postId%>"><%=tempabs.postTitle%></a></h1>
                    <p><%=tempabs.postArticle%></p>
                    <p style="white-space: nowrap">
                       <%-- <i style="vertical-align: 1px;" class="fa fa-commenting-o fa-1x"></i> <%=tempabs.replieNum%> --%>
                       <%=tempabs.posterName%>
                       <%=gettimedif(tempabs.updateTime)%></p>
                  </article>
                  <%
                }
              }
              //帖子详情
              else{
                //帖子回复处理
                if(request.getMethod().equalsIgnoreCase("post") && !request.getParameter("replie_content").trim().equals("")){
                  postcomment comment = new postcomment();
                  comment.postId = Integer.parseInt(postid);
                  String tempid = request.getParameter("repliedid");
                  comment.repliedId = tempid.equals("")?0:Integer.parseInt(tempid);
                  comment.replierId = 23;
                  comment.replierName = "Test";
                  comment.subComment = request.getParameter("replie_content");
                  add_post_replie(conn, log, comment);
                }

                post this_post = getPost(conn, log, postid);
                if(this_post == null){
                %><h1><%="访问的帖子不存在！"%></h1><%
                }
                else{

                %><article class="post_article">
                    <h1><%=this_post.postTitle%></h1>
                    <p><i style="vertical-align: 1px;" class="fa fa-calendar fa-1x"></i>&nbsp;<%=ymd_sdf.format(this_post.createTime)%> <span><%=this_post.posterName%></span> </p>
                    <p class=""><%=this_post.postArticle%></p>
                  </article>

                  <div id="post_comment">
                    <h2>评论</h2>
                  <%Iterator<postcomment> it_comment = this_post.replies.iterator();
                    while(it_comment.hasNext()){
                      postcomment comm = it_comment.next();
                    %><div class="comment">
                        <img src="./src/image.jpeg" />
                        <p id="commername"><%=comm.replierName%><span><%=gettimedif(comm.replieTime)%></span> </p>
                        <p id="subcomm"><%=comm.subComment%></p>
                      </div><%
                    }
                  %>
                  </div>

                  <%-- 帖子回复区 --%>
                  <div id="post_replie">
                    <form class="" action="index.jsp?indexid=3&postid=<%=postid%>" method="post">
                      <textarea class="input_text replie_input" name="replie_content" placeholder="回复内容"></textarea>
                      <input type="hidden" name="repliedid" value="">
                      <input type="submit" class="input_btn replie_btn" name="submit" value="回复">
                    </form>
                  </div>
                <%
                }
              }

            }
            
            close_db(conn, log);
          %>
          <%-- <p style="white-space: pre;"><%=log.toString()%></p> --%>
        </div>
      </div>
      <div id="content_foot">
        <%
          if(indexid.equals("3")){
            String postid = request.getParameter("postid");
            if(postid == null){
              // 发帖区
              %>
              <div id="post_edit">
                <form class="" action="index.jsp?indexid=3" method="post">
                  <input type="text" class="input_text add_post_title" name="add_posttitle" placeholder="帖子标题">
                  <textarea class="input_text add_post_article" name="add_postarticle" placeholder="帖子内容"></textarea>
                  <input type="submit" class="input_btn add_post_btn" name="submit" value="发表">
                </form>
              </div>
              <%
            }
          }

        %>
      </div>
    </div>
  </div>


  <!--背景用的JS画图脚本-->
  <script type="text/javascript" color="252,3,184" zindex="-1" opacity="20" count="99" src="./src/canvas-nest.min.js"></script>
</body>

</html>
