# frozen_string_literal: true
module Hyrax
  module LocationDecorator
    # the Location class throws an error that split is undefined since it is an enumerator, but this error is coming from deeply nested dependencies. This causes 500 errors for works with their Location field filled in.
    # defining split just for the purpose of getting past this error seemed to work and allow locations to save correctly with no adverse effects.
    # See https://github.com/scientist-softserv/palni-palci/issues/524 for more details
    def split(argument1, argument2)
      []
    end
  end
end

Hyrax::ControlledVocabularies::Location.prepend(Hyrax::LocationDecorator)