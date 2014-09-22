class AlbumMapping < Roaster::JsonApi::Mapping
  property :title

  collection :tracks
  #collection_representer class: Album
end

