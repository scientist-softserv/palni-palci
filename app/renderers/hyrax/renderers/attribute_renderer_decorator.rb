# frozen_string_literal: true
# OVERRIDE Hyrax v3.4.2 Enable markdown rendering on work show page metadata
module Hyrax::Renderers
  module AttributeRendererDecorator
    include ApplicationHelper

    private
    def attribute_value_to_html(value)
      if microdata_value_attributes(field).present?
        "<span#{html_attributes(microdata_value_attributes(field))}>#{markdown(li_value(value))}</span>"
      else
        markdown(li_value(value))
      end
    end
  end
end

Hyrax::Renderers::AttributeRenderer.prepend(Hyrax::Renderers::AttributeRendererDecorator)
