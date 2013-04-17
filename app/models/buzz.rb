require 'file_size_validator'
class Buzz < ActiveRecord::Base

  belongs_to  :channel, :inverse_of => :buzzs
  belongs_to  :user
  has_many    :buzz_insyncs, dependent: :destroy
  has_many    :buzz_members, dependent: :destroy
  has_many    :buzz_tags, dependent: :destroy
  has_many    :tags, :through => :buzz_tags
  has_many    :buzz_flags, dependent: :destroy
  has_many    :buzz_names, dependent: :destroy
  delegate    :full_name, :to => :user
  has_ancestry orphan_strategy: :destroy
  has_many :tags, through: :buzz_tags
  has_many :responded_users, :through => :response_expected_buzzs, :source =>:user
  has_many :response_expected_buzzs
  has_many :priority_buzzs
  has_many :priority_buzz_users, :through => :priority_buzzs, :source =>:user, :conditions => "priority_buzzs.insync = false"
  has_many :buzz_members_details, :through => :buzz_members, :source =>:user

  has_many :buzz_tasks, dependent: :destroy, :inverse_of => :buzz
  accepts_nested_attributes_for :buzz_tasks, :allow_destroy => true
  accepts_nested_attributes_for :buzz_names,  :allow_destroy => true
  accepts_nested_attributes_for :response_expected_buzzs,  :allow_destroy => true, :reject_if => proc {|attr| attr[:user_id] == '0'}
  accepts_nested_attributes_for :priority_buzzs,  :allow_destroy => true, :reject_if => proc {|attr| ((attr[:user_id] == '0' || attr[:user_id].blank?) && attr[:expiry_date].blank?) }

  
  #accepts_nested_attributes_for :buzz_flags, :reject_if => proc { |attributes| attributes['flag_id'].blank? },  :allow_destroy => true
  #  accepts_nested_attributes_for :buzz_members, :reject_if => proc { |attributes| attributes['user_id'].blank? }, :allow_destroy => true
  #  accepts_nested_attributes_for :buzz_tags, :allow_destroy => true
  attr_accessor :is_richtext_editor

  validates :message, :presence => true, :length => { :maximum => 365 }, :if => :is_richtext_editor_check
  validates :channel, :presence => true
  validates :user_id, :presence => true, :numericality => true

  default_scope :order => 'buzzs.id DESC'

  scope :out_of_sync, proc {|last_insynced_id| where('buzzs.id > (?)', last_insynced_id)}
  scope :in_sync, proc {|last_insynced_id| where('buzzs.id <= (?)', last_insynced_id)}
  
  scope :limited_buzzs, lambda{|user_id, channel_id|
    joins('left outer join buzz_members on buzzs.id = buzz_members.buzz_id').
      where('buzzs.channel_id = ? and (buzz_members.user_id = ? or buzz_members.user_id is null)', channel_id, user_id)
  }

