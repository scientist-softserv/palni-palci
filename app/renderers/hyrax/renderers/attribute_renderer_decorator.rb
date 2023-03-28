# frozen_string_literal: true
# OVERRIDE Hyrax v3.4.2 Enable markdown rendering on work show page metadata
module Hyrax::Renderers
  module AttributeRendererDecorator
    include ApplicationHelper

    private
    def li_value(value)
      markdown(auto_link(ERB::Util.h(value)))
    end
  end
end

Hyrax::Renderers::AttributeRenderer.prepend(Hyrax::Renderers::AttributeRendererDecorator)
