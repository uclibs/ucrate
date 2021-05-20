# frozen_string_literal: true

require 'aws-xray-sdk'

class ApplicationJob < ActiveJob::Base

  after_enqueue do |job|
    Rails.logger.info "#{Time.current}: Enqueued job: #{self.class.name}: #{job.inspect}"
  end

  around_perform do |job, block|
    Rails.logger.info "#{Time.current}: Beginning execution of the job: #{job.inspect}"
    # Create XRay Segment before perform
    subsegment = XRay.recorder.begin_segment("sidekiq::#{self.class.name}")
    subsegment.annotations.update context: 'sidekiq'
    subsegment.annotations.update job_id: job.job_id
    subsegment.annotations.update provider_job_id: job.provider_job_id
    job.attributes.each { |k,v|
      subsegment.metadata.update "job_info_#{k}": v
    }
    subsegment.metadata.update job_info: job.inspect
    # yield
    block.call
    # Destroy XRay Segment after perform
    XRay.recorder.end_segment
    Rails.logger.info "#{Time.current}: finished execution of the job: #{job.inspect}"
  end
end
