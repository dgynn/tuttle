### Unreleased

* Features
  * ActiveSupport inspection including Dependencies, TimeZones, and Deprecation
  * Load path inspection (Ruby and Active Support autoloading)
  * No longer requires asset pipeline

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

