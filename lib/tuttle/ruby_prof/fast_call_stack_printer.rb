require 'ruby-prof/printers/call_stack_printer'

# This is a modified version of the RubyProf::CallStackPrinter
# It has been sped up by removing most link generation and
# expensive HTML formatting (like coloring)

module Tuttle
  module RubyProf
    # prints a HTML visualization of the call tree
    class FastCallStackPrinter < ::RubyProf::CallStackPrinter

      # Specify print options.
      #
      # options - Hash table
      #   :min_percent - Number 0 to 100 that specifes the minimum
      #                  %self (the methods self time divided by the
      #                  overall total time) that a method must take
      #                  for it to be printed out in the report.
      #                  Default value is 0.
      #
      #   :print_file  - True or false. Specifies if a method's source
      #                  file should be printed.  Default value if false.
      #
      #   :threshold   - a float from 0 to 100 that sets the threshold of
      #                  results displayed.
      #                  Default value is 1.0
      #
      #   :title       - a String to overide the default "ruby-prof call tree"
      #                  title of the report.
      #
      #   :expansion   - a float from 0 to 100 that sets the threshold of
      #                  results that are expanded, if the percent_total
      #                  exceeds it.
      #                  Default value is 10.0
      #
      #   :application - a String to overide the name of the application,
      #                  as it appears on the report.
      #
      def print(output = STDOUT, options = {})
        @output = output
        setup_options(options)

        print_header

        @overall_threads_time = @result.threads.inject(0) do |val, thread|
          val + thread.total_time
        end

        @method_full_name_cache = {}.compare_by_identity

        @result.threads.each do |thread|
          @overall_time = thread.total_time
          thread_info = "Thread: #{thread.id}"
          thread_info << ", Fiber: #{thread.fiber_id}" unless thread.id == thread.fiber_id
          thread_info << " (#{'%4.2f%%' % ((@overall_time / @overall_threads_time) * 100)} ~ #{@overall_time})"
          @output.print "<div class=\"thread\">#{thread_info}</div>"
          @output.print '<ul name="thread">'
          thread.methods.each do |m|
            # $stderr.print m.dump
            next unless m.root?
            m.call_infos.each do |ci|
              next unless ci.root?
              print_stack ci, @overall_time
            end
          end
          @output.print '</ul>'
        end

        @method_full_name_cache = nil

        print_footer
      end

      def print_stack(call_info, parent_time)
        total_time = call_info.total_time
        percent_total = (total_time / @overall_time) * 100
        return unless percent_total > min_percent

        percent_parent = (total_time / parent_time) * 100
        if percent_total < threshold
          @output.write '<li style="display:none;">'.freeze
        else
          @output.write '<li>'.freeze
        end

        expanded = percent_total >= expansion
        kids = call_info.children

        toggle_href = if kids.empty? || kids.none? {|ci| (ci.total_time / @overall_time) * 100 >= threshold}
                        '<a href="#" class="toggle empty"></a>'.freeze
                      elsif expanded
                        '<a href="#" class="toggle minus"></a>'.freeze
                      else
                        '<a href="#" class="toggle plus"></a>'.freeze
                      end
        @output.write toggle_href

        method = call_info.target
        @output.printf "<span>%4.2f%% (%4.2f%%) %s [%d calls, %d total]</span>\n".freeze,
                       percent_total, percent_parent,
                       method_full_name(method), call_info.called, method.called
        unless kids.empty?
          if expanded
            @output.write '<ul>'.freeze
          else
            @output.write '<ul style="display:none">'.freeze
          end
          kids.sort_by!(&:total_time).reverse_each do |callinfo|
            print_stack callinfo, total_time
          end
          @output.write '</ul>'.freeze
        end
        @output.write '</li>'.freeze
      end

      def name(call_info)
        method = call_info.target
        method.full_name
      end

      def method_full_name(method)
        @method_full_name_cache[method] ||= begin
          # Use ruby-prof klass_name only for non-Classes or klasses that do not report a name
          # This prevents klass.inspect from being used which prints complex names for ActiveRecord classes
          klass_name = method.klass && method.klass.class == Class && method.klass.name || method.klass_name
          h("#{klass_name}##{method.method_name}")
        end
      end

      def threshold
        @threshold ||= super
      end

      def expansion
        @expansion ||= super
      end

      def application
        @application ||= @options.delete(:application) || $PROGRAM_NAME
      end

      def print_title_bar
        @output.puts <<-"end_title_bar"
<div id="titlebar">
Call tree for application <b>#{h application} #{h arguments}</b><br/>
Generated on #{Time.current} with options #{h @options.inspect}<br/>
</div>
end_title_bar
      end

      def print_css
        super
        @output.puts <<-CSS_OVERRIDE
<style type="text/css">
<!--
ul li { background-color: white; }
-->
</style>
CSS_OVERRIDE
      end

    end
  end
end
