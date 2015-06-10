module Tuttle
  module ApplicationHelper

    def truth_label(is_true, true_label='true'.freeze, false_label='false'.freeze)
      "<span class='label label-#{ is_true ? 'success'.freeze : 'danger'.freeze}'>#{ is_true ? true_label : false_label}</span>".html_safe
    end

    def tuttle_redacted(enumarator)
      enumarator.each do |key, value|
        yield key, redact_by_key(key, value)
      end
    end

    private

    def redact_by_key(key, value)
      case key
      when 'password', %r/(_secret|_credentials)/
        '--HIDDEN--'.freeze
      else
        value
      end
    end

  end
end
