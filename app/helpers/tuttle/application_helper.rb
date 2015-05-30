module Tuttle
  module ApplicationHelper

    def truth_label(is_true, true_label='true'.freeze, false_label='false'.freeze)
      "<span class='label label-#{ is_true ? 'success'.freeze : 'danger'.freeze}'>#{ is_true ? true_label : false_label}</span>".html_safe
    end

  end
end
