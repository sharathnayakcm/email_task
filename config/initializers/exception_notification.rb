if Rails.env == "production"
  Beehive::Application.config.middleware.use ExceptionNotifier,
    :email_prefix => "[Beehive Exception] ",
    :sender_address => '"Beehive Exception" <no-reply@beehive.com>',
    :exception_recipients => %w{chirag.singhal@sumerusolutions.com sukhwinder.tambar@sumerusolutions.com prabhat.thapa@sumerusolutions.com sandeep.mehendale@sumerusolutions.com}
end