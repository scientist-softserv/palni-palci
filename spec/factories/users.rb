# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: User do
    sequence(:email) { |_n| "email-#{srand}@test.com" }
    password { 'a password' }
    password_confirmation { 'a password' }

    transient do
      roles { [] }
    end

    after(:create) do |user, evaluator|
      evaluator.roles.each do |role|
        user.add_role(role, Site.instance)
      end
    end

    factory :admin do
      before(:create) do |user|
        user.add_role(:admin, Site.instance)
      end

      after(:build) do |user|
        user.add_role(:admin, Site.instance)
      end
    end

    factory :superadmin do
      before(:create) { |user| user.add_role(:superadmin) }
      after(:build)   { |user| user.add_role(:superadmin) }
    end

    factory :user_admin do
      before(:create) { |user| user.add_role(:user_admin) }
      after(:build)   { |user| user.add_role(:user_admin) }
    end

    factory :user_manager do
      before(:create) { |user| user.add_role(:user_manager) }
      after(:build)   { |user| user.add_role(:user_manager) }
    end

    factory :user_reader do
      before(:create) { |user| user.add_role(:user_reader) }
      after(:build)   { |user| user.add_role(:user_reader) }
    end

    factory :collection_manager do
      before(:create) do |user|
        user.add_role(:collection_manager, Site.instance)
      end

      after(:build) do |user|
        user.add_role(:collection_manager, Site.instance)
      end
    end

    factory :collection_editor do
      before(:create) do |user|
        user.add_role(:collection_editor, Site.instance)
      end

      after(:build) do |user|
        user.add_role(:collection_editor, Site.instance)
      end
    end

    factory :collection_reader do
      before(:create) do |user|
        user.add_role(:collection_reader, Site.instance)
      end

      after(:build) do |user|
        user.add_role(:collection_reader, Site.instance)
      end
    end

    factory :invited_user do
      after(:create, &:invite!)
    end

    factory :guest_user do
      guest { true }

      transient do
        stale { false }
      end

      after(:create) do |guest_user, evaluator|
        guest_user.update!(updated_at: 8.days.ago) if evaluator.stale
      end
    end
  end
end
