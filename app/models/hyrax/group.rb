# Override from hyrax 2.5.1 to migrate Hyku::Group into Hyrax::Group
module Hyrax
  class Group < ApplicationRecord
    resourcify # Declares Hyrax::Group a resource model so rolify can manage membership

    MEMBERSHIP_ROLE = :member
    DEFAULT_MEMBER_CLASS = ::User

    validates :name, presence: true, uniqueness: true
    has_many :group_roles
    has_many :roles, through: :group_roles

    def self.search(query)
      if query.present?
        left_outer_joins(:roles).where(
          "LOWER(hyrax_groups.humanized_name) LIKE LOWER(:q) " \
          "OR LOWER(hyrax_groups.description) LIKE LOWER(:q) " \
          "OR LOWER(REPLACE(roles.name, '_', ' ')) LIKE LOWER(:q)",
          q: "%#{query}%"
        ).distinct
      else
        includes(:roles).order('roles.sort_value')
      end
    end

    def search_members(query, member_class: DEFAULT_MEMBER_CLASS)
      if query.present? && member_class == DEFAULT_MEMBER_CLASS
        members.where("email LIKE :q OR display_name LIKE :q", q: "%#{query}%")
      else
        members(member_class: member_class)
      end
    end

    # @example group.add_members_by_id(user.id)
    def add_members_by_id(ids, member_class: DEFAULT_MEMBER_CLASS)
      new_members = member_class.unscoped.find(ids)
      Array.wrap(new_members).collect { |m| m.add_role(MEMBERSHIP_ROLE, self) }
    end

    def remove_members_by_id(ids, member_class: DEFAULT_MEMBER_CLASS)
      old_members = member_class.find(ids)
      Array.wrap(old_members).collect { |m| m.remove_role(MEMBERSHIP_ROLE, self) }
    end

    def members(member_class: DEFAULT_MEMBER_CLASS)
      member_class.with_role(MEMBERSHIP_ROLE, self)
    end

    def number_of_users
      members.count
    end

    def to_sipity_agent
      sipity_agent || create_sipity_agent!
    end

    def description_label
      label = description || I18n.t("hyku.admin.groups.description.#{name}")
      return '' if label =~ /^translation missing:/

      label
    end

    private

      def sipity_agent
        Sipity::Agent.find_by(proxy_for_id: id, proxy_for_type: self.class.name)
      end

      def create_sipity_agent!
        Sipity::Agent.create!(proxy_for_id: id, proxy_for_type: self.class.name)
      end
  end
end
