# To change this template, choose Tools | Templates
# and open the template in the editor.
FactoryGirl.define do


  factory :user do |f|
    f.sequence(:first_name) { |n| "foo#{n}" }
    f.sequence(:last_name) { |n| "last#{n}" }
    f.password "foobar"
    f.password_confirmation { |u| u.password }
    f.sequence(:email) { |n| "foo#{n}@in.com" }
    f.is_admin false
    f.sequence(:display_name) {|n| "some#{n}"}
    f.confirmed_at Time.now
    f.sequence(:dozz_email) { |n| "dozz#{n}@in.com" }
    f.dormant_days 2
  end


  factory :admin,:parent => :user do |f|
    f.is_admin true
  end

  factory :channel do |f|
    f.sequence(:name) {|n| "channel#{n}"}
    f.is_cug false
    f.association :user
    f.description "this is testing "
  end

    factory :cug,:parent => :channel do |f|
    f.is_cug true
  end

  factory :subscription do |f|
    f.association :user
    f.association :channel
    f.last_viewed Time.now
    f.is_core true
  end

  factory :buzz do |f|
    f.sequence(:message) {|n| "this is buzz#{n}"}
    f.association :user
    f.association :channel
    f.ancestry nil
  end

  factory :watch_channel do |f|
    f.association :user
    f.association :channel
  end

  factory :channel_alias do |f|
    f.sequence(:name) {|n| "alias#{n}"}
    f.association :user
    f.association :channel
  end

  factory :buzz_insync do |f|
    f.association :buzz
    f.association :user
    f.association :channel
  end

  factory :tag do |f|
    f.sequence(:name) {|n| " tag#{n}"}
    f.association :channel

  end
  factory :setting do |f|
    f.company_info :domain_name=>"gmail.com"
  end

  factory :channel_association do |f|
    f.association :channel
  end


  factory :buzz_member do |f|
    f.association :user
    f.association :channel
    f.association :buzz
  end

  factory :flag do |f|
    f.id 2
    f.name "red"
  end

  factory :buzz_flag do |f|
    f.association :buzz
    f.association :flag
    f.association :user
    f.expiry_date Date.today + 1.week
  end

  factory :buzz_name do |f|
    f.association :buzz
    f.association :user
    f.sequence(:name) { |n| "rails#{n}"}
  end

  factory :buzz_task do |f|
    f.association :user
    f.association :buzz
    f.sequence(:name) { |n| "tasks#{n}"}
    f.due_date Date.today + 2.days
    f.priority "medium"
    f.status false
  end

  factory :priority_buzz do |f|
    f.association :user
    f.association :buzz
    f.owner_id 1
    f.insync 1
  end

  factory :buzz_tag do |f|
    f.association :tag
    f.association :buzz
  end
 
  factory :response_expected_buzz do |f|
    f.association :user
    f.association :buzz
    f.owner_id 1
    f.expiry_date Date.tomorrow
  end
end

