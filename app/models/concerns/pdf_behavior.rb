# frozen_string_literal: true

module RDF
  class CustomShowPdfViewerTerm < Vocabulary('http://id.loc.gov/vocabulary/identifiers/')
    property 'show_pdf_viewer'
  end

  class CustomShowPdfDownloadButtonTerm < Vocabulary('http://id.loc.gov/vocabulary/identifiers/')
    property 'show_pdf_download_button'
  end
end

module PdfBehavior
  extend ActiveSupport::Concern

  included do
    property :show_pdf_viewer, predicate: RDF::CustomShowPdfViewerTerm.show_pdf_viewer, multiple: false do |index|
      index.as :stored_searchable
    end

    property :show_pdf_download_button,
             predicate: RDF::CustomShowPdfDownloadButtonTerm.show_pdf_download_button,
             multiple: false do |index|
               index.as :stored_searchable
             end

    after_initialize :set_default_show_pdf_viewer, :set_default_show_pdf_download_button

    include IiifPrint.model_configuration(
      pdf_split_child_model: GenericWork,
      pdf_splitter_service: IiifPrint::TenantConfig::PdfSplitter
    )
  end

  private

    # This is here so that the checkbox is checked by default
    def set_default_show_pdf_viewer
      self.show_pdf_viewer ||= '1'
    end

    def set_default_show_pdf_download_button
      self.show_pdf_download_button ||= '1'
    end
end
