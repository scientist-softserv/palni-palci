# frozen_string_literal: true
#
# OVERRIDE: Hyrax hyrax-v3.5.0 to add download restricted specific uv-config
module Hyrax
  module IiifHelperDecorator
    def universal_viewer_config_url
      if Site.account.settings[:allow_downloads].nil? || Site.account.settings[:allow_downloads].to_i.nonzero?
        "#{request&.base_url}/uv/uv-config.json"
      else
        "#{request&.base_url}/uv/uv-config-no-download.json"
      end
    end
  end
end

Hyrax::IiifHelper.prepend(Hyrax::IiifHelperDecorator)
