#require 'spec_helper'
#
#describe ChannelAssociation do
#  it { should belong_to(:channel) }
#
#  describe 'validation' do
#    describe '#channel_id' do
#      it { should validate_presence_of(:channel_id) }
#      it { should validate_numericality_of(:channel_id) }
#    end
#
#    describe '#cug_id' do
#      it { should validate_presence_of(:cug_id) }
#      it { should validate_numericality_of(:cug_id) }
#      it do
#           ChannelAssociation.create(:channel_id => 1, :cug_id => 1)
#           should validate_uniqueness_of(:cug_id).scoped_to(:channel_id).
#            with_message(/^This CUG is already merged to this channel$/)
#      end
#    end
#  end
#
#  describe '.merge_channels' do
#    before(:each) do
#      @channel = FactoryGirl.create(:channel, :name=>"Mychannel")
#      @cug = FactoryGirl.create(:channel, :name=>"Mycug", :user=>@channel.user, :is_cug=>true)
#    end
#
#    context "when cug name is nil" do
#      it do
#       ChannelAssociation.merge_channels(nil, @channel.name, @channel.user).
#         should eql [["$CUG doesn't exist or is inactive or you are not owner of CUG", "$Problem in merging CUG  to Channel #{@channel.name}"], false]
#      end
#    end
#
#    context "when channel name is nil" do
#      it do
#       ChannelAssociation.merge_channels(@cug.name, nil, @channel.user).
#         should eql [["$Channel doesn't exist or is inactive", "$Problem in merging CUG #{@cug.name} to Channel "], false]
#      end
#    end
#
#    context "when user is invalid" do
#      it do
#       ChannelAssociation.merge_channels(@cug.name, @channel.name, User.new).
#         should eql [["$CUG doesn't exist or is inactive or you are not owner of CUG", "$Problem in merging CUG #{@cug.name} to Channel #{@channel.name}"], false]
#      end
#    end
#
#    context "when channel_assocation.save returns false" do
#      it 'should return validation errors' do
#        Channel.stub(:where).and_return([Channel.new(:is_cug => true)], [Channel.new])
#        ChannelAssociation.merge_channels('mycug', 'mychannel', User.new).
#          should eql [["$Channel can't be blank", "$Channel is not a number", "$Cug can't be blank", "$Cug is not a number"], false]
#      end
#    end
#
#    context 'when valid arumgents passed' do
#      let(:merging_channel) { ChannelAssociation.merge_channels(@cug.name, @channel.name, @channel.user) }
#      it { expect { merging_channel }.to change(ChannelAssociation, :count).by(1) }
#      it { merging_channel.should eql [["CUG #{@cug.name} merged successfully to Channel #{@channel.name}"], true] }
#    end
#  end
#end
