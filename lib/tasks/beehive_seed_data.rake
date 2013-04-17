def ask message
  print message
  STDIN.gets.chomp
end

def create_beehive_views
  BeehiveView.delete_all
  channel_views = {"My Channels" => "my_channels", "Other Channels" => "other_channels", "New Channels" => "new_channels", "Favorite Channels" => "fav_channels", "Today Channels" => ""}
  cug_views = {"Priority" => "", "Action" => "", "Moderated" => "owner_cugs", "Favorite" => "fav_cugs", "Today" => "", "Flags" => ""}
  old_views = BeehiveView.all.map{|v| v.view_name}

  channel_views.each do |cv|
    show_insync = cv[1].blank? ? true : false
    BeehiveView.create(:view_name => cv[0],:view_type => "default",:view_for => 'channel',:owner_id => nil, :view_scope => cv[1], :show_insync => show_insync, :parametrized_link => "/buzzs?channel_id=[channel_id]&channel_view_type=[channel_type]")
  end
  
  cug_views.each do |cgv|
    show_insync = (cgv[1].blank? && cgv[0] == "Today") ? true : false
    BeehiveView.create(:view_name => cgv[0],:view_type => "default",:view_for => 'cug',:owner_id => nil, :view_scope => cgv[1], :show_insync => show_insync, :parametrized_link => "/buzzs?channel_id=[channel_id]&cug_view_type=[cug_type]")
  end
  views = BeehiveView.all.map{|v| v.view_name}
  puts "\n\n Total #{views.count - old_views.count} views created \n\n #{views}"
end

def create_action_cug_child_view
  action_child_views = {"Priority" => "priority_cugs","Response Expected from you" => "responce_expected_cugs", "Awaiting Responses" => "awaiting_responses_cugs" , "Dozz" => "dozz_cugs", "Dormant" => "dormant_cugs", "Normal" => "normal_cugs"}
  action_view = BeehiveView.where(:view_name => "Action").first
  action_child_views.each do |av|
    path = av[0] == "Dozz" ? "/buzz_tasks/cug_channel_tasks?channel_id=[channel_id]&is_channel=true&cug_view_type=[cug_type]" : "/buzzs?channel_id=[channel_id]&cug_view_type=[cug_type]"
    BeehiveView.create(:view_name => av[0], :view_type => "default", :view_for => 'cug', :owner_id => nil, :ancestry => action_view.id, :view_scope => av[1], :parametrized_link => path)
  end
end

def create_priority_cug_child_view
  priority_child_views = {"Core CUGs" => "core_cugs", "Peripheral CUGs" => "peripheral_cugs"}
  priority_view = BeehiveView.where(:view_name => "Priority").first
  priority_child_views.each do |pv|
    BeehiveView.create(:view_name => pv[0], :view_type => "default", :view_for => 'cug', :owner_id => nil, :ancestry => priority_view.id, :view_scope => pv[1], :parametrized_link => "/buzzs?channel_id=[channel_id]&cug_view_type=[cug_type]")
  end
end

def create_today_cug_child_view
  todays_child_views = {"CUGs Buzzed By Me " => "today_cugs_buzzed_me", "CUGs Buzzed By Others" => "today_cugs"}
  today_view = BeehiveView.where(:view_name => "Today").first
  todays_child_views.each do |pv|
    BeehiveView.create(:view_name => pv[0], :view_type => "default", :view_for => 'cug', :owner_id => nil, :ancestry => today_view.id, :view_scope => pv[1], :parametrized_link => "/buzzs?channel_id=[channel_id]&cug_view_type=[cug_type]")
  end
end

