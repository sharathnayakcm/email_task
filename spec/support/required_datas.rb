module RequiredData
  
  def self.users_datas
    @user_a = create(:user,:first_name=>"user_a")
    @user_b = create(:user,:first_name=>"user_b")
    @user_c = create(:user,:first_name=>"user_c")
    @user_d = create(:user,:first_name=>"user_d")

    @chan_a = create(:channel,:user=>@user_a)
    @chan_b = create(:channel,:user=>@user_b)

    @buzz_a =  create(:buzz,:user=>@user_a,:channel=>@chan_a)
    @buzz_b =  create(:buzz,:user=>@user_b,:channel=>@chan_b)
    
    create(:subscription,:user =>@user_a,:channel=>@chan_a)
    create(:subscription,:user =>@user_d,:channel=>@chan_a)
    create(:subscription,:user =>@user_b,:channel=>@chan_b)
    create(:subscription,:user =>@user_c,:channel=>@chan_a)
  end

end
