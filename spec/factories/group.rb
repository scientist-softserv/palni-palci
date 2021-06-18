FactoryBot.define do
  factory :group, class: Hyrax::Group do
    sequence(:name) { |_n| "group-#{srand}" }
    sequence(:humanized_name) { |_n| "Group #{name}" }
    sequence(:description) { |_n| "Somthing about group-#{srand}" }

    transient do
      member_users { [] }
      roles { [] }
    end

    after(:create) do |group, evaluator|
      evaluator.member_users.each do |user|
        group.add_members_by_id(user.id)
      end

      evaluator.roles.each do |role|
        group.roles << Role.find_or_create_by(
          name: role,
          resource_id: Site.instance.id,
          resource_type: 'Site'
        )
      end
    end

    factory :admin_group do
      name { 'admin' }
    end

    factory :registered_group do
      name { 'registered' }
    end

    factory :public_group do
      name { 'public' }
    end
  end
end
