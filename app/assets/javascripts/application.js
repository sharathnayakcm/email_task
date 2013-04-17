// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require_tree .
//= require jquery.remotipart
//= require jquery.autocomplete
//= require jquery.ui.touch-punch

var validStringRegEx = /^[a-zA-Z() ]+$/;
var alphaNumericRegEx = /^[A-Z\sa-z0-9_-]+$/i;
var aliasNameRegEx = /^[A-Za-z0-9_-]+$/i;
var numeric = /d/;

// dozz related function start
function remove_fields(link) {
  var check_record = $(link).prev('input[type=hidden]').attr('id').split('_destroy')[0]
  if(check_record.search(/new/i) != -1 || $('#'+check_record+'id').val() == undefined){
    var hiddenField = $(link).prev('input[type=hidden]');
    hiddenField.val('1');
    var field = $(link).closest('.fields');
    field.hide();
    $(link).closest("form").trigger({
      type: 'nested:fieldRemoved',
      field: field
    });
  }
  else
  {
    if(confirm("Are you sure, you want to delete the Dozz?")){
      $.ajax({
        type: 'delete',
        url: "/buzz_tasks/"+$('.edit_buzz_task_form').attr('id')+"?buzz_id="+$('.edit_buzz_task_form').attr('id')+"&buzz_task_id="+$('#'+check_record+'id').val()
      });
    }
  }
}

function add_fields(link, assoc, content) {
  var regexp = new RegExp('new_' + assoc, 'g');
  var new_id = new Date().getTime();
  content = content.replace(regexp, "new_" + new_id);
  content.replace(regexp, new_id)
  $(content).insertBefore('#add_dozz_rows');
  init_datepicker();
}

function mark_as_completed(data,obj_id,channel,buzz_id)
{
  if(confirm("Are you sure, you want to mark this Dozz as complete?")){
    channel_url = ''
    if(channel){
      channel_url = "&channel_id="+obj_id+"&is_channel="+channel+"&buzz_id="+buzz_id
      $('#processing_channel').show()
    }
    else{
      channel_url = "&buzz_id="+obj_id
    }
    $.ajax({
      type: 'put',
      url: "/buzz_tasks/buzz_task_mark_as_complete?buzz_task_id="+$('#'+$(data).attr('id').split('_status')[0]+'_id').val()+channel_url
    });
  }
  else{
    $(data).attr('checked',false)
  }
}

$('#cug_topic_name_display').live("click",function(){
  $('#buzzes_list_'+$(this).attr('buzzid')).toggle("slow")
  if($(this).children().hasClass('group_icon'))
    $(this).children().removeClass('group_icon').addClass('group_icon_close')
  else
    $(this).children().removeClass('group_icon_close').addClass('group_icon')
});

$(".channels_search_button").live("click",function(){
  if($("#search_channel_name_left_nav").val()== ""){
    alert("Please enter the search keyword")
    return false;
  }
})

$(".view_buzz_links").live("click",function(){
  id = $(this).attr('buzztaskid')
  $('.channel_buzz_tasks').css({
    "background-color":"#fff"
  })
  $('#channel_buzz_task_'+id).css({
    "background-color":"#ececec"
  })
  $(".view_buzz_links").parent().show()
  $(".hide_buzz_links").parent().hide()
  $('#view_buzz_link_'+id).parent().hide()
  $('#hide_buzz_link_'+id).parent().show()
})

$(".hide_buzz_links").live("click",function(){
  $('.channel_buzz_tasks').css({
    "background-color":"#fff"
  })
  $('#view_buzz_link_'+id).parent().show()
  $('#hide_buzz_link_'+id).parent().hide()
  $('#buzzes_list').html('');
})

// ipad functions

$(".ipad_buzz_icons").live("click",function(){
  if($('#ipad_buzzer_icons_'+$(this).attr('id')).css('display') == "none"){
    $('.ipad_buzzers_icon').hide();
    $('#ipad_buzzer_icons_'+$(this).attr('id')).toggle("slow");
  }
  else
    $('#ipad_buzzer_icons_'+$(this).attr('id')).toggle("slow");
})  

$(".ipad_channel_icons_link").live("click",function(){

  if($('#ipad_channel_icons_'+$(this).attr('id')).css('display') == "none"){
    $('.ipad_channel_icons').hide();
    $(".ipad_channel_icons_link").removeClass('left').addClass('down');
    $('#ipad_channel_icons_'+$(this).attr('id')).show("slide", {
      direction: "right"
    }, 1000);
    $(this).removeClass('down').addClass('left');
  }
  else{
    $('#ipad_channel_icons_'+$(this).attr('id')).hide("slide", {
      direction: "right"
    }, 1000);
    $(this).removeClass('left').addClass('down');
  }
})


$('.buzz_tasks_show_completed_links, .buzz_tasks_hide_completed_links').live("click",function(){
  spliting = $(this).attr('id').split('_')
  if(spliting[0] == 'show'){
    $('#processing_'+spliting[4]).show()
    $('#hide_completed_tasks_link_'+spliting[4]).show()
    $('#show_completed_tasks_link_'+spliting[4]).hide()
  }
  else{
    $('#task_list_completed_'+spliting[4]).html('')
    $('#hide_completed_tasks_link_'+spliting[4]).hide()
    $('#show_completed_tasks_link_'+spliting[4]).show()
  }
});

// dozz related function end


// User data related functions start
function show_change_password_box(){
  $("#spinner").show();
  $('.change_password').each(function(){
    $(this).show();

  });
  $("#spinner").hide();
  $('#change_password_link').attr('onClick', "hide_change_password_box();");
}

function hide_change_password_box(){
  $('.change_password').each(function(){
    $(this).hide()
  });
  $('#change_password_link').attr('onClick', "show_change_password_box();");
}

// User data related functions end


// Showing error messages and notifications
function notify(){
  $('#boxd').fadeOut();
  var message = $.trim($('#msg').html());
  // Set the message using text method and chain fadeIn with it
  // apply simple setTimeout to fadeOut the message
  if(message != '' && message != '"'){
    $('#boxd').html(message).fadeIn();
    setTimeout(function(){
      $('#boxd').fadeOut();
    }, 2*1000);
  }
  $('#msg').html('');
}


// controls character input/counter
function count_char(me, show_block){
  var charLength = $(me).val().length;
  // Displays count
  if($('#is_tablet_device').val() == "true"){
    $(show_block).html("<strong>"+ (365 - charLength) +"</strong> out of <strong>365</strong> characters remaining ");
  }
  else{
    $(show_block).html("You have <strong>"+ (365 - charLength) +"</strong> characters remaining out of <strong>365</strong> characters");
  }
  // Alerts when 365 characters is reached
  if(charLength > 365){
    $(show_block).html('<strong>You only have up to 365 characters.</strong>');
    $(me).val($(me).val().substr(0, 365));
  }
}

// validating attachment
function check_attachment(fileid){
  var attachment = $('#'+fileid).text();
  if(attachment != ''){
    $('#msg').html("<span class='err_msg'>Multiple attachment feature is not supported. You have already attached a file. If you want to attach another file, delete an existing attachment and then select a new file to attach.</span>");
    notify();
    return false
  }
}

