# frozen_string_literal: true

# rubocop:disable RSpec/FilePath
RSpec.describe IiifPrint::Jobs::CreateRelationshipsJobDecorator, type: :decorator do
  describe '#perform' do
    subject(:job) { IiifPrint::Jobs::CreateRelationshipsJob.new }

    let(:parent) { FactoryBot.create(:cdl) }
    let(:child) { FactoryBot.create(:generic_work) }

    it 'calls CreateGroupAndAddMembersJob' do
      expect(CreateGroupAndAddMembersJob).to receive(:set).with(wait: 2.minutes).and_return(CreateGroupAndAddMembersJob)

      job.perform(parent_id: parent.id, parent_model: parent.class.to_s, child_model: child.class)
    end
  end
end
# rubocop:enable RSpec/FilePath
