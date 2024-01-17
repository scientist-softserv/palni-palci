# frozen_string_literal: true

class DestroySplitPagesJob < ApplicationJob
  queue_as :default

  def perform(id)
    work = Cdl.where(id: id).first
    work.members.each do |member|
      member.destroy if member.is_child && member.class == work.iiif_print_config.pdf_split_child_model
    end
  end
end
