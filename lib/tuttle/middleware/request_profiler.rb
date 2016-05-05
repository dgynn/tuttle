# frozen-string-literal: true

module Tuttle
  module Middleware
    class RequestProfiler

      def initialize(app)
        @app = app
      end

      def call(env)
        query_string = env['QUERY_STRING']

        tuttle_profiler_action = /tuttle\-profiler=([\w\-]*)/.match(query_string) { |m| m[1] }

        case tuttle_profiler_action
        when 'memory_profiler', 'memory'
          profile_memory(env, query_string)
        when 'ruby-prof', 'cpu'
          profile_cpu(env, query_string)
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

        case rubyprof_printer
        when 'flat'
          ::RubyProf::FlatPrinter.new(data).print(result, options)
          content_type = 'text/plain'
        when 'graph'
          ::RubyProf::GraphHtmlPrinter.new(data).print(result, options)
        when 'stack', 'call_stack'
          ::RubyProf::CallStackPrinter.new(data).print(result, options)
        else
          require 'tuttle/ruby_prof/fast_call_stack_printer'
          options[:application] = env['REQUEST_URI']
          ::Tuttle::RubyProf::FastCallStackPrinter.new(data).print(result, options)
        end

        [200, { 'Content-Type' => content_type }, [result.string]]
      end

    end
  end
end
