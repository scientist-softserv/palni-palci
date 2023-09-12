# frozen_string_literal: true

module PdfJsHelper
  def pdf_js_url(path)
    "/pdf.js/viewer.html?file=#{path}##{query_param}"
  end

  def query_param
    return unless params[:q]

    "search=#{params[:q]}&phrase=true"
  end

  def render_pdf_download_btn?
    file_set_id = @presenter.file_set_presenters.first.id
    (Flipflop.default_pdf_viewer? && @presenter.file_set_presenters.first) &&
      (can?(:download, file_set_id) && (Site.account.settings[:allow_downloads].nil? || Site.account.settings[:allow_downloads].to_i.nonzero?))
  end
end
