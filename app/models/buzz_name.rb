class BuzzName < ActiveRecord::Base
  belongs_to :user
  belongs_to :buzz

  validates :name, :presence => true
  validates_length_of :name, :maximum => 40
  validates_format_of :name, :with =>/^[A-Z\sa-z0-9_-]+$/i, :message => 'should be alphanumeric only.'

  #Add buzz name for a particular user
  def self.create_all_buzz_name(buzz,user_id,name)
    buzzes = buzz.root.subtree.pluck :id
    for buzz_id in buzzes
      buzz_name = BuzzName.create(:buzz_id => buzz_id, :user_id => user_id, :name => name )
    end
    buzz_name
  end

  #update buzz name for a particular user
  def self.update_all_buzz_name(buzz, user_id, name)
    where(:buzz_id => buzz.root.subtree.pluck(:id), :user_id => user_id).update_all(:name => name)
    BuzzName.where(:buzz_id => buzz.id, :user_id => user_id).first
  end
  
  #Deleting a buzz name for a buzz and its related children by a particular user
  def self.delete_buzz_name(buzz, user)
    buzzes = buzz.root.subtree
    for rbuzz in buzzes
      buzz_name = rbuzz.buzz_names.where("user_id = ?", user.id).first
      buzz_name.destroy if buzz_name
    end
  end  
end