# frozen_string_literal: true

class User < ApplicationRecord
  # Includes lib/rolify from the rolify gem
  rolify
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats

  attr_accessible :email, :password, :password_confirmation if Blacklight::Utils.needs_attr_accessible?
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :invitable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_create :add_default_group_memberships!

  scope :for_repository, ->{
    joins(:roles)
  }

  # set default scope to exclude guest users
  def self.default_scope
    where(guest: false)
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier.
  def to_s
    email
  end

  def is_superadmin
    has_role? :superadmin
  end

  # This comes from a checkbox in the proprietor interface
  # Rails checkboxes are often nil or "0" so we handle that
  # case directly
  def is_superadmin=(value)
    value = ActiveModel::Type::Boolean.new.cast(value)
    if value
      add_role :superadmin
    else
      remove_role :superadmin
    end
  end

  def site_roles
    roles.site
  end

  def site_roles=(roles)
    roles.reject!(&:blank?)

    existing_roles = site_roles.pluck(:name)
    new_roles = roles - existing_roles
    removed_roles = existing_roles - roles

    new_roles.each do |r|
      add_role r, Site.instance
    end

    removed_roles.each do |r|
      remove_role r, Site.instance
    end
  end

  def enrolled_hyrax_groups
    roles.where(name: 'member', resource_type: 'Hyrax::Group').map(&:resource).uniq
  end

  ##
  # Override method from hydra-access-controls v11.0.0 to use Hyrax::Groups.
  # NOTE(bkiahstroud): DO NOT RENAME THIS METHOD - it is required for
  # permissions to function properly.
  def groups
    enrolled_hyrax_groups.map(&:name)
  end

  # TODO this needs tests and to be moved to the service
  # Tmp shim to handle bug
  def group_roles
    enrolled_hyrax_groups.map(&:roles).flatten.uniq
  end

  def add_default_group_memberships!
    return if Account.global_tenant?

    Hyrax::Group.find_or_create_by!(name: 'public').add_members_by_id(self.id)

    if self.has_role?(:admin, Site.instance)
      Hyrax::Group.find_or_create_by!(name: 'admin').add_members_by_id(self.id)
    end

    unless self.guest?
      Hyrax::Group.find_or_create_by!(name: 'registered').add_members_by_id(self.id)
    end
  end
end
