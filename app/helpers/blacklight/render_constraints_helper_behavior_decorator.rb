# frozen_string_literal: true
# OVERRIDE Blacklight 6.7 to enable markdown in facet value constraints

module Blacklight
  module RenderConstraintsHelperBehaviorDecorator

    # OVERRIDE to enable markdown in the facet constraints
    def render_constraint_element(label, value, options = {})
      render(:partial => "catalog/constraints_element", :locals => {:label => label, :value => markdown(value), :options => options})
    end
  end
end

Blacklight::RenderConstraintsHelperBehavior.prepend(Blacklight::RenderConstraintsHelperBehaviorDecorator)