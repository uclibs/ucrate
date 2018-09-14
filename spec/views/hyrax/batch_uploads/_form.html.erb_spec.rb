# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'hyrax/batch_uploads/_form.html.erb', type: :view do
  let(:work) { Article.new }
  let(:ability) { double('ability', current_user: user) } # rubocop:disable RSpec/VerifiedDoubles
  let(:form) { Hyrax::Forms::BatchUploadForm.new(work, ability, controller) }
  let(:user) { stub_model(User) }
  let(:page) do
    render
    Capybara::Node::Simple.new(rendered)
  end

  before do
    stub_template "hyrax/base/_guts4form.html.erb" => "Form guts"
    assign(:form, form)
    allow(form).to receive(:payload_concern).and_return('Article')
  end

  it "draws the page" do
    expect(page).to have_selector("form[action='/batch_uploads']")
    expect(page).to have_selector("form[action='/batch_uploads'][data-behavior='work-form']")
    expect(page).to have_selector("form[action='/batch_uploads'][data-param-key='batch_upload_item']")
    # No title, because it's captured per file (e.g. Display label)
    expect(page).not_to have_selector("input#generic_work_title")
    expect(view.content_for(:files_tab)).to have_link("Add New Article", href: "/concern/articles/new")
  end
end
