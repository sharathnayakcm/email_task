require 'spec_helper'

describe BuzzFlag do

  it{should belong_to(:buzz)}
  it{should belong_to(:user)}
  it{should belong_to(:flag)}
  
  before {
    @user = create(:user)
    @buzz = create(:buzz,:user=>@user)
    @buzz_flag = create(:buzz_flag,:user=>@user,:buzz=>@buzz)
  }

end
