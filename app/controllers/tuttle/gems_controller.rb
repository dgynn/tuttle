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
      require 'get_process_mem/version'
    end

    def other
    end

  end
end