def create_flag_cug_child_view
  flags_child_views = {"Red" => "red_flag", "Green" => "green_flag","Blue" => "blue_flag","Orange" => "orange_flag","Yellow" =>"yellow_flag"}
  flag_view = BeehiveView.where(:view_name => "Flags").first
  flags_child_views.each do |pv|
    BeehiveView.create(:view_name => pv[0], :view_type => "default", :view_for => 'cug', :owner_id => nil, :ancestry => flag_view.id, :view_scope => pv[1], :parametrized_link => "/buzzs?channel_id=[channel_id]&cug_view_type=[cug_type]")
  end
end

def create_today_channel_child_view
  todays_child_views = {"Channels Buzzed By Me" => "today_channels_buzzed_me", "Channels Buzzed By Others" => "today_channels_buzzed"}
  today_view = BeehiveView.where(:view_name => "Today Channels").first
  todays_child_views.each do |pv|
    BeehiveView.create(:view_name => pv[0], :view_type => "default", :view_for => 'channel', :owner_id => nil, :ancestry => today_view.id, :view_scope => pv[1], :parametrized_link => "/buzzs?channel_id=[channel_id]&channel_view_type=[channel_type]")
  end
end


namespace :beehive do
  namespace :user do
    task :admin => :environment do
      first_name = ask('Please enter first name = ')
      last_name = ask('Please enter last name = ')
      password = ask('Please enter password = ')
      email = ask('Please enter your email id = ')
      if !email.empty?
        User.delete_all
        user = User.new(:first_name => first_name, :last_name => last_name, :email => email,:dozz_email => email, :password => password, :display_name => "admin",:is_admin => true)
        user.skip_confirmation!
        user.save
        user_preference = UserPreference.create(:user_id => user.id, :buzz_rate_1 => 24, :buzz_rate_2 => 72)
        Setting.delete_all
        Setting.create(:company_info => { :domain_name => "sumerusolutions.com"})
        puts "Congratulation. Admin created with email #{email} and password #{password}."
      else
        puts "Ahh!!! Please specify email for admin user."
      end
    end

    task :default_preference => :environment do
      User.all.each do |u|
        user_preference = UserPreference.create({:user_id => u.id,:buzz_rate_1 => '24', :buzz_rate_2 => '72'})
        user_preference.save
      end
    end

    # rake task to update dozz email
    task :update_dozz_email => :environment do
      User.where("dozz_email is null or dozz_email = ''").all.each do |c|
        c.update_attributes(:dozz_email => c.email)
      end
    end

    # rake task to make entry of all moderator
    namespace :subscribe do
      task :moderators => :environment do
        Channel.all.each do |c|
          #if !Subscription.find_by_channel_id_and_user_id c.id, c.user_id
          unless Subscription.where(:channel_id => c.id, :user_id => c.user_id).first
            Subscription.create(:channel_id => c.id, :user_id => c.user_id)
          end
        end
      end
    end

    # rake task to update user preferences
    namespace :user_cug_and_channel do  desc "update the default cug view and channel view"
      task :update_default_view => :environment do
        UserPreference.where("cug_view is null or cug_view = ''").all.each do |c|
          c.update_attributes(:cug_view => BeehiveView.default_cug_view.id)
        end
        UserPreference.where("channel_view is null or channel_view = ''").all.each do |c|
          c.update_attributes(:channel_view => BeehiveView.default_channel_view.id)
        end
      end
    end
  end ## end of user namespace

  namespace :default_view do
    desc "Default view namespace"
    task :setup => :environment do
      desc " Creating beehive default views and setting up default view for users"
      create_beehive_views
      create_priority_cug_child_view
      create_today_cug_child_view
      create_flag_cug_child_view
      create_today_channel_child_view
      create_action_cug_child_view
      default_channel_view = BeehiveView.where(:view_name => "New Channels").first.id
      default_cug_view = BeehiveView.where(:view_name => "Action").first.id
      UserPreference.all.each{ |c| c.update_attributes(:cug_view =>  default_cug_view) }
      UserPreference.all.each{ |c| c.update_attributes(:channel_view => default_channel_view) }
    end
  end ## end of default view namespace
end


