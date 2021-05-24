require 'rails_helper'

module Hyrax
  RSpec.describe Group, type: :model, clean: true do
    describe 'group with no members' do
      subject { described_class.new(name: name, description: description) }

      let(:name) { 'Empty Group' }
      let(:description) { 'Add members plz' }
      let(:empty_group_attributes) do
        {
          name: name,
          description: description,
          number_of_users: 0
        }
      end

      it { is_expected.to have_attributes(empty_group_attributes) }
      it { is_expected.to respond_to(:created_at) }
    end

    context '.search' do
      context 'with a query' do
        before do
          FactoryBot.create(:group, humanized_name: 'IMPORTANT-GROUP-NAME')
          FactoryBot.create(:group, description: 'IMPORTANT-GROUP-DESCRIPTION')
          FactoryBot.create(:group, roles: ['important_people', 'test'])
        end

        it 'returns groups that match a query on a humanized name' do
          expect(described_class.search('IMPORTANT-GROUP-NAME').count).to eq(1)
        end

        it 'returns groups that match a query on a description' do
          expect(described_class.search('IMPORTANT-GROUP-DESCRIPTION').count).to eq(1)
        end

        it 'returns groups with a partial match' do
          expect(described_class.search('IMPORTANT-GROUP').count).to eq(2)
        end

        it 'returns an empty set when there is no match' do
          expect(described_class.search('NULL').count).to eq(0)
        end

        it 'returns groups that match a query on a role name' do
          expect(described_class.search('test').count).to eq(1)
          expect(described_class.search('important').count).to eq(3)
        end

        it 'is case-insensitive' do
          expect(described_class.search('important-group-name').count).to eq(1)
          expect(described_class.search('iMpOrTaNt').count).to eq(3)
          expect(described_class.search('TEST').count).to eq(1)
        end
      end

      context 'without a query' do
        before do
          FactoryBot.create(:group, humanized_name: 'Users')
          FactoryBot.create(:group, humanized_name: 'Depositors', roles: ['admin_set_depositor'])
          FactoryBot.create(:group, humanized_name: 'Readers', roles: ['user_reader'])
          FactoryBot.create(:group, humanized_name: 'Managers', roles: ['admin'])
          FactoryBot.create(:group, humanized_name: 'Editors', roles: ['collection_editor'])
        end

        it 'returns all groups' do
          expect(described_class.search(nil).count).to eq(5)
        end

        # See Role#set_sort_value
        it "orders groups by their roles' sort_value" do
          result = described_class.search(nil)

          expect(result[0].humanized_name).to eq('Managers')
          expect(result[1].humanized_name).to eq('Editors')
          expect(result[2].humanized_name).to eq('Depositors')
          expect(result[3].humanized_name).to eq('Readers')
          expect(result[4].humanized_name).to eq('Users')
        end
      end
    end

    context '#search_members' do
      subject { FactoryBot.create(:group) }

      let(:known_user_name) { FactoryBot.create(:user, display_name: 'Tom Cramer') }
      let(:known_user_email) { FactoryBot.create(:user, email: 'tom@project-hydra.com') }

      before { subject.add_members_by_id([known_user_name.id, known_user_email.id]) }

      it 'returns members based on name' do
        expect(subject.search_members(known_user_name.name).count).to eq(1)
      end

      it 'returns members based on email' do
        expect(subject.search_members(known_user_email.email).count).to eq(1)
      end

      it 'returns members based on partial matches' do
        expect(subject.search_members('Tom').count).to eq(1)
      end

      it 'returns an empty set when there is no match' do
        expect(subject.search_members('Jerry').count).to eq(0)
      end
    end

    describe '#add_members_by_id' do
      subject { FactoryBot.create(:group) }

      let(:user) { FactoryBot.create(:user) }

      before { subject.add_members_by_id(user.id) }

      it 'adds one user when passed a single user id' do
        expect(subject.members).to include(user)
      end

      # This is tested in the setup of #search_members and #remove_members_by_id
      it 'adds multiple users when passed a collection of user ids' do
      end
    end

    describe '#remove_members_by_id' do
      subject { FactoryBot.create(:group) }

      context 'single user id' do
        let(:user) { FactoryBot.create(:user) }

        before { subject.add_members_by_id(user.id) }

        it 'removes one user' do
          expect(subject.members).to include(user)
          subject.remove_members_by_id(user.id)
          expect(subject.members).not_to include(user)
        end
      end

      context 'collection of user ids' do
        let(:user_list) { FactoryBot.create_list(:user, 3) }
        let(:user_ids) { user_list.collect(&:id) }

        before { subject.add_members_by_id(user_ids) }

        it 'removes multiple users' do
          expect(subject.members.collect(&:id)).to eq(user_ids)
          subject.remove_members_by_id(user_ids)
          expect(subject.members.count).to eq(0)
        end
      end
    end

    context '#number_of_users' do
      subject { FactoryBot.create(:group) }

      let(:user) { FactoryBot.create(:user) }

      it 'starts out with 0 users' do
        expect(subject.number_of_users).to eq(0)
      end

      it 'increments when users are added' do
        subject.add_members_by_id(user.id)
        expect(subject.number_of_users).to eq(1)
      end
    end

    ##
    # A Role can be assigned to a group, and this will grant all Users who are members of that Group certain abilities
    context 'roles' do
      context '#roles' do
        let(:group1) { described_class.create(name: "Pirate Studies") }
        let(:group2) { described_class.create(name: "Arcane Arts") }
        let(:edit_collection_role) { FactoryBot.create(:role, name: "Edit Collection") }
        it "can add a role" do
          group1.roles << edit_collection_role
          group2.roles << edit_collection_role
          expect(group1.roles).to be_present
          expect(group2.roles).to be_present
          expect(group1.roles).to include(edit_collection_role)
          expect(group2.roles).to include(edit_collection_role)
        end
      end
    end
  end
end
