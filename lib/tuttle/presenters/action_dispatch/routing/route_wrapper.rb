module Tuttle
  module Presenters
    module ActionDispatch
      module Routing
        class RouteWrapper < ::ActionDispatch::Routing::RouteWrapper

          def endpoint_or_app_name
            uses_dispatcher? ? endpoint : (rack_app.is_a?(Class) ? rack_app : rack_app.class)
          end

          def controller
            super if uses_dispatcher?
          end

          def action
            super if uses_dispatcher?
          end

          def uses_dispatcher?
            rack_app.respond_to?(:dispatcher?)
          end

          def is_internal_to_rails?
            !!internal?
          end

        end
      end
    end
  end
end
