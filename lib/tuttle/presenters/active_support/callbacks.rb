require 'delegate'

module Tuttle
  module Presenters
    module ActiveSupport
      module Callbacks

        class CallbackWrapper < DelegateClass(::ActiveSupport::Callbacks::Callback)
          def safe_source_location(controller_instance)
            controller_instance.method(filter).try(:source_location) rescue [nil, nil]
          end
        end

        class CallbackChainWrapper < DelegateClass(::ActiveSupport::Callbacks::CallbackChain)
          def size
            chain.size
          end

          def each(&block)
            chain.map { |cb| CallbackWrapper.new(::Tuttle::Presenters::ActiveSupport::Callbacks::CallbackWrapper.new(cb)) } .each(&block)
          end
        end
      end
    end
  end
end