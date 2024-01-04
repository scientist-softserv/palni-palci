# frozen_string_literal: true

module CreateDerivativesJobDecorator
  def self.prepended(base)
    base.class_eval do
      before_perform :reassign_queue, if: ->() { arguments.first.video? || arguments.first.audio? }
    end
  end

  def reassign_queue
    self.queue_name = 'resource_intensive'
  end
end

CreateDerivativesJob.prepend(CreateDerivativesJobDecorator)
