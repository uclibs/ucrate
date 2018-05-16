# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/dashboard/_sidebar.html.erb', type: :view do
  let(:user) { stub_model(User, user_key: 'mjg', name: 'Foobar') }
  let(:read_admin_dashboard) { false }
  let(:manage_any_admin_set) { false }
  let(:review_submissions) { false }
  let(:manage_user) { false }
  let(:update_appearance) { false }
  let(:manage_feature) { false }
  let(:manage_workflow) { false }
  let(:manage_collection_types) { false }

  before do
    allow(view).to receive(:signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
    assign(:user, user)
    allow(view).to receive(:can?).with(:read, :admin_dashboard).and_return(read_admin_dashboard)
    allow(view).to receive(:can?).with(:manage_any, AdminSet).and_return(manage_any_admin_set)
    allow(view).to receive(:can?).with(:review, :submissions).and_return(review_submissions)
    allow(view).to receive(:can?).with(:manage, User).and_return(manage_user)
    allow(view).to receive(:can?).with(:update, :appearance).and_return(update_appearance)
    allow(view).to receive(:can?).with(:manage, Hyrax::Feature).and_return(manage_feature)
    allow(view).to receive(:can?).with(:manage, Sipity::WorkflowResponsibility).and_return(manage_workflow)
    allow(view).to receive(:can?).with(:manage, :collection_types).and_return(manage_collection_types)
  end

  context 'with a user who can read the admin dash' do
    subject { rendered }
    let(:read_admin_dashboard) { true }

    before { render }

    it { is_expected.to have_link t('hyrax.admin.sidebar.statistics') }
    it { is_expected.to have_link t('hyrax.embargoes.index.manage_embargoes') }
    it { is_expected.not_to have_link t('hyrax.leases.index.manage_leases') }
  end

  it "shows Manage Exports link" do
    render
    expect(rendered).to have_link t('hyrax.collection.actions.manage_exports')
  end
end
