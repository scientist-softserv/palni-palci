# frozen_string_literal: true

RSpec.describe GenericWork do

  it 'has a title' do
    subject.title = ['Test title']
    expect(subject.title).to eq ['Test title']
  end

  it 'has a institution' do
    subject.institution = 'institution'
    expect(subject.institution).to eq 'institution'
  end

  it 'has a format' do
    subject.format = ['format']
    expect(subject.format).to eq ['format']
  end

  it 'has a types' do
    subject.types = ['types']
    expect(subject.types).to eq ['types']
  end

  describe '.model_name' do
    subject { described_class.model_name.singular_route_key }

    it { is_expected.to eq 'hyrax_generic_work' }
  end

  describe ".properties" do
    subject { described_class.properties.keys }

    it { is_expected.to include("has_model", "create_date", "modified_date") }
  end

  describe '#state' do
    let(:work) { described_class.new(state: inactive) }
    let(:inactive) { ::RDF::URI('http://fedora.info/definitions/1/0/access/ObjState#inactive') }

    it 'is inactive' do
      expect(work.state.rdf_subject).to eq inactive
    end

    it 'allows state to be set to ActiveTriples::Resource' do
      other_work = described_class.new(state: work.state)
      expect(other_work.state.rdf_subject).to eq inactive
    end
  end

  describe '#suppressed?' do
    let(:work) { described_class.new(state: state) }

    context "when state is inactive" do
      let(:state) { ::RDF::URI('http://fedora.info/definitions/1/0/access/ObjState#inactive') }

      it 'is suppressed' do
        expect(work).to be_suppressed
      end
    end

    context "when the state is active" do
      let(:state) { ::RDF::URI('http://fedora.info/definitions/1/0/access/ObjState#active') }

      it 'is not suppressed' do
        expect(work).not_to be_suppressed
      end
    end

    context "when the state is nil" do
      let(:state) { nil }

      it 'is not suppressed' do
        expect(work).not_to be_suppressed
      end
    end
  end

  describe "embargo" do
    subject(:work) { described_class.new(title: ['a title'], embargo_release_date: embargo_release_date) }
    let(:embargo_release_date) { Time.zone.today + 10 }

    it { is_expected.to be_valid }

    context 'with a past date' do
      let(:embargo_release_date) { Time.zone.today - 10 }

      it { is_expected.not_to be_valid }

      it 'has errors related to the date' do
        expect { work.valid? }
          .to change { work.errors.to_a }
          .from(be_empty)
          .to include("Embargo release date Must be a future date")
      end
    end

    context 'with a saved embargo' do
      let(:past) { Time.zone.today - 10 }

      before { work.save! }

      it 'can update the embargo with any date' do
        work.embargo_release_date = past

        expect(work).to be_valid
        expect { work.save! }.not_to raise_error
      end
    end
  end

  describe "delegations" do
    let(:work) { described_class.new { |gw| gw.apply_depositor_metadata("user") } }
    let(:proxy_depositor) { create(:user) }

    before do
      work.proxy_depositor = proxy_depositor.user_key
    end

    it "includes proxies" do
      expect(work).to respond_to(:relative_path)
      expect(work).to respond_to(:depositor)
      expect(work.proxy_depositor).to eq proxy_depositor.user_key
    end
  end

  describe "metadata" do
    it "has descriptive metadata" do
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
      expect(subject).to respond_to(:types)
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
      expect(subject).to respond_to(:based_near)
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
    end
  end

  describe "validates title" do
    subject(:work) { FactoryBot.build(:generic_work, title: nil) }

    it { should_not be_valid }

    context 'with a title' do

      before { work.title = ['Test title'] }

      it { should be_valid }
    end
  end
end