// diaplying attachment name
function get_attachment_name(obj, id){
  var filename = obj.value.replace(/^.*[\\\/]/, '');
  if ($.browser.msie) {
    /*
   its a fix for IE, in IE we can't measure file size so atleast we will show filename.'
     */
    if(filename != ''){
      $("#"+id).html("<img src='/assets/attachment.png' alt='attached_file' title='attached file' /> <span class='attachment_info'>"+filename.substring(0,30)+"...</span><span class='delete delete_attachment' id='"+$(obj).attr("id")+"'><img src='/assets/remove_attachment.png' alt='attached_file' title='remove attached file' /></span>");
    }
  }
  else{
    var filesize = obj.files[0].size/1048576;
    if(filesize <= 3){
      $("#"+id).html("<img src='/assets/attachment.png' alt='attached_file' title='attached file' /> <span class='attachment_info'>"+filename.substring(0,30)+"...</span><span class='delete delete_attachment' id='"+$(obj).attr("id")+"'><img src='/assets/remove_attachment.png' alt='attached_file' title='remove attached file' /></span>");
    }
    else {
      $('#msg').html("<span class='err_msg'>Attachment cannot be more than 3 MB in size</span>");
      $("#"+id).html("");
      obj.value = "";
      notify();
    }
  }
}


$('#buzz_attachment').live("change", function(){
  get_attachment_name(this, 'attached_file_add_buzz')
});

$('#rezz_attachment').live("change", function(){
  get_attachment_name(this, 'attached_file_add_buzz')
});


// deleting the attachment
$(".delete_attachment").live("click", function(){
  obj = $(this).attr("id");
  $('#'+obj).replaceWith($('#'+obj).clone());
  $(this).parent().html("");
  $('#'+obj).attr('value', '');
});


$("#beehive_channel_id").live('change',function(){
  $('#beehive_channel_id').css('border','1px solid #CCCCCC');
});

// validating the rezz out
function check_rezzout(){
  if($('.rezz_out_type:checked').val() == "true")
  {
    if(tinyMCE.get('rezz_command').getContent() == ""){
      $('#rezz_command_ifr').css('border','2px solid red');
      $('#empty_rezz_msg').html("<span class='err_msg'> Message can't be blank.</span>");
      return false
    }
    else{
      $('#rezz_command_ifr').css('border','none');
      $('#empty_rezz_msg').html('');
    }
  }
  else{
    if($('#rezz_command').val()== ""){
      $('#rezz_command').css('border','2px solid red');
      $('#empty_rezz_msg').html("<span class='err_msg'> Message can't be blank.</span>");
      return false
    }
    else{
      $('#rezz_command').css('border', '1px solid #C9C9C9');
      $('#empty_rezz_msg').html('');
    }

  }
  $('#rezzout').removeAttr('onclick');
  $('#add_buzz_spinner').show();


}

// validating the buzz out
function submit_command(form_id){
  if($('#buzz_channel_name').val() == ""){
    $('#buzz_channel_name').css('border','2px solid red');
    msg = $('.left_nav li a.channel').hasClass('active') ? "Channel" : "CUG"
    $('#empty_name').html("<span class='err_msg'>Please enter "+ msg +" name.</span>");
    return false;
  }

  else{
    $('#buzz_channel_name').css('border', '1px solid #CCCCCC');
    $('#empty_name').html('');
  }

  if($('.buzz_out_type:checked').val() == "true")
  {
    if(tinyMCE.get('command').getContent() == ""){
      $('#command_ifr').css('border','2px solid red');
      $('#empty_buzz').html("<span class='err_msg'> Message can't be blank.</span>");
      return false
    }
    else{
      $('#command_ifr').css('border','none');
    }
  }
  else{
    if($('#command').val()== ""){
      $('#command').css('border','2px solid red');
      $('#empty_buzz').html("<span class='err_msg'> Message can't be blank.</span>");
      return false
    }
    else{
      $('#command').css('border', '1px solid #C9C9C9');
    }

  }


  var buzz_name_text =  $('#buzz_name_buzz_properties');
  if(buzz_name_text.length > 0 && buzz_name_text.val() != ''){
    if(!alphaNumericRegEx.test(buzz_name_text.val())){
      buzz_name_text.css('border', '2px solid red');
      $('#msg').html("<span class='err_msg'>Buzz name should be alphanumeric only.</span>");
      notify();
      return false
    }
    else{
      $('#buzz_channel_name').css('border', '1px solid #CCCCCC');
    }
  }

  if($(".buzz_properties_holder :checkbox:checked").length > 0){
    $('.current_user_buzz_member').attr('value', $('.current_user_buzz_member').attr('user_id_val'))
  }
  else{
    $('.current_user_buzz_member').attr('value', '')
  }
  $('#buzzout').removeAttr('onclick');
  $('#add_buzz_spinner').show();

}

//unselecting the buzz limit users
$(".unselect input").live("click",function(){
  var element = $(this);
  $.get("/rezzs/members.js?buzz_id=" + $('#buzz_id').val() ,
    function(data) {
      if(data == "true"){
        $('#limit_box .details').find("input").each(function(){
          $(this).attr("checked",false);
        });
      }
      else{
        $('#error_explanation').show().html("Some of the buzzer(s) have rezzed on this Buzz. Hence you can not use 'Unselect All'.").fadeOut(10000);
        element.attr("checked",false);
      }
    });
});

//Selecting all users for response buzz
$(".select input").live("click",function(){
  $(".response_user_check").attr("checked","checked");
});

// unselecting the rezzed user
$(".details input").live("click",function(){
  var element = $(this);
  $.get("/rezzs/members.js?buzz_id=" + $('#buzz_id').val() + "&user_id=" + element.val() ,
    function(data) {
      if(data =="true"){
        $('#error_explanation').show().html("This user has rezzed on this buzz hence this user has to be a part of limited users").fadeOut(10000);
        element.attr("checked",true);
      }
    });
  if(!element.is(":checked")){
    $.get("/buzzs/user_has_priority_response_expected.js?buzz_id=" + $('#buzz_id').val() + "&user_id=" + element.val() ,
      function(data) {
        if(data =="false"){
          $('#error_explanation').show().html("This user has Priority (or) Response Expected  set, so this user has to be a part of limited users").fadeOut(10000);
          element.attr("checked",true);
        }
      });
  }
});

$("#select_unselect_buzz_properties").live("click",function(){
  if($(this).is(':checked')){
    $(".limit_members_for_buzz :checkbox").attr('checked', true);
  }
  else{
    $(".limit_members_for_buzz :checkbox").attr('checked', false)
  }
})

$("#select_unselect_response_expected").live("click",function(){
  if($(this).is(':checked')){
    $(".response_expected_for_buzz :checkbox").each(function (){
      $(this).attr('checked', true);
      expirydate = get_expiry_date();
      $(this).parent().parent().next().find('input').datepicker("setDate",expirydate);
    });
  }
  else{
    $(".response_expected_for_buzz :checkbox").each(function (){
      $(this).attr('checked', false);
      $(this).parent().parent().next().find('input').attr('value', '')
    });
  }
})


$("#select_unselect_prioritize_members").live("click",function(){
  if($(this).is(':checked')){
    $(".prioritize_members_for_buzz :checkbox").attr('checked', true);
  }
  else{
    $(".prioritize_members_for_buzz :checkbox").attr('checked', false)
  }
})

