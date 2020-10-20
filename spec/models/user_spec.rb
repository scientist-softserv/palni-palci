RSpec.describe User, type: :model do
  context 'the first created user in global tenant' do
    subject { FactoryBot.create(:user) }

    before do
      allow(Account).to receive(:global_tenant?).and_return true
    end

    it 'does not get the admin role' do
      expect(subject).not_to have_role :admin
      expect(subject).not_to have_role :admin, Site.instance
    end
  end

  context 'the first created user on a tenant' do
    subject { FactoryBot.create(:user) }

    it 'is not given the admin role' do
      expect(subject).not_to have_role :admin
      expect(subject).not_to have_role :admin, Site.instance
    end
  end

  context 'a subsequent user' do
    let!(:first_user) { FactoryBot.create(:user) }
    let!(:next_user) { FactoryBot.create(:user) }

    it 'is not given the admin role' do
      expect(next_user).not_to have_role :admin
      expect(next_user).not_to have_role :admin, Site.instance
    end
  end

  describe '#site_roles' do
    subject { FactoryBot.create(:admin) }

    it 'fetches the global roles assigned to the user' do
      expect(subject.site_roles.pluck(:name)).to match_array ['admin']
    end
  end

  describe '#site_roles=' do
    subject { FactoryBot.create(:user) }

    it 'assigns global roles to the user' do
      expect(subject.site_roles.pluck(:name)).to be_empty

      subject.update(site_roles: ['admin'])

      expect(subject.site_roles.pluck(:name)).to match_array ['admin']
    end

    it 'removes roles' do
      subject.update(site_roles: ['admin'])
      subject.update(site_roles: [])
      expect(subject.site_roles.pluck(:name)).to be_empty
    end
  end

  describe '#enrolled_hyrax_groups' do
    subject { FactoryBot.create(:user) }

    it 'returns an array of Hyrax::Groups' do
      expect(subject.enrolled_hyrax_groups).to be_an_instance_of(Array)
      expect(subject.enrolled_hyrax_groups.first).to be_an_instance_of(Hyrax::Group)
    end
  end

  describe '#groups' do
    subject { FactoryBot.create(:user) }

    before do
      FactoryBot.create(:group, name: 'group1', member_users: [subject])
    end

    it 'returns the names of the Hyrax::Groups the user is a member of' do
      expect(subject.groups).to include('group1')
    end
  end

  describe '#add_default_group_memberships!' do
    context 'when the user is a new user' do
      subject { FactoryBot.build(:user) }

      it 'is called after a user is created' do
        expect(subject).to receive(:add_default_group_memberships!)

        subject.save!
      end
    end

    context 'when the user is a guest user' do
      subject { FactoryBot.build(:guest_user) }

      it 'adds the user as a member of the registered Hyrax::Group' do
        expect(subject.groups).to eq([])

        subject.save!

        expect(subject.groups).to contain_exactly('public')
      end
    end

    context 'when the user is a registered user' do
      subject { FactoryBot.build(:user) }

      it 'adds the user as a member of the registered Hyrax::Group' do
        expect(subject.groups).to eq([])

        subject.save!

        expect(subject.groups).to contain_exactly('registered', 'public')
      end
    end

    context 'when the user is an admin user' do
      subject { FactoryBot.build(:admin) }

      it 'adds the user as a member of the registered Hyrax::Group' do
        expect(subject.groups).to eq([])

        subject.save!

        expect(subject.groups).to contain_exactly('admin', 'registered', 'public')
      end
    end
  end
end
