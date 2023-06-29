# frozen_string_literal: true
module Hyrax
  module LocationDecorator
    # the location controlled vocabulary throws an error that split is undefined, which causes 500 errors for works with their Location field filled in.
    # See https://github.com/scientist-softserv/palni-palci/issues/524 for more details
    def split(argument1, argument2)
      []
    end
  end
end

Hyrax::ControlledVocabularies::Location.prepend(Hyrax::LocationDecorator)