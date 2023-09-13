# frozen_string_literal: true

module PdfFormBehavior
  extend ActiveSupport::Concern

  included do
    self.terms += %i[show_pdf_viewer show_pdf_download_button]
  end
end
