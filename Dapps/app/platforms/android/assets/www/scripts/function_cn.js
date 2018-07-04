//$("#buttonjoin").click(function(){
	function memjoin(){
     	var user_id = document.getElementById("user_id");
	 	var user_phone = document.getElementById("user_phone");
	 	var user_pw = document.getElementById("user_pw");
	 	var user_name = document.getElementById("user_name");
	 	var user_reco = document.getElementById("user_reco");

	 	var isup = 1;
	   if (user_id.value.trim() == "" || user_id.value.trim().length<4 || user_id.value == "电子邮件(4-50字)") {
	   	var isup = 0;
	   	alert("电子邮件长度为4-50字.");
	   	user_id.focus();
	   	return;
	   }

	   if (user_id.value.length != null && user_id.value.length > 0 && user_id.value.search(/(\S+)@(\S+)\.(\S+)/) == -1){
	   	alert("请确认一下电子邮件的格式.");
	   	user_id.focus();
	   	return;
	   }

	   if (user_name.value.trim() == "" || user_name.value.trim().length<2 || user_name.value == "名字") {
	   	var isup = 0;
	   	alert("名字是2-5字.");
	   	user_name.focus();
	   	return;
	   }

	   if (user_phone.value.trim() == "" || user_phone.value.trim().length<10) {
	   	var isup = 0;
	   	alert("请确认一下联系方式.");
	   	user_phone.focus();
	   	return;
	   }
	   if (user_pw.value.trim() == "" || user_pw.value.trim().length<8 || user_pw.value == "密码(8-20字)") {
	   	var isup = 0;
	   	alert("密码是8-20字.");
	   	user_pw.focus();
	   	return;
	   }

	   if (user_reco.value.trim() == "促销代码(如果没有,则为空)") {
	   	user_reco.value = "";
	   }
	   


	   var dataString="sid="+user_id.value+"&sname="+user_name.value+"&sphone="+user_phone.value+"&spw="+user_pw.value+"&reco="+user_reco.value+"&join=1";
			$.ajax({
			type: "POST",
			url: "http://app.abalab.io/php/memjoin.php",
			data: dataString,
			dataType: "json",
			crossDomain: true,
			cache: false,
		success: function(data){
			console.log(data);
			if(data.result=="success")
			{
				sessionStorage.setItem('login','true');
				sessionStorage.setItem('usernum',data.usernum);
				localStorage.setItem('userid',user_id.value);
				window.location.href = "main_cn.html";
			}
			else if(data.result=="sameid")
			{
				alert("存在重复的邮件");
				user_id.focus();
			}
			else if(data.result=="recoerror")
			{
				alert("没有信息");
				user_reco.focus();
			}
			else if(data.result=="toolong")
			{
				alert("请确认邮件、密码的长度");
			}else{
				alert("注册失败.");
			}

		}

		});


     }

	function chgpw(){
	 	var user_pw = document.getElementById("user_pw");
	 	var user_pw_new1 = document.getElementById("user_pw_new1");
	 	var user_pw_new2 = document.getElementById("user_pw_new2");
	 	var sId = localStorage.getItem('userid');

	 	var isup = 1;
	   if (user_pw.value.trim() == "" || user_pw.value.trim().length<8 || user_pw.value == "密码(8-20字)") {
	   	var isup = 0;
	   	alert("密码是8-20字.");
	   	user_pw.focus();
	   	return;
	   }
	   if (user_pw_new1.value.trim() == "" || user_pw_new1.value.trim().length<8 || user_pw_new1.value == "新密码(8-20字)") {
	   	var isup = 0;
	   	alert("密码是8-20字.");
	   	user_pw_new1.focus();
	   	return;
	   }
	   if (user_pw_new1.value.trim() != user_pw_new2.value.trim()) {
	   	var isup = 0;
	   	alert("新的密码不合适.");
	   	user_pw_new1.focus();
	   	return;
	   }

	   var dataString="sId="+sId+"&spw="+user_pw.value+"&spw_new="+user_pw_new1.value+"&join=1";
			$.ajax({
			type: "POST",
			url: "http://app.abalab.io/php/chgpw.php",
			data: dataString,
			dataType: "json",
			crossDomain: true,
			cache: false,
		success: function(data){
			console.log(data);
			if(data.result=="success")
			{
				alert("密码变更");
				window.location.href = "pg_info_cn.html";
			}
			else if(data.result=="wrongpw")
			{
				alert("现在密码不合适");
				user_pw.focus();
			}
			else if(data.result=="toolong")
			{
				alert("密码的长度");
			}else{
				alert("注册失败.");
			}

		}

		});


     }
	function memfind(){
     	var user_id = document.getElementById("user_id");
	 	var user_name = document.getElementById("user_name");
	 	var buttonjoin = document.getElementById("buttonjoin");

	 	buttonjoin.innerHTML = 'Sending';
	 	buttonjoin.href = '#';

	 	var isup = 1;
	   if (user_id.value.trim() == "" || user_id.value.trim().length<4 || user_id.value == "电子邮件(4-50字)") {
	   	var isup = 0;
	   	alert("电子邮件长度为4-50字.");
	   	user_id.focus();
		 	buttonjoin.innerHTML = '重新设置密码';
		 	buttonjoin.href = 'javascript:memfind();';
	   	return;
	   }

	   if (user_id.value.length != null && user_id.value.length > 0 && user_id.value.search(/(\S+)@(\S+)\.(\S+)/) == -1){
	   	alert("请确认一下电子邮件的格式.");
	   	user_id.focus();
		 	buttonjoin.innerHTML = '重新设置密码';
		 	buttonjoin.href = 'javascript:memfind();';
	   	return;
	   }

	   if (user_name.value.trim() == "" || user_name.value.trim().length<2 || user_name.value == "名字") {
	   	var isup = 0;
	   	alert("名字是2-5字.");
	   	user_name.focus();
		 	buttonjoin.innerHTML = '重新设置密码';
		 	buttonjoin.href = 'javascript:memfind();';
	   	return;
	   }

	   var dataString="sid="+user_id.value+"&sname="+user_name.value+"&join=0";
			$.ajax({
			type: "POST",
			url: "http://app.abalab.io/php/memfindpw.php",
			data: dataString,
			dataType: "json",
			crossDomain: true,
			cache: false,
		success: function(data){
			console.log(data);
			if(data.result=="success")
			{
				alert("已发送电子邮件");
				window.location.href = "index_cn.html";
			}
			else if(data.result=="nomatch")
			{
				alert("无信息");
				user_id.focus();
			}
			else if(data.result=="toolong")
			{
				alert("请确认邮件,姓名的长度");
			}else{
				alert("发货失败了");
			}

		}

		});
		 	buttonjoin.innerHTML = '重新设置密码';
		 	buttonjoin.href = 'javascript:memfind();';


     }


function aaa(){
	alert("aaaa");
}
