require_dependency 'tuttle/application_controller'
require 'rails/generators'
require 'tuttle/presenters/action_dispatch/routing/route_wrapper'

module Tuttle
  class RailsController < ApplicationController

    def index
      Rails::Generators.lookup! if Rails::Generators.subclasses.empty?
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

    def models
      @models = ActiveRecord::Base.descendants
      @models.sort_by!(&:name)
    end

    def database
      @conn = ActiveRecord::Base.connection
    end

    def helpers
      @helpers = ::ApplicationController.send(:modules_for_helpers,[:all])
    end

    def assets
      @sprockets = Rails.application.assets
      @engines = @sprockets.instance_variable_get(:@engines)
    end

    def routes
      @routes = Rails.application.routes.routes.collect do |route|
        Tuttle::Presenters::ActionDispatch::Routing::RouteWrapper.new(route)
      end
      # TODO: include engine-mounted routes
    end

    def instrumentation
      @events = Tuttle::Engine.events
      @event_counts = Tuttle::Engine.event_counts
    end

    def inflectors
      @test_word = params[:test_word] || ''

      @plurals = ActiveSupport::Inflector.inflections.plurals
      @singulars = ActiveSupport::Inflector.inflections.singulars
      @uncountables = ActiveSupport::Inflector.inflections.uncountables
      @humans = ActiveSupport::Inflector.inflections.humans
      @acronyms = ActiveSupport::Inflector.inflections.acronyms
    end

    def cache
      # TODO: make cache instrumentation controllable - this will automatically turn in on in Rails < 4.2
      # Instrumentation is always on in Rails 4.2+
      if Rails::VERSION::STRING =~ /^4\.1\./ && !ActiveSupport::Cache::Store.instrument
        ActiveSupport::Cache::Store.instrument=true
      end
      @cache = Rails.cache
      @cache_events = Tuttle::Engine.events.select {|e| /cache_(read|write)\.active_support/ =~ e.name }
      @tuttle_cache_events = Tuttle::Engine.cache_events
    end

  end
end
