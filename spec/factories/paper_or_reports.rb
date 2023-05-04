# frozen_string_literal: true

FactoryBot.define do
  factory :paper_or_report do
    transient do
      user { FactoryBot.create(:user) }
    end

    title { ["title"] }
    institution { "institution" }
    creator { ["creator"] }
    date_created { "2002" }

    factory :paper_or_report_with_one_file do
      before(:create) do |work, evaluator|
        work.ordered_members << FactoryBot.create(:file_set,
                                                  user: evaluator.user,
                                                  title: ['A Sample Paper or Report with file'])
      end
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user)
    end
  end
end
