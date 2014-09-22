class AlbumMapping < Roaster::JsonApi::Mapping
  property :title
  property :band

  collection :tracks
  #collection_representer class: Album
end

