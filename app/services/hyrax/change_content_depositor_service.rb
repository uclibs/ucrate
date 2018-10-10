# frozen_string_literal: true
module Hyrax
  class ChangeContentDepositorService
    # @param [ActiveFedora::Base] work
    # @param [User] user
    # @param [TrueClass, FalseClass] reset
    def self.call(work, user, reset)
      work.proxy_depositor = work.depositor
      work.permissions = [] if reset
      work.apply_depositor_metadata(user)
      work.file_sets.each do |f|
        # Clear the fileset permissions too!
        f.permissions = [] if reset
        f.apply_depositor_metadata(user)
        f.save!
      end
      work.save!
      work
    end
  end
end
