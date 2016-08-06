require 'rails/generators'
require_dependency 'tuttle/application_controller'
require_dependency 'tuttle/presenters/action_dispatch/routing/route_wrapper'

module Tuttle
  class RailsController < ApplicationController

    def index
    end

    def controllers
      # TODO: Both ObjectSpace and .descendants approaches have issues with class reloading during development
      # It seems likely that .descendants will work best when Tuttle and Rails classes are not modified
      # but both approaches also require eager_load to be true
      # @controllers = ObjectSpace.each_object(::Class).select {|klass| klass < ActionController::Base }
      @controllers = ActionController::Base.descendants
      @controllers.reject! {|controller| controller <= Tuttle::ApplicationController || controller.abstract?}
      @controllers.sort_by!(&:name)
    end

    def engines
      @engines = Rails::Engine.subclasses.map(&:instance)
    end

    def generators
      Rails::Generators.lookup! if 'true' == params[:load_all_generators]
      @generators = Rails::Generators.subclasses.group_by(&:base_name)
    end

    def models
      @models = ActiveRecord::Base.descendants
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
      @sprockets = Rails.application.assets
      # TODO: revisit detection of "engines" which are classified as processors, transformers, etc.
    end

    def routes
      @routes = Rails.application.routes.routes.collect do |route|
        Tuttle::Presenters::ActionDispatch::Routing::RouteWrapper.new(route)
      end
      # TODO: include engine-mounted routes
    end

    def instrumentation
      @events = Tuttle::Instrumenter.events
      @event_counts = Tuttle::Instrumenter.event_counts
    end

    def cache
      # TODO: make cache instrumentation controllable - this will automatically turn in on in Rails < 4.2
      # Instrumentation is always on in Rails 4.2+
      if Rails::VERSION::STRING =~ /^4\.1\./ && !ActiveSupport::Cache::Store.instrument
        ActiveSupport::Cache::Store.instrument = true
      end
      @cache = Rails.cache
      @cache_events = Tuttle::Instrumenter.events.select {|e| /cache_(read|write)\.active_support/ =~ e.name }
      @tuttle_cache_events = Tuttle::Instrumenter.cache_events
    end

  end
end
