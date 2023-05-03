# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::GenericWorkPresenter do
  subject { described_class.new(double, double) }

  let(:solr_document) { SolrDocument.new(attributes) }
  let(:request) { double(host: 'example.org', base_url: 'http://example.org') }
  let(:user_key) { 'a_user_key' }

  let(:attributes) do
    { "id" => '888888',
      "title_tesim" => 'My Title',
      "has_model_ssim" => ["GenericWork"],
      "date_created_tesim" => 'an unformatted date',
      "depositor_tesim" => user_key }
  end
  let(:ability) { double Ability }
  let(:presenter) { described_class.new(solr_document, ability, request) }

  describe "#model_name" do
    subject { presenter.model_name }

    it { is_expected.to be_kind_of ActiveModel::Name }
  end

  describe '#iiif_viewer?' do
    subject { presenter.iiif_viewer? }

    let(:id_present) { false }
    let(:representative_presenter) { double('representative', present?: false) }
    let(:image_boolean) { false }
    let(:iiif_enabled) { true }
    let(:file_set_presenter) { Hyrax::FileSetPresenter.new(solr_document, ability) }
    let(:file_set_presenters) { [file_set_presenter] }
    let(:read_permission) { true }

    before do
      allow(presenter).to receive(:representative_id).and_return(id_present)
      allow(presenter).to receive(:representative_presenter).and_return(representative_presenter)
      allow(presenter).to receive(:file_set_presenters).and_return(file_set_presenters)
      allow(file_set_presenter).to receive(:image?).and_return(true)
      allow(ability).to receive(:can?).with(:read, solr_document.id).and_return(read_permission)
      allow(representative_presenter).to receive(:image?).and_return(image_boolean)
      allow(Hyrax.config).to receive(:iiif_image_server?).and_return(iiif_enabled)
    end

    context 'with no representative_id' do
      it { is_expected.to be false }
    end

    context 'with no representative_presenter' do
      let(:id_present) { true }

      it { is_expected.to be false }
    end

    context 'with IIIF image server turned off' do
      let(:id_present) { true }
      let(:representative_presenter) { double('representative', present?: true) }
      let(:image_boolean) { true }
      let(:iiif_enabled) { false }

      it { is_expected.to be false }
    end

    context 'with representative image and IIIF turned on' do
      let(:id_present) { true }
      let(:representative_presenter) { double('representative', present?: true) }
      let(:image_boolean) { true }
      let(:iiif_enabled) { true }

      it { is_expected.to be true }

      context "when the user doesn't have permission to view the image" do
        let(:read_permission) { false }

        it { is_expected.to be false }
      end
    end

    describe "#attribute_to_html" do
      let(:renderer) { double('renderer') }

      context 'with an existing field' do
        before do
          allow(Hyrax::Renderers::AttributeRenderer).to receive(:new)
            .with(:title, ['My Title'], {})
            .and_return(renderer)
        end

        it "calls the AttributeRenderer" do
          expect(renderer).to receive(:render)
          presenter.attribute_to_html(:title)
        end
      end

      context "with a field that doesn't exist" do
        it "logs a warning" do
          # rubocop:disable Metrics/LineLength
          expect(Rails.logger).to receive(:warn).with('Hyrax::GenericWorkPresenter attempted to render restrictions, but no method exists with that name.')
          # rubocop:enable Metrics/LineLength
          presenter.attribute_to_html(:restrictions)
        end
      end
    end
  end

  describe "#show_deposit_for?" do
    subject { presenter }

    context "when user has depositable collections" do
      let(:user_collections) { double }

      it "returns true" do
        expect(subject.show_deposit_for?(collections: user_collections)).to be true
      end
    end

    context "when user does not have depositable collections" do
      let(:user_collections) { nil }

      context "and user can create a collection" do
        before do
          allow(ability).to receive(:can?).with(:create_any, Collection).and_return(true)
        end

        it "returns true" do
          expect(subject.show_deposit_for?(collections: user_collections)).to be true
        end
      end

      context "and user can NOT create a collection" do
        before do
          allow(ability).to receive(:can?).with(:create_any, Collection).and_return(false)
        end

        it "returns false" do
          expect(subject.show_deposit_for?(collections: user_collections)).to be false
        end
      end
    end
  end

  describe '#iiif_viewer' do
    subject { presenter.iiif_viewer }

    it 'defaults to universal viewer' do
      expect(subject).to be :universal_viewer
    end
  end
end
