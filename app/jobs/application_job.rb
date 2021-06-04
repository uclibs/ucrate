# frozen_string_literal: true

require 'aws-xray-sdk'

class ApplicationJob < ActiveJob::Base
  def serialize
    super.merge('parent_trace_id' => @parent_trace_id || XRay.recorder.current_segment.trace_id)
  end

  def deserialize(job_data)
    super(job_data)
    @parent_trace_id = job_data['parent_trace_id']
  end

  around_enqueue do |job, block|
    Rails.logger.info "#{Time.current}: Enqueuing job: #{self.class.name}: #{job.inspect}"
    XRay.recorder.capture("job_enqueue::#{self.class.name}") do |subsegment|
      subsegment.metadata.update job_info: job.inspect
      subsegment.annotations.update job_id: job.job_id
      subsegment.annotations.update provider_job_id: job.provider_job_id
      block.call
    end
    Rails.logger.info "#{Time.current}: Enqueued job: #{self.class.name}: #{job.inspect}"
  end

  around_perform do |job, block|
    Rails.logger.info "#{Time.current}: Beginning execution of the job: #{job.inspect}"
    # Create XRay Segment before perform
    seg_name = ENV.fetch("AWS_XRAY_TRACING_NAME", "")
    subsegment = XRay.recorder.begin_segment("#{seg_name}::sidekiq::#{self.class.name}")
    subsegment.annotations.update context: 'sidekiq'
    subsegment.annotations.update job_class: "sidekiq::#{self.class.name}"
    subsegment.annotations.update job_parent_id: @parent_trace_id.to_s
    subsegment.annotations.update job_id: job.job_id
    subsegment.annotations.update provider_job_id: job.provider_job_id
    subsegment.metadata.update job_info: job.inspect
    block.call
    # Destroy XRay Segment after perform
    XRay.recorder.end_segment
    Rails.logger.info "#{Time.current}: finished execution of the job: #{job.inspect}"
  end
end
