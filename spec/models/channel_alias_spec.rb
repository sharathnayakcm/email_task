require 'spec_helper'

describe ChannelAlias do
  it { should belong_to(:user) }
  it { should belong_to(:channel) }
  it { 
      create(:channel_alias) 
      should validate_uniqueness_of(:channel_id).scoped_to(:user_id).
        with_message(/^Alias for this channel already exists$/)
  }

  
  describe '.add_alias' do
    before(:all) { @channel = create(:channel) }

    context "when channel doesn't exist" do
      it { 
          ChannelAlias.add_alias("alias_channel", nil, false, User.new).
            should eql [["$Channel doesn't exist or is inactive."],false]
      }
    end

    context "when user is not owner or subscribed to" do
      it {
        ChannelAlias.add_alias("alias_channel", @channel.name, false, create(:user)).
        should eql [["$You must be subscribed to or owner of the Channel"],false]
      }
    end

    context 'when valid arguments passed' do
      let(:adding_alias) { ChannelAlias.add_alias("aliaschannel", @channel.name, false, @channel.user) }
      it { expect { adding_alias }.to change(ChannelAlias, :count).by(1) }
      it { adding_alias.first.should eql ["Channel alias aliaschannel added successfully"] }
    end
  end
end
#[["$Alias name should be alphanumeric only"], false]