<%@ page language="java" import="java.util.*,java.sql.*" 
         contentType="text/html; charset=utf-8"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>

<!DOCTYPE html>

<html class="uk-touch">
 <head>
  <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.0.9/css/all.css" integrity="sha384-5SOiIsAziJl6AWe0HWRKTXlfcSHKmYV4RBF18PPJ173Kzn7jzMyFuTtk8JA7QQG1" crossorigin="anonymous">
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 
  <title>Chat</title>
  <style type="text/css">
  	#beginchat{
  		width: 800px;
  		height: 700px;
      margin: 50px auto;
      border: 1px grey solid;
  	}
    #user{
      width: 10em;
      height: 100%;
      float: left;
      border-right: 1px grey solid;
      
    }
    #mess{
      width: 39em;
      height: 100%;
      float: right;
      border-left: 1px grey solid;
    }
    #get{
      height: 575px;
      overflow:auto;
      border-bottom: 1px grey solid;
    }
    #co{
      display:block;
      right: 50%;
      color: grey;
      float: right;
    }
    #po{
      margin-top:1.5px;
      margin-left:1px;
      width: 79%;
      height: 115px;
      font-size: 2em
    }
    #world{
    	position: relative;
    	height: 4em;
    	border-bottom: 1px grey solid;
    }
    #w{
    	position: absolute;
    	font-size:2em;
    	top:0.5em;
    	left:13%;
    }
    #time{
    	 text-align:center;
    }
    #me{
    	text-align: right;
    }
    #ot{
    	text-align: left;
    }
    #na{
    	font-size: 2em;
    	border: 1px grey solid;
    }
  </style> 

 </head> 
 <body class="uk-height-1-1" style=""> 
  
  <script type="text/javascript" color="252,3,184" zindex="-1" opacity="20" count="99">
  !function(){function o(w,v,i){return w.getAttribute(v)||i}function j(i){return document.getElementsByTagName(i)}function l(){var i=j("script"),w=i.length,v=i[w-1];return{l:w,z:o(v,"zIndex",-1),o:o(v,"opacity",0.5),c:o(v,"color","0,0,0"),n:o(v,"count",99)}}function k(){r=u.width=window.innerWidth||document.documentElement.clientWidth||document.body.clientWidth,n=u.height=window.innerHeight||document.documentElement.clientHeight||document.body.clientHeight}function b(){e.clearRect(0,0,r,n);var w=[f].concat(t);var x,v,A,B,z,y;t.forEach(function(i){i.x+=i.xa,i.y+=i.ya,i.xa*=i.x>r||i.x<0?-1:1,i.ya*=i.y>n||i.y<0?-1:1,e.fillRect(i.x-0.5,i.y-0.5,1,1);for(v=0;v<w.length;v++){x=w[v];if(i!==x&&null!==x.x&&null!==x.y){B=i.x-x.x,z=i.y-x.y,y=B*B+z*z;y<x.max&&(x===f&&y>=x.max/2&&(i.x-=0.03*B,i.y-=0.03*z),A=(x.max-y)/x.max,e.beginPath(),e.lineWidth=A/2,e.strokeStyle="rgba("+s.c+","+(A+0.2)+")",e.moveTo(i.x,i.y),e.lineTo(x.x,x.y),e.stroke())}}w.splice(w.indexOf(i),1)}),m(b)}var u=document.createElement("canvas"),s=l(),c="c_n"+s.l,e=u.getContext("2d"),r,n,m=window.requestAnimationFrame||window.webkitRequestAnimationFrame||window.mozRequestAnimationFrame||window.oRequestAnimationFrame||window.msRequestAnimationFrame||function(i){window.setTimeout(i,1000/45)},a=Math.random,f={x:null,y:null,max:20000};u.id=c;u.style.cssText="position:fixed;top:0;left:0;z-index:"+s.z+";opacity:"+s.o;j("body")[0].appendChild(u);k(),window.onresize=k;window.onmousemove=function(i){i=i||window.event,f.x=i.clientX,f.y=i.clientY},window.onmouseout=function(){f.x=null,f.y=null};for(var t=[],p=0;s.n>p;p++){var h=a()*r,g=a()*n,q=2*a()-1,d=2*a()-1;t.push({x:h,y:g,xa:q,ya:d,max:6000})}setTimeout(function(){b()},100)}();
  </script>

  
  <div id="beginchat">
    <div id="user">
    	<div id="world"><div id="w">WORLD</div></div>
    	<div id="user1"></div>
    </div>
    <div id="mess">
      <div id="get"></div>
      <form action="" target="nm_iframe" method="post" id="myform">
        <textarea id="po" name="post"></textarea>
        <div id="co"><i class="fa fa-arrow-left fa-5x pull-right fa-border"></i></div>
      </form>
      <iframe id="id_iframe" name="nm_iframe" style="display:none;"></iframe>
    </div>
  </div>

  <script type="text/javascript">
     var ws=null; 
     var target = "ws://"+window.location.host+"/15336189_v6/echo?username=${requestScope.username}"; // 打开管道  ,ws://localhost:8080/项目名/@ServerEndpoint名字
     window.onload=function(){
       if(ws==null){
          if ('WebSocket' in window) {
                ws = new WebSocket(target);
            } else if ('MozWebSocket' in window) {
                ws = new MozWebSocket(target);
            } else {
                alert('WebSocket is not supported by this browser.');
                return;
         }
           ws.onmessage = function (event) { //创建websocket同时,接收服务器发给客服端的消息
        	   if(event!=null){
         		//将json字符串转为对象
         		 eval("var msg="+event.data+";"); 
         		 //得到对象里面的值
         		 var welcome = msg.welcome;
         		 var content = msg.content;
         		 var usernames = msg.usernames;
         		 //为聊天区teaxarea赋值
         		 var textArea = document.getElementById("get");
         		 if(undefined!=welcome){
         		   //textArea.innerHTML += "<div name='r'>" + welcome +"</div>";
         		 }
         		  if(undefined!=content){
         			  var temp = content.split("|");
         			  if("${requestScope.username}" == temp[1]){
         				 textArea.innerHTML += "<div id='time'>"+temp[0]+"</div>";
         				 var cont = temp[2];
         				 if(temp[2].indexOf(":") > 0)cont = temp[2].split(":")[1];
         				 textArea.innerHTML += "<div id='me'><a id='con'>"+cont+"        "+"</a><a id='na'>"+ temp[1]+"</a></div>";
            		  	}
         			  else{
         				 textArea.innerHTML += "<div id='time'>"+temp[0]+"</div>";
         				 textArea.innerHTML += "<div id='ot'><a id='na'>"+temp[1]+"</a><a id='con'>"+"        "+ temp[2]+"</a></div>";
         			  }
         		   
         		 }
         		
         		 var userListTD = document.getElementById("user1");
         		 userListTD.innerHTML="";
         		 for(var i = 0 ; i < usernames.length; i++){
         		  	if(undefined!=usernames[i]){
         		  	if("${requestScope.username}" == usernames[i]){
         		  	  //userListTD.innerHTML += "\r\n  <input name='msgCheckBox' disabled='true' type='checkbox' value='"+usernames[i]+"'> <span style='color: red'>" +  usernames[i]+"</span></br>";
         		  	}else{
         		  	  userListTD.innerHTML += "\r\n  <input name='msgCheckBox' type='checkbox' value='"+usernames[i]+"'>" +  usernames[i]+"</br>";
         		  	}
         		  	 
         		  	}
         			
         		 }
         		 
         		 
         		}
         	  };
       
       
       }



     };
    
     
     sendMessage = function(){ //发送信息
      if(ws!=null){
       var checkNumber = 0 ; // 被选中复选框的个数
       var checkedUsernameArray = new Array();  // 被选中的复选框名字
       var checkBoxs =  document.getElementsByName("msgCheckBox");
       for(var i = 0 ; i < checkBoxs.length ; i++ ){ 
      	  var checkbox = checkBoxs[i];
         if(checkbox.checked == true){
         	checkNumber ++;
         	checkedUsernameArray.push(checkbox.value) ;
         }
      }

    var flag = "";
      var type; // 单聊 type = 1 ,type =2 群聊
      if(checkNumber > 0 ) { // 单聊 type = 1 
        type = 1;
      	flag = "Private chat to you : ";
      }else{ //群聊
        type = 2; 
      }
       var sendMessageInput = document.getElementById("po");
       var msg = sendMessageInput.value; 
     

       var msgObj={
         type:type,
         from:'${requestScope.username}',
         to:checkedUsernameArray,
         content:flag+msg
       };
     //将msgOjb对象转为json
         var json = JSON.stringify(msgObj);
         ws.send(json);
       	 sendMessageInput.value ="";
       	
       }
       else{
         alert("websocket is null , please create a websocket");
       }
     }
     
     var sub = document.getElementById("co");
     sub.onclick = sendMessage;
    

 
   </script>
 </body>
</html>