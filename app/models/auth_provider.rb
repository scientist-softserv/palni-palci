class AuthProvider < ApplicationRecord
  belongs_to :account

  validates :provider, :client_id, :client_secret, presence: true
end
