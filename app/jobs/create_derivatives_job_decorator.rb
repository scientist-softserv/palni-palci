# frozen_string_literal: true

module CreateDerivativesJobDecorator
  def self.prepended(base)
    base.class_eval do
      queue_as :resource_intensive
    end
  end
end

CreateDerivativesJob.prepend(CreateDerivativesJobDecorator)
