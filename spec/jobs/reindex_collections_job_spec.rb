# frozen_string_literal: true

RSpec.describe ReindexCollectionsJob, type: :job do
  describe '#perform' do
    context 'when collection_id is present' do
      it 'updates the index of the specified collection' do
        collection = create(:collection)
        allow_any_instance_of(Collection).to receive(:update_index)
        described_class.perform_now(collection.id)
      end
    end

    context 'when collection_id is not present' do
      it 'updates the index of all collections' do
        create_list(:collection, 3)
        allow_any_instance_of(Collection).to receive(:update_index)
        described_class.perform_now
      end
    end
  end
end
