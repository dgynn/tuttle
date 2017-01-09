### 0.0.6

* Features
  * Easier configuration with config.enable_profiling to load profiling middleware
  * Improved Asset Pipeline configuration inspector
  * Improved Rails Caching configuration inspector
  * Basic ActiveJob configuration inspector
  * Improved Rails general configuration options from Rails Guides
  * Syntax highlighting with highlight.js
  * Experimental inspector for Facter
  * Experimental profiler for Busted with additional DTrace inspections

### 0.0.5

* Features
  * Request profiling middleware for ruby-prof and memory_profiler
  * ActiveSupport inspection including Dependencies, TimeZones, and Deprecation
  * Load path inspection (Ruby and Active Support autoloading)
  * No longer requires asset pipeline
  * Experimental inspector for Rack MiniProfiler and ActiveModelSerializers

### 0.0.4

* Features
  * Experimental Rails5 support
  * Paperclip registry inspection
  * ActiveRecord schema cache and schema_cache.dump inspection
  * Configuration control of notification_tracking

### 0.0.3

* Features
  * Rails caching instrumentation
  * Improved initialization/configuration approach
  * Gem detection and reporting for HTTP clients and JSON libraries
  * Ruby GC tuning stats and advice
  * Favicon!
  * Experimental Postgres stored-procedure cache inspection

### 0.0.2

* Features
  * Tuttle::Engine will now auto-mount routes
  * Engine configurable via initializer
  * ActiveSupport cache configuration inspection
  * ActiveSupport inflectors inspection and simple testing

### 0.0.1

* Features
  * Initial engine implementation with instrumentation monitoring
  * Rails inspection for general configuration, controllers, models, assets, helpers
  * Ruby VM inspection
  * Devise configuration inspection
  * CanCanCan configuration inspection and simple rule testing

