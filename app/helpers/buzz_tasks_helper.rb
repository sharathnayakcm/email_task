module BuzzTasksHelper
  def get_buzz_data(id, user)
    buzz = Buzz.where(:id => id).first
    return buzz, buzz.buzz_tasks.where(:user_id => user)
  end

  def get_channel_buzz_tasks(obj, user)
    obj.channel.buzz_tasks.where(:user_id => user)
  end
end
