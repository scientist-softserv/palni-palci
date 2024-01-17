# frozen_string_literal: true

class CreateGroupAndAddMembersJob < ApplicationJob
  RETRY_MAX = 5

  queue_as :default

  def perform(cdl_id, retries = 0)
    work = Cdl.where(id: cdl_id).first
    return if work.nil?

    page_count = work.file_sets.first.page_count.first.to_i
    child_model = work.iiif_print_config.pdf_split_child_model
    child_works_count = work.members.select { |member| member.is_a?(child_model) }.count

    if page_count == child_works_count
      group = Hyrax::Group.create(name: work.id)
      work.read_groups = [group.name]

      work.members.each do |member|
        assign_read_groups(member, group.name)
      end

      work.save
      group.save
    else
      return if retries > RETRY_MAX

      retries += 1
      CreateGroupAndAddMembersJob.set(wait: 10.minutes).perform_later(cdl_id, retries)
    end
  end

  private

    def assign_read_groups(member, group_name)
      member.read_groups = [group_name]
      member.save
      member.members.each do |sub_member|
        assign_read_groups(sub_member, group_name)
      end
    end
end
