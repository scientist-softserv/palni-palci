# frozen_string_literal: true
#
# OVERRIDE: Hyrax hyrax-v3.5.0 to add download restricted specific uv-config
module IiifPrint
  module IiifHelperDecoratorDecorator
    def universal_viewer_config_url
      if Site.account.settings[:allow_downloads].nil? || Site.account.settings[:allow_downloads].to_i.nonzero?
        "#{request&.base_url}#{IiifPrint.config.uv_config_path}"
      else
        "#{request&.base_url}/uv/uv-config-no-download.json"
      end
    end
  end
end

IiifPrint::IiifHelperDecorator.prepend(IiifPrint::IiifHelperDecoratorDecorator)
