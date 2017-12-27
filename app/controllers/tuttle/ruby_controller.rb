# frozen-string-literal: true

require_dependency 'tuttle/application_controller'

module Tuttle
  class RubyController < ApplicationController

    ENV_FILTERS = [/.*_(URL|PASSWORD|KEY|KEY_BASE|AUTHENTICATION)$/].freeze

    def index
      # TODO: need better filter for sensitive values. this covers DB-style URLs with passwords, passwords, and keys
      env_hash = ENV.to_hash
      env_hash = ActionDispatch::Http::ParameterFilter.new(ENV_FILTERS).filter(env_hash) unless params[:nofilter]
      @filtered_env = env_hash.sort
    end

    def tuning
      @gc_enabled = (GC.disable ? false : GC.enable)

      # taken verbatim from the ruby 2.2 man page
      @gc_params = {
        'RUBY_GC_HEAP_INIT_SLOTS' =>               'Initial allocation slots.  Introduced in Ruby 2.1, default: 10000.',
        'RUBY_GC_HEAP_FREE_SLOTS' =>               'Prepare at least this amount of slots after GC. Allocate this number slots if there are not enough slots.  Introduced in Ruby 2.1, default: 4096',
        'RUBY_GC_HEAP_GROWTH_FACTOR' =>            'Increase allocation rate of heap slots by this factor.  Introduced in Ruby 2.1, default: 1.8, minimum: 1.0 (no growth)',
        'RUBY_GC_HEAP_GROWTH_MAX_SLOTS' =>         'Allocation rate is limited to this number of slots, preventing excessive allocation due to RUBY_GC_HEAP_GROWTH_FACTOR.  Introduced in Ruby 2.1, default: 0 (no limit)',
        'RUBY_GC_HEAP_OLDOBJECT_LIMIT_FACTOR' =>   'Perform a full GC when the number of old objects is more than R * N, where R is this factor and N is the number of old objects after the last full GC.  Introduced in Ruby 2.1.1, default: 2.0',
        'RUBY_GC_MALLOC_LIMIT' =>                  'The initial limit of young generation allocation from the malloc-family.  GC will start when this limit is reached.  Default: 16MB',
        'RUBY_GC_MALLOC_LIMIT_MAX' =>              'The maximum limit of young generation allocation from malloc before GC starts.  Prevents excessive malloc growth due to RUBY_GC_MALLOC_LIMIT_GROWTH_FACTOR.  Introduced in Ruby 2.1, default: 32MB.',
        'RUBY_GC_MALLOC_LIMIT_GROWTH_FACTOR' =>    'Increases the limit of young generation malloc calls, reducing GC frequency but increasing malloc growth until RUBY_GC_MALLOC_LIMIT_MAX is reached. Introduced in Ruby 2.1, default: 1.4, minimum: 1.0 (no growth)',
        'RUBY_GC_OLDMALLOC_LIMIT' =>               'The initial limit of old generation allocation from malloc, a full GC will start when this limit is reached.  Introduced in Ruby 2.1, default: 16MB',
        'RUBY_GC_OLDMALLOC_LIMIT_MAX' =>           'The maximum limit of old generation allocation from malloc before a full GC starts.  Prevents excessive malloc growth due to RUBY_GC_OLDMALLOC_LIMIT_GROWTH_FACTOR.  Introduced in Ruby 2.1, default: 128MB',
        'RUBY_GC_OLDMALLOC_LIMIT_GROWTH_FACTOR' => 'Increases the limit of old generation malloc allocation, reducing full GC frequency but increasing malloc growth until RUBY_GC_OLDMALLOC_LIMIT_MAX is reached.  Introduced in Ruby 2.1, default: 1.2, minimum: 1.0 (no growth)'
      }
    end

    def miscellaneous
    end

    def constants
      # Global constants minus a few deprecated constants (to prevent warnings)
      @constants = (Object.constants - %i[Bignum Fixnum NIL TRUE FALSE TimeoutError]).
                      sort.
                      map { |sym| [sym, Object.const_get(sym).class, Object.const_get(sym)] }.
                      reject { |_sym, klass, _val| klass == Class || klass == Module }
    end

    def extensions
      @obj_extensions = Object.methods.select { |meth| Object.method(meth).source_location }.
                               sort.
                               map { |meth| [meth, *Object.method(meth).source_location] }
    end

  end
end
