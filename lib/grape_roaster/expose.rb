# Change my (file, method) name please, i'm sad
require 'byebug'

module GrapeRoaster

  def self.included(base)
    base.class_eval do
      extend ClassMethods
      helpers Helpers
      include DSL
    end
  end

  module DSL

    def self.included(base)
      base.extend Methods
    end

    class TargetBuilder
      attr_accessor :resource_name
      attr_accessor :resource_ids_key
      attr_accessor :relationship_name
      attr_accessor :relationship_ids_key

      def initialize(resource_name)
        @resource_name = resource_name
      end

      def parse_id_list(raw)
        raw.split(',')
      end

      def build(params)
        args = [@resource_name]
        args.push parse_id_list(params[resource_ids_key]) if resource_ids_key
        args.push relationship_name if relationship_name
        args.push parse_id_list(params[relationship_ids_key]) if relationship_ids_key
        Roaster::Query::Target.new(*args)
      end
    end

    module Methods

      METHOD_MAP = {
        post: :create,
        get: :read,
        put: :update,
        delete: :delete
      }

      cattr_accessor :target_builders
      cattr_accessor :adapter_resource

      def self.extended(base)
        base.target_builders = []
      end

      def scoped_builder(builder, &block)
        target_builders.push builder
        block.yield
        target_builders.pop
      end

      def dup_last_builder
        builder = target_builders.last || raise('No target builder available !')
        builder.dup
      end

      def resource(name, &block)
        scoped_builder TargetBuilder.new(name) do
          super(name, &block)
        end
      end

      def resource_id_param(name, &block)
        builder = dup_last_builder
        builder.resource_ids_key = name
        scoped_builder builder do
          route_param(name, &block)
        end
      end

      def relationship(name, &block)
        builder = dup_last_builder
        builder.relationship_name = name
        scoped_builder builder do
          namespace(name, &block)
        end
      end

      def relationship_id_param(name, &block)
        builder = dup_last_builder
        builder.relationship_ids_key = name
        scoped_builder builder do
          route_param(name, &block)
        end
      end

      def create_route(method, path: '/', adapter_resource: nil)
        roaster_method = METHOD_MAP[method] || raise("Invalid method: #{method}")
        ares = adapter_resource || self.adapter_resource
        builder = target_builders.last
        send(method, path) do
          target = builder.build(params)
          exec_request(roaster_method, target, ares)
        end
      end

    end

  end

  module ClassMethods

    def expose_resource(mapping,
                        adapter_class: Roaster::Adapters::ActiveRecord,
                        methods: {})
      resource_name = mapping_to_resource_name(mapping)
      self.adapter_resource = Roaster::Resource.new(adapter_class)
      resource resource_name do

        create_route(:post)
        create_route(:get)

        #TODO: Use a real id name ( #{resource_name}_id )
        resource_id_param :resource_id do

          create_route(:get)
          create_route(:put)
          create_route(:delete)

          namespace :links do

            defs = mapping.representable_attrs[:definitions]
            defs = defs.values.select { |_def| _def[:collection] === true }
            defs.each do |definition|
              relationship_name = definition[:as].evaluate(nil).to_sym

              relationship relationship_name do

                create_route(:get)
                create_route(:post)
                create_route(:delete)

                relationship_id_param :rel_ids do
                  create_route(:post)
                  create_route(:delete)
                end

              end

            end
          end

        end
      end
    end

    private

    def mapping_to_resource_name(mapping)
      mapping.to_s.gsub(/Mapping$/, '').underscore.pluralize.to_sym
    end

  end # !module ClassMethods

  module Helpers

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
