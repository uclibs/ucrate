# frozen_string_literal: true

require "pathname"
visibility_path = Pathname.new(Gem.loaded_specs['hydra-access-controls'].full_gem_path + '/app/models/concerns/hydra/access_controls/visibility.rb')
require visibility_path
module Hydra::AccessControls
  module Visibility
    def visibility
      return AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC if id.nil?
      if read_groups.include? AccessRight::PERMISSION_TEXT_VALUE_PUBLIC
        AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      elsif read_groups.include? AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED
        AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
      else
        AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      end
    end
  end
end
