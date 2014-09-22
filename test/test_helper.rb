ENV['RACK_ENV'] = 'test'

require 'grape-roaster'
require 'byebug'
require 'minitest/autorun'
require 'rack/test'
require 'awesome_print'
require 'database_cleaner'

require_relative 'support/active_record'
require_relative 'support/fixtures'
require_relative 'api'

DatabaseCleaner.strategy = :transaction

class MiniTest::Test

  include Rack::Test::Methods

  def app
    SongVault::API
  end

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

end
