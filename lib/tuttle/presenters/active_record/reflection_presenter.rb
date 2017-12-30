# frozen_string_literal: true
require_dependency 'tuttle/presenters/base_presenter'

module Tuttle
  module Presenters
    module ActiveRecord
      class ReflectionPresenter < ::Tuttle::Presenters::BasePresenter

        def name; super.inspect end
        def macro; super.inspect end
        def type; super rescue 'Unknown' end

        def inverse_of
          if has_inverse?
            h.content_tag(:span, has_inverse?.inspect, class: options[:inverse_of].present? ? 'specified' : 'autodetected')
          end
        end

        def scoped?
          # TODO: potentially show the scope
          h.true_label(scope.present?, 'scoped')
        end

        def polymorphic?
          h.true_label(super, 'polymorphic')
        end

        def validate?
          h.true_label(super, 'validate')
        end

        def options_dependent; options[:dependent] rescue 'Unknown' end
        def options_class_name; options[:class_name] rescue 'Unknown' end

        def options_autosave
          h.true_label(options[:autosave].present?, 'autosave')
        end

        def options_required
          ## Todo handle auto-required?
          h.true_label(options[:required].present?, 'required')
        end

        def foreign_key; super rescue 'Unknown' end

        def options_other
          other_options = options.except(:polymorphic, :dependent, :class_name, :autosave, :before_add, :before_remove)
          other_options.inspect unless other_options.empty?
        end

      end
    end
  end
end
