require_relative 'track'

class AlbumMapping < Roaster::JsonApi::Mapping
  property :title
  property :band

  has_many :tracks#, mapping: TrackMapping
  has_one :band, mapping: BandMapping
end
