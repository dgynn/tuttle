# Tuttle

[![Build Status](https://github.com/dgynn/tuttle/workflows/tests/badge.svg)](https://github.com/dgynn/tuttle/actions)
[![Code Climate](https://codeclimate.com/github/dgynn/tuttle/badges/gpa.svg)](https://codeclimate.com/github/dgynn/tuttle)

Tuttle is a tool that helps Rails developers peek behind the curtain to inspect runtime configuration
information for their applications. Tuttle can help with troubleshooting misconfigured
apps or just help you better understand what is going on inside the frameworks you use.

#### Features

* Web dashboard mounted in your running app
  * Rails general configuration including defaults
  * Runtime internals of libraries and frameworks (eg ActiveRecord Query Cache)
  * Application inventory of Controllers and Models
  * Gems loaded
  * Ruby VM runtime information (GC stats, tuning parameters)
* Optional profiling middleware for on-demand request profiling
  * Memory profiling using [memory_profiler](https://github.com/SamSaffron/memory_profiler)
  * CPU profiling using [ruby-prof](https://github.com/ruby-prof/ruby-prof)


Tuttle has no dependencies other than Rails but works with a number of gems if
they are loaded to provide inspections.
Gems supported include devise, paperclip, active_model_serializers, cancancan, and more.

Tuttle is still in beta/proof-of-concept mode but is safe to use in development and disabled by default in other environments.

You can see it in action in a [simple demo application](http://tuttle-demo.herokuapp.com/). The [source code](https://github.com/dgynn/tuttle-demo) for that demo is also on GitHub.

## To use...

Add tuttle to your Gemfile
```ruby
gem 'tuttle'

# Include optional profiling gems
gem 'memory_profiler'
gem 'ruby-prof'

```
Browse to `/tuttle`

## Configuration

Tuttle will automatically be enabled and mounted in development. To control the
configuration, you can use an initializer.

config/initializers/tuttle.rb
```ruby
if defined?(::Tuttle::Engine)
  Tuttle.setup do |config|
    config.enabled = true           # Defaults to true in development, false in other environments
    config.automount_engine = true  # Defaults to true to mount the engine at /tuttle
    config.enable_profiling = true  # Defaults to false
  end
end
```

**Important:** Do not enable Tuttle in production. Tuttle does not require authentication
and exposes internal application details. Sensitive data should be filtered but
it is still not something end users should be able to access.

It is also possible to use the profiling middleware without the Tuttle engine enabled.

You can directly include the profiling middleware as follows:

```ruby
  # Add memory/cpu profiler middleware at the end of the stack
  require 'tuttle/middleware/request_profiler'
  Rails.application.config.middleware.use Tuttle::Middleware::RequestProfiler
```
