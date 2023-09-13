# frozen_string_literal: true

module PdfJsHelper
  def pdf_js_url(path)
    "/pdf.js/viewer.html?file=#{path}##{query_param}"
  end

  def query_param
    return unless params[:q]

    "search=#{params[:q]}&phrase=true"
  end

  def render_show_viewer_checkbox?
    return unless Flipflop.default_pdf_viewer?
    return if params[:id].nil?

    doc = SolrDocument.find params[:id]

    presenter = @_controller.show_presenter.new(doc, current_ability)
    presenter.file_set_presenters.any?(&:pdf?)
  end

  def render_pdf_download_btn?
    Flipflop.default_pdf_viewer? && @presenter.show_download_button? && @presenter.file_set_presenters.first
  end
end
