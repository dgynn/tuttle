module Tuttle
  module Middleware
    class RequestProfiler

      def initialize(app)
        @app = app
      end

      def call(env)
        query_string = env['QUERY_STRING']

        mp_action    = /mp=([\w\-]*)/.match(query_string) { $1.to_sym }

        case mp_action
        when :'profile-memory'
          require 'memory_profiler'

          query_params = Rack::Utils.parse_nested_query(query_string)
          options = {
              :ignore_files => query_params['memory_profiler_ignore_files'],
              :allow_files => query_params['memory_profiler_allow_files'],
          }
          options[:top]= Integer(query_params['memory_profiler_top']) if query_params.key?('memory_profiler_top')
          result = StringIO.new
          report = MemoryProfiler.report(options) do
            _,_,body = @app.call(env)
            body.close if body.respond_to? :close
          end
          report.pretty_print(result)
          [200, { 'Content-Type' => 'text/plain' }, ["Report from Tuttle::Middeware::RequestProfiler\n", result.string]]
        when :'profile-prof', :'profile-cpu'

          require 'ruby-prof'
          result = StringIO.new
          data = ::RubyProf::Profile.profile do
            _,_,body = @app.call(env)
            body.close if body.respond_to? :close
          end

          mp_printer    = /mp_printer=([\w]*)/.match(query_string) { $1.to_sym }
          case mp_printer
          when :flat
            ::RubyProf::FlatPrinter.new(data).print(result)
            [200, { 'Content-Type' => 'text/plain' }, [result.string]]
          when :graph
            ::RubyProf::GraphHtmlPrinter.new(data).print(result)
            [200, { 'Content-Type' => 'text/html' }, [result.string]]
          when :fast_stack
            require 'tuttle/ruby_prof/fast_call_stack_printer'
            options = { :application => env['REQUEST_URI']}
            ::Tuttle::RubyProf::FastCallStackPrinter.new(data).print(result, options)
            [200, { 'Content-Type' => 'text/html' }, [result.string]]
          else
            options = { :application => env['REQUEST_URI'] }
            ::RubyProf::CallStackPrinter.new(data).print(result, options)
            [200, { 'Content-Type' => 'text/html' }, [result.string]]
          end

        else
          @app.call(env)
        end

      end
    end
  end
end