$(document).ready(function(){
  $("#loader").bind("ajaxSend", function() {
    $(this).show();
  }).bind("ajaxStop", function() {
    $(this).hide();
  }).bind("ajaxError", function() {
    $(this).hide();
  });
  if($('#is_tablet_device').val() == "true"){
    $('#login_footer').addClass('ipad_device');
  }
  $('input, textarea').placeholder();
  $("ul.tabs").tabs("div.panes > div");
  $.ajaxSetup({
    complete:hide_ajax_loading,
    statusCode: {
      401:function() {
        alert("Your session has been lost.. Please login...!");
        window.location.href = '/'
      }
    }
  });

  //used in the login page hover
  $('.rezz_icon').hover(function(){
    $('#login_tooltag.dozz').hide();
    $('#login_tooltag.reply').show();
    $('#login_footer li .content .dozz_icon').css("background","url(../assets/login_enhancements/dozz_disable.png)");

  },function(){
    $('#login_tooltag.reply').hide();
  });

  $('.tag_icon').hover(function(){
    $('#login_tooltag.dozz').hide();
    $('#login_tooltag.tag').show();
    $('#login_footer li .content .dozz_icon').css("background","url(../assets/login_enhancements/dozz_disable.png)");

  },function(){
    $('#login_tooltag.tag').hide();
  });

  $('.dozz_icon').hover(function(){
    $('#login_tooltag.dozz').show();
  },function(){
    $('#login_tooltag.dozz').hide();
  });

  $('.content').mouseout(function() {
    $('#login_tooltag.dozz').show();
    $('#login_footer li .content .dozz_icon').css("background","url(../assets/login_enhancements/dozz.png)");
  });
  $('#login_tooltag.dozz').show();
});

// validating while adding tag
function add_tag(field, error_block){
  var tag = $(field).val();
  var error = false
  if (tag.indexOf(" ")> -1){
    error_msg = 'Tag should not contain space.'
    error = true
  }
  else if(!tag.length){
    error_msg = 'Tag should not be blank.'
    error = true
  }
  else if(!validStringRegExp.test(tag)){
    error_msg = 'Tag should be alphanumeric only.'
    error = true
  }
  if(error){
    $(field).css('border', '2px solid red')
    $(error_block).html(error_msg);
    return false;
  }
  $('#tag_name_field')
  return true;
}

// cancel adding tag block
function cancel_add_buzz_tag_properties()
{
  $('.add_tag_buzz_properties').hide();
  $('#tag_name_buzz_properties').css('border','1px solid #CCC').val('');
  $("#properties_buzz_tag_id option[value='']").attr('selected', 'selected');
  $('#error_explanation_buzz_tag').html("");
}

// cancel adding tag block
function cancel_add_buzz()
{
  $('.add_tag').hide();
  $('#tag_name_field').css('border','1px solid #CCC').val('');
  $("#buzz_tag_tag_id option[value='']").attr('selected', 'selected');
  $('#error_explanation').html("");
}

// adding channel tags to a buzz
$("#buzz_tag_tag_id").live("change",function(){
  $(".add_tag").hide();
  var tag = $(this).val();
  var tag_name = $("#buzz_tag_tag_id option:selected").text();
  var status = true;
  if(tag == ""){
    status = false;
  }
  else
  {
    $('.buzz_tags').children().each(function(){
      if(tag_name == $.trim($(this).text())){
        alert("This tag is already assigned to the current buzz.");
        status = false;
      }
    });
    if (status){
      $.ajax({
        type:"POST",
        url : $(this).attr('path'),
        data :"buzz_tag="+tag
      });
      $(".buzz_tags").show( );
    }
  }
});


$("#add_buzz_tag_properties_button").live("click",function(){
  var status = add_tag('#tag_name_buzz_properties', '#error_explanation_buzz_tag');
  if(status == true){
    $.ajax({
      type:"POST",
      url : $(this).attr('path'),
      data :"tag="+ $('#tag_name_buzz_properties').val()
    });
  }
})

$("#properties_buzz_tag_id").live("change",function(){
  var status = true;
  var tag = $(this).val();
  var tag_name = $("#properties_buzz_tag_id option:selected").text();
  $('.buzz_tags_buzz_properties').children().each(function(){
    if(tag_name == $.trim($(this).text())){
      alert("This tag is already assigned to the current buzz.");
      status = false
    }
  });
  if (status && tag != ''){
    add_tag_to_buzz_properties(tag, tag_name);
  }
})

function add_tag_to_buzz_properties(tag, tag_name){
  $('#buzz_properties_tag_ids').attr('value', $('#buzz_properties_tag_ids').val()+","+ tag )
  $(".buzz_tags_buzz_properties").append("<div class='buzz_tag_name' id = 'delete_tag_buzz_properties"+ tag +"'>"+tag_name+" <a data-remote='true' onclick='return remove_buzz_tag_buzz_properties("+ tag +");'><img src='/assets/close_button.png' alt='Close_button'></div>")
}

function remove_buzz_tag_buzz_properties(tag_id){
  $("#delete_tag_buzz_properties"+tag_id).remove();
  obj = $('#buzz_properties_tag_ids')
  obj.attr("value",obj.val().replace(tag_id, " "));
}

function show_add_tag_block(){
  $(".add_tag").show();
  $("#tag_name_field").attr('value','').focus()
}

//used for selecting the flags fopr a buzz
$(".buzz_flags li div img").live("click",function(){
  if ($(this).attr("class") == "selected_flag"){
    $(this).removeClass("selected_flag");
    $(this).siblings('input[type=checkbox]').attr("checked", false);
    $("#expiry_date_"+$(this).attr("id")).val("")
  }else{
    $(this).addClass("selected_flag");
    $(this).siblings('input[type=checkbox]').attr("checked","checked");
  }
});

$(".buzz_flags_buzz_properties div img").live("click",function(){
  if ($(this).attr("class") == "selected_flag"){
    $(this).removeClass("selected_flag");
    $(this).siblings('input[type=checkbox]').attr("checked", false);
    $("#expiry_date_"+$(this).attr("id")).val("")
  }else{
    $(this).addClass("selected_flag");
    $(this).siblings('input[type=checkbox]').attr("checked","checked");
  }
});

$("#awaiting_for_response_filter").live("click",function(){
  if($(this).is(':checked')){
    $('#awaiting_for_response_filter_block').css('display', 'block');
    $('#awaiting_for_response_filter_block input:[type=checkbox]').attr('checked', true);
  }
  else{
    $('#awaiting_for_response_filter_block').css('display', 'none');
    $('#awaiting_for_response_filter_block input:[type=checkbox]').attr('checked', false);
  }
})

$("#response_expected_filter").live("click",function(){
  if($(this).is(':checked')){
    $('#response_expected_filter_block').css('display', 'block');
    $('#response_expected_filter_block input:[type=checkbox]').attr('checked', true);
  }
  else{
    $('#response_expected_filter_block').css('display', 'none');
    $('#response_expected_filter_block input:[type=checkbox]').attr('checked', true);
  }
})


$("#hide_insync").live("click",function(){
  $(this).attr('value', !$(this).is(':checked'))
});
//channels
$("#channel_view_type").live("change",function(){
  $("#search_channel_name_left_nav").attr("value", '');
  channel_view();
});


function channel_view()
{
  activating_home_link();
}
// functions related when clicking on the channel name and edit channel
$('.channel_topic_link').live('click',function(){
  making_channel_active_deactive($(this).attr('id'))
});

$('.channel_edit_link').live('click',function(){
  making_channel_active_deactive($(this).siblings(".channel_topic_link").attr('id'))
});

function making_channel_active_deactive(id_data)
{
  $('.channel_topic_links').removeClass('selected_channel_topic')
  $('#channel_topic_'+id_data).addClass('selected_channel_topic')
  $('.channel_stats_icon li').removeClass('active');
  $("#channel_info_data").html("");
  activating_home_link();
}

// function showing/hiding the info of a channel
$('.channel_stats_icon li.info').live('click',function(){
  if ($('.info').hasClass('active')){
    $(this).removeClass('active')
    $('#channel_info_data').html("");
  }
  else{
    $.ajax({
      type: 'get',
      url: "/channels/"+$(this).attr('id'),
      dataType: "script"
    })
    $(this).addClass('active')
  }
});

// functions which are used in the edting of a channel
$('#unsubcribe_yourself_channel').live('click',function(){
  if(!confirm("Are you sure, you want to unsubcribe yourself from this channel?")){
    $(this).attr('checked',false);
  }
})

$('#channel_is_active').live('click',function(){
  if($(this).is(':checked')){
    if(!confirm("Are you sure, you want to close this Channel?")){
      $(this).attr('checked',false);
    }
  }
})

//group
$('.channel_group_view_link').live('click',function(){
  $('.add_nav li.add_cug_or_channel').removeClass('active');
  $.ajax({
    type: 'get',
    url: $(this).attr('path')
  })
})

//common cugs and channels
$('.add_cug_or_channel').live("click",function(){
  reset_the_icons()
  $('.channel_topic_links').removeClass('selected_channel_topic');
  $('.top_links li a').removeClass('active');
  $('.add_nav li.add').addClass('active');
  $('ul.right_nav li.info').removeClass('active')
  $('.cug_related_block, .channel_related_block').html('')
  $.ajax({
    type: 'get',
    url: $(this).attr('path'),
    dataType: "script"
  })
});

//below functions are used for the adding a buzz

// cugs

// left pane
$(".hide_show_insyn_chk_box").live("click",function(){
  $("#search_channel_name_left_nav").attr("value", '');
  $('#loading_insync_cugs').html("&nbsp;Loading CUGs...")
  $.ajax({
    type: 'get',
    url: "/cugs/get_cug_view",
    data: "cug_view_type="+ $(this).attr('cug_view_type') + "&hide_insync_cugs=" + $(this).is(':checked')
  });
});

$('.cug_topic_link').live('click',function(){
  making_cug_active_deactive($(this))
});

$('.cug_edit_link').live('click',function(){
  making_cug_active_deactive($(this))
});

$('.insync').live('click',function(){
  $.ajax({
    type: 'get',
    url: $(this).attr('path'),
    data: "hide_insync_cugs="+ $('#hide_insync_cugs').is(':checked')
  });
});

function making_cug_active_deactive(id_data)
{
  $('.add_nav li.add_cug_or_channel').removeClass('active');
  $('.cug_topic_links').removeClass('selected_cug_topic')
  $('#cug_topic_'+id_data.attr('id')+'_'+id_data.attr('cug_type')).addClass('selected_cug_topic')
  $("#cug_info_data").html("");
  $('.stats_filter_icons li').removeClass('active');
  activating_home_link();

}

//top pane
$("#cug_view_type").live("change",function(){
  $("#search_channel_name_left_nav").attr("value", '');
  cug_view();
});


function url_for_geting_cugs(cug_val, group_view)
{
  obj = ''
  if($('.cug_group_view').length > 1)
    obj = $('.cug_group_view.open').prev().attr("id")
  $.ajax({
    type: 'get',
    url: "/cugs/get_cug_view?cug_view_type="+cug_val+"&hide_insync_cugs=" + $("#hide_insync_cugs").is(':checked')+"&opened_block="+obj+"&group_view="+group_view
  });
}

function url_for_getting_channels(channel_val, group_view)
{
  obj = ''
  if($('.channel_group_view_link').length > 1)
    obj = $('.channel_group_view_link.open').prev().attr("id")
  $.ajax({
    type: 'get',
    url: "/channels/get_channels?channel_view_type="+channel_val+"&opened_block="+obj+"&group_view="+group_view
  });
}

function cug_view(){
  activating_home_link();
}

//top pane
$('.stats_filter_icons li.info, .stats_filter_icons li.filter').live('click',function(){
  $('.stats_filter_icons li').removeClass('active')
  if($(this).hasClass('info')){
    if($('#cug_info_data').children().children('.tabs').text() == ''){
      $.ajax({
        type: 'get',
        url: "/cugs/"+$(this).attr('id')+"?cug_view_type="+$(this).attr('cug_view_type'),
        dataType: "script"
      })
      $(this).addClass('active');
    } else {
      $('#cug_info_data').html('');
      $(this).removeClass('active')
    }
  }
  else {
    if($('#cug_info_data').children().children('#channel_buzz_task_page').text() == ''){
      $.ajax({
        type: 'get',
        url: "/buzz_tasks/cug_channel_tasks",
        data: "channel_id="+$(this).attr('id')+"&is_channel="+true+"&cug_view_type="+$(this).attr('cug_view_type'),
        dataType: "script"
      })
      $(this).addClass('active')
    } else {
      $.ajax({
        type: 'get',
        url: "/buzzs?channel_id="+$(this).attr('id')+"&cug_view_type="+$(this).attr('cug_view_type'),
        dataType: "script"
      })
      $('#cug_info_data').html('');
      $(this).removeClass('active')
    }
  }
})

$('.top_links li .profile').live('click',function(){
  $('.top_links li a').removeClass('active');
  $(this).addClass('active')
  reset_the_icons()
  $('.cug_related_block, .channel_related_block').html('')
})


$('.top_links li .refresh').live('click',function(){
  if($('.left_nav li a.cug').hasClass('active')){
    if($('.selected_cug_topic').length > 0){
      $('.selected_cug_topic a.cug_topic_link').click()
    }
    else
    {
      if($('.cug_group_view').length > 1){
        obj = $('.cug_group_view.open')
        $.ajax({
          type: 'get',
          url: $(obj).attr('path'),
          data: {
            hide_insync_cugs: $("#hide_insync_cugs").is(':checked')
          },
          dataType: "script"
        })
      }
      else{
        $('#cug_view_type').change();
      }
    }
  }
  else{
    if($('.selected_channel_topic').length > 0)
      $('.selected_channel_topic a.channel_topic_link').click()
    else{
      if($('.channel_group_view_link').length > 1){
        obj = $('.channel_group_view_link.open')
        $.ajax({
          type: 'get',
          url: $(obj).attr('path')
        })
      }
      else{
        $('#channel_view_type').change();
      }
    }
  }
})

// main pane more button
$('.more_buzz_actions_link').live("click",function(){
  $('#more_buzz_icons_'+$(this).attr('buzzid')).toggle("slow");
  if($(this).text() == "< more"){
    $(this).text('> less').removeClass('more').addClass('less');
  } else {
    $(this).text('< more').removeClass('less').addClass('more');
  }
});

