# frozen_string_literal: true

module PdfViewerFormBehavior
  extend ActiveSupport::Concern

  included do
    self.terms += %i[show_viewer]
  end
end
