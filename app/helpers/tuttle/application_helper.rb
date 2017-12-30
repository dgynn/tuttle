# frozen_string_literal: true
module Tuttle
  module ApplicationHelper
    BUNDLER_GEM_PATHS_REGEX = %r{(#{Bundler.rubygems.gem_dir}|#{File.realpath(Bundler.rubygems.gem_dir)})+(/bundler)*/gems}

    # Display true/false label with text overrides
    def truth_label(is_true, true_label = 'true', false_label = 'false')
      content_tag(:span, is_true ? true_label : false_label,
                  class: ['label', is_true ? 'label-success' : 'label-danger'])
    end

    # Display label if condition is true
    def true_label(is_true, true_label = 'true')
      content_tag(:span, true_label, class: %w[label label-success]) if is_true
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

    def link_to_rails_guide(file, title)
      content_tag(:a, title, :href => rails_guides_versioned_url(file + '.html'))
    end

    def rails_guides_versioned_url(path)
      "http://guides.rubyonrails.org/v#{Tuttle::VersionDetector.rails_major_minor}/#{path}"
    end

    def display_path(path)
      return if path.blank?
      display_location =
        if path.start_with?(Rails.root.to_s)
          path.gsub(Rails.root.to_s, "$RAILS_ROOT")
        elsif File.realpath(path).start_with?(File.realpath(Bundler.rubygems.gem_dir))
          File.realpath(path).gsub(BUNDLER_GEM_PATHS_REGEX, "$GEMS")
        else
          path
        end
      expanded_path = File.expand_path(path)
      content_tag(:span, display_location, :class => 'tuttle-path', :data => { :initial => path, :expanded => expanded_path })
    end

    def display_source_locaction(path, line)
      return content_tag(:span, "Unknown", :class => 'tuttle-path') if path.nil?

      display_location = file_location(path)
      expanded_path = File.expand_path(path)
      content_tag(:span, :class => 'tuttle-path', :data => { :initial => path, :expanded => expanded_path }) do
        "#{display_location}##{line}"
      end
    end

    def file_location(path)
      if path.start_with?(Rails.root.to_s)
        path.gsub(Rails.root.to_s, "$RAILS_ROOT")
      elsif path.start_with?(RbConfig::CONFIG['rubylibdir'])
        path.gsub(RbConfig::CONFIG['rubylibdir'], "$RUBY_LIB_DIR")
      elsif path == "<internal:prelude>"
        path
      elsif File.realpath(path).start_with?(File.realpath(Bundler.rubygems.gem_dir))
        File.realpath(path).gsub(BUNDLER_GEM_PATHS_REGEX, "$GEMS")
      else
        path
      end
    end

    def value_inspect(val, hide_nil: false)
      case val
      when NilClass
        content_tag(:code, val.inspect) unless hide_nil
      when String
        content_tag(:code, val.inspect)
      when Symbol
        content_tag(:code, val.inspect)
      else
        val.inspect
      end
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
