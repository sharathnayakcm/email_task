require 'spec_helper'

describe PriorityBuzz do
  
  it { should belong_to(:user) }
  it { should belong_to(:buzz) }
end
