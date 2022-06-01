# frozen_string_literal: true
class WorksResave
  def self.work_resave
    Rails.logger.debug "THIS IS A TEST"

    File.open('pids.txt').each do |work|
      work = work.chop
      object = ActiveFedora::Base.find(work.to_s)
      object.save
      Rails.logger.debug object.id
      object.file_sets.each(&:save)
    rescue => error
      Rails.logger.debug error.inspect + ' ' + work
    end
  end
end
