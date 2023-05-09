# frozen_string_literal: true

FactoryBot.define do
  factory :etd do
    transient do
      user { FactoryBot.create(:user) }
    end

    title { ['title'] }
    institution { 'institution' }
    creator { ['creator'] }
    degree { ['bachelor of arts'] }
    level { ['level'] }
    discipline { ['discipline'] }
    degree_granting_institution { ['degree_granting_institution'] }

    factory :etd_with_one_file do
      before(:create) do |work, evaluator|
        work.ordered_members << FactoryBot.create(:file_set,
                                                  user: evaluator.user,
                                                  title: ['A Sample ETD with file'])
      end
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user)
    end
  end
end