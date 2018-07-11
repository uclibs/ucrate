# frozen_string_literal: true
require 'rails_helper'

describe 'classify_concerns/new.html.erb', type: :view do
  let(:classes) { [GenericWork, Article, Dataset, Image, Document, StudentWork, Medium, Etd] }
  before do
    classes.each do |klass|
      allow(view).to receive(:can?).with(:create, klass) { true }
    end
    allow(view).to receive(:can?).with(:create, Image) { false }
    allow(view).to receive(:classify_concern) { stub_model(ClassifyConcern) }
    render
  end

  it 'displays the concern title when the user has access' do
    expect(rendered).to match(/Generic Work/)
    expect(rendered).to match(/Article/)
    expect(rendered).to match(/Dataset/)
    expect(rendered).not_to match(/Image/)
  end

  it 'displays the concern description' do
    expect(rendered).to match(/Deposit any non-text-based document/)
    expect(rendered).to match(/Published or unpublished articles/)
    expect(rendered).to match(/Files containing collections of data/)
  end

  it 'displays a link to create a new work' do
    expect(rendered).to have_link 'Add New', href: main_app.new_polymorphic_path(GenericWork)
    expect(rendered).to have_link 'Add New', href: main_app.new_polymorphic_path(Article)
    expect(rendered).to have_link 'Add New', href: main_app.new_polymorphic_path(Dataset)
  end
end
