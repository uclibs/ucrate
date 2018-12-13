# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::Actors::MintDoiActor do
  let(:user) { create(:user) }
  let(:ability) { ::Ability.new(user) }
  let(:work) { create(:generic_work, user: user) }
  let(:env) { Hyrax::Actors::Environment.new(work, ability, attributes) }
  let(:attributes) { {} }
  let(:terminator) { Hyrax::Actors::Terminator.new }

  subject(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end
    stack.build(terminator)
  end

  [:create, :update].each do |mode|
    context "on #{mode}" do
      it "returns true" do
        expect(subject.send(mode, env)).to be true
      end
    end
  end
end
