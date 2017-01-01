require_dependency 'tuttle/application_controller'

module Tuttle
  class GemsController < ApplicationController

    def index
    end

    def http_clients
    end

    def json
    end

    # rubocop:disable Style/AccessorMethodName
    def get_process_mem
      require 'get_process_mem' rescue nil
      require 'get_process_mem/version' rescue nil
      if defined?(GetProcessMem)
        @memory_self = GetProcessMem.new
        @memory_parent = GetProcessMem.new(Process.ppid)
      end
    end

    def other
    end

  end
end
