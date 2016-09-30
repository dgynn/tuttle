# frozen_string_literal: true

module Tuttle
  module Middleware
    class RequestProfiler

      def initialize(app)
        @app = app
      end

      def call(env)
        query_string = env['QUERY_STRING']

        tuttle_profiler_action = /(^|[&?])tuttle\-profiler=([\w\-]*)/.match(query_string) { |m| m[2] }

        case tuttle_profiler_action
        when 'memory_profiler', 'memory'
          profile_memory(env, query_string)
        when 'ruby-prof', 'cpu'
          profile_cpu(env, query_string)
        when 'busted'
          profile_busted(env, query_string)
        else
          @app.call(env)
        end
      end

      private

      def profile_memory(env, query_string)
        require 'memory_profiler'

        query_params = Rack::Utils.parse_nested_query(query_string)
        options = {
          :ignore_files => query_params['memory_profiler_ignore_files'],
          :allow_files => query_params['memory_profiler_allow_files']
        }
        options[:top] = Integer(query_params['memory_profiler_top']) if query_params.key?('memory_profiler_top')

        report = MemoryProfiler.report(options) do
          _, _, body = @app.call(env)
          body.close if body.respond_to?(:close)
        end

        result = StringIO.new
        report.pretty_print(result)

        [200, { 'Content-Type' => 'text/plain' }, ["Report from Tuttle::Middeware::RequestProfiler\n", result.string]]
      end

      def profile_cpu(env, query_string)
        require 'ruby-prof'
        require 'tuttle/ruby_prof/fast_call_stack_printer'

        query_params = Rack::Utils.parse_nested_query(query_string)
        options = {}
        options[:threshold] = Float(query_params['ruby-prof_threshold']) if query_params.key?('ruby-prof_threshold')
        rubyprof_printer = /ruby\-prof_printer=([\w]*)/.match(query_string) { |m| m[1] }

        data = ::RubyProf::Profile.profile do
          _, _, body = @app.call(env)
          body.close if body.respond_to? :close
        end

        result = StringIO.new
        content_type = 'text/html'

        profiler = case rubyprof_printer
                   when 'flat'
                     content_type = 'text/plain'
                     ::RubyProf::FlatPrinter
                   when 'graph'
                     ::RubyProf::GraphHtmlPrinter
                   when 'stack', 'call_stack'
                     ::RubyProf::CallStackPrinter
                   else
                     options[:application] = env['REQUEST_URI']
                     ::Tuttle::RubyProf::FastCallStackPrinter
                   end

        profiler.new(data).print(result, options)

        [200, { 'Content-Type' => content_type }, [result.string]]
      end

      def profile_busted(env, query_string)
        # Note: Requires Busted (of course) and DTrace so will need much better error handling and information
        # For DTrace on OS X (post 10.11) you may need to disable SIP as well as be running with root privileges
        # https://derflounder.wordpress.com/2015/10/01/system-integrity-protection-adding-another-layer-to-apples-security-model/

        require 'busted'
        require 'busted/profiler/default' # Required so `autoload :Default` does not get included in trace

        # Notes:
        # Much of this is per https://tenderlovemaking.com/2015/12/23/inline-caching-in-mri.html
        #   and https://github.com/charliesome/charlie.bz/blob/master/posts/things-that-clear-rubys-method-cache.md
        # RubyVM.stat tracks the :global_method_state, :global_constant_state, and :class_serial
        #   :global_method_state - "global serial number that increments every time certain classes get mutated"
        #      ** Changes to this are BAD because they invalidate all caches
        #   :global_constant_state - counter of constants defined *or redefined(?)*
        #   :class_serial - global serial number that increments every time a method is Class is created/modified (?-verify)
        # Since Ruby 2.1(2.2?) the method caches are per-Class rather than global.
        #   So clearing the method cache of a single Class is less of a performance hit than blowing away the entire method cache
        #
        # Busted Dtraces :method-cache-clear internal events which are when Ruby says the method cache was cleared
        # The @tracer Dtraces Class/Module definitions (:end) and calls to C method (:c_call) which would likely cause a method cache clear
        #
        # From the observed results...
        #   :method-cache-clear may fire more times than RubyVM.stat[]
        cache_busters = []
        # These methods *may* cause the method cache to be invalidated
        trace_methods = Set.new([:extend, :include, :const_set, :remove_const, :alias_method, :remove_method,
                                 :prepend, :append_features, :prepend_features,
                                 :public_constant, :private_constant, :autoload,
                                 :define_method, :define_singleton_method])

        # Trace class definitions (which always invalidate the cache) and c-calls which may invalidate the cache
        # TODO: decide whether :start or :end calls should be traced
        @tracer = TracePoint.new(:end, :c_call) do |trace|
          if trace.event == :end
            cache_busters << {
                :event => trace.event,
                :location => "#{trace.path}:#{trace.lineno}",
                :target_class => trace.self
            }
          elsif trace_methods.include?(trace.method_id)
            cache_busters << {
                :event => trace.event,
                :location => "#{trace.path}:#{trace.lineno}",
                :target_class => trace.self.class,
                :defined_class => trace.defined_class,
                :method_id => trace.method_id
            }
          end
        end

        # Trace the request and capture the RubyVM.stat before/after
        vmstat_before = RubyVM.stat
        @tracer.enable
        results = Busted.run(trace: true) do
          _, _, body = @app.call(env)
          body.close if body.respond_to?(:close)
        end
        @tracer.disable
        vmstat_after = RubyVM.stat

        # Prepare the output
        # TODO: convert to ERB (with table?)
        output = "\nRubyVM.stat:\n".dup
        [:global_method_state, :global_constant_state, :class_serial].each do |stat|
          output << sprintf("%-25s %10d %10d %+d\n", stat, vmstat_before[stat], vmstat_after[stat],  vmstat_after[stat] - vmstat_before[stat])
        end

        output << "\nTraces (method-cache-clear):\n"
        results[:traces][:method].each do |trace|
          output << "#{trace[:class]} - #{trace[:sourcefile]}##{trace[:lineno]}\n"
        end

        output << "\nTraces (method cache clearing calls):\n"
        cache_busters.each do |trace_info|
          if trace_info[:event] == :c_call
            output << sprintf("%s\#%s: %s %s\n",
                              trace_info[:defined_class],
                              trace_info[:method_id],
                              trace_info[:target_class],
                              # trace_info[:target_object_id],
                              trace_info[:location])
          else
            output << sprintf("Class/Module Definition: %s %s\n",
                              trace_info[:target_class],
                              #trace_info[:target_object_id],
                              trace_info[:location])
          end
        end

        [ 200,
          { 'Content-Type' => 'text/plain' },
          [ "Tuttle - Ruby Method/Constant Caches Request Observer v0.0.1\n",
            "Ruby Version: #{RUBY_VERSION}\n",
            output
          ]
        ]
      end

    end
  end
end
