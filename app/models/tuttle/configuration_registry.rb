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
        if Rails::VERSION::MAJOR == 4
          data.merge!(YAML.load_file(File.expand_path('rails_config_v4.x.yml', data_dir)))
        elsif Rails::VERSION::MAJOR == 5
          data.merge!(YAML.load_file(File.expand_path('rails_config_v5.x.yml', data_dir)))
        end

        data
      end
    end
  end
end
