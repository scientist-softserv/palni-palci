require 'spec_helper'

require 'cancan/matchers'

RSpec.describe WorkAuthorization, type: :model do
  let(:work) { FactoryBot.create(:generic_work) }
  let(:borrowing_user) { FactoryBot.create(:user) }
  let(:ability) { ::Ability.new(borrowing_user) }

  describe '.authorize!' do
    it 'gives the borrowing user the ability to "read" the work' do
      # We re-instantiate an ability class because CanCan caches many of the ability checks.  By
      # both passing the id and reinstantiating, we ensure that we have the most fresh data; that is
      # no cached ability "table" nor cached values on the work.
      expect { described_class.authorize!(user: borrowing_user, work_pid: work.id) }
        .to change { ::Ability.new(borrowing_user).can?(:read, work.id) }.from(false).to(true)
    end

    context 'when the work_pid is not found' do
      it 'raises a WorkAuthorization::WorkNotFoundError' do
        expect { described_class.authorize!(user: borrowing_user, work_pid: "oh-so-404") }.to raise_error(WorkAuthorization::WorkNotFoundError)
      end
    end
  end

  describe '.revoke!' do
    it 'revokes an authorized user from being able to "read" the work' do
      # Ensuring we're authorized
      described_class.authorize!(user: borrowing_user, work_pid: work.id)

      expect { described_class.revoke!(user: borrowing_user, work_pid: work.id) }
        .to change { ::Ability.new(borrowing_user).can?(:read, work.id) }.from(true).to(false)
    end

    it 'gracefully handles revocation of non-existent works' do
      expect(described_class.revoke!(user: borrowing_user, work_pid: "oh-so-404")).to be_truthy
    end

    it 'gracefully handles revoking that which was never authorized' do
      expect { described_class.revoke!(user: borrowing_user, work_pid: work.id) }
        .not_to change { ::Ability.new(borrowing_user).can?(:read, work.id) }.from(false)
    end
  end

  xdescribe 'adding errors' do
    let(:authorization) { WorkAuthorization.new }

    it 'adds the error' do
      authorization.update_error 'test error'
      expect(authorization.error).to eq('test error')
    end

    it 'clears error' do
      authorization.update_error 'test error'
      authorization.clear_error
      expect(authorization.error).to eq(nil)
    end
  end
end
