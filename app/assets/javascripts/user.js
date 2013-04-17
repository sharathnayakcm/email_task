var email_regex = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
var validStringRegEx = /^[a-zA-Z() ]+$/;
var domain_regex = /^[a-zA-Z\.]/;
var validStringRegExp =  /^[a-zA-Z0-9() ]+$/;

function login_validation(){
  var email = $.trim($('#user_email').val());
  var password = $.trim($('#user_password').val());
  var flag = true;

  if(email == ''){
    $('#msg').html("<span class='err_msg'>Email can't be blank.</span>");
    flag = false;
    notify();
  } else if(email.indexOf("@") > 0 && !email_regex.test(email)){
    $('#msg').html("<span class='err_msg'>Please enter valid email id.</span>");
    flag = false;
    notify();
  } else if(password == ''){
    $('#msg').html("<span class='err_msg'>Password can't be blank.</span>");
    flag = false;
    notify();
  }
  return flag;
}

function resend_confirmation_validation(){
  var email = $.trim($('#user_email').val());
  var flag = true;

  if(email == ''){
    $('#msg').html("<span class='err_msg'>Email can't be blank.</span>");
    flag = false;
    notify();
  } else if(!email_regex.test(email)){
    $('#msg').html("<span class='err_msg'>Please enter valid email id.</span>");
    flag = false;
    notify();
  }
  return flag;
}

function forget_password_validation(){
  var email = $.trim($('#user_email').val());
  var flag = true;

  if(email == ''){
    $('#msg').html("<span class='err_msg'>Email can't be blank.</span>");
    flag = false;
    notify();
  }
  else if(!email_regex.test(email)){
    $('#msg').html("<span class='err_msg'>Please enter valid email id.</span>")
    flag = false;
    notify();
  }
 
  return flag;
}

function confirm_password_validation(){
  var password = $.trim($('#reset_user_password').val());
  var confirm_password = $.trim($('#user_confirmation_password').val());
  var flag = true;
  if(password == ''){
    $('#msg').html("<span class='err_msg'>Password can't be blank.</span>");
    flag = false;
    notify();
  } else if(password != confirm_password){
    $('#msg').html("<span class='err_msg'>Confirm password did not match.</span>");
    flag = false;
    notify();
  }
  
  return flag;
}

function profile_validation(form_id){
  var display_name = $.trim($('#user_display_name').val());
  var first_name = $.trim($('#user_first_name').val());
  var last_name = $.trim($('#user_last_name').val());
  var dozz_email = $.trim($('#user_dozz_email').val());
  var dormant_days = $.trim($('#user_dormant_days').val());
  var numeric = /^[1-9]\d*$/;
  //var current_password = $.trim($('#user_current_password').val());
  var flag = true;
  $('#user_display_name, #user_first_name, #user_last_name, #dozz_email').css('border','none');
  if(display_name == ''){
    $('#user_display_name').css('border','2px solid red')
    $('#msg').html("<span class='err_msg'>Display name can't be blank.</span>");
    flag = false;
    notify();
  } else if(!validStringRegEx.test(display_name)){
    $('#msg').html("<span class='err_msg'>Please enter valid display name.</span>");
    flag = false;
    notify();
  } else if(first_name == ''){
    $('#user_first_name').css('border','2px solid red')
    $('#msg').html("<span class='err_msg'>First name can't be blank.</span>");
    flag = false;
    notify();
  } else if(!validStringRegEx.test(first_name)){
    $('#msg').html("<span class='err_msg'>Please enter valid first name.</span>");
    flag = false;
    notify();
  } else if(last_name == ''){
    $('#user_last_name').css('border','2px solid red')
    $('#msg').html("<span class='err_msg'>Last name can't be blank.</span>");
    flag = false;
    notify();
  } else if(!validStringRegEx.test(last_name)){
    $('#msg').html("<span class='err_msg'>Please enter valid last name.</span>");
    flag = false;
    notify();
  } else if(dozz_email == ''){
    $('#user_dozz_email').css('border','2px solid red')
    $('#msg').html("<span class='err_msg'>Dozz email can't be blank.</span>");
    flag = false;
    notify();
  } else if(dormant_days == '' ){
    $('#user_dormant_days').css('border','2px solid red')
    $('#msg').html("<span class='err_msg'>Dormant days can't be blank .</span>");
    flag = false;
    notify();
  } else if(!numeric.test(dormant_days)){
    $('#user_dormant_days').css('border','2px solid red')
    $('#msg').html("<span class='err_msg'>Dormant days should be greater than zero.</span>");
    flag = false;
    notify();
  }
  /*else if(current_password == ''){
    $('#msg').val("Current password can't be blank");
    flag = false;
    notify();
  }*/
  
  if(flag){
    return true;
  }
  else{
    return false;
  }
}

