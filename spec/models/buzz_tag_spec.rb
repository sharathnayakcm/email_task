require 'spec_helper'

describe BuzzTag do

  context "This will create the buzz tag and return buzz tag ids" do
    before{@buzz = create(:buzz)
            @tag = create(:tag)
    }
    it{BuzzTag.add_buzz_tag(@buzz,@tag.id).should be_instance_of(BuzzTag) }
  end
end
