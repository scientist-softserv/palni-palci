# frozen_string_literal: true

# OVERRIDE Hyrax v2.9.6 add #uv_search_param
# OVERRDIDE IIIFPRINT v1.0.0 to modify the config url

module IiifPrint
  module IiifHelperDecorator
    def iiif_viewer_display(work_presenter, locals = {})
      render iiif_viewer_display_partial(work_presenter),
             locals.merge(presenter: work_presenter)
    end

    def iiif_viewer_display_partial(work_presenter)
      'hyrax/base/iiif_viewers/' + work_presenter.iiif_viewer.to_s
    end

    def universal_viewer_base_url
      "#{request&.base_url}#{IiifPrint.config.uv_base_path}"
    end

    def universal_viewer_config_url
      if Site.account.settings[:allow_downloads].nil? || Site.account.settings[:allow_downloads].to_i.nonzero?
        "#{request&.base_url}#{IiifPrint.config.uv_config_path}"
      else
        "#{request&.base_url}/uv/uv-config-no-download.json"
      end
    end

    # Extract query param from search
    def uv_search_param
      search_params = current_search_session.try(:query_params) || {}
      q = search_params['q'].presence || ''

      "&q=#{url_encode(q)}" if q.present?
    end
  end
end