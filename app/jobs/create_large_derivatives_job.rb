# frozen_string_literal: true

class CreateLargeDerivativesJob < CreateDerivativesJob
  queue_as :resource_intensive
end
