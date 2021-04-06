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
    end
  end

  context 'when user manager' do
    subject { Ability.new(user_manager) }
    let(:user_manager) { FactoryBot.create(:user_manager) }

    it 'allows most abilities' do
      is_expected.to be_able_to(:create, User)
      is_expected.to be_able_to(:create, user)
      is_expected.to be_able_to(:read, user)
      is_expected.to be_able_to(:update, user)
      is_expected.to be_able_to(:edit, user)
      is_expected.to be_able_to(:destroy, user)
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
      is_expected.to be_able_to(:manage, user_reader)
    end

    it 'denies most abilities' do
      is_expected.not_to be_able_to(:destroy, user)
      is_expected.not_to be_able_to(:become, user)
      is_expected.not_to be_able_to(:edit, user)
      is_expected.not_to be_able_to(:update, user)
      is_expected.not_to be_able_to(:create, user)
    end
  end

  context 'when superadmin' do
    subject { Ability.new(superadmin) }
    let(:superadmin) { FactoryBot.create(:superadmin) }

    it 'allows all abilities' do
      is_expected.to be_able_to(:read, user)
      is_expected.to be_able_to(:create, User)
      is_expected.to be_able_to(:destroy, user)
      is_expected.to be_able_to(:become, user)
      is_expected.to be_able_to(:edit, user)
      is_expected.to be_able_to(:update, user)
    end
  end

  context 'when registered user' do
    subject { Ability.new(current_user) }
    let(:current_user) { FactoryBot.create(:user) }

    it 'allows all self abilities' do
      is_expected.to be_able_to(:create, User)
      is_expected.to be_able_to(:edit, current_user)
      is_expected.to be_able_to(:update, current_user)
      is_expected.to be_able_to(:destroy, current_user)
      is_expected.to be_able_to(:read, current_user)
    end

    it 'denies most abilities' do
      is_expected.not_to be_able_to(:create, user)
      is_expected.not_to be_able_to(:read, user)
      is_expected.not_to be_able_to(:update, user)
      is_expected.not_to be_able_to(:edit, user)
      is_expected.not_to be_able_to(:destroy, user)
      is_expected.not_to be_able_to(:become, user)
    end
  end

  context 'when registered user' do
    subject { Ability.new(guest_user) }
    let(:guest_user) { FactoryBot.create(:guest_user) }

    it 'allows all self abilities' do
      is_expected.to be_able_to(:create, guest_user)
    end

    it 'denies most abilities' do
      is_expected.not_to be_able_to(:create, user)
      is_expected.not_to be_able_to(:read, user)
      is_expected.not_to be_able_to(:update, user)
      is_expected.not_to be_able_to(:edit, user)
      is_expected.not_to be_able_to(:destroy, user)
      is_expected.not_to be_able_to(:become, user)
    end
  end

end