//below functions are used in the cug edit
$('#unsubcribe_yourself').live('click',function(){
  if($(this).is(':checked')){
    if(!confirm("Are you sure, you want to unsubcribe yourself from this CUG?")){
      $(this).attr('checked',false);
    } else {
      if($('#change_the_moderator').val() == ''){
        if($('#change_the_moderator option').length == 1){
          alert("You cannot unsubscribe from this CUG. You can only close this CUG.")
          $(this).attr('checked',false);
        } else {
          alert("You should change the moderator to someone else in order to unsubcribe yourself from this CUG.")
          $(this).attr('checked',false);
        }
      }
    }
  }
})

$("#subscription_is_core").live("change",function(){
  if($(this).val() != ''){
    if(!confirm("Are you sure, you want to switch to "+$('#subscription_is_core :selected').text()+"?")){
      $("#subscription_is_core option[value='"+ $('#subscription_is_core_val').val()+"']").attr('selected', 'selected');
    }
  }
});

$("#change_the_moderator").live("change",function(){
  if($(this).val() != ''){
    if(!confirm("Are you sure, you want to change the moderator of this CUG?")){
      $("#change_the_moderator option:first-child").attr("selected","selected");
    }
  }
});

$('.manage_mode_fav_icon').live('click',function(){
  if($(this).hasClass('offstar')){
    $(this).removeClass('offstar').addClass('onstar');
    $('#cug_fav_manage_mode, #fav_manage_mode').attr('value','false');
  }
  else{
    $(this).removeClass('onstar').addClass('offstar');
    $('#cug_fav_manage_mode, #fav_manage_mode').attr('value','true');
  }
})

// Group view functions
$('.cug_group_view').live('click',function(){
  $.ajax({
    type: 'get',
    url: $(this).attr('path'),
    data: {
      hide_insync_cugs: $("#hide_insync_cugs").is(':checked')
    },
    dataType: "script"
  })
})

//search functions
$('#search_box').live('focus',function(){
  $('#search_options .advance_search_link').slideDown("slow");
  return false;
});

$('#search_box').live('blur',function(){
  $('#search_options .advance_search_link').slideUp("slow");
  return false;
});

$('#search_box').live('keypress',function(e){
  if(e.keyCode == 13){
    submit_search(this)
  }
});

$('.search_fld_icon').live('click',function(e){
  submit_search($('#search_box'))
});

var ajax_result = null ;
$('#search_channel_name_left_nav').live('keyup',function(e){
 
  if($(this).val() == ""){
    if($('.left_nav li a.channel').hasClass('active'))
      url_for_getting_channels($('#channel_view_type').val(), 'false');
    else
      url_for_geting_cugs($('#cug_view_type').val(), 'false');
  }
  else{
    if(ajax_result != null) {
      ajax_result.abort();
    }
    obj = ''
    if($('.left_nav li a.channel').hasClass('active')){
      if($('.channel_group_view_link').length > 1)
        obj = $('.channel_group_view_link.open').prev().attr("id")
    }
    else{
      if($('.cug_group_view').length > 1)
        obj = $('.cug_group_view.open').prev().attr("id")
    }
    form =  $(this).closest("form");
    ajax_result = jQuery.ajax({
      type: 'POST',
      url: form.attr('action'),
      data: form.serialize(),
      success: function(data){
      // do stuff
      }
    });
  }
});

function submit_search(obj)
{
  if($(obj).val() == ''){
    $("#msg").html("<span class='err_msg'>Please enter search keyword</span>");
    notify();
    return false;
  }
  else{
    $(obj).closest("form").submit();
  }
}


$('#beehive_search').live('ajax:before', function(){
  show_search_loader();
});

$('#beehive_search').live('ajax:complete', function(){
  $('#beehive_search').unbind('ajax:success');
});

function show_search_options(search_div_id){
  $("#"+search_div_id).show();
}

function show_advance_search_box(){
  $('#advance_search_link').hide();
  $('.search_fld_icon').hide();
  $('#advance_search_options').slideDown("slow");
  $('#search_type').val('advance');
}

function hide_advance_search_box(){
  $('#search_box').val('');
  $('#search_cug_name').val('');
  $('#cug_search').hide();
  //$('input:radio[class=beehive_current_cug]')[2].checked = true;
  $(".beehive_search_tags").attr('checked', false);
  $("#beehive_search_tags").attr('checked', false);
  $(".beehive_search_flags").attr('checked', false);
  $("#beehive_search_flags").attr('checked', false);
  $(".beehive_search_buzzed_by").attr('checked', false);
  $("#beehive_search_buzzed_by").attr('checked', false);
  $(".beehive_search_insync_types").attr('checked', false);
  $("#beehive_search_insync_types").attr('checked', false);
  $(".buzz_flags").removeClass('selected_flag')
  $('#advance_search_link').show();
  $('.search_fld_icon').show();
  $('#advance_search_options').slideUp("slow");
  $('#search_type').val('simple');
}

$('.beehive_current_cug').live('click',function(){
  $("#search_cug_name").val('');
  if($(this).attr('checked') == 'checked'){
    if($(this).val() == 'cug'){
      $('#cug_search').show();
    } else {
      $('#cug_search').hide();
    }
  }
});

$("#tags_box").live('click', function(){
  $("#tags_select_all").toggle('slow');
  $('#tags_scrollbar').toggle('slow', function() {
    $(this).mCustomScrollbar("update");
  });
  if($(this).find('img').attr('src').replace(/^.*\/|\.png$/g, '') == 'search_accor_up'){
    $(this).find('img').attr('src', '/assets/beehive-newui/search_accor_down.png')
  }else{
    $(this).find('img').attr('src', '/assets/beehive-newui/search_accor_up.png')
  }
});
$("#flags_box").live('click', function(){
  $("#flags_options").toggle('slow');
  $("#flags_select_all").toggle('slow');
  if($(this).find('img').attr('src').replace(/^.*\/|\.png$/g, '') == 'search_accor_up'){
    $(this).find('img').attr('src', '/assets/beehive-newui/search_accor_down.png')
  }else{
    $(this).find('img').attr('src', '/assets/beehive-newui/search_accor_up.png')
  }
});
$("#buzzed_by_box").live('click', function(){
  $("#buzzed_by_select_all").toggle('slow');
  $('#buzzedby_scrollbar').toggle('slow', function() {
    $(this).mCustomScrollbar("update");
  });

  if($(this).find('img').attr('src').replace(/^.*\/|\.png$/g, '') == 'search_accor_up'){
    $(this).find('img').attr('src', '/assets/beehive-newui/search_accor_down.png')
  }else{
    $(this).find('img').attr('src', '/assets/beehive-newui/search_accor_up.png')
  }
});
$("#insync_type_box").live('click', function(){
  $("#insync_type_options").toggle('slow');
  $("#insync_type_select_all").toggle('slow');
  if($(this).find('img').attr('src').replace(/^.*\/|\.png$/g, '') == 'search_accor_up'){
    $(this).find('img').attr('src', '/assets/beehive-newui/search_accor_down.png')
  }else{
    $(this).find('img').attr('src', '/assets/beehive-newui/search_accor_up.png')
  }
});

$("#hide_completed_tasks_link_channel").live("click",function(){
  $("tr.completed").fadeOut();
});

