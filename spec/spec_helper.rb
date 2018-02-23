require 'simplecov'

if ENV['CI']
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
end

if ENV['COVERAGE'] || ENV['CI']
  SimpleCov.start('rails') do
    add_filter '/spec'
    add_filter '/.internal_test_app'
    add_filter '/lib/generators'
    add_filter '/lib/geo_works/version.rb'
  end
end

require 'engine_cart'
require 'pry'

ENV['RAILS_ENV'] ||= 'test'
EngineCart.load_application!
Dir['./spec/support/**/*.rb'].sort.each { |f| require f }
require 'rspec/rails'

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :poltergeist
Capybara.default_max_wait_time = ENV['TRAVIS'] ? 30 : 15
# Adding the below to deal with random Capybara-related timeouts in CI.
# Found in this thread: https://github.com/teampoltergeist/poltergeist/issues/375
poltergeist_options = {
  js_errors: true,
  timeout: 30,
  logger: nil,
  phantomjs_logger: StringIO.new,
  phantomjs_options: [
    '--load-images=no',
    '--ignore-ssl-errors=yes'
  ]
}
Capybara.register_driver(:poltergeist) do |app|
  Capybara::Poltergeist::Driver.new(app, poltergeist_options)
end

ActiveJob::Base.queue_adapter = :inline

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.fixture_path = File.expand_path("../fixtures", __FILE__)

  config.include FactoryBot::Syntax::Methods
  if defined? Devise::Test::ControllerHelpers
    config.include Devise::Test::ControllerHelpers, type: :controller
    config.include Devise::Test::ControllerHelpers, type: :view
  else
    config.include Devise::TestHelpers, type: :controller
    config.include Devise::TestHelpers, type: :view
  end

  config.include TestViewHelpers, type: :view

  config.include(ControllerLevelHelpers, type: :helper)
  config.before(:each, type: :helper) { initialize_controller_helpers(helper) }

  config.include(ControllerLevelHelpers, type: :view)
  config.before(:each, type: :view) { initialize_controller_helpers(view) }

  config.include BackportTest, type: :controller unless Rails.version > '5'
  config.include Controllers::EngineHelpers, type: :controller
  config.include Controllers::EngineHelpers, type: :helper
  config.include ::Rails.application.routes.url_helpers
end
