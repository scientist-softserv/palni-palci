# frozen_string_literal: true

module Hyrax
  module PdfFormBehavior
    extend ActiveSupport::Concern

    included do
      class_attribute :hidden_terms

      self.terms += %i[show_pdf_viewer show_pdf_download_button]
      self.hidden_terms = %i[show_pdf_viewer show_pdf_download_button]
    end

    def hidden?(key)
      hidden_terms.include? key.to_sym
    end

    class_methods do
      # Not sure why this is needed but the form was no working without it
      # it was getting an Unpermitted paratemter error for these terms
      def permitted_params
        super + %i[show_pdf_viewer show_pdf_download_button]
      end
    end
  end
end
