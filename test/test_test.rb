require 'grape-roaster'
require 'minitest/autorun'
require_relative 'test_helper'

class Test < MiniTest::Test

  def test_wut
  end

end

class AlbumMapping < Roaster::Decorator
  property :title

  collection :tracks
end

class Omg < Grape::API

  include GrapeRoaster

  expose_resource AlbumMapping

end
