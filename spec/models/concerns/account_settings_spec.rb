# frozen_string_literal: true

RSpec.describe AccountSettings do
  let(:account) { FactoryBot.create(:account) }

  describe '#public_settings' do
    context 'when is_superadmin is true' do
      # rubocop:disable RSpec/ExampleLength
      it 'returns all settings except private and disabled settings' do
        expect(account.public_settings(is_superadmin: true).keys.sort).to eq %i[allow_downloads
                                                                                allow_signup
                                                                                analytics_provider
                                                                                cache_api
                                                                                contact_email
                                                                                contact_email_to
                                                                                doi_reader
                                                                                doi_writer
                                                                                email_domain
                                                                                email_format
                                                                                email_subject_prefix
                                                                                file_acl
                                                                                file_size_limit
                                                                                geonames_username
                                                                                google_analytics_id
                                                                                google_oauth_app_name
                                                                                google_oauth_app_version
                                                                                google_oauth_client_email
                                                                                google_oauth_private_key_path
                                                                                google_oauth_private_key_secret
                                                                                google_oauth_private_key_value
                                                                                gtm_id
                                                                                oai_admin_email
                                                                                oai_prefix
                                                                                oai_sample_identifier
                                                                                s3_bucket
                                                                                smtp_settings
                                                                                solr_collection_options
                                                                                ssl_configured]
        expect(account.public_settings(is_superadmin: true).size).to eq 29
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when is_superadmin is false' do
      # rubocop:disable RSpec/ExampleLength
      it 'returns all settings except private, disabled, and superadmin settings' do
        expect(Account::SUPERADMIN_SETTINGS_ONLY.size).to eq 8
        expect(account.public_settings(is_superadmin: false).keys.sort).to eq %i[allow_downloads
                                                                                 allow_signup
                                                                                 cache_api
                                                                                 doi_reader
                                                                                 doi_writer
                                                                                 email_domain
                                                                                 email_format
                                                                                 email_subject_prefix
                                                                                 geonames_username
                                                                                 google_analytics_id
                                                                                 google_oauth_app_name
                                                                                 google_oauth_app_version
                                                                                 google_oauth_client_email
                                                                                 google_oauth_private_key_path
                                                                                 google_oauth_private_key_secret
                                                                                 google_oauth_private_key_value
                                                                                 gtm_id
                                                                                 oai_admin_email
                                                                                 smtp_settings
                                                                                 solr_collection_options
                                                                                 ssl_configured]
        expect(account.public_settings(is_superadmin: false).size).to eq 21
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
