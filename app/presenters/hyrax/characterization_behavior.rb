# frozen_string_literal: true

require Hyrax::Engine.root.join('app/presenters/hyrax/characterization_behavior.rb')
module Hyrax
  module CharacterizationBehavior
    extend ActiveSupport::Concern

    def label_for_term(term)
      if term == :original_checksum
        "MD5 Checksum"
      else
        term.to_s.titleize
      end
    end
  end
end
