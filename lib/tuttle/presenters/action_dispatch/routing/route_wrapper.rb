# frozen_string_literal: true
module Tuttle
  module Presenters
    module ActionDispatch
      module Routing
        class RouteWrapper < ::ActionDispatch::Routing::RouteWrapper

          def endpoint_or_app_name
            if uses_dispatcher?
              endpoint
            else
              rack_app.is_a?(Class) ? rack_app : rack_app.class
            end
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

          def route_problem
            # TODO: this does not handle ImplicitRender actions where the method does not exist but the template does
            return @route_problem if defined?(@route_problem)
            @route_problem =
              if controller_klass
                if requirements[:action] && controller_klass.action_methods.exclude?(action)
                  'Action does not exist'
                end
              elsif requirements[:controller]
                'Controller does not exist'
              end
          end

          private

          def controller_klass
            return @controller_klass if defined?(@controller_klass)
            @controller_klass =
              if requirements[:controller].present?
                begin
                  controller_reference(controller)
                rescue NameError
                  # No class is defined for the give route
                  # puts "NameError for #{requirements[:controller]}"
                  nil
                end
              end
          end

          # Copied from <actionpack>/lib/action_dispatch/routing/route_set.rb
          def controller_reference(controller_param)
            const_name = "#{controller_param.camelize}Controller"
            ::ActiveSupport::Dependencies.constantize(const_name)
          end

        end
      end
    end
  end
end
