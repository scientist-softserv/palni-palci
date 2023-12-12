# frozen_sting_literal: true

module VideoEmbedFormBehavior
  extend ActiveSupport::Concern

  included do
    self.terms += %i[video_embed]
  end
end
