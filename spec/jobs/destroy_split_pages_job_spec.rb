# frozen_string_literal: true

RSpec.describe DestroySplitPagesJob, type: :job do
  subject(:job) { described_class.new(work.id) }

  let(:split_work_factory) { work.iiif_print_config.pdf_split_child_model.to_s.underscore }
  let(:work) { FactoryBot.create(:cdl, title: ['Test CDL']) }
  let(:work_page_1) { FactoryBot.create(split_work_factory, title: ["#{work.id} - #{work.title.first} Page 1"], is_child: true) }

  before do
    work.ordered_members << work_page_1
    work.save
  end

  describe '#perform' do
    it 'destroys the child works when the work is destroyed' do
      expect { work_page_1.class.find(work_page_1.id) }.not_to raise_error

      job.perform(work.id)

      expect { work_page_1.class.find(work_page_1.id) }.to raise_error(Ldp::Gone)
    end
  end
end