//$(".mCustomScrollBox").live("click", function(){
//  $('.mCustomScrollbar _mCS_1').css("background-color", "red")
//  $('.mCustomScrollbar _mCS_1').removeClass("keyword-input")
//  $('.keyword-input').css("background-color", "green")
//})

//used for search
function select_flag_check(flag_id){
  if(!$("#beehive_search_flag_id_"+flag_id).is(':checked')){
    $("#beehive_search_flag_id_"+flag_id).attr('checked', true);
    $("#beehive_search_flag_"+flag_id).addClass('selected_flag');
  } else {
    $("#beehive_search_flag_id_"+flag_id).attr('checked', false);
    $("#beehive_search_flag_"+flag_id).removeClass('selected_flag');
  }
  check_uncheck_all('beehive_search_flags')
}

function select_all_options(obj, element_class){
  is_flag = (element_class=='flags');
  selection_status = ($(obj).attr('checked') == 'checked');
  $(".beehive_search_"+element_class).each( function() {
    $(this).attr("checked",selection_status);
    if(is_flag){
      if(selection_status)
        $("#beehive_search_flag_"+$(this).val()).addClass('selected_flag');
      else
        $("#beehive_search_flag_"+$(this).val()).removeClass('selected_flag');
    }
  });
}

function breadcrumb_direct_view(type, id){
  cug_view();
  if(type == 'parent')
    id = get_first_non_zero_block().match(/\d+/);
  if($('.left_nav li a.cug').hasClass('active'))
    url_for_geting_cugs(id, 'true');
  else
    url_for_getting_channels(id, 'true')
}

// validating when adding channel/CUG
function validate_add_channel_cug(){
  var error = false
  if($("#add_channel_name").val()==""){
    error = true
    error_msg = "<span class='err_msg'>Name cannot be blank.</span>"
  }
  if($("#add_channel_name").val().length > 25){
    error = true
    error_msg = "<span class='err_msg'>Name should not be more than 25 characters long.</span>"
  }
  if(error == true){
    $('#add_channel_name').css('border','2px solid red')
    $('#msg').html(error_msg)
    notify();
    return false;
  }
  else{
    $('#add_channel_name').css('border','1px solid #cccccc')
  }
  if ($('#command').val()== ""){
    $('#command').css('border','2px solid red')
    $('#msg').html("<span class='err_msg'>Message cannot be blank.</span>")
    notify();
    return false;
  }
  else{
    $('#command').css('border','1px solid #cccccc')
  }
  return true;
}

function reset_the_icons()
{
  $('.add_nav li.add_cug_or_channel').removeClass('active');
  $('.top_links li .buzz_icon').removeClass('add_buzz');
  $('.top_links li .buzz_icon').removeClass('add_group_buzz');
  $('.cug_topic_links').removeClass('selected_cug_topic')
  $('.stats_filter_icons li.info, .stats_filter_icons li.filter').attr("id",'').removeClass('active')
}

function show_search_loader(){
  $('#msg').html("Please wait ...");
  notify();
}

function hide_ajax_loading(){
  height_of_main_pane();
  tooltip_active();

  if($('#is_tablet_device').val() == "true"){
    $('a').removeAttr("title").removeAttr("alt");
    $('#dashboard').addClass('ipad_device');
  }
  else{
    //  This is for tooltip
    $("ul.buzzers li a").tipTip({
      maxWidth: "150",
      defaultPosition: "left"
    });
    $(".dozz_grid a").tipTip({
      maxWidth: "150",
      defaultPosition: "left"
    });

    $(".top_links li a").tipTip({
      maxWidth: "150"
    });
  }
}

$("#search_cug_name").live('click', function(){
  $("#search_cug_name").autocomplete({
    serviceUrl: '/cugs/cugs_names_with_aliases'
  });
});

function empty_channels(){
  if($('.left_nav li a.channel').hasClass('active')) msg = 'Channels';
  else msg = 'CUGs';
  $('.channels_or_cugs_list ul').html('<li class="no_cugs"><a>No '+ msg +'</a></li>');
}

function tooltip_active(){
  if($('#is_tablet_device').val() == "true"){
    $('img, a, #buzzout_img, li, .add, .help_icon img').removeAttr("title").removeAttr("alt");
  }
  else{
    $(".buzzout_img #buzzout_img, .buzzout_img #buzz_properties_icon_img").tipTip({
      maxWidth: "150",
      defaultPosition: "right"
    });

    $("ul.buzzers li a").tipTip({
      maxWidth: "150",
      defaultPosition: "left"
    });

    $(".add").tipTip({
      maxWidth: "150",
      defaultPosition: "right"
    });

    $("ul.left_nav li a").tipTip({
      maxWidth: "150",
      defaultPosition: "right"
    });

    $("ul.stats_filter_icons li, ul.channel_stats_icon li").tipTip({
      maxWidth: "150",
      defaultPosition: "left"
    });

    $(".cug_topic_links a, .channel_topic_links a").tipTip({
      maxWidth: "150",
      defaultPosition: "right"
    });

    $(".buzz_title a").tipTip();

    $(".action_view_icons img").tipTip();

    $(".help_icon img").tipTip({
      maxWidth: "100px",
      defaultPosition: "right"
    });

    $(".buzzout_img #buzzout_img").tipTip({
      maxWidth: "150",
      defaultPosition: "right"
    });

    $(".buzz_title a").tipTip();

    $(".arrow_rezz_icon_block a").tipTip({
      maxWidth: "150",
      defaultPosition: "right"
    });
  }
}

function init_datepicker()
{
  $(".select_date_picker, .buzz_task_due_date").datepicker({
    dateFormat: 'dd-M-yy',
    minDate: new Date()
  });
}

function buttons_styling(){
  $( "input:submit, a", ".popup_actions" ).button();
}

function height_of_main_pane(){
  $('.buzz_scroll').css('height', $(window).height()-160+'px')
}

function left_nav_height(){
  var height = 0
  //  if($('#is_tablet_device').val() == "false")
  height = $(window).height()-260;
  //  else
  //    height = $(window).height()-260;

  var length = $('.channels_or_cugs_list').length;
  if(length > 1){
    open_block = get_first_non_zero_block();
    toggle_effect_channel(open_block);
  }
  else{
    $('.channels_or_cugs_list').each(function(index){
      $(this).css('height', height+'px');
    });
  }
}

function get_first_non_zero_block(){

  open_block = $('.view_icon:first').attr("id");
  channels_open_find = 0;

  $('.view_icon').each(function(){
    if(channels_open_find == 0){
      if($(this).attr('channels_count') != 0){
        open_block = $(this).attr("id");
        channels_open_find = 1
      }
    }
  })
  return open_block;
}

function animating_insync_text(buzz_id){
  var toAnimate="#insync_effect_"+buzz_id,
  settings={
    animation:13,
    animationType:"in",
    backwards:!1,
    easing:"easeOutQuint",
    speed:1E3,
    sequenceDelay:50,
    startDelay:0,
    offsetX:100,
    offsetY:50,
    onComplete:fireThis,
    restoreHTML:!0
  };
  $.cjTextFx(settings);
  $.cjTextFx.animate(toAnimate);

  function fireThis()
  {
    sets={
      animationType:"out"
    };
    if($(toAnimate).length > 0){
      $.cjTextFx.animate(toAnimate,sets)
      setTimeout(function(){
        jQuery.cjTextFx.remove(true);
      },2400)
    }
  }
}

