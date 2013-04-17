require 'spec_helper'


describe "LOGIN USER " do
  subject {page}
  before :all do
    @sahana = create(:user,:email=>'sahana.feb@gmail.com',:password=>'password',:display_name =>'sahana')
    @suki = create(:user,:email=>'suki@gmail.com',:password=>'password',:display_name =>'suki')

    @chan = create(:channel,:name=>"chan1",:user=>@sahana)
    @chan2 = create(:channel,:name=>"chan2",:user=>@sahana)
    @chan3 = create(:channel,:name=>"chan3",:user=>@suki)

    @cug = create(:cug,:name=>"cug1",:user=>@sahana)
    @scug = create(:cug,:name=>"sukicug",:user=>@suki)

    @subscription = create(:subscription, :channel => @cug, :user => @suki)
    create(:subscription, :channel => @scug, :user => @sahana)

    @buzz = create(:buzz,:user=>@suki,:channel=>@cug)
    @buzz1 = create(:buzz,:user=>@suki,:channel=>@scug)
    @buzz2 = create(:buzz,:user=>@suki,:channel=>@scug)
    @buzz3 = create(:buzz,:user=>@sahana,:channel=>@cug)
    @buzz4 = create(:buzz,:user=>@sahana,:channel=>@chan)
    @buzz5 = create(:buzz,:user=>@suki,:channel=>@chan)

    @watch_chan = create(:watch_channel,:user=>@sahana,:channel=>@chan3)

    @tag = create(:tag,:name=>"tag",:channel=>@chan)
    @tag1 = create(:tag,:name=>"tag1",:channel=>@scug)

    create(:setting)
  end

  describe  "login with invalid users" do

    it "check for invalid",:js => true   do
      visit home_index_path
      fill_in 'user_email', :with=> 'ahana.feb@gmail.com'
      fill_in 'user_password', :with =>  'root'
      click_link('login')
      should have_content("Invalid email or password")
    end

    it "check for invalid password",:js => true   do
      visit home_index_path
      fill_in 'user_email', :with=> 'sahana.feb'
      fill_in 'user_password', :with =>  'ssword'
      click_link('login')
      should have_content("Invalid email or password")
    end

    it "check for blank ",:js => true   do
      visit home_index_path
      click_link('login')
      should have_content("Email can't be blank.")
    end


    it "check for valid users ",:js => true do
      visit home_index_path
      fill_in 'user_email', :with => 'sahana.feb'
      fill_in 'user_password', :with => 'password'
      click_link('login')
      should have_content("Signed in successfully.")
    end
  end

  describe "Dashboard page assuming channel is default view" ,:js => true do
    before :each do
      visit home_index_path
      fill_in 'user_email', :with => 'sahana.feb'
      fill_in 'user_password', :with => 'password'
      click_link('login')
    end

    context "when visit home page" do
      before{visit '/home/channels'}
      it {should have_link('Sahana') }
      it {should have_link('Dashboard') }
      it {should have_link('Logout') }
      it {should have_link('Help') }
      it { click_link('chan1')
        should have_content('You')
        find('#buzzes_list')
        should have_content(@buzz5.message)
      }
    end

    describe "Dashboard Tabs related links " do

      context "Dashboard Tabs must contain " do
        before{visit '/home/channels'}
        it {should have_link('Watch') }
        it {should have_link('Channels') }
        it {should have_link('CUGs') }
        it {should have_link('Today') }
        it {should have_link('Calendar') }
      end

      it "check the buzz box" do
        visit '/home/channels'
        find(:css,"#command").click
        find(:css, ".buzzout_img").click
      end


      context "when visit channel tab" do
        it { should have_content('Other Channels')}
        it { should have_content('My Channels')}
        it { should have_content('New Channels')}
      end

      context "channel tab " do
        it {should have_content('chan1')}
      end

      context "Watch page" do
        before {visit '/home'}
        it {should have_content('Watch')}
      end

      context "CUG page" do
        before {visit '/home/cugs'}
        it {should have_content('CUGs')}
      end

      context "Today page" do
        before { visit '/home/today'
        }
        it {should have_content('Today')}
      end

      context "check the Calendar page" do
        before {visit '/home/calendar'}
        it {should have_content('Calendar')}
        it {should have_content('From')}
        it {should have_content('To')}
      end

      context "check the Calendar page" do
        before {visit '/home/calendar'}
        it {should have_selector("input#from_date")}
        it {should have_selector("input#to_date")}
      end

    end
  end

  describe "User Profile page" ,:js => true do
    before :each do
      visit '/home'
      fill_in 'user_email', :with => 'sahana.feb'
      fill_in 'user_password', :with => 'password'
      click_link('login')
    end

    context "when visit my profile page" do
      before {visit edit_user_registration_path}
      it {should have_link('User') }
      it {should have_link('Moderator') }
      it {should have_link('Aliases') }
    end

    context "when visit my profile  user page " do
      before {visit edit_user_registration_path}
      it {should have_selector("li.selected", :text => "User")}
      it { should have_content("Default view")}
      it {should have_content('Change Password') }
      it { should have_selector("#user_email")}
    end

    context "when visit my profile moderator page" do
      before {visit '/users/moderator'}
      it {should have_selector("li.selected", :text => "Moderator")}
      it { should have_content('Moderated Channels')}
      it {should have_content('Moderated CUGs ')}
    end

    context "when visit My Profile - Channel Aliases" do
      before {visit '/users/aliases'}
      it {should have_selector("li.selected", :text => "Aliases")}
      it {should have_content('Channels Aliases')}
      it { should have_content('CUGs Aliases')}

    end
  end

  describe "CUG page ",:js => true do
    before :each do
      visit home_index_path
      fill_in 'user_email', :with => 'sahana.feb'
      fill_in 'user_password', :with => 'password'
      click_link('login')
    end

    context "cug tab should conatin " do
      before{visit '/home/cugs'}
      it { should have_link("Add CUG")}
      it{find("#formElem").find("a").should have_content('CUG Dashboard')  }
    end

    context  "Core and Peripheral CUG " do
      before {visit '/home/cugs'}
      it {
        should have_content("core CUG")
        should have_content("peripheral CUG")
        should have_content("You are Insync with all the buzzes of Peripheral CUGs.")
      }
    end

    context "find the check box" do
      before {
        visit '/home/cugs'
        check('core_sync_cug')
      }
      it {find('#core_sync_cug')}

      it{find('#core_sync_cug').should be_checked }
    end

    context "check box should not checked" do
      before { visit '/home/cugs'}
      it{ find('#core_sync_cug').should_not be_checked }
    end

    it "ADD CUG" do
      visit '/home/cugs'
      click_link('Add CUG')
      fill_in 'cug_name' ,:with=>"mycug"
      click_button('Add')
      should have_content("CUG mycug added successfully")
      click_link('mycug')
      should have_content('You')
    end

    context " In cug page " do

      before{
        visit '/home/cugs'
        click_link('sukicug')
      }

      it "checking the cug header tabs" do
        find('#watch')
        find('#involvement')
        should have_link('In Sync Stats')
        should have_link('CUG Stats')
        should have_link('Tags')
        should have_link('Flags')
        should have_link('Dozz')
      end
    end

    context "cug" do
      it "check cug buzz" do
        visit '/home/cugs'
        click_link(@scug.name)
        click_link('CUG Stats')
        find('.cug_insync_link')
        should have_content(@buzz1.message)
        find('.buzz_actions')
        find('.involvement').click


      end
    end

    context "cug" do
      it "check cug buzz" do
        visit '/home/cugs'
        click_link(@scug.name)
        click_link('In Sync Stats')
        find('.toggle_link')
        should have_content(@buzz1.message)
        find('.buzz_actions')
      end

      it "check cug tags" do
        visit '/home/cugs'
        click_link(@scug.name)
        click_link('Tags')
        should have_link('Clear Tag Filters')
        

      end
    end



  end

end

