# frozen_string_literal: true

# TODO get this decorator to work, and remove the location.rb override.
module Hyrax
  module LocationDecorator
    def split(argument1, argument2)
      []
    end
  end
end

Hyrax::ControlledVocabularies::Location.prepend(Hyrax::LocationDecorator)