# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::Actors::DatasetActor do
  # The only thing our class has to test is inheritance from Hyrax::Actors::BaseActor.
  it 'inherits from Hyrax::Actors::BaseActor' do
    expect(described_class).to be < Hyrax::Actors::BaseActor
  end
end
