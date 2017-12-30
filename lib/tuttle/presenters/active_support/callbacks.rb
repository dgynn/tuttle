# frozen_string_literal: true
require 'delegate'

module Tuttle
  module Presenters
    module ActiveSupport
      module Callbacks
        class CallbackWrapper < DelegateClass(::ActiveSupport::Callbacks::Callback)
          def safe_source_location(controller_instance)
            controller_instance.method(filter).try(:source_location)
          rescue StandardError
            [nil, nil]
          end
        end

        class CallbackChainWrapper < DelegateClass(::ActiveSupport::Callbacks::CallbackChain)
          delegate :size, to: :chain

          def each(&block)
            chain.map { |cb| CallbackWrapper.new(::Tuttle::Presenters::ActiveSupport::Callbacks::CallbackWrapper.new(cb)) } .each(&block)
          end
        end
      end
    end
  end
end
