
# frozen_string_literal: true

# OVERRIDE Hyrax v3.5.0 to change what appears in the title tags for pages

module Hyrax
  module WorkShowPresenterDecorator
    def page_title
      "#{title.first} | #{I18n.t('hyrax.product_name')} | ID: #{id}"
    end
  end
end

Hyrax::WorkShowPresenter.prepend(Hyrax::WorkShowPresenterDecorator)
