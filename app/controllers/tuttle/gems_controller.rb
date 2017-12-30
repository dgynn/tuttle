# frozen_string_literal: true
require_dependency 'tuttle/application_controller'

module Tuttle
  class GemsController < ApplicationController

    def index
      @gemspecs = Bundler.rubygems.all_specs.sort_by(&:name)
    end

    def http_clients
    end

    def json
    end

    def get_process_mem # rubocop:disable Naming/AccessorMethodName
      require 'get_process_mem'
      require 'get_process_mem/version'
      @memory_self = GetProcessMem.new
      @memory_parent = GetProcessMem.new(Process.ppid)
    end

    def other
    end

  end
end
