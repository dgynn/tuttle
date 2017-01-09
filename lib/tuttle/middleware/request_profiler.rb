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

        status = nil
        body = nil

        t0 = Time.current
        report = MemoryProfiler.report(options) do
          status, _headers, body = @app.call(env)
          body.close if body.respond_to?(:close)
        end
        response_time = Time.current - t0

        result = StringIO.new
        report.pretty_print(result)

        response = ["Report from Tuttle::Middeware::RequestProfiler\n"]
        response << "Time of request: #{Time.current}\n"
        response << "Response status: #{status}\n" unless status == 200
        response << "Response time: #{response_time}\n"
        response << "Response body size: #{body.body.length}\n" if body.respond_to?(:body)
        response << "\n"
        response << result.string
        [200, { 'Content-Type' => 'text/plain' }, response]
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

      # These methods *may* cause the method cache to be invalidated
      TRACE_METHODS = Set.new([:extend, :include, :const_set, :remove_const, :alias_method, :remove_method,
                               :prepend, :append_features, :prepend_features,
                               :public_constant, :private_constant, :autoload,
                               :define_method, :define_singleton_method])

      def profile_busted(env, _query_string)
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
        # The @cache_buster_tracepoint Dtraces Class/Module definitions (:class)
        # and calls to C method (:c_call) which would likely cause a method cache clear
        #
        # From the observed results...
        #   :method-cache-clear may fire more times than RubyVM.stat[]
        cache_busters = []

        # This is really still incomplete...
        # Internally, Ruby does not fire :c_call or :class for many events that would increment the :class_serial
        # For example `Person = Class.new` does not fire a :class event
        # And it also does create a new constant (:constant_state) but does not fire a :const_set event

        # Trace class definitions (which always(?) invalidate the cache) and c-calls which may invalidate the cache
        @cache_buster_tracepoint ||= TracePoint.new(:class, :c_call) do |trace|
          if trace.event == :class
            cache_busters << {
              :event => trace.event,
              :event_description => "Class definition",
              :location => "#{trace.path}##{trace.lineno}",
              :target_class => trace.self
            }
          elsif TRACE_METHODS.include?(trace.method_id)
            cache_busters << {
              :event => trace.event,
              :event_description => "#{trace.defined_class}##{trace.method_id}",
              :location => "#{trace.path}##{trace.lineno}",
              :target_class => trace.self.class,
              :defined_class => trace.defined_class,
              :method_id => trace.method_id
            }
          end
        end

        # Trace the request and capture the RubyVM.stat before/after
        vmstat_before = RubyVM.stat
        results = @cache_buster_tracepoint.enable do
          Busted.run(trace: true) do
            _, _, body = @app.call(env)
            body.close if body.respond_to?(:close)
          end
        end
        vmstat_after = RubyVM.stat

        # Prepare the output
        output = "\nRubyVM.stat:           Before     After      Change\n".dup
        [:global_method_state, :global_constant_state, :class_serial].each do |stat|
          output << format("%-22s %-10d %-10d %+d\n",
                           stat,
                           vmstat_before[stat],
                           vmstat_after[stat],
                           vmstat_after[stat] - vmstat_before[stat])
        end

        output << "\nCounts:\n"
        output << "method-cache-clear: #{results[:traces][:method].size}\n"
        output << "C calls that may cause cache clear: #{cache_busters.size}\n"
        grouped_traces = cache_busters.group_by do |trace_info|
          if trace_info[:event] == :c_call
            "#{trace_info[:defined_class]}##{trace_info[:method_id]}"
          else
            "Class Defined"
          end
        end
        grouped_traces.each do |grouping, traces|
          output << "  #{grouping}: #{traces.size}\n"
        end

        output << "\nTraces (method-cache-clear): (#{results[:traces][:method].size} times)\n"
        results[:traces][:method].each do |trace|
          output << "#{trace[:class]} - #{trace[:sourcefile]}##{trace[:lineno]}\n"
        end

        output << "\nTraces (method cache clearing calls): (#{cache_busters.size} times)\n"
        cache_busters.each do |trace_info|
          if trace_info[:event] == :c_call
            output << format("%s\#%s: %s %s\n",
                             trace_info[:defined_class],
                             trace_info[:method_id],
                             trace_info[:target_class],
                             trace_info[:location])
          else
            output << format("Class Definition: %s %s %s\n",
                             trace_info[:target_class],
                             trace_info[:defined_class],
                             trace_info[:location])
          end
        end

        [200,
         { 'Content-Type' => 'text/plain' },
         ["Tuttle - Ruby Method/Constant Caches Request Observer v0.0.1\n",
          "Ruby Version: #{RUBY_VERSION}\n",
          output]]
      end

    end
  end
end
