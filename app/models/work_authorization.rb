# frozen_string_literal: true

# WorkAuthorization models users granted access to works.  The instigator of the authorizations is
# outside the model.  In the case of PALNI/PALCI there will be a Shibboleth/SAML authentication that
# indicates we should create a WorkAuthorization entry.
#
# @note Transactions across data storage layers (e.g. postgres and fedora) are precarious.  Fedora
#       doesn't have proper transactions and there is not a clear concept of Postgres and Fedora
#       sharing a transaction pool.  However, we can emulate one by having a postgres transaction that:
#       first does all of the postgres and then does one (ideally single) fedora change.  It is
#       not bullet proof but does hopefully improve the chances of data integrity.
#
# @see https://github.com/scientist-softserv/palni-palci/issues/633
class WorkAuthorization < ActiveRecord::Base # rubocop:disable ApplicationRecord
  class WorkNotFoundError < StandardError
    def initialize(user:, work_pid:)
      "Unable to authorize #{user.class} #{user.user_key.inspect} for work with ID=#{work_pid} because work does not exist."
    end
  end

  belongs_to :user

  # This will be a non-ActiveRecord resource
  validates :work_pid, presence: true

  ##
  # Grant the given :user permission to read the work associated with the given :work_pid.
  #
  # @param user [User]
  # @param work_pid [String]
  #
  # @raise [WorkAuthorization::WorkNotFoundError] when the given :work_pid is not found.
  #
  # @see .revoke!
  # rubocop:disable Rails/FindBy
  def self.authorize!(user:, work_pid:)
    work = ActiveFedora::Base.where(id: work_pid).first
    raise WorkNotFoundError.new(user: user, work_pid: work_pid) unless work

    transaction do
      authorization = find_or_create_by!(user_id: user.id, work_pid: work.id)
      authorization.update!(work_title: work.title)
      work.set_read_users([user.user_key], [user.user_key])
      work.save!
    end
  end
  # rubocop:enable Rails/FindBy

  ##
  # Remove permission for the given :user to read the work associated with the given :work_pid.
  #
  # @param user [User]
  # @param work_pid [String]
  #
  # @see .authorize!
  # rubocop:disable Rails/FindBy
  def self.revoke!(user:, work_pid:)
    # When we delete the authorizations, we want to ensure that we've tidied up the corresponding
    # work's read users.  If for some reason the ActiveFedora save fails, this the destruction of
    # the authorizations will rollback.  Meaning we still have a record of what we've authorized.
    transaction do
      where(user_id: user.id, work_pid: work_pid).destroy_all
      work = ActiveFedora::Base.where(id: work_pid).first
      if work
        work.set_read_users([], [user.user_key])
        work.save!
      end
      true
    end
  end
  # rubocop:enable Rails/FindBy
end