function user_profile_validation(){
  var display_name = $.trim($('#user_display_name').val());
  var first_name = $.trim($('#user_first_name').val());
  var last_name = $.trim($('#user_last_name').val());
  var email = $.trim($('#user_email').val());
  var flag = true;

  if(display_name == ''){
    $('#msg').html("<span class='err_msg'>Display name can't be blank.</span>");
    flag = false;
    notify();
  } else if(!validStringRegEx.test(display_name)){
    $('#msg').html("<span class='err_msg'>Please enter valid display name.</span>");
    flag = false;
    notify();
  } else if(first_name == ''){
    $('#msg').html("<span class='err_msg'>First name can't be blank.</span>");
    flag = false;
    notify();
  } else if(!validStringRegEx.test(first_name)){
    $('#msg').html("<span class='err_msg'>Please enter valid first name.</span>");
    flag = false;
    notify();
  } else if(last_name == ''){
    $('#msg').html("<span class='err_msg'>Last name can't be blank.</span>");
    flag = false;
    notify();
  } else if(!validStringRegEx.test(last_name)){
    $('#msg').html("<span class='err_msg'>Please enter valid last name.</span>");
    flag = false;
    notify();
  } else if(email == ''){
    $('#msg').html("<span class='err_msg'>Email can't be blank.</span>");
    flag = false;
    notify();
  } else if(email.indexOf("@") > 0 && !email_regex.test(email)){
    $('#msg').html("<span class='err_msg'>Please enter valid email id.</span>");
    flag = false;
    notify();
  }
  return flag;
}

function user_new_profile_validation(){
  var display_name = $.trim($('#user_display_name').val());
  var first_name = $.trim($('#user_first_name').val());
  var last_name = $.trim($('#user_last_name').val());
  var email = $.trim($('#user_email').val());
  var password = $.trim($('#user_password').val());
  var confirm_password = $.trim($('#user_password_confirmation').val());
  var flag = true;

  if(display_name == ''){
    $('#msg').html("<span class='err_msg'>Display name can't be blank.</span>");
    flag = false;
    notify();
  } else if(!validStringRegEx.test(display_name)){
    $('#msg').html("<span class='err_msg'>Please enter valid display name.</span>");
    flag = false;
    notify();
  } else if(first_name == ''){
    $('#msg').html("<span class='err_msg'>First name can't be blank.</span>");
    flag = false;
    notify();
  } else if(!validStringRegEx.test(first_name)){
    $('#msg').html("<span class='err_msg'>Please enter valid first name.</span>");
    flag = false;
    notify();
  } else if(last_name == ''){
    $('#msg').html("<span class='err_msg'>Last name can't be blank.</span>");
    flag = false;
    notify();
  } else if(!validStringRegEx.test(last_name)){
    $('#msg').html("<span class='err_msg'>Please enter valid last name.</span>");
    flag = false;
    notify();
  } else if(email == ''){
    $('#msg').html("<span class='err_msg'>Email can't be blank.</span>");
    flag = false;
    notify();
  } else if(email.indexOf("@") > 0 && !email_regex.test(email)){
    $('#msg').html("<span class='err_msg'>Please enter valid email id.</span>");
    flag = false;
    notify();
  } else if(password == ''){
    $('#msg').html("<span class='err_msg'>Password can't be blank.</span>");
    flag = false;
    notify();
  } else if(password != confirm_password){
    $('#msg').html("<span class='err_msg'>Confirm password did not match.</span>");
    flag = false;
    notify();
  }
  return flag;
}

function domain_validation(form_id){
  var domain_name = $.trim($('#setting_domain_name').val());
  var flag = true;
  if(domain_name == ''){
    $('#msg').html("<span class='err_msg'>Domain name can't be blank.</span>");
    flag = false;
    notify();
  } else if(!domain_regex.test(domain_name)){
    $('#msg').html("<span class='err_msg'>Please enter valid domain name.</span>");
    flag = false;
    notify();
  }

  if(flag){
    $("#"+form_id).submit();
  }
}