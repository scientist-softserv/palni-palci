# frozen_string_literal: true

class CreateLargeDerivativesJob < CreateDerivativesJob
  queue_as :resource_intensive
  queue_with_priority 20 # TODO: necessary?
end
