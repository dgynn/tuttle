# frozen_string_literal: true
require_dependency 'tuttle/application_controller'

module Tuttle
  class RequestController < ApplicationController

    def index
      @session_hash = session.to_hash
      @cookies_hash = request.cookie_jar.to_h
    end

  end
end
