# frozen_string_literal: true

module CreateDerivativesJobDecorator
  def perform(file_set, file_id, filepath = nil)
    return super if self.is_a?(CreateLargeDerivativesJob)
    return super unless file_set.video? || file_set.audio?

    CreateLargeDerivativesJob.perform_later(*self.arguments)
    true
  end
end

CreateDerivativesJob.prepend(CreateDerivativesJobDecorator)
