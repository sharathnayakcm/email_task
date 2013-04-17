require 'spec_helper'

describe BuzzTask do
  it{should belong_to :buzz}
  it{should belong_to :user}

  it{should validate_presence_of(:name)}

  describe "expiry_date" do
    before{
      @user_a = create(:user,:first_name=>"aaa")
      @chan_a = create(:channel,:user=>@user_a)
      @buzz = create(:buzz,:user=>@user_a,:channel=>@chan_a)
      @task = create(:buzz_task,:buzz=>@buzz)
    }

    context"this will return task expiry date" do
      it{@task.expiry_date.should eql @task.due_date.strftime("%d %b %Y")}
    end

  end

  
end
