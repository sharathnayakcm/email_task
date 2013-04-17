class UserMailer < ActionMailer::Base
  default from: "beehive@sumerusolutions.com"

  def activation(user)
    @user = user
    mail(:to => user[:email], :subject => " Account activated ")
  end

  def deactivation(user)
    @user = user
    mail(:to => user[:email], :subject => " Account Deactivated ")
  end

  def beehive_autoresponse(subject,email,message)
    subject_message = ((subject.nil? || subject =="") ? "-" : subject)
    mail(:from=> "no-reply@beehive.com",:to => email, :subject => "Beehive [Auto Response]: " + subject_message,:body => message)
  end

  def buzz_dozz(buzz_task)
    @buzz_task = buzz_task
    mail(:to => buzz_task.user.dozz_email, :subject => "#{buzz_task.name};#{buzz_task.due_date}")
  end
end
