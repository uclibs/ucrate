# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Article`
require 'rails_helper'

RSpec.describe BatchUploadItem do
  describe "single valued fields" do
    it "returns false for multi value" do
      expect(described_class.multiple?("title")).to be false
      expect(described_class.multiple?("rights_statement")).to be false
      expect(described_class.multiple?("description")).to be false
      expect(described_class.multiple?("date_created")).to be false
      expect(described_class.multiple?("license")).to be false
    end
  end
end
