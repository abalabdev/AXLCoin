//$("#buttonjoin").click(function(){
	function memjoin(){
     	var user_id = document.getElementById("user_id");
	 	var user_phone = document.getElementById("user_phone");
	 	var user_pw = document.getElementById("user_pw");
	 	var user_name = document.getElementById("user_name");
	 	var user_reco = document.getElementById("user_reco");

	 	var isup = 1;
	   if (user_id.value.trim() == "" || user_id.value.trim().length<4 || user_id.value == "이메일(4-50자)") {
	   	var isup = 0;
	   	alert("이메일 길이는 4-50자 입니다.");
	   	user_id.focus();
	   	return;
	   }

	   if (user_id.value.length != null && user_id.value.length > 0 && user_id.value.search(/(\S+)@(\S+)\.(\S+)/) == -1){
	   	alert("이메일 형식을 확인해주세요.");
	   	user_id.focus();
	   	return;
	   }

	   if (user_name.value.trim() == "" || user_name.value.trim().length<2 || user_name.value == "이름") {
	   	var isup = 0;
	   	alert("이름 길이는 2-5자 입니다.");
	   	user_name.focus();
	   	return;
	   }

	   if (user_phone.value.trim() == "" || user_phone.value.trim().length<10) {
	   	var isup = 0;
	   	alert("연락처를 확인해주세요.");
	   	user_phone.focus();
	   	return;
	   }
	   if (user_pw.value.trim() == "" || user_pw.value.trim().length<8 || user_pw.value == "비밀번호(8-20자)") {
	   	var isup = 0;
	   	alert("비밀번호 길이는 8-20자 입니다.");
	   	user_pw.focus();
	   	return;
	   }

	   if (user_reco.value.trim() == "프로모션코드(없으면공란)") {
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
				window.location.href = "main.html";
			}
			else if(data.result=="sameid")
			{
				alert("중복된 이메일이 존재합니다");
				user_id.focus();
			}
			else if(data.result=="recoerror")
			{
				alert("잘못된 코드입니다");
				user_reco.focus();
			}
			else if(data.result=="toolong")
			{
				alert("이메일,비밀번호의 길이를 확인해주세요");
			}else{
				alert("등록에 실패 했습니다.");
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
	   if (user_pw.value.trim() == "" || user_pw.value.trim().length<8 || user_pw.value == "비밀번호(8-20자)") {
	   	var isup = 0;
	   	alert("비밀번호 길이는 8-20자 입니다.");
	   	user_pw.focus();
	   	return;
	   }
	   if (user_pw_new1.value.trim() == "" || user_pw_new1.value.trim().length<8 || user_pw_new1.value == "새비밀번호(8-20자)") {
	   	var isup = 0;
	   	alert("비밀번호 길이는 8-20자 입니다.");
	   	user_pw_new1.focus();
	   	return;
	   }
	   if (user_pw_new1.value.trim() != user_pw_new2.value.trim()) {
	   	var isup = 0;
	   	alert("비밀번호 확인이 일치하지 않습니다.");
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
				alert("비밀번호가 변경되었습니다");
				window.location.href = "pg_info.html";
			}
			else if(data.result=="wrongpw")
			{
				alert("현재 비밀번호가 맞지 않습니다");
				user_pw.focus();
			}
			else if(data.result=="toolong")
			{
				alert("비밀번호의 길이를 확인해주세요");
			}else{
				alert("등록에 실패 했습니다.");
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
	   if (user_id.value.trim() == "" || user_id.value.trim().length<4 || user_id.value == "이메일(4-50자)") {
	   	var isup = 0;
	   	alert("이메일 길이는 4-50자 입니다.");
	   	user_id.focus();
		 	buttonjoin.innerHTML = '비밀번호 재설정';
		 	buttonjoin.href = 'javascript:memfind();';
	   	return;
	   }

	   if (user_id.value.length != null && user_id.value.length > 0 && user_id.value.search(/(\S+)@(\S+)\.(\S+)/) == -1){
	   	alert("이메일 형식을 확인해주세요.");
	   	user_id.focus();
		 	buttonjoin.innerHTML = '비밀번호 재설정';
		 	buttonjoin.href = 'javascript:memfind();';
	   	return;
	   }

	   if (user_name.value.trim() == "" || user_name.value.trim().length<2 || user_name.value == "이름") {
	   	var isup = 0;
	   	alert("이름 길이는 2-5자 입니다.");
	   	user_name.focus();
		 	buttonjoin.innerHTML = '비밀번호 재설정';
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
				alert("이메일이 발송되었습니다");
				window.location.href = "index.html";
			}
			else if(data.result=="nomatch")
			{
				alert("정보가 없습니다");
				user_id.focus();
			}
			else if(data.result=="toolong")
			{
				alert("이메일,이름의 길이를 확인해주세요");
			}else{
				alert("발송에 실패 했습니다.");
			}

		}

		});

	 	buttonjoin.innerHTML = '비밀번호 재설정';
	 	buttonjoin.href = 'javascript:memfind();';



     }

function aaa(){
	alert("aaaa");
}
