# frozen_string_literal: true

module PdfJsHelper
  def pdf_js_url(path)
    "/pdf.js/viewer.html?file=#{path}##{query_param}"
  end

  def query_param
    return unless params[:q]

    "search=#{params[:q]}&phrase=true"
  end
end
