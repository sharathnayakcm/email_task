class BuzzMember < ActiveRecord::Base
  belongs_to :buzz
  belongs_to :user
  belongs_to :channel

  # limit action on buzz
  def self.limit_members(buzz, user_ids = nil)
    begin
      message =""
      transaction do
        buzz.buzz_members.destroy_all if buzz.buzz_members.any?
        buzz.root.descendants.each do |child|
          child.buzz_members.destroy_all if child.buzz_members.any?
          message = "Buzz limit has been removed successfully."
        end
        if user_ids.blank? || (user_ids.size.to_i == buzz.channel.subscriptions.size)
          message = "Buzz can be viewed by every members now!!"
        else
          user_ids.each do |user_id|
            buzz.buzz_members.create({:channel_id => buzz.channel_id, :user_id => user_id})
            buzz.root.descendants.each{|child| child.buzz_members.create({:channel_id => buzz.channel_id, :user_id => user_id})}
          end
          message = "Buzz has been limited successfully."
        end
      end
      return message
    rescue ActiveRecord::RecordInvalid => invalid
      return "Error limiting buzz"
    end
  end
end
