require 'logger'
require 'active_model'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3", :database => ':memory:'
)

if ENV['DEBUG']
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
    t.belongs_to :band
  end
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
