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
      attr_accessor :config

      def config=(config)
        @config = config || {}
      end

      def initialize(resource_name, config: {})
        @resource_name = resource_name
        @config = config
      end

      def parse_id_list(raw)
        raw.split(',')
      end

      def allowed_route?(method)
        without = Array(config[:without])
        !without.include?(method)
      end

      def dup_for_resource_id_param(name)
        builder = self.dup
        builder.config = self.config[:id_scope]
        builder.resource_ids_key = name
        builder
      end

      def dup_for_relationship(name)
        builder = self.dup
        builder.config = self.config[name]
        builder.relationship_name = name
        builder
      end

      def dup_for_relationship_id_param(name)
        builder = self.dup
        builder.config = self.config[:id_scope]
        builder.relationship_ids_key = name
        builder
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

      def builder_scope(builder, &block)
        target_builders.push builder
        block.yield
        target_builders.pop
      end

      def last_builder
        target_builders.last || raise('No target builder available !')
      end

      def resource(name, config: {}, &block)
        builder_scope TargetBuilder.new(name, config: config) do
          super(name, &block)
        end
      end

      def resource_id_param(name, &block)
        builder = last_builder.dup_for_resource_id_param(name)
        builder_scope builder do
          route_param(name, &block)
        end
      end

      def relationship(name, &block)
        builder = last_builder.dup_for_relationship(name)
        builder_scope builder do
          namespace(name, &block)
        end
      end

      def relationship_id_param(name, &block)
        builder = last_builder.dup_for_relationship_id_param(name)
        builder_scope builder do
          route_param(name, &block)
        end
      end

      def create_route(method, path: '/', adapter_resource: nil)
        builder = target_builders.last
        return unless builder.allowed_route?(method)
        roaster_method = METHOD_MAP[method] || raise("Invalid method: #{method}")
        ares = adapter_resource || self.adapter_resource
        send(method, path) do
          target = builder.build(params)
          exec_request(roaster_method, target, ares).tap do |res|
            status 204 if res.nil?
          end
        end
      end

    end

  end

  module ClassMethods

    def expose_resource(mapping,
                        adapter_class: Roaster::Adapters::ActiveRecord,
                        model_class: nil,
                        config: {})
      resource_name = mapping_to_resource_name(mapping)
      self.adapter_resource = Roaster::Resource.new(adapter_class, model_class: model_class)
      resource resource_name, config: config do

        create_route(:post)
        create_route(:get)

        #TODO: Use a real id name ( #{resource_name}_id )
        resource_id_param :resource_id do

          create_route(:get)
          create_route(:put)
          create_route(:delete)

          namespace :links do

            rels = mapping.representable_attrs.values_at(:_has_many, :_has_one).flatten.compact
            rels.each do |rel|
              relationship rel[:name].to_sym do

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
