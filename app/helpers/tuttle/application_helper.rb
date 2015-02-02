module Tuttle
  module ApplicationHelper

    def truth_label(is_true, true_label='true', false_label='false')
      "<span class='label label-#{ is_true ? 'success':'danger'}'>#{ is_true ? true_label : false_label}</span>".html_safe
    end

  end
end
