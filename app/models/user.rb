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

  before_create :add_default_roles

  scope :for_repository, ->{
    joins(:roles)
  }
  scope :exclude_guests, -> { where(guest: false) }

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier.
  def to_s
    email
  end

  def is_superadmin
    has_role? :superadmin
  end

  def is_superadmin=(value)
    if value && value != "0"
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

  # TODO: return the Hyrax::Groups that the user belongs to
  # TODO: user.groups is called several times in Hyrax so need to investigate
  def groups
    return ['admin'] if has_role?(:admin, Site.instance)
    []
  end

  def workflow_groups
    self.roles.where(name: "member", resource_type: "Hyrax::Group").map(&:resource).uniq
  end

  def add_default_roles
    add_role :admin, Site.instance unless self.class.joins(:roles).where("roles.name = ?", "admin").any? || Account.global_tenant?
  end
end
