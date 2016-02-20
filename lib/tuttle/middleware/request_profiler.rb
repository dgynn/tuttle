# frozen-string-literal: true

module Tuttle
  module Middleware
    class RequestProfiler

      def initialize(app)
        @app = app
      end

      def call(env)
        query_string = env['QUERY_STRING']

        mp_action = /mp=([\w\-]*)/.match(query_string) { $1.to_sym }

        case mp_action
        when :'profile-memory'
          profile_memory(env, query_string)
        when :'profile-prof', :'profile-cpu'
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
            :allow_files => query_params['memory_profiler_allow_files'],
        }
        options[:top]= Integer(query_params['memory_profiler_top']) if query_params.key?('memory_profiler_top')

        report = MemoryProfiler.report(options) do
          _,_,body = @app.call(env)
          body.close if body.respond_to? :close
        end

        result = StringIO.new
        report.pretty_print(result)

        [200, { 'Content-Type' => 'text/plain' }, ["Report from Tuttle::Middeware::RequestProfiler\n", result.string]]
      end

      def profile_cpu(env, query_string)
        require 'ruby-prof'

        data = ::RubyProf::Profile.profile do
          _, _, body = @app.call(env)
          body.close if body.respond_to? :close
        end

        result = StringIO.new
        mp_printer    = /mp_printer=([\w]*)/.match(query_string) { $1.to_sym }
        content_type = 'text/html'

        case mp_printer
        when :flat
          ::RubyProf::FlatPrinter.new(data).print(result)
          content_type = 'text/plain'
        when :graph
          ::RubyProf::GraphHtmlPrinter.new(data).print(result)
        when :fast_stack
          require 'tuttle/ruby_prof/fast_call_stack_printer'
          ::Tuttle::RubyProf::FastCallStackPrinter.new(data).print(result, { :application => env['REQUEST_URI']})
        else
          ::RubyProf::CallStackPrinter.new(data).print(result)
        end

        [200, { 'Content-Type' => content_type }, [result.string]]
      end

    end
  end
end
