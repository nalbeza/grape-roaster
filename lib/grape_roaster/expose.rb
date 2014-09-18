# Change my (file, method) name please, i'm sad
require 'byebug'

module GrapeRoaster

  def self.included(base)
    base.class_eval do
      extend ClassMethods
      helpers Helpers
    end
  end

  module ClassMethods


    def expose_resource(mapping, adapter_class: Roaster::Adapters::ActiveRecord)
      resource_name = mapping_to_resource_name(mapping)
      resource = Roaster::Resource.new(adapter_class)
      resource resource_name do

        # CREATE
        post '/' do
          target = build_target(resource_name)
          exec_request(:create, target, resource)
        end

        # READ
        get '/' do
          target = build_target(resource_name)
          exec_request(:read, target, resource)
        end

        #TODO: Use a real id name ( #{resource_name}_id )
        route_param :id do

          # READ
          get '/' do
            ids = parse_id_list(params.delete(:id))
            target = build_target(resource_name, ids)
            exec_request(:read, target, resource)
          end

          # UPDATE
          put '/' do
            ids = parse_id_list(params.delete(:id))
            target = build_target(resource_name, ids)
            exec_request(:update, target, resource)
          end

          # DELETE
          delete '/' do
            ids = parse_id_list(params.delete(:id))
            target = build_target(resource_name, ids)
            exec_request(:delete, target, resource)
          end

          namespace :links do
            collections = mapping.representable_attrs[:definitions]
            collections.select do |_, definition|
              definition[:collection] === true
            end
            collections.each do |definition|
              relationship_name = definition[:as]

              namespace relationship_name do
                get '/' do
                  ids = parse_id_list(params.delete(:id))
                  target = build_target(resource_name, ids, relationship_name)
                  exec_request(:read, target, resource)
                end

                post '/' do
                  ids = parse_id_list(params.delete(:id))
                  target = build_target(resource_name, ids, relationship_name)
                  exec_request(:create, target, resource)
                end

                delete '/' do
                  ids = parse_id_list(params.delete(:id))
                  target = build_target(resource_name, ids, relationship_name)
                  exec_request(:delete, target, resource)
                end

                route_param :rel_ids do

                  post '/' do
                    ids = parse_id_list(params.delete(:id))
                    rel_ids = parse_id_list(params.delete(:rel_ids))
                    target = build_target(resource_name, ids, relationship_name)
                    exec_request(:create, target, resource)
                  end

                  delete '/' do
                    ids = parse_id_list(params.delete(:id))
                    rel_ids = parse_id_list(params.delete(:rel_ids))
                    target = build_target(resource_name, ids, relationship_name)
                    exec_request(:delete, target, resource)
                  end

                end # !route_param

              end # !namespace relationship_name

            end # !route_param :id
          end # !namespace :links

        end
      end
    end

    private

    def mapping_to_resource_name(mapping)
      mapping.to_s.gsub(/Mapping$/, '').underscore.pluralize.to_sym
    end

  end # !module ClassMethods

  module Helpers
    def parse_id_list(raw)
      raw.split(',')
    end

    def build_target(resource_name, resource_ids = nil, relationship_name = nil, relationship_ids = nil)
      Roaster::Query::Target.new(resource_name, resource_ids, relationship_name, relationship_ids)
    end

    def build_request(operation, target, resource)
      params = env['rack.request.query_hash']
      document = env['api.request.body']
      Roaster::Request.new(operation,
                           target,
                           resource,
                           params,
                           document: document)
    end

    def exec_request(*args)
      res = build_request(*args)
      res.execute
    end
  end

end
