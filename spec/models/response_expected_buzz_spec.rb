require 'spec_helper'

describe ResponseExpectedBuzz do
  
  it { should belong_to(:user) }
  it { should belong_to(:buzz) }

  describe "#expiry date" do
    it{should validate_presence_of(:expiry_date)}
  end
end
