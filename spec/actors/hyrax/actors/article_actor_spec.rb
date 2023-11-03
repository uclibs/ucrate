# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Article`
require 'rails_helper'

RSpec.describe Hyrax::Actors::ArticleActor do
  # The only thing our class has to test is inheritance from Hyrax::Actors::BaseActor.
  it 'inherits from Hyrax::Actors::BaseActor' do
    expect(described_class).to be < Hyrax::Actors::BaseActor
  end
end
