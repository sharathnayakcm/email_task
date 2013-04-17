#require 'spec_helper'
#
#
#describe "capybara " do
#  subject {page}
#  before :all do
#    @user = create(:user,:email=>'san.feb@gmail.com',:password=>'password',:display_name =>'san')
#    @chan = create(:channel,:name=>"chan1",:user=>@user)
#    @cug = create(:cug,:name=>"cug1",:user=>@user)
#    @buzz = create(:buzz,:user=>@user,:channel=>@cug)
#    create(:setting)
#  end
#
#
#  it "navigation" do
#    visit "/users/sign_in"
#    should have_content("Login")
#  end
#
#  it "navigation" do
#    visit home_index_path
#    should have_content("Login")
#  end
#
#  describe  "login users" do
#
#    it "check for invalid",:js => true   do
#      visit home_index_path
#      fill_in 'user_email', :with=> 'ahana.feb@gmail.com'
#      fill_in 'user_password', :with =>  'root'
#      click_link('login')
#      should have_content("Invalid email or password")
#    end
#
#
#    it "check for valid users ",:js => true do
#      visit home_index_path
#      fill_in 'user_email', :with => 'san.feb@gmail.com'
#      fill_in 'user_password', :with => 'password'
#      click_link('login')
#      should have_content("Signed in successfully.")
#    end
#  end
#
#  describe "capybara test",:js => true do
#    before :each do
#      visit home_index_path
#      fill_in 'user_email', :with => 'san.feb@gmail.com'
#      fill_in 'user_password', :with => 'password'
#      click_link('login')
#    end
#
#    context "when visit home page" do
#      before{visit '/home/channels'}
#      it {should have_link('Logout') }
#      it {should have_link('Help') }
#
#      it "css" do
#        visit '/home/channels'
#        find(:css,"#command").click
#        find(:css, ".buzzout_img").click
#      end
#
#      it "checkbox"do
#        visit '/home/cugs'
#        check('core_sync_cug')
#        find('#core_sync_cug').should be_checked
#      end
#
#
#      it"has_selector"do
#        visit '/home/channels'
#        has_selector?('table tr')
#        has_xpath?('/html/body/div[2]/div/div[4]/div[2]/div/div[3]/form/fieldset/legend')
#      end
#
#      it"has_selector"do
#        visit '/home/channels'
#        has_selector?('table tr')
#        print page.html
#      end
#
#    end
#
#  end
#end