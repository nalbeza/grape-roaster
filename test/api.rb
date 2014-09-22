require_relative 'mappings/album'

module SongVault
  class API < Grape::API
    version 'v1', using: :path
    format :json

    include GrapeRoaster

    expose_resource AlbumMapping,
      adapter_class: Roaster::Adapters::ActiveRecord
=begin
      config: {
        without: :get,
        id_scope: {
          without: [:delete, :put],
          tracks: {
            without: :post,
            id_scope: {
              without: :delete
            }
          },
          band: false
        }
      }
=end

  end
end

def print_routes(api_class)
  api_class.routes.each do |route|
    info = route.instance_variable_get :@options
    description = "%-40s..." % info[:description][0..39] if info[:description]
    method = "%-7s" % info[:method]
    puts "#{description}  #{method}#{info[:path]}"
  end
end

puts print_routes(SongVault::API)
