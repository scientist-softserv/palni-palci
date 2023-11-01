# frozen_string_literal: true

RSpec.describe ReindexWorksJob, type: :job do
  describe '#perform' do
    context 'when works is present' do
      it 'updates the index of the specified works' do
        work = create(:work)
        allow_any_instance_of(GenericWork).to receive(:update_index)
        described_class.perform_now(work)
      end
    end

    context 'when works_id is not present' do
      it 'updates the index of all workss' do
        create_list(:work, 3)
        allow_any_instance_of(GenericWork).to receive(:update_index)
        described_class.perform_now
      end
    end
  end
end