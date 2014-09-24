require_relative 'track'
require_relative 'band'

class AlbumMapping < Roaster::JsonApi::Mapping
  property :title
  property :band

  has_many :tracks#, mapping: TrackMapping
  has_one :band#, mapping: BandMapping
end
