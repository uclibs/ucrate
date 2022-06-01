# frozen_string_literal: true
class PidsOut
  def self.pids_output
    work_type_classes.each do |type_class|
      Rails.logger.debug "Work Type : #{type_class}"
      type_class.all.each do |work|
        pid = work.id
        Rails.logger.debug "PID #{pid}"
        File.write("pids.txt", pid + "\n", mode: "a")
      end
    end
  end

  def self.work_type_classes
    Hyrax.config.registered_curation_concern_types.collect(&:constantize)
  end
end
