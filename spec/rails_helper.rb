# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'sidekiq/testing'
Sidekiq::Testing.fake!
# Add additional requires below this line. Rails is not loaded until this point!
require 'simplecov'
SimpleCov.start 'rails'

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
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Custom config goes first
  config.include Devise::TestHelpers, type: :controller
  config.include Devise::TestHelpers, type: :view
  config.extend ControllerMacros, type: :controller
  config.include Requests::JsonHelpers, type: :request

  config.before(:each) do
    Sidekiq::Worker.clear_all
    ActionMailer::Base.deliveries.clear
  end

  RSpec.configure do |config|
    config.before :each do
      Typhoeus::Expectation.clear
    end
  end

  # Cequel database cleaner for spec
  records = []

  config.before :suite do
    Cequel::Record.descendants.each do |klass|
      klass.after_create { |r| records << r }
    end
  end

  config.after :each do
    records.each(&:destroy)
    records.clear
  end

  def clean_cequel!
    Cequel::Record.descendants.each do |klass|
      Cequel::Record.connection.schema.truncate_table(klass.table_name)
    end
  end

  config.before :suite do
    clean_cequel!
  end

  config.after :suite do
    clean_cequel!
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

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
end
