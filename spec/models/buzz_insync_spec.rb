require 'spec_helper'

describe BuzzInsync do

  it {should belong_to(:channel)}
  it {should belong_to(:user)}
  it {should belong_to(:buzz)}


  describe '.insync' do
    before(:all) do
      @buzz_ram = create(:user, :first_name =>'buzzram')
      @buzz_chan = create(:channel, :name=>"buzzchan", :user=>@buzz_ram)
      @buzz_chan1 = create(:channel, :name=>"buzzchan12", :user=>@buzz_ram)
      @buzz = create(:buzz, :user=>@buzz_ram, :channel=>@buzz_chan)
      @buzz_in = create(:buzz_insync, :buzz=>@buzz, :user=>@buzz_ram, :channel=>@buzz_chan)
      @buzz2 = create(:buzz, :user=>@buzz_ram, :channel=>@buzz_chan)
    end

    context "with valid user for the channel" do
      let(:insync_buzz) { BuzzInsync.insync(@buzz_chan.id, @buzz.id, @buzz_ram) }

      it 'should update the existing buzz_iysnc' do
        expect{ insync_buzz }.to change(BuzzInsync, :count).by(0)
      end

      it {insync_buzz.should eql true }
    end

    context "with invalid user for the channel" do
      let(:insync_buzz) { BuzzInsync.insync(@buzz_chan1.id, @buzz.id, @buzz_ram) }

      it 'should create new buzz isync record' do
        expect {insync_buzz}.to change(BuzzInsync, :count).by(1)
      end

    end
  end
end
