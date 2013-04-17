module BeehiveMailman
  require 'mms2r'
  require File.expand_path('../../app/helpers/application_helper.rb',  __FILE__)
  include ApplicationHelper

  class BMailman

    attr_reader :body

    def initialize(message)
      @object = message
      @message = MMS2R::Media.new(@object)
      @attachment = @message.default_media
      @body = @message.body
      @from = @message.from
      idx = @body.index("\n\n\n\n")
      @body.slice!(idx..-1) if idx
      @mail_text = "Hi, \n\n "
      @status = true
    end

    def from
      @object.from
    end

    def subject
      @object.subject || ""
    end

    def channel_name
      subject
    end

    def process
      if subject.nil? || subject == "" || subject.blank?
        @mail_text += "Your email can not be processed because message was sent without subject. "
      elsif sender.blank?
        @mail_text += "Sorry! You are not authorised"
      elsif is_sender_verified?
        @mail_text += "Currently your account is not activated. First activate your account then re-send an email."
      elsif have_more_attachments?
        @mail_text += "Currently 'Buzz through email' functionality does not support processing of multiple attachments.Hence your buzz is not processed.Please re-send an email with single attachment."
      elsif length_exceed?
        @mail_text += "Your message is too long (maximum is 365 characters) or contains a signature. If the message contain signature, please remove the signature and re-send message."
      elsif @attachment and @attachment.size > 10485760
        @mail_text += "Attachment size is greater than 10MB"
      else
        buzz_out
      end
      @mail_text + disclaimer
    end

    def response
      @mail_text
    end

    def buzz_out
      if channel
        @attachment = @object.attachments.size == 0 ? nil: @attachment
        response = Buzz.channel_buzzout(channel, @body, sender, @attachment)
        @mail_text += "\n" + autoresponse_msg(response)
      else
        @mail_text += "CUG/Channel \"#{channel_name}\" does not exist"
      end
    end

    def disclaimer
      "\n\n\n** THIS IS AN AUTO GENERATED EMAIL.PLEASE DO NOT REPLY TO THIS MAIL ** \n\n Thanks, \n Beehive Support Team"
    end

    private

    def channel
      Channel.where(:name => channel_name).first
    end

    def sender
      User.where(:email => @message.from).first
    end

    def is_sender_verified?
      !sender.blank? && sender.user_account_status == "Not Verified"
    end

    def have_more_attachments?
      @object.attachments.length > 1
    end

    def length_exceed?
      @body.to_s.length.to_i >= 365
    end
  end
end