require_dependency 'tuttle/application_controller'
require 'paperclip/version' if defined?(::Paperclip)

module Tuttle
  class PaperclipController < ApplicationController

    def index
      # Note: in development with reloading, classes will show up in the registry multiple times
      render(plain: "Paperclip not installed") and return unless defined?(::Paperclip)
      @pcar = Paperclip::AttachmentRegistry.instance
    end

  end
end
