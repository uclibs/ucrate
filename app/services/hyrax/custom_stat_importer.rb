# frozen_string_literal: true
require 'legato'
require 'hyrax/pageview'
require 'hyrax/download'

module Hyrax
  class CustomStatImporter
    attr_reader :start_date, :object
    def initialize(object, options)
      if options[:verbose]
        stdout_logger = Logger.new(STDOUT)
        stdout_logger.level = Logger::INFO
        Rails.logger.extend(ActiveSupport::Logger.broadcast(stdout_logger))
      end
      @logging = options[:logging]
      @delay_secs = options[:delay_secs].to_f
      @number_of_retries = options[:number_of_retries].to_i
      @object = object
      @start_date = if object.stats_last_gathered.nil?
                      Hyrax.config.analytic_start_date
                    else
                      object.stats_last_gathered
                    end
    end

    def import
      user = ::User.find_by_email(object.user_email)

      case object.object_type
      when "work"
        begin
          work = Hyrax::WorkRelation.new.find(object.object_id)

          rescue_and_retry("Retried WorkViewStat on #{user} for work #{work.id} too many times.") do
            WorkViewStat.statistics(work, start_date, user.id)
          end

          delay
        rescue Exception => ex
          puts ex.message.to_s
          return
        end
      when "file"
        begin
          file = ::FileSet.find(object.object_id)

          rescue_and_retry("Retried FileViewStat on #{user} for file #{file.id} too many times.") do
            FileViewStat.statistics(file, start_date, user.id)
          end
          delay

          rescue_and_retry("Retried FileDownloadStat on #{user} for file #{file.id} too many times.") do
            FileDownloadStat.statistics(file, start_date, user.id)
          end
          delay
        rescue Exception => ex
          puts ex.message.to_s
          return
        end
      end

      object.update_stats_last_gathered
    end

    private

      def delay
        sleep @delay_secs
      end

      def rescue_and_retry(fail_message)
        retry_count = 0
        begin
          return yield
        rescue StandardError => e
          retry_count += 1
          if retry_count < @number_of_retries
            delay
            retry
          else
            log_message fail_message
            log_message "Last exception #{e}"
          end
        end
      end

      def log_message(message)
        Rails.logger.info "#{self.class}: #{message}" if @logging
      end
  end
end
