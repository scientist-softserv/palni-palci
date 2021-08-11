# frozen_string_literal: true

# NOTE: If want to run spec in browser, you have to set "js: true"
RSpec.describe 'Creating a new Work', type: :feature, clean: true, cohort: 'bravo' do
  let(:user) { create(:user) }

  before do
    FactoryBot.create(:registered_group)
    FactoryBot.create(:admin_group)
    AdminSet.find_or_create_default_admin_set_id
    login_as user, scope: :user
  end

  # TODO: unskip when Work roles are completed
  xit 'creates the work' do
    visit '/'
    click_link "Share Your Work"
    expect(page).to have_button "Create work"
  end
end
