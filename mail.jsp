<%@ page contentType="text/html; charset=gb2312" language="java" errorPage="" %>
<%@ page import="java.sql.*,java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*,javax.mail.*"%>
<%@ page import="javax.mail.internet.*"%>
<%request.setCharacterEncoding("utf-8");
String sr="";
   Random random=new Random();
   for(int i=0;i<6;i++){
       String rand=String.valueOf(random.nextInt(10));
       sr+=rand;
   }
String fmt = "";
String qm ="yongyuceshi"; //您的QQ密码
String tu = "sina.com"; //你邮箱的后缀域名
String tto=	request.getParameter("email"); //接收邮件的邮箱

  try{
		String connectString = "jdbc:mysql://localhost:3306/web" + "?autoReconnect=true&useUnicode=true&characterEncoding=UTF-8";
  		Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
  		Connection con = DriverManager.getConnection(connectString, "root", "666666");

	Statement stmt = con.createStatement();

    fmt="REPLACE INTO code_table (email,code) VALUES ('%s','%s');";
    String sql = String.format(fmt,tto,sr);
    int cnt = stmt.executeUpdate(sql);
	stmt.close();
	con.close();
	}
catch (Exception e){
	}


    String ttitle="邮箱验证码";
    String tcontent="你的邮箱验证码为"+sr+"，如非本人操作，请忽略此邮件";
    Properties props=new Properties();
    props.put("mail.smtp.host","smtp."+tu);//发信的主机，这里我填写的是我们公司的主机！可以不用修改！
    props.put("mail.smtp.localhost","smtp.qq.com");
    props.put("mail.smtp.auth","true");
    Session s=Session.getInstance(props);
    s.setDebug(true);
    MimeMessage message=new MimeMessage(s);
    //给消息对象设置发件人/收件人/主题/发信时间
    InternetAddress from=new InternetAddress("orgwebpro@"+tu); //这里的115798090 改为您发信的QQ号
    message.setFrom(from);
    InternetAddress to=new InternetAddress(tto);
    message.setRecipient(Message.RecipientType.TO,to);
    message.setSubject(ttitle);
    message.setSentDate(new Date());
    //给消息对象设置内容
    BodyPart mdp=new MimeBodyPart();//新建一个存放信件内容的BodyPart对象
    mdp.setContent(tcontent,"text/html;charset=gb2312");//给BodyPart对象设置内容和格式/编码方式
    Multipart mm=new MimeMultipart();//新建一个MimeMultipart对象用来存放BodyPart对
    //象(事实上可以存放多个)
    mm.addBodyPart(mdp);//将BodyPart加入到MimeMultipart对象中(可以加入多个BodyPart)
    message.setContent(mm);//把mm作为消息对象的内容
    message.saveChanges();
    try{
      Transport transport=s.getTransport("smtp");
      transport.connect("smtp."+tu,"orgwebpro",qm); //这里的115798090也要修改为您的QQ号码
      transport.sendMessage(message,message.getAllRecipients());
      transport.close();
    }
    catch(Exception e){
       out.write(e.getMessage());
    }

%>
<html>
<head>
<title>邮件发送中</title>
</head>
<body onload="custom_close()">
<center>
<h1 align="center">正在发送邮件，请不要关闭此页面，发送成功后会自动关闭</h1>
</center>
<p align="center">
<script language="javascript">
// 这个脚本是 ie6和ie7 通用的脚本
function custom_close(){
window.opener=null;
window.open('','_self');
window.close();
}

</script>
</p>
</body>
</html>
