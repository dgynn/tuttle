# frozen_string_literal: true
require 'rails/generators'
require_dependency 'tuttle/application_controller'
require_dependency 'tuttle/presenters/action_dispatch/routing/route_wrapper'
require_dependency 'tuttle/presenters/active_support/callbacks'
require_dependency 'tuttle/presenters/active_record/reflection_presenter'

module Tuttle
  class RailsController < ApplicationController

    def index
      @config_options = Tuttle::ConfigurationRegistry.data.to_a.sort_by!(&:first)
    end

    def controllers
      # It seems likely that .descendants will work best when Tuttle and Rails classes are not modified
      # but both approaches also require eager_load to be true
      # @controllers = ObjectSpace.each_object(::Class).select {|klass| klass < ActionController::Base }
      @controllers = ActionController::Base.descendants
      @controllers.reject! do |controller|
        controller.abstract? || controller <= Tuttle::ApplicationController
      end

      # Rails 5.1 introduced Rails::ApplicationController which really should be abstract
      if defined?(Rails::ApplicationController)
        @controllers.reject! { |controller| controller == Rails::ApplicationController }
      end

      @controllers.sort_by!(&:name)
    end

    def engines
      @engines = Rails::Engine.subclasses.map(&:instance)
    end

    def generators
      Rails::Generators.lookup! if params[:load_all_generators] == 'true'
      @generators = Rails::Generators.subclasses.group_by(&:base_name)
    end

    def models
      @models = ActiveRecord::Base.descendants.reject { |model| model.abstract_class? || !model.table_exists? }
      @models.sort_by!(&:name)
    end

    def database
      @conn = ActiveRecord::Base.connection
      @data_sources = @conn.respond_to?(:data_sources) ? @conn.data_sources : @conn.tables
    end

    def schema_cache
      @schema_cache_filename = File.join(Rails.application.config.paths['db'].first, 'schema_cache.dump')
      if File.file?(@schema_cache_filename)
        @schema_cache = Marshal.load(File.binread(@schema_cache_filename))
      end
      # TODO: wrap in a facade and handle unloaded file
      @schema_cache ||= ActiveRecord::ConnectionAdapters::SchemaCache.new(nil)

      # TODO: consider allowing a schema cache clear!
      # TODO: consider allowing a schema_cache.dump reload
      # if @schema_cache.version && params[:reload_schema_cache_dump]
      #   ActiveRecord::Base.connection.schema_cache = @schema_cache.dup
      # end

      @connection_schema_cache = ActiveRecord::Base.connection.schema_cache
      # Note: Rails 5 should also support ActiveRecord::Base.connection_pool.respond_to?(:schema_cache)
    end

    def helpers
      # TODO: Rails.application.helpers.instance_methods
      # helper_symbol = Rails.application.helpers.instance_methods.first
      # Rails.application.helpers.instance_method(helper_symbol).owner
      # Rails.application.helpers.instance_method(helper_symbol).parameters
      @helpers = ::ApplicationController.send(:modules_for_helpers, [:all])
    end

    def assets
      @sprockets_env = Rails.application.assets
      @assets_config = Rails.application.config.assets
      # TODO: revisit detection of "engines" which are classified as processors, transformers, etc.
    end

    def routes
      @routes = Rails.application.routes.routes.collect do |route|
        Tuttle::Presenters::ActionDispatch::Routing::RouteWrapper.new(route)
      end
      if params[:recognize_path]
        @path_to_recognize = params[:recognize_path]
        @recognized_paths = recognize_paths(params[:recognize_path])
      end
      # TODO: include engine-mounted routes
    end

    def instrumentation
      @events = Tuttle::Instrumenter.events
      @event_counts = Tuttle::Instrumenter.event_counts
    end

    def cache
      @cache = Rails.cache
      # TODO: make cache instrumentation controllable - this will automatically turn in on in Rails < 4.2
      # Instrumentation is always on in Rails 4.2+
      # if Rails::VERSION::STRING =~ /^4\.1\./ && !ActiveSupport::Cache::Store.instrument
      #   ActiveSupport::Cache::Store.instrument = true
      # end
      # @cache_events = Tuttle::Instrumenter.events.select {|e| /cache_(read|write)\.active_support/ =~ e.name }
      # @tuttle_cache_events = Tuttle::Instrumenter.cache_events
    end

    private

    def recognize_paths(path)
      results = {}
      %i[get post put delete patch].each {|method| results[method] = recognize_path(path, method: method)}
      results
    end

    # a version that handles engines - based on https://gist.github.com/jtanium/6114632
    # it's possible that multiple engines could handle a particular path.  So we will
    # capture each of them
    def recognize_path(path, options)
      recognized_paths = []
      recognized_paths << Rails.application.routes.recognize_path(path, options)
    rescue ActionController::RoutingError => exception
      # The main app didn't recognize the path, try the engines...
      Rails::Engine.subclasses.each do |engine|
        engine_instance = engine.instance
        engine_class = engine_instance.class
        begin
          recognized_path = engine_instance.routes.recognize_path(path, options)
          recognized_path[:engine] = engine_class
          recognized_paths << recognized_path
        rescue ActionController::RoutingError
          Tuttle::Engine.logger.info("Routing error recognizing path for #{path}")
        end
      end

      recognized_paths.empty? ? [{ error: exception.message }] : recognized_paths
    end

  end
end