#  scope :limited_buzzs_count_for_cugs, lambda{|user_id, channel_id|
#    joins('left outer join buzz_members on buzzs.id = buzz_members.buzz_id').
#      where('buzzs.channel_id = ? and buzzs.user_id !=?  and (buzz_members.user_id = ? or buzz_members.user_id is null)', channel_id, user_id, user_id)
#  }

  mount_uploader :attachment, AttachmentUploader
  validates :attachment, :file_size => { :maximum => 10.megabytes.to_i }

  def is_richtext_editor_check
    return false unless self.is_richtext_editor == "true"
  end

  #checks whether a flag is checked by the user
  def buzz_flag_checked(flag,user)
    BuzzFlag.select('id, expiry_date').where('buzz_id = ? and flag_id = ? and user_id = ? and (expiry_date >= ? or expiry_date is Null)',self.id, flag.id, user.id, Date.today).first
  end

  #getting the attachment url for the buzz
  def getting_attachment_name
    url = self.attachment.url
    "#{File.basename(url, '.*').truncate(15, :omission => '...')}.#{File.extname(url)}" if url.present?
  end

  #getting the buzz name for the buzz
  def getting_buzz_name(user)
    user.buzz_names.select("id, name").where('buzz_id = ?', self.id).first
  end

  def set_rezz_name(user)
    buzz_names = self.root.buzz_names.where('user_id = ?', user.id).first
    BuzzName.create(:user_id => user.id, :buzz_id => self.id, :name => buzz_names.name) if buzz_names
  end

  #getting buzz limted user names
  def get_buzz_limited_member_names(buzz_members)
    user_name = []
    buzz_members.each{|member| user_name << member.user.full_name}
    user_name.join(' , ')
  end

  def rezz?
    self.ancestry ? true :false
  end

  def rezzed_users
    self.root.descendants.all.map{|b| b.user_id if b.user_id != self.user_id.to_i}
  end

  def buzzed_users
    self.root.descendants.all.map{|b| b.user_id}
  end

  #limiting the members for rezzs
  def save_rezz_members buzz
    buzz.buzz_members.each{|member| self.buzz_members.create({:channel_id => buzz.channel_id, :user_id => member.user_id})}
  end

  def is_priority_buzz(user_id)
    PriorityBuzz.select("id").where("buzz_id = ? and (owner_id = ? or user_id = ?)",self.id, user_id, user_id)
  end


  def is_response_expected(user_id)
    ResponseExpectedBuzz.select("id").where("buzz_id = ? and user_id = ?",self.id, user_id).first
  end

  def is_awaiting_response(user_id)
    ResponseExpectedBuzz.select("id").where("buzz_id = ? and owner_id = ?",self.id, user_id)
  end


#  def is_owners_priority_buzz(user_id)
#    PriorityBuzz.owner_priority_buzz(self.id,user_id).count > 0
#  end

  def is_user_insync?(user_id)
    BuzzInsync.where("buzz_id = ? and user_id = ?",self.id,user_id).first.present?
  end

  def self.channel_buzzout(channel, buzz_msg, user, attachment = nil)
    msg = []
    if channel.nil?
      msg << "CUG/Channel doesn't exist or inactive"
    else
      if channel.is_admin?(user) || channel.is_subscribed?(user)
        buzz = Buzz.new(:message => buzz_msg, :channel_id => channel.id, :user_id => user.id, :attachment => attachment)
        buzz.save ? msg << "Buzzed out to #{channel.channel_or_cug} \"#{channel.name}\" successfully" : buzz.errors.full_messages.each{|e| msg << "#{e}" unless msg.include?(e)}
      else
        msg << "You must be subscribed to or owner of the #{channel.channel_or_cug} \"#{channel.name}\""
      end
    end
    return msg
  end

  def self.check_filters(params, buzzs, user)
    buzzs = buzzs.joins(:priority_buzzs).where("priority_buzzs.owner_id = #{user} or priority_buzzs.user_id = #{user}") if params[:priority_filter]
    buzzs = buzzs.where("attachment is not null") if params[:with_attachment_filter]
    if params[:awaiting_for_response_filter]
      buzzs = if params[:awaiting_for_response_filter_user]
        ids = params[:awaiting_for_response_filter_user].map(&:to_i)
        buzzs.joins(:response_expected_buzzs).where("response_expected_buzzs.owner_id = #{user} and response_expected_buzzs.user_id in (?)", ids)
      else
        buzzs.joins(:response_expected_buzzs).where("response_expected_buzzs.owner_id = #{user}")
      end
    end
     if params[:response_expected_filter]
      buzzs = if params[:response_expected_filter_user]
        ids = params[:response_expected_filter_user].map(&:to_i)
        buzzs.joins(:response_expected_buzzs).where("response_expected_buzzs.user_id = #{user} and response_expected_buzzs.owner_id in (?)", ids)
      else
        buzzs.joins(:response_expected_buzzs).where("response_expected_buzzs.user_id = #{user}")
      end
    end
    return buzzs
  end
end