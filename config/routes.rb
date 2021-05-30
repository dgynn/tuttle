# frozen_string_literal: false
Tuttle::Engine.routes.draw do

  root :to => 'home#index'

  namespace :rails do
    get '', :action => :index
    get :controllers, :models, :database, :schema_cache, :helpers, :assets,
        :routes, :instrumentation, :cache, :generators, :engines
  end

  namespace :ruby do
    get '', :action => :index
    get :miscellaneous, :tuning, :extensions, :constants
  end

  namespace :gems do
    get '', :action => :index
    get :get_process_mem, :http_clients, :json, :other
  end

  namespace :i18n do
    get '', :action => :index
    get :localize, :translations
  end

  namespace :active_support do
    get '', :action => :index
    get :dependencies, :inflectors, :time_zones
  end

  if defined?(ActiveJob)
    namespace :active_job do
      get '', :action => :index
    end
  end

  get '/rack_mini_profiler' => 'rack_mini_profiler#index'

  get '/request' => 'request#index'

  if defined?(ActiveModelSerializers)
    get '/active_model_serializers' => 'active_model_serializers#index' # 0.10.x?
  elsif defined?(ActiveModel::Serializer)
    get '/active_model_serializers' => 'active_model_serializers#index' # 0.9.x?
  end

  if defined?(Devise)
    get '/devise' => 'devise#index'
  end

  if defined?(CanCanCan)
    get '/cancancan' => 'cancancan#index'
    get '/cancancan/rule_tester' => 'cancancan#rule_tester'
  end

  if defined?(::ExecJS)
    get '/execjs' => 'execjs#index'
  end

  if defined?(::Rack::Attack)
    get '/rack-attack' => 'rack_attack#index'
  end

end
