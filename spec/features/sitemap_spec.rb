# frozen_string_literal: true

require 'rails_helper'

shared_examples 'sitemap' do |work_class|
  let!(:work_type) { work_class.name.underscore }
  let!(:private_work) { FactoryBot.create(work_type.to_sym) }
  let!(:public_work) { FactoryBot.create("public_#{work_type}".to_sym) }
  let(:xml) { Capybara.string(page.body) }

  before { visit sitemap_path }

  it "indexes public #{work_class}s" do
    expect(xml).to have_content build_test_path(work_type, public_work.id)
  end

  it "does not index private #{work_class}s" do
    expect(xml).not_to have_content build_test_path(work_type, private_work.id)
  end

  it "indexes the catalog facet for #{work_class}s" do
    expect(xml).to have_content build_facet_path(work_class)
  end
end

describe 'Viewing the sitemap', :js, :workflow do
  let!(:static_paths) { StaticController.instance_methods(false) }
  let(:xml) { Capybara.string(page.body) }

  before { visit sitemap_path }

  Hyrax.config.registered_curation_concern_types.append('Collection').each do |type|
    it_behaves_like 'sitemap', type.constantize
  end

  it 'displays the root URL' do
    expect(xml).to have_content(root_path)
  end

  it 'displays the catalog URL' do
    expect(xml).to have_content(search_catalog_path)
  end

  it 'displays all static URLs in the application' do
    static_paths.each { |static_path| expect(xml).to have_content(send("#{static_path}_path")) }
  end
end

private

def build_facet_path(work_class)
  "/catalog?f[human_readable_type_sim][]=#{work_class}"
end

def build_test_path(work_type, work_id)
  "/concern/#{work_type.pluralize}/#{work_id}"
end
