ENV['RACK_ENV'] = 'test'

require 'grape-roaster'
require 'byebug'
require 'minitest/autorun'
require 'rack/test'
require 'awesome_print'
require 'database_cleaner'
require 'json_expressions/minitest'

require_relative 'support/active_record'
require_relative 'support/fixtures'
require_relative 'api'

DatabaseCleaner.strategy = :transaction

class MiniTest::Test

  include Rack::Test::Methods

  def method_missing(meth, *args, &block)
    if meth.to_s =~ /^json_(.+)$/
      res = self.send($1, *args, &block)
      class << res
        attr_accessor :json_body
      end
      res.json_body = JSON.parse(res.body)
      res
    else
      super
    end
  end

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
