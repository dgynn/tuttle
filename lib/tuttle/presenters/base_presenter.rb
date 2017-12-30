# frozen_string_literal: true
require 'tuttle'
require 'delegate'

module Tuttle
  module Presenters
    class BasePresenter < SimpleDelegator
      def initialize(delegate, view)
        @view = view
        super(delegate)
      end

      # noinspection RubyInstanceMethodNamingConvention
      def h
        @view
      end
    end
  end
end
