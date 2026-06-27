# frozen_string_literal: true

# THROWAWAY — SLOW-TIER SLOP CHECKS
# ===================================
# Mocks and shortcuts only. Does NOT replace :slow specs or CircleCI.
# Tagged throwaway: true — excluded from full suite; runs with bin/rspec-fast only.
# Safe to delete or rewrite when stale. See spec/throwaway/README.md

require 'rails_helper'

RSpec.describe 'THROWAWAY slow-tier slop checks', throwaway: true do
  describe 'work deposit forms (excluded: spec/forms/hyrax/)' do
    let(:work) { GenericWork.new }

    [
      Hyrax::GenericWorkForm,
      Hyrax::ArticleForm,
      Hyrax::DatasetForm,
      Hyrax::DocumentForm,
      Hyrax::EtdForm,
      Hyrax::ImageForm,
      Hyrax::MediumForm,
      Hyrax::StudentWorkForm
    ].each do |form_class|
      it "#{form_class} instantiates and lists required fields" do
        form = form_class.new(work, nil, nil)
        expect(form).to be_a(form_class)
        expect(form.required_fields).to include(:title)
      end
    end

    it 'GenericWorkForm.model_attributes accepts params without Fedora file sets' do
      params = ActionController::Parameters.new(
        title: 'slop title',
        description: [''],
        visibility: 'open',
        rights_statement: 'http://creativecommons.org/licenses/by/4.0/us/',
        member_of_collection_ids: ['col-1']
      )
      attrs = Hyrax::GenericWorkForm.model_attributes(params)
      expect(attrs['title']).to eq ['slop title']
      expect(attrs['member_of_collection_ids']).to eq ['col-1']
    end
  end

  describe 'work models (excluded: spec/models/*_spec.rb for work types)' do
    it 'each registered curation concern builds in memory' do
      Hyrax.config.registered_curation_concern_types.each do |type_name|
        work = type_name.constantize.new
        work.title = ["#{type_name} slop"]
        expect(work.title).to eq ["#{type_name} slop"]
      end
    end
  end

  describe 'collection indexing (excluded: spec/indexers/)' do
    it 'CollectionIndexer produces Solr fields from an in-memory collection (stubbed)' do
      collection = Collection.new(title: ['Slop Collection'])
      collection.apply_depositor_metadata('slop@example.com')
      indexer = Hyrax::CollectionIndexer.new(collection)
      allow(collection).to receive(:bytes).and_return(500)
      allow(collection).to receive(:in_collections).and_return([])
      allow(collection).to receive(:visibility).and_return('open')
      allow(Hyrax::ThumbnailPathService).to receive(:call).and_return('/downloads/thumb')

      doc = indexer.generate_solr_document
      expect(doc.fetch('generic_type_sim')).to eq ['Collection']
      expect(doc.fetch('bytes_lts')).to eq 500
    end
  end

  describe 'expiration service (excluded: spec/services/expiration_service_spec.rb)' do
    before do
      (Hyrax.config.registered_curation_concern_types.map(&:constantize) + [FileSet]).each do |klass|
        allow(klass).to receive(:where).and_return([])
      end
    end

    it 'runs when Solr/Fedora return no expired embargoes' do
      expect(VisibilityCopyJob).not_to receive(:perform_later)
      expect { ExpirationService.call }.not_to raise_error
    end
  end

  describe Hyrax::GenericWorksController, type: :controller do
    routes { Rails.application.routes }
    let(:main_app) { Rails.application.routes.url_helpers }

    it 'creates a work when the actor succeeds (mocked slop check)' do
      user = create(:user)
      work = stub_model(GenericWork)
      actor = instance_double('Hyrax::CurationConcern', create: true)

      allow(Hyrax::CurationConcern).to receive(:actor).and_return(actor)
      allow(controller).to receive(:curation_concern).and_return(work)
      sign_in user

      post :create, params: {
        generic_work: {
          title: ['slop title'],
          description: 'slop description',
          note: 'slop note'
        }
      }

      expect(response).to redirect_to(main_app.hyrax_generic_work_path(work, locale: 'en'))
    end
  end

  describe 'catalog / Solr discovery (excluded: spec/features/*catalog*)' do
    it 'CatalogController is configured for Hyrax search' do
      expect(CatalogController.blacklight_config.search_builder_class).to eq Hyrax::CatalogSearchBuilder
    end

    it 'Solr discovery queries can be stubbed without a live Solr process' do
      allow(ActiveFedora::SolrService).to receive(:get).and_return(
        'response' => { 'docs' => [], 'numFound' => 0 }
      )
      result = ActiveFedora::SolrService.get('has_model_ssim:GenericWork', rows: 1)
      expect(result.dig('response', 'numFound')).to eq 0
    end
  end

  describe 'work show presentation (excluded: spec/views/hyrax/base/show.html.erb_spec.rb)' do
    it 'WorkShowPresenter reads title from an in-memory SolrDocument' do
      user = create(:user)
      doc = SolrDocument.new(
        id: 'slop-work-1',
        title_tesim: ['Slop Work Title'],
        has_model_ssim: ['GenericWork'],
        depositor_tesim: [user.user_key]
      )
      presenter = Hyrax::WorkShowPresenter.new(doc, Ability.new(user))
      expect(presenter.title).to eq ['Slop Work Title']
    end
  end

  describe 'file attach job (excluded: spec/jobs/attach_files_to_work_job_spec.rb)' do
    it 'AttachFilesToWorkJob accepts an empty upload list without saving to Fedora' do
      user = create(:user)
      work = GenericWork.new
      work.apply_depositor_metadata(user.user_key)

      expect { AttachFilesToWorkJob.perform_now(work, []) }.not_to raise_error
    end
  end

  describe 'key routes (excluded: most feature specs)' do
    it 'recognizes catalog and a deposit path' do
      expect(Rails.application.routes.recognize_path('/catalog')).to include(
        controller: 'catalog',
        action: 'index'
      )
      expect(Rails.application.routes.recognize_path('/concern/generic_works/new')).to include(
        controller: 'hyrax/generic_works',
        action: 'new'
      )
    end
  end
end
