# frozen_string_literal: true

# OVERRIDE Hyrax 3.4.0 to override the mail to
module Hyrax
  class ContactForm
    include ActiveModel::Model
    attr_accessor :contact_method, :category, :name, :email, :subject, :message
    validates :email, format: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i, allow_blank: true

    # - can't use this without ActiveRecord::Base
    # validates_inclusion_of :category, in: self.class.issue_types_for_locale

    # They should not have filled out the `contact_method' field. That's there to prevent spam.
    def spam?
      contact_method.present?
    end

    # Declare the e-mail headers. It accepts anything the mail method
    # in ActionMailer accepts.
    ###### OVERRODE the to: field to add the Tenant's email, first
    def contact_email
      Site.account.contact_email_to
    end

    def headers
      ## OVERRIDE Hyrax 3.4.0 send the mail 'from' the submitter, which doesn't work on most smtp transports
      {
        subject: "#{Site.account.email_subject_prefix} #{email} #{subject}",
        to: contact_email,
        from: Site.account.contact_email,
        reply_to: email
      }
    end

    def self.issue_types_for_locale
      I18n.t('hyrax.contact_form.issue_types').values.select(&:present?)
    end
  end
end
