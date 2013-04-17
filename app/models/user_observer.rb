class UserObserver < ActiveRecord::Observer
  def after_save(user)
    UserMailer.send(user.status_delivery, user).deliver if user.status_delivery.present?
  end
end
