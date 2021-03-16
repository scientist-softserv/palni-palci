# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

# In test most, unset some variables that can cause trouble
# before booting up Rails
ENV['SETTINGS__MULTITENANCY__ADMIN_HOST'] = nil
ENV['SETTINGS__MULTITENANCY__ADMIN_ONLY_TENANT_CREATION'] = nil
ENV['SETTINGS__MULTITENANCY__DEFAULT_HOST'] = nil
ENV['SETTINGS__MULTITENANCY__ENABLED'] = nil

require 'simplecov'
require 'coveralls'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
)
SimpleCov.start('rails')

require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'database_cleaner'
require 'active_fedora/cleaner'
require 'rspec/retry'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Ensure the Hyrax::Admin constant is loaded. Because testing is done using autoloading,
# the order of the test run determines where the constants are loaded from.  Prior to
# this change we were seeing intermittent errors like:
#   uninitialized constant Admin::UserActivityPresenter
# This can probably be removed once https://github.com/projecthydra-labs/hyrax/pull/440
# is merged
# rubocop:disable Lint/Void
Hyrax::Admin
# rubocop:enable Lint/Void

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

# Uses faster rack_test driver when JavaScript support not needed
Capybara.default_max_wait_time = 8
Capybara.default_driver = :rack_test

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false
  config.include Capybara::DSL

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  
  # show retry status in spec process
  config.verbose_retry = true
  # Try twice (retry once)
  config.default_retry_count = 2
  # Only retry when Selenium raises Net::ReadTimeout
  config.exceptions_to_retry = [Net::ReadTimeout]

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Fixtures::FixtureFileUpload
  config.include FactoryBot::Syntax::Methods
  config.include ApplicationHelper, type: :view
  config.include Warden::Test::Helpers, type: :feature

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    Account.destroy_all
    CreateSolrCollectionJob.new.without_account('hydra-test') if ENV['IN_DOCKER']
  end

  config.before(:each) do |example|
    # Pass `:clean' to destroy objects in fedora/solr and start from scratch
    ActiveFedora::Cleaner.clean! if example.metadata[:clean]
    if example.metadata[:type] == :feature && Capybara.current_driver != :rack_test
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    end
  end

  config.after(:each, type: :feature) do
    Warden.test_reset!
    Capybara.reset_sessions!
    page.driver.reset!
  end

  config.after do
    begin
      DatabaseCleaner.clean
    rescue NoMethodError
      'This can happen which the database is gone, which depends on load order of tests'
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
