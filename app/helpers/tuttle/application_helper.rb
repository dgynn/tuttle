# frozen-string-literal: true

module Tuttle
  module ApplicationHelper
    def truth_label(is_true, true_label = 'true', false_label = 'false')
      content_tag(:span, is_true ? true_label : false_label,
                  class: ['label', is_true ? 'label-success' : 'label-danger'])
    end

    def tuttle_redacted(enumarator)
      enumarator.collect do |key, value|
        yield key, redact_by_key(key, value)
      end
    end

    def main_app_root_path
      main_app.respond_to?(:root_path) ? main_app.root_path : '/'
    end

    def main_app_root_url
      main_app.respond_to?(:root_url) ? main_app.root_url : '/'
    end

    def rails_guides_versioned_url(path)
      "http://guides.rubyonrails.org/v#{Tuttle::VersionDetector.rails_major_minor}/#{path}"
    end

    private

    def redact_by_key(key, value)
      case key
      when 'password', /(_secret|_credentials)/
        '--HIDDEN--'
      else
        value
      end
    end
  end
end
