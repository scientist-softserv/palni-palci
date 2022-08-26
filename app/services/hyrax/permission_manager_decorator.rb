# frozen_string_literal: true

# OVERRIDE Hyrax 3.4.1 to pass a hash as an argument for groups
module Hyrax
  module PermissionManagerDecorator
    def update_groups_for(mode:, groups:)
      groups = groups.map(&:to_s)

      acl.permissions.each do |permission|
        next unless permission.mode.to_sym == mode
        next unless permission.agent.starts_with?(Hyrax::Group.name_prefix)

        group_name = permission.agent.gsub(Hyrax::Group.name_prefix, '')
        next if groups.include?(group_name)

        acl.revoke(mode).from(Group.new(name: group_name))
      end

      groups.each { |g| acl.grant(mode).to(Group.new(name: g)) }
    end   
  end
end

Hyrax::PermissionManager.prepend(Hyrax::PermissionManagerDecorator)
