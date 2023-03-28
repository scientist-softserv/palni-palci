# frozen_string_literal: true
# OVERRIDE Blacklight 6.7 to enable markdown in facet values on search results page

module Blacklight
  module FacetsHelperBehaviorDecorator

    # OVERRIDE to enable markdown in the facet list
    def render_facet_limit_list(paginator, facet_field, wrapping_element=:li)
      safe_join(paginator.items.map { |item| markdown(render_facet_item(facet_field, item)) }.compact.map { |item| content_tag(wrapping_element,item)})
    end
  end
end

Blacklight::FacetsHelperBehavior.prepend(Blacklight::FacetsHelperBehaviorDecorator)