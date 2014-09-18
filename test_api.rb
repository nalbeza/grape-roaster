require 'grape-roaster'
require 'logger'
require 'active_model'
require 'active_record'

def wutz
  ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3", :database => ':memory:'
  )

  if ENV['DEBUG'] || true
    ActiveRecord::Base.logger = Logger.new(STDOUT)
  end

  ActiveRecord::Migration.class_eval do
    create_table :tracks do |t|
      t.string  :title
      t.string  :index
      t.belongs_to :album
    end
  end

  ActiveRecord::Migration.class_eval do
    create_table :bands do |t|
      t.string  :name
    end
  end

  ActiveRecord::Migration.class_eval do
    create_table :albums do |t|
      t.string  :title
      t.string  :dafuq
      t.belongs_to :band
    end
  end

  b = Band.create!(name: 'The Fugees')
  album = Album.create!(title: 'The Score', dafuq: 'yes sir')
  album.tracks << Track.create!(title: 'Ready or Not', index: 0)
  album.tracks << Track.create!(title: 'Killing Me Softly', index: 1)
end

class Track < ActiveRecord::Base

  belongs_to :album
end

class Band < ActiveRecord::Base
end

class Album < ActiveRecord::Base
  belongs_to :band
  has_many :tracks
end

require 'byebug'

class TrackMapping
  #property :index
end

class AlbumMapping < Roaster::JsonApi::Mapping
  property :title
  property :dafuq

  collection :tracks
  #collection_representer class: Album
end


module Test
  class API < Grape::API
    version 'v1', using: :path
    format :json

    before do
      wutz()
    end

    include GrapeRoaster
    
    expose_resource AlbumMapping
  end
end
