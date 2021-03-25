require 'cancan/matchers'

RSpec.describe 'UserAbility' do
  subject { ability }

  let(:ability) { Ability.new(current_user) }
  let(:user) { create(:user) }
  let(:current_user) { user }

  context 'when user admin' do
    subject { Ability.new(user_admin) }
    let(:user_admin) { FactoryBot.create(:user_admin) }

    it 'allows all abilities' do
      is_expected.to be_able_to(:manage, user)
      is_expected.to be_able_to(:manage, user_admin)
    end
  end

  context 'when user manager' do
    subject { Ability.new(user_manager) }
    let(:user_manager) { FactoryBot.create(:user_manager) }

    it 'allows most abilities' do
      is_expected.to be_able_to(:create, User)
      is_expected.to be_able_to(:read, user)
      is_expected.to be_able_to(:update, user)
      is_expected.to be_able_to(:edit, user)
      is_expected.to be_able_to(:destroy, user)
      # TODO: create ability to manage self
      # is_expected.to be_able_to(:manage, user_manager)
    end

    it 'denies become ability' do
      is_expected.not_to be_able_to(:become, user)
    end
  end

  context 'when user reader' do
    subject { Ability.new(user_reader) }
    let(:user_reader) { FactoryBot.create(:user_reader) }

    it 'allows read ability' do
      is_expected.to be_able_to(:read, user)
      # TODO: create ability to manage self
      # is_expected.to be_able_to(:manage, user_reader)
    end

    it 'denies most abilities' do
      is_expected.not_to be_able_to(:create, User)
      is_expected.not_to be_able_to(:destroy, user)
      is_expected.not_to be_able_to(:become, user)
      is_expected.not_to be_able_to(:edit, user)
      is_expected.not_to be_able_to(:update, user)
    end
  end

end