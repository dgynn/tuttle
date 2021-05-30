# frozen_string_literal: true
module Tuttle
  class ConfigurationRegistry

    class << self
      def data
        @registry ||= load_data
      end

      private

      def load_data
        data_dir = Tuttle::Engine.instance.paths['config'].first

        data = YAML.load_file(File.expand_path('rails_config_base.yml', data_dir))
        if Rails::VERSION::MAJOR == 6
          data.merge!(YAML.load_file(File.expand_path('rails_config_v6.x.yml', data_dir)))
        end

        data
      end
    end
  end
end
