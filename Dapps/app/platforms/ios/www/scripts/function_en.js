//$("#buttonjoin").click(function(){
	function memjoin(){
     	var user_id = document.getElementById("user_id");
	 	var user_phone = document.getElementById("user_phone");
	 	var user_pw = document.getElementById("user_pw");
	 	var user_name = document.getElementById("user_name");
	 	var user_reco = document.getElementById("user_reco");
	 	
	 	var isup = 1;
	   if (user_id.value.trim() == "" || user_id.value.trim().length<4 || user_id.value == "Email(4-50Characters)") {
	   	var isup = 0;
	   	alert("Email length is 4 to 50 characters.");
	   	user_id.focus();
	   	return;
	   }

	   if (user_id.value.length != null && user_id.value.length > 0 && user_id.value.search(/(\S+)@(\S+)\.(\S+)/) == -1){
	   	alert("Please check the email format.");
	   	user_id.focus();
	   	return;
	   }

	   if (user_name.value.trim() == "" || user_name.value.trim().length<2 || user_name.value == "Name") {
	   	var isup = 0;
	   	alert("The name length is 2 to 20 characters.");
	   	user_name.focus();
	   	return;
	   }

	   if (user_phone.value.trim() == "" || user_phone.value.trim().length<10) {
	   	var isup = 0;
	   	alert("Please check your contact number.");
	   	user_phone.focus();
	   	return;
	   }
	   if (user_pw.value.trim() == "" || user_pw.value.trim().length<8 || user_pw.value == "Password(8-20Characters)") {
	   	var isup = 0;
	   	alert("Password length is 8 to 20 characters.");
	   	user_pw.focus();
	   	return;
	   }

	   if (user_reco.value.trim() == "Promotional code (blank if none)") {
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
				window.location.href = "main_en.html";
			}
			else if(data.result=="sameid")
			{
				alert("Duplicate Email Present");
				user_id.focus();
			}
			else if(data.result=="recoerror")
			{
				alert("Wrong Code");
				user_reco.focus();
			}			
			else if(data.result=="toolong")
			{
				alert("Please check the length of your email and password");
			}else{
				alert("Registration failed.");
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
	   if (user_pw.value.trim() == "" || user_pw.value.trim().length<8 || user_pw.value == "Password(8-20Characters)") {
	   	var isup = 0;
	   	alert("Password length is 8 to 20 characters.");
	   	user_pw.focus();
	   	return;
	   }
	   if (user_pw_new1.value.trim() == "" || user_pw_new1.value.trim().length<8 || user_pw_new1.value == "New Password(8-20Chars)") {
	   	var isup = 0;
	   	alert("Password length is 8 to 20 characters.");
	   	user_pw_new1.focus();
	   	return;
	   }
	   if (user_pw_new1.value.trim() != user_pw_new2.value.trim()) {
	   	var isup = 0;
	   	alert("The new password is incorrect.");
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
				alert("Password changed");
				window.location.href = "pg_info_en.html";
			}
			else if(data.result=="wrongpw")
			{
				alert("The current password is incorrect");
				user_pw.focus();
			}
			else if(data.result=="toolong")
			{
				alert("Please check the length of your password");
			}else{
				alert("Registration failed.");
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
	   if (user_id.value.trim() == "" || user_id.value.trim().length<4 || user_id.value == "Email(4-50Characters)") {
	   	var isup = 0;
	   	alert("Email length is 4 to 50 characters.");
	   	user_id.focus();
		 	buttonjoin.innerHTML = 'Reset Password';
		 	buttonjoin.href = 'javascript:memfind();';
	   	return;
	   }

	   if (user_id.value.length != null && user_id.value.length > 0 && user_id.value.search(/(\S+)@(\S+)\.(\S+)/) == -1){
	   	alert("Please check the email format.");
	   	user_id.focus();
		 	buttonjoin.innerHTML = 'Reset Password';
		 	buttonjoin.href = 'javascript:memfind();';
	   	return;
	   }

	   if (user_name.value.trim() == "" || user_name.value.trim().length<2 || user_name.value == "Name") {
	   	var isup = 0;
	   	alert("The name length is 2 to 20 characters.");
	   	user_name.focus();
		 	buttonjoin.innerHTML = 'Reset Password';
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
				alert("email sent");
				window.location.href = "index_en.html";
			}
			else if(data.result=="nomatch")
			{
				alert("No match information");
				user_id.focus();
			}
			else if(data.result=="toolong")
			{
				alert("please check the length of the name or email");
			}else{
				alert("Sending Failed.");
			}

		}

		});

		 	buttonjoin.innerHTML = 'Reset Password';
		 	buttonjoin.href = 'javascript:memfind();';

     }


function aaa(){
	alert("aaaa");
}