$('.buzz_out_type').live("click",function(){
  if($(this).val() == "true"){
    tinyMCE.execCommand('mceAddControl', false, 'command');
    $('#command').css('border', '1px solid #C9C9C9');
    $('#dashboard_msg').html("");
    
  }
  else{
    var buzz_text_obj = tinyMCE.get('command').getContent();
    tinyMCE.execCommand('mceFocus', false, 'command');
    tinyMCE.execCommand('mceRemoveControl', false, 'command');
    $('#command_ifr').css('border', 'none');
    if($(buzz_text_obj).text() == '')
      buzz_text = buzz_text_obj
    else
      buzz_text = $(buzz_text_obj).text();
    $('#command').attr("value", buzz_text.replace(/^\s*/,''));
    count_char('#command', '#dashboard_msg');
  }
  $('#empty_buzz').html('');
})

//adding tinymce to rezz
$('.rezz_out_type').live("click",function(){
  if($(this).val() == "true"){
    tinyMCE.execCommand('mceAddControl', false, 'rezz_command');
    $('#rezz_command').css('border', '1px solid #C9C9C9');
    $('#dashboard_msg_rezz').html("");
  }
  else{
    var buzz_text_obj = tinyMCE.get('rezz_command').getContent();
    tinyMCE.execCommand('mceFocus', false, 'rezz_command');
    tinyMCE.execCommand('mceRemoveControl', false, 'rezz_command');
    $('#rezz_command_ifr').css('border', 'none');
    if($(buzz_text_obj).text() == '')
      buzz_text = buzz_text_obj
    else
      buzz_text = $(buzz_text_obj).text();
    $('#rezz_command').attr("value", buzz_text.replace(/^\s*/,''));
    count_char('#rezz_command', '#dashboard_msg_rezz');
  }
  $('#empty_rezz_msg').html('');
})

$('#buzz_properties_icon_img').live("click",function(){
  if($('#buzz_channel_name').val() == ""){
    $('#buzz_channel_name').css('border','2px solid red');
    msg = $('.left_nav li a.channel').hasClass('active') ? "Channel" : "CUG"
    $('#empty_buzz').html("<span class='err_msg'>Please enter "+ msg +" name.</span>");
    notify();
    return false;
  }

  else{
    $('#buzz_channel_name').css('border', '1px solid #CCCCCC');
    $('#empty_buzz').html('');
  }
})

$('#buzz_channel_name').live("keypress",function(){
  $('#buzz_channel_id').attr('value', 0)
});

function toggle_effect_channel(obj){
  height = $(window).height()-260+(17*($('.channels_or_cugs_list').length-1));
  $('.channel_names_block').css('display', 'none');
  closed_blocks_height = 50*($('.channel_names_block').length -1)
  $('.channels_or_cugs_list').each(function(index){
    $(this).css('height', height-closed_blocks_height+'px');
  });
  $('.cug_group_view').removeClass('open');
  $('.channel_group_view_link').removeClass('open');
  $('#'+obj).next().addClass('open');
  $('#'+obj+'_data').show();
  $('.view_icon').each(function(){
    $("#"+$(this).attr('view_type')+"_scrollbar").mCustomScrollbar("update");
  });
}

$('.view_icon').live("click",function(){
  toggle_effect_channel($(this).attr("id"))
});

$('.filters_icon').live("click",function(){
  if($('#filters_block').css('display') == "none"){
    $('#filters_block').slideDown("slow");
    $(this).addClass("active");
  }
  else{
    $('#filters_block').slideUp("slow");
    $(this).removeClass("active");
  }
});

$('.new_buzz_remove_user').live("click",function(){
  delete_type = $(this).attr("to_be_removed_frm")
  if((($('.channel_users_name span').length-1) == $('.channel_users_name span.cannot_drag').length) &&  delete_type == 'information_user_ids'){
    alert("Aleast one user need to be there to buzzout!")
    return false;
  }
  var obj = ''
  if(delete_type == 'information_user_ids'){
    if(confirm("If you delete this user, you cannot be able to drag into Response Expected and Priority!")){
      $("#"+$(this).attr("id")).remove();
      obj = '#'+delete_type;
      id = $(this).attr("id").match(/\d+/)
      $(obj).attr('value', $(obj).val().replace(id, ''));
      $('.channel_users_name #'+id).addClass('cannot_drag');
      if($('.user_'+id).length > 0){
        $('.user_'+id).each(function(index){
          check = "#"+$(this).parent().next().attr("id");
          $(check).attr('value', $(check).val().replace(id, ''));
          $(this).remove();
        });
      }
    }
  }
  else{
    $("#"+$(this).attr("id")).remove();
    obj = '#'+delete_type;
    id = $(this).attr("id").match(/\d+/)
    $(obj).attr('value', $(obj).val().replace(id, ''));
  }


  $('.drop_boxes').each(function(index){
    if($('#'+$(this).attr('id')+' span').html() == null)
      $(this).html('<span class="placeholder">Drag & Drop Names Here...</span>')
  });
})



function activating_home_link()
{
  $('.top_links li a').removeClass('active');
  $('.top_links li .home').addClass('active')
}

//function update_scroll_by_keyword_arrows(obj){}

function update_scroll_by_keyword_arrows(obj)
{
  if($('#is_tablet_device').val() == "false"){
    $(obj).hover(function(){
      $(document).data({
        "keyboard-input":"enabled"
      });
      $(this).addClass("keyboard-input");
    },function(){
      $(document).data({
        "keyboard-input":"disabled"
      });
      $(this).removeClass("keyboard-input");
    });
    $(document).keydown(function(e){
      if($(this).data("keyboard-input")==="enabled"){
        //e.preventDefault();
        var activeElem=$(".keyboard-input"),
        activeElemPos=Math.abs($(".keyboard-input .mCSB_container").position().top),
        pixelsToScroll=40;
        if(e.which===38){ //scroll up
          if(pixelsToScroll>activeElemPos){
            activeElem.mCustomScrollbar("scrollTo","top");
          }else{
            activeElem.mCustomScrollbar("scrollTo",(activeElemPos-pixelsToScroll));
          }
        }else if(e.which===40){ //scroll down
          activeElem.mCustomScrollbar("scrollTo",(activeElemPos+pixelsToScroll));
        }
      }
    });
  }
}

function cannot_rezz_out(){
  $('#msg').html("<span class='err_msg'>You are not owner of the buzz to limit..!</span>");
  notify();
}

function check_uncheck_check_boxes(obj, apply_to){
  var a = $(obj+" :checkbox")
  var b = $(obj+" :checkbox:checked")
  if(a.length == b.length){
    $(apply_to).attr("checked",true)
  }
  else{
    $(apply_to).attr("checked",false)
  }
}

function checking_unchecking_priority_responce_expected(obj, apply_to){
  if($(obj).is(':checked')){
    $(apply_to+" .users_data :checkbox").attr('checked', true);
  }
  else{
    $(apply_to+" .users_data :checkbox").attr('checked', false)
  }
  $(apply_to+" .users_data :checkbox").each(function (){
    if(apply_to == '#response_expected')
      set_destroy_and_date_responce_expected(this);
    else
      set_destroy_priority(this);
  });
}

