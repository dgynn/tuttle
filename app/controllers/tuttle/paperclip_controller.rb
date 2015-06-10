require_dependency 'tuttle/application_controller'
require 'paperclip/version' if defined?(::Paperclip)

module Tuttle
  class PaperclipController < ApplicationController

    def index
      render(plain: "Paperclip not installed") and return unless defined?(::Paperclip)
      @pcar = Paperclip::AttachmentRegistry.instance
    end

  end
end
