require_dependency 'tuttle/application_controller'

module Tuttle
  class ActiveJobController < ApplicationController

    def index
      @job_classes = ActiveJob::Base.descendants # May want to not includ ApplicationJob if it exists

      # TODO: could also look to see if GlobalID is available
      # https://github.com/rails/globalid

      # See http://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html

      # TODO: detect available backend libraries
      # TODO: catalog the .descendants of ActiveJob::Base
      #   - list the queue_name and queue_adapter per job

      # == Active Job adapters
      #
      # Active Job has adapters for the following queueing backends:
      #
      # * {Backburner}[https://github.com/nesquena/backburner]
      # * {Delayed Job}[https://github.com/collectiveidea/delayed_job]
      # * {Qu}[https://github.com/bkeepers/qu]
      # * {Que}[https://github.com/chanks/que]
      # * {queue_classic}[https://github.com/QueueClassic/queue_classic]
      # * {Resque 1.x}[https://github.com/resque/resque/tree/1-x-stable]
      # * {Sidekiq}[http://sidekiq.org]
      # * {Sneakers}[https://github.com/jondot/sneakers]
      # * {Sucker Punch}[https://github.com/brandonhilkert/sucker_punch]
      # * {Active Job Async Job}[http://api.rubyonrails.org/classes/ActiveJob/QueueAdapters/AsyncAdapter.html]
      # * {Active Job Inline}[http://api.rubyonrails.org/classes/ActiveJob/QueueAdapters/InlineAdapter.html]
      #
      # === Backends Features
      #
      #   |                   | Async | Queues | Delayed    | Priorities | Timeout | Retries |
      #   |-------------------|-------|--------|------------|------------|---------|---------|
      #   | Backburner        | Yes   | Yes    | Yes        | Yes        | Job     | Global  |
      #   | Delayed Job       | Yes   | Yes    | Yes        | Job        | Global  | Global  |
      #   | Qu                | Yes   | Yes    | No         | No         | No      | Global  |
      #   | Que               | Yes   | Yes    | Yes        | Job        | No      | Job     |
      #   | queue_classic     | Yes   | Yes    | Yes*       | No         | No      | No      |
      #   | Resque            | Yes   | Yes    | Yes (Gem)  | Queue      | Global  | Yes     |
      #   | Sidekiq           | Yes   | Yes    | Yes        | Queue      | No      | Job     |
      #   | Sneakers          | Yes   | Yes    | No         | Queue      | Queue   | No      |
      #   | Sucker Punch      | Yes   | Yes    | Yes        | No         | No      | No      |
      #   | Active Job Async  | Yes   | Yes    | Yes        | No         | No      | No      |
      #   | Active Job Inline | No    | Yes    | N/A        | N/A        | N/A     | N/A     |


    end

  end
end