function check_uncheck_all(obj){
  var a = $("input[type='checkbox']."+obj);
  if(a.length == a.filter(":checked").length){
    $('#'+obj).attr("checked",true)
  }
  else{
    $('#'+obj).attr("checked",false)
  }
}

function getting_cugs_to_add_buzz(){
  if($('.selected_cug_topic').length > 0){
    $('#buzz_channel_name').attr("value", $('.selected_cug_topic a').attr('channel_name'));
    $('#buzz_channel_id').attr("value", $('.selected_cug_topic a').attr('id'));
  }
  else{
    $('#buzz_channel_name').attr('placeholder', 'Type CUG name here...');
  }
}

function getting_channels_to_add_buzz(){
  if($('.selected_channel_topic').length > 0){
    $('#buzz_channel_name').attr("value", $('.selected_channel_topic a').attr('channel_name'));
    $('#buzz_channel_id').attr("value", $('.selected_channel_topic a').attr('id'));
  }
  else{
    $('#buzz_channel_name').attr('placeholder', 'Type Channel name here...');
  }
}

function set_destroy_and_date_responce_expected(buzz){
  expirydate = get_expiry_date()
  if (!$(buzz).is(':checked')){
    $("#destroy_"+buzz.value).attr("value","1")
    $("#response_expiry_date_"+buzz.value).attr("value","");
  }
  else{
    $("#destroy_"+buzz.value).attr("value","0")
    $("#response_expiry_date_"+buzz.value).datepicker("setDate",expirydate);
  }
}

function set_destroy_priority(buzz){
  if (!$(buzz).is(':checked')){
    $("#destroy_"+buzz.value).attr("value","1")
  }
  else{
    $("#destroy_"+buzz.value).attr("value","0")
  }
}

function get_expiry_date(){
  var d = new Date();
  var day = d.getDay();
  switch(day){
    case 5:
      expirydate = (new Date(),3);
      break;
    case 6:
      expirydate = (new Date(),2);
      break;
    default:
      expirydate = (new Date(),1);
  }
  return expirydate
}

function get_exipry_date_buzz_properties(obj)
{
  if($(obj).is(':checked')){
    $(".response_expected_for_buzz :checkbox").each(function (){
      expirydate = get_expiry_date();
      $(obj).parent().parent().next().find('input').datepicker("setDate",expirydate);
    });
  }
  else{
    $(".response_expected_for_buzz :checkbox").each(function (){
      $(obj).parent().parent().next().find('input').attr('value', '')
    });
  }
}


//ipad buzz action
$('.ipad_buzzers_icon a').live("click",function(){
  $('.ipad_buzzers_icon').hide();
});

function drap_and_drop(){
  $( ".channel_users_name span").draggable({
    appendTo: "body",
    helper: "clone"
  });
  $( ".drop_boxes" ).droppable({
    hoverClass: "ui-state-hover",
    accept: ":not(.ui-sortable-helper)",
    drop: function( event, ui ) {
      id = $(this).attr("id")+ui.draggable.attr("id");
      if($(this).find("#"+id).size() == 0){
        if($(this).attr("id") == 'new_buzz_information')
        {
          if($('.channel_users_name #'+ui.draggable.attr("id")).hasClass('cannot_drag'))
            $('.channel_users_name #'+ui.draggable.attr("id")).removeClass('cannot_drag')
        }
        if($('.channel_users_name #'+ui.draggable.attr("id")).hasClass('cannot_drag'))
          return false;
        $(this).find( ".placeholder" ).remove();
        $("<span id='"+id+"' class='user_"+ui.draggable.attr("id")+"'></span>").html(ui.draggable.text()+'<p class="close right new_buzz_remove_user" id="'+id+'" to_be_removed_frm="'+$("#"+$(this).attr("id")).next().attr("id")+'"></p>').appendTo(this)
        $(this).next().attr("value",$(this).next().val()+","+ui.draggable.attr("id").match(/\d+/))
      }
    }
  })
}

function autocomplete_buzz_channel_name(){
  $('#buzz_channel_name').autocomplete({
    serviceUrl: "/buzzs/channel_search?channel="+$('.left_nav li a.cug').hasClass('active')+"&is_channel_view="+$('.left_nav li a.channel').hasClass('active'),
    onSelect: function set(value,data){
      if($('.left_nav li a.channel').hasClass('active')){
        $('#buzz_channel_id').attr('value', data);
      }
      else{
        $.ajax({
          type: 'get',
          url: '/buzzs/'+data+'/get_channel'
        })
      }
      $('#buzz_channel_name').css('border', '1px solid #CCCCCC');
      $('#empty_name').html('');
    }
  });
}

function add_buzz_block_scroll(){
  $("#new_buzz_users_data_block").mCustomScrollbar({
    advanced:{
      updateOnBrowserResize:true,
      updateOnContentResize:true,
      autoExpandHorizontalScroll:false
    }
  });
  update_scroll_by_keyword_arrows("#new_buzz_users_data_block");
}

function add_rezz_block_scroll(){
  $("#new_rezz_users_data_block").mCustomScrollbar({
    advanced:{
      updateOnBrowserResize:true,
      updateOnContentResize:true,
      autoExpandHorizontalScroll:false
    }
  });
  update_scroll_by_keyword_arrows("#new_rezz_users_data_block");
}

$('.top_links li .buzz_icon').live('click',function(){
  if($('#add_new_buzz').html() != ''){
    $('#add_new_buzz').html('');
    activating_home_link();
  }
  else{
    $.ajax({
      type: 'get',
      url: $(this).attr('path'),
      dataType: "script"
    })
  }
});

function get_first_cug_opened_block(){
  var obj =''
  if($('.cug_group_view.open').length > 0)
    obj = "cug_block_"+$('.cug_group_view.open').attr('path').match(/\d+/)+"_data"
  else
    obj = "cug_block_"+$('.cug_group_view').attr('path').match(/\d+/)+"_data"
  if($('#'+obj+' li:first a:first').attr('href') == undefined)
    $('#buzzes_list').html("<div class='no_buzzs_found'>No Out Of Sync Buzzes found...</div>");
  else
    $('#'+obj+' li:first a:first').click();
}


function get_first_channel_opened_block(){
  var obj =''
  if($('.channel_group_view_link.open').length > 0)
    obj = "channel_block_"+$('.channel_group_view_link.open').attr('path').match(/\d+/)+"_data"
  else
    obj = "channel_block_"+$('.channel_group_view_link').attr('path').match(/\d+/)+"_data"
  if($('#'+obj+' li:first a:first').attr('href') == undefined)
    $('#buzzes_list').html("<div class='no_buzzs_found'>No Buzzes found...</div>");
  else
    $('#'+obj+' li:first a:first').click();
}

$('.token-input-list-facebook').live('click',function(){
  $('.token-input-list-facebook input').focus();
})

function check_alias_name_validation(type){
  alias_name = $('.alias_name');
  if(!aliasNameRegEx.test(alias_name.val()) && alias_name.val() != ''){
    alias_name.css('border', '2px solid red');
    $('#msg').html("<span class='err_msg'>"+type+" alias name should be alphanumeric only.</span>");
    notify();
    return false;
  }
  else{
    alias_name.css('border', '1px solid #CCCCCC');
  }
}
