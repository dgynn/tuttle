require 'ruby-prof/printers/call_stack_printer'

# This is a modified version of the RubyProf::CallStackPrinter
# It has been sped up by removing most link generation and
# to use the forked, experimental version of ruby-prof at
# https://github.com/dgynn/ruby-prof/tree/performance_tuning_experiments

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
          val += thread.total_time
        end

        @method_link_cache = Hash.new.compare_by_identity

        @result.threads.each do |thread|
          @current_thread_id = thread.fiber_id.to_s
          @overall_time = thread.total_time
          thread_info = "Thread: #{thread.id}"
          thread_info << ", Fiber: #{thread.fiber_id}" unless thread.id == thread.fiber_id
          thread_info << " (#{"%4.2f%%" % ((@overall_time/@overall_threads_time)*100)} ~ #{@overall_time})"
          @output.print "<div class=\"thread\">#{thread_info}</div>"
          @output.print "<ul name=\"thread\">"
          thread.methods.each do |m|
            # $stderr.print m.dump
            next unless m.root?
            m.call_infos.each do |ci|
              next unless ci.root?
              print_stack ci, @overall_time
            end
          end
          @output.print "</ul>"
        end

        @method_link_cache = nil

        print_footer

      end

      def print_stack(call_info, parent_time)
        total_time = call_info.total_time
        percent_parent = (total_time/parent_time)*100
        percent_total = (total_time/@overall_time)*100
        return unless percent_total > min_percent
        color = self.color(percent_total)
        kids = call_info.children
        visible = percent_total >= threshold
        expanded = percent_total >= expansion
        display = visible ? "block".freeze : "none".freeze
        @output.write "<li class=\"color#{color}\" style=\"display:#{display}\">"

        toggle_href = if kids.empty? || kids.none?{|ci| (ci.total_time/@overall_time)*100 >= threshold}
                        "<a href=\"#\" class=\"toggle empty\" ></a>".freeze
                      else
                        if expanded
                          "<a href=\"#\" class=\"toggle minus\" ></a>".freeze
                        else
                          "<a href=\"#\" class=\"toggle plus\" ></a>".freeze
                        end
                      end
        @output.write toggle_href

        method = call_info.target
        @output.printf "<span> %4.2f%% (%4.2f%%) %s %s</span>\n".freeze,
                       percent_total, percent_parent,
                       link(method), graph_link(call_info, method)
        unless kids.empty?
          if expanded
            @output.write "<ul>".freeze
          else
            @output.write '<ul style="display:none">'.freeze
          end
          kids.sort_by!(&:total_time).reverse_each do |callinfo|
            print_stack callinfo, total_time
          end
          @output.write "</ul>".freeze
        end
        @output.write "</li>".freeze
      end

      def name(call_info)
        method = call_info.target
        method.full_name
      end

      def link(method)
        @method_link_cache[method] ||= begin
          file = method.memoized_source_file
          if file == 'ruby_runtime'.freeze
            h(method.full_name)
          else
            # file = source_file # File.expand_path(source_file)
            # @link_template % [file, method.line, h(method.full_name)]    - disabled all file-open HREFs. not appropriate for web.
            h(method.full_name)
          end
        end
      end

      def graph_link(call_info, method)
        "[#{call_info.called} calls, #{method.called} total]"
      end

      def color(p)
        i = p.to_i
        if i < 5
          "01".freeze
        elsif i < 10
          "05".freeze
        elsif i == 100
          "9".freeze
        else
          "#{i/10}"
        end
      end

      def application
        @application ||= @options.delete(:application) || $PROGRAM_NAME
      end

      def print_title_bar
        @output.puts <<-"end_title_bar"
<div id="titlebar">
Call tree for application <b>#{h application} #{h arguments}</b><br/>
Generated on #{Time.now} with options #{h @options.inspect}<br/>
</div>
end_title_bar
      end

    end
  end

end

