module Tuttle
  class VersionDetector

    def self.rails_major_minor
      @rails_major_minor ||= Rails::VERSION::STRING.slice(0, 3)
    end

  end
end
