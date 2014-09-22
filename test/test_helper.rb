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

  HTTP_METHODS = [:get, :post, :put, :patch, :delete, :options, :head]

  HTTP_METHODS.each do |meth|
    define_method("json_#{meth}") do |uri, params = {}, env = {}, &block|
      env['CONTENT_TYPE'] = 'application/vnd.api+json' if [:post, :put, :patch].include?(meth)
      env['ACCEPT'] = 'application/vnd.api+json'
      res = send(meth, uri, params, env, &block)
      class << res
        attr_accessor :json_body
      end
      res.json_body = JSON.parse(res.body)
      res
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
