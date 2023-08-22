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
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: %i[saml openid_connect cas]

  after_create :add_default_group_membership!

  # set default scope to exclude guest users
  def self.default_scope
    where(guest: false)
  end

  scope :for_repository, -> {
    joins(:roles)
  }

  scope :registered, -> { for_repository.group(:id).where(guest: false) }

  def self.from_omniauth(auth)
    Rails.logger.fatal("********************* auth.uid: #{auth.uid}") # empty
    Rails.logger.fatal("********************* auth.extra.raw_info: #{auth.extra.raw_info.inspect}") #<OneLogin::RubySaml::Attributes:0x00007f9d50c093c0 @attributes={"urn:oid:1.3.6.1.4.1.5923.1.1.1.6"=>["SOFTSERV@pitt.edu"], "urn:oid:0.9.2342.19200300.100.1.3"=>["SOFTSERV@pitt.edu"], "urn:oid:2.5.4.4"=>["Bradford"], "urn:oid:2.5.4.42"=>["Lea Ann"], "fingerprint"=>nil}>
    Rails.logger.fatal("********************* auth.info: #{auth.info.inspect}") # auth.info: #<OmniAuth::AuthHash::InfoHash email=nil first_name=nil last_name=nil name=nil>
    Rails.logger.fatal("********************* auth.extra.raw_info.urn: #{auth.extra.raw_info['urn:oid:1.3.6.1.4.1.5923.1.1.1.6']}") # auth.extra.raw_info.urn: SOFTSERV@pitt.edu
    Rails.logger.fatal("********************* PITT_EMAIL: #{pitt_email}") # PITT_EMAIL: SOFTSERV@pitt.edu
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user_email = auth.extra.raw_info['urn:oid:1.3.6.1.4.1.5923.1.1.1.6'] || auth.uid
      user.email = user_email || auth&.info&.email || [user_email, '@', Site.instance.account.email_domain].join if user.email.blank?
      user.password = Devise.friendly_token[0, 20]
      first_name = auth.extra.raw_info['urn:oid:2.5.4.42'] || auth.info.first_name
      last_name = auth.extra.raw_info['urn:oid:2.5.4.4'] || auth.info.last_name
      Rails.logger.fatal("********************* FIRST_NAME: #{first_name}") # FIRST_NAME: Lea Ann
      Rails.logger.fatal("********************* LAST_NAME: #{last_name}") # LAST_NAME: Bradford
      display_name = "#{first_name} #{last_name}"
      user.display_name = display_name || auth&.info&.name # assuming the user model has a name
      Rails.logger.fatal("********************* DISPLAY_NAME: #{display_name}") # 
      # user.image = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!

      # (0.5ms)  BEGIN
      # D, [2023-08-22T00:00:46.677083 #1] DEBUG -- : [5d4b622d031332a8aa29ee644b60635c]   User Exists (0.6ms)  SELECT  1 AS one FROM "public"."users" WHERE "public"."users"."email" = $1 LIMIT $2  [["email", "softserv@pitt.edu"], ["LIMIT", 1]]
      # D, [2023-08-22T00:00:46.678514 #1] DEBUG -- : [5d4b622d031332a8aa29ee644b60635c]    (0.3ms)  ROLLBACK
      # I, [2023-08-22T00:00:46.679289 #1]  INFO -- : [5d4b622d031332a8aa29ee644b60635c] Redirected to https://pittir.commons-archive.org/users/sign_up?locale=en
      # I, [2023-08-22T00:00:46.679720 #1]  INFO -- : [5d4b622d031332a8aa29ee644b60635c] Completed 302 Found in 143ms (ActiveRecord: 15.7ms)
    end
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

  # Hyrax::Group memberships are tracked through User#roles. This method looks up
  # the Hyrax::Groups the user is a member of and returns each one in an Array.
  # Example:
  #   u = User.last
  #   u.roles
  #   => #<ActiveRecord::Associations::CollectionProxy [#<Role id: 8, name: "member",
  #      resource_type: "Hyrax::Group", resource_id: 2,...>]>
  #   u.hyrax_groups
  #   => [#<Hyrax::Group id: 2, name: "registered", description: nil,...>]
  def hyrax_groups
    roles.where(name: 'member', resource_type: 'Hyrax::Group').map(&:resource).uniq
  end

  # Override method from hydra-access-controls v11.0.0 to use Hyrax::Groups.
  # NOTE: DO NOT RENAME THIS METHOD - it is required for permissions to function properly.
  # @return [Array] Hyrax::Group names the User is a member of
  def groups
    hyrax_groups.map(&:name)
  end

  # NOTE: This is an alias for #groups to clarify what the method is doing.
  # This is necessary because #groups overrides a method from a gem.
  # @return [Array] Hyrax::Group names the User is a member of
  def hyrax_group_names
    groups
  end

  # TODO: this needs tests and to be moved to the service
  # Tmp shim to handle bug
  def group_roles
    hyrax_groups.map(&:roles).flatten.uniq
  end

  # TODO: The current way this method works may be problematic; if a User signs up
  # in the global tenant, they won't get group memberships for any tenant. Need to
  # identify all the places this kind of situation can arise (invited users, etc)
  # and decide what to do about it.
  def add_default_group_membership!
    return if guest?
    return if Account.global_tenant?

    Hyrax::Group.find_or_create_by!(name: Ability.registered_group_name).add_members_by_id(id)
  end
end
