# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`

RSpec.describe Image do
  describe 'indexer' do
    subject { described_class.indexer }

    it { is_expected.to eq ImageIndexer }
  end

  # rubocop:disable RSpec/ExampleLength
  describe 'metadata' do
    it 'has descriptive metadata' do
      expect(subject).to respond_to(:depositor)
      expect(subject).to respond_to(:title)
      expect(subject).to respond_to(:date_uploaded)
      expect(subject).to respond_to(:date_modified)
      expect(subject).to respond_to(:state)
      expect(subject).to respond_to(:proxy_depositor)
      expect(subject).to respond_to(:on_behalf_of)
      expect(subject).to respond_to(:arkivo_checksum)
      expect(subject).to respond_to(:owner)
      expect(subject).to respond_to(:institution)
      expect(subject).to respond_to(:format)
      expect(subject).to respond_to(:alternative_title)
      expect(subject).to respond_to(:label)
      expect(subject).to respond_to(:import_url)
      expect(subject).to respond_to(:resource_type)
      expect(subject).to respond_to(:creator)
      expect(subject).to respond_to(:contributor)
      expect(subject).to respond_to(:description)
      expect(subject).to respond_to(:abstract)
      expect(subject).to respond_to(:keyword)
      expect(subject).to respond_to(:license)
      expect(subject).to respond_to(:rights_notes)
      expect(subject).to respond_to(:rights_statement)
      expect(subject).to respond_to(:access_right)
      expect(subject).to respond_to(:publisher)
      expect(subject).to respond_to(:date_created)
      expect(subject).to respond_to(:subject)
      expect(subject).to respond_to(:language)
      expect(subject).to respond_to(:identifier)
      expect(subject).to respond_to(:related_url)
      expect(subject).to respond_to(:bibliographic_citation)
      expect(subject).to respond_to(:source)
      expect(subject).to respond_to(:is_child)
      expect(subject).to respond_to(:access_control_id)
      expect(subject).to respond_to(:representative_id)
      expect(subject).to respond_to(:thumbnail_id)
      expect(subject).to respond_to(:rendering_ids)
      expect(subject).to respond_to(:admin_set_id)
      expect(subject).to respond_to(:embargo_id)
      expect(subject).to respond_to(:lease_id)
      expect(subject).to respond_to(:location)
    end
  end
  # rubocop:enable RSpec/ExampleLength
end
