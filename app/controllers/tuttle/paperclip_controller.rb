# frozen_string_literal: true
require_dependency 'tuttle/application_controller'
require 'paperclip/version' if defined?(Paperclip)

module Tuttle
  class PaperclipController < ApplicationController

    def index
      # Note: in development with reloading, classes will show up in the registry multiple times
      @pcar = Paperclip::AttachmentRegistry.instance
    end

  end
end
