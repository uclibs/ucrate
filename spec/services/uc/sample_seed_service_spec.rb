# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Uc::SampleSeedService do
  subject(:service) { described_class.new(works_per_user: 1) }

  let(:admin_user) { instance_double(User, email: 'admin@example.com', user_key: 'admin@example.com') }
  let(:sample_users) do
    {
      many_deposits: instance_double(User, email: 'manydeposits@example.com'),
      no_deposits: instance_double(User, email: 'nodeposits@example.com'),
      delegate: instance_double(User, email: 'delegate@example.com'),
      admin: admin_user,
      depositors: [admin_user]
    }
  end

  around do |example|
    previous = {
      'INITIAL_ADMIN_PASSWORD' => ENV.fetch('INITIAL_ADMIN_PASSWORD', nil),
      'UC_SEED_FORCE' => ENV.fetch('UC_SEED_FORCE', nil),
      'HYKU_SINGLE_TENANT_CNAME' => ENV.fetch('HYKU_SINGLE_TENANT_CNAME', nil),
      'UC_SEED_WORKS_PER_USER' => ENV.fetch('UC_SEED_WORKS_PER_USER', nil),
      'HYRAX_VALKYRIE' => ENV.fetch('HYRAX_VALKYRIE', nil)
    }
    ENV['INITIAL_ADMIN_PASSWORD'] = 'testing123'
    ENV['HYKU_SINGLE_TENANT_CNAME'] = 'single.tenant.default'
    ENV.delete('UC_SEED_FORCE')
    ENV.delete('UC_SEED_WORKS_PER_USER')
    example.run
  ensure
    previous.each { |key, value| restore_env(key, value) }
  end

  def restore_env(key, value)
    value.nil? ? ENV.delete(key) : ENV[key] = value
  end

  def stub_tenant_and_modes
    allow(service).to receive(:switch_to_single_tenant!)
    allow(service).to receive(:already_seeded?).and_return(false)
    allow(service).to receive(:remove_uc_seed_objects!)
    allow(service).to receive(:setup_active_fedora_mode!)
    allow(service).to receive(:restore_active_fedora_mode!)
  end

  def stub_create_steps
    allow(service).to receive(:create_users).and_return(sample_users)
    allow(service).to receive(:find_or_create_active_fedora_admin_set!).and_return(instance_double(AdminSet))
    allow(service).to receive(:create_bulk_generic_works)
    allow(service).to receive(:create_complete_works_collection)
    allow(service).to receive(:write_completion_marker!)
    allow(service).to receive(:index_created!)
  end

  def stub_successful_create_path
    stub_tenant_and_modes
    stub_create_steps
  end

  describe '.call' do
    it 'passes UC_SEED_WORKS_PER_USER into the service' do
      ENV['UC_SEED_WORKS_PER_USER'] = '3'
      instance = instance_double(described_class)
      allow(described_class).to receive(:new).with(works_per_user: 3).and_return(instance)
      allow(instance).to receive(:call).and_return(described_class::Result.new(status: :skipped))

      expect(described_class.call.status).to eq(:skipped)
      expect(described_class).to have_received(:new).with(works_per_user: 3)
    end

    it 'defaults works_per_user to 10 when the env var is unset' do
      instance = instance_double(described_class)
      allow(described_class).to receive(:new).with(works_per_user: 10).and_return(instance)
      allow(instance).to receive(:call).and_return(described_class::Result.new(status: :skipped))

      described_class.call

      expect(described_class).to have_received(:new).with(works_per_user: 10)
    end
  end

  describe '#call' do
    context 'when already seeded' do
      before do
        allow(service).to receive(:switch_to_single_tenant!)
        allow(service).to receive(:already_seeded?).and_return(true)
      end

      it 'returns skipped and does not create works' do
        expect(service).not_to receive(:create_users)

        result = service.call

        expect(result).to have_attributes(status: :skipped, created_count: nil)
      end
    end

    context 'when UC_SEED_FORCE is true and already seeded' do
      before do
        ENV['UC_SEED_FORCE'] = 'true'
        stub_successful_create_path
        allow(service).to receive(:already_seeded?).and_return(true)
      end

      it 'wipes prior seed objects then recreates' do
        expect(service).to receive(:remove_uc_seed_objects!).ordered
        expect(service).to receive(:create_users).ordered.and_return(sample_users)

        expect(service.call.status).to eq(:created)
      end
    end

    context 'happy path' do
      before { stub_successful_create_path }

      it 'returns created with the initial-admin password source' do
        result = service.call

        expect(result).to have_attributes(
          status: :created,
          password_source: :initial_admin_password,
          created_count: 0
        )
      end

      it 'runs create steps in order' do
        expect(service).to receive(:create_users).ordered.and_return(sample_users)
        expect(service).to receive(:find_or_create_active_fedora_admin_set!).with(admin_user).ordered
        expect(service).to receive(:create_bulk_generic_works).with(sample_users[:depositors]).ordered
        expect(service).to receive(:create_complete_works_collection).with(sample_users[:many_deposits]).ordered
        expect(service).to receive(:write_completion_marker!).with(sample_users[:many_deposits]).ordered
        expect(service).to receive(:index_created!).ordered

        service.call
      end
    end

    context 'when create raises after AF mode is enabled' do
      before do
        allow(service).to receive(:switch_to_single_tenant!)
        allow(service).to receive(:already_seeded?).and_return(false)
        allow(Hyrax.config).to receive(:use_valkyrie?).and_return(true)
        allow(Hyrax.config).to receive(:use_valkyrie=)
        allow(service).to receive(:remove_uc_seed_objects!)
        allow(service).to receive(:create_users).and_raise(RuntimeError, 'create failed')
      end

      it 'restores the previous Hyrax use_valkyrie setting' do
        expect { service.call }.to raise_error(RuntimeError, 'create failed')

        expect(Hyrax.config).to have_received(:use_valkyrie=).with(false).ordered
        expect(Hyrax.config).to have_received(:use_valkyrie=).with(true).ordered
      end
    end

    context 'when Rails.env is production' do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
        allow(Rails.env).to receive(:staging?).and_return(false)
      end

      after { allow(Rails.env).to receive(:production?).and_call_original }

      it 'raises before switching tenants or creating data' do
        expect(Account).not_to receive(:find_by)
        expect(service).not_to receive(:create_users)

        expect { service.call }
          .to raise_error(RuntimeError, 'UC sample seeds must not run in production or staging.')
      end
    end

    context 'when Rails.env is staging' do
      before do
        allow(Rails.env).to receive(:production?).and_return(false)
        allow(Rails.env).to receive(:staging?).and_return(true)
      end

      after do
        allow(Rails.env).to receive(:production?).and_call_original
        allow(Rails.env).to receive(:staging?).and_call_original
      end

      it 'raises' do
        expect { service.call }
          .to raise_error(RuntimeError, 'UC sample seeds must not run in production or staging.')
      end
    end

    context 'when INITIAL_ADMIN_PASSWORD is missing' do
      it 'raises after tenant switch when not already seeded' do
        ENV.delete('INITIAL_ADMIN_PASSWORD')
        bare = described_class.new(works_per_user: 1)
        allow(bare).to receive(:switch_to_single_tenant!)
        allow(bare).to receive(:already_seeded?).and_return(false)

        expect { bare.call }
          .to raise_error(RuntimeError, /INITIAL_ADMIN_PASSWORD is not set/)
      end
    end

    context 'when the single-tenant account is missing' do
      before do
        allow(Account).to receive(:find_by).with(cname: 'single.tenant.default').and_return(nil)
      end

      it 'raises with instructions to run Hyku db:seed first' do
        expect { service.call }
          .to raise_error(RuntimeError, /Single-tenant account not found.*db:seed first/)
      end
    end
  end

  describe '#switch_to_single_tenant!' do
    it 'uses HYKU_SINGLE_TENANT_CNAME when set' do
      account = instance_double(Account, cname: 'custom.tenant.local')
      ENV['HYKU_SINGLE_TENANT_CNAME'] = 'custom.tenant.local'
      allow(Account).to receive(:find_by).with(cname: 'custom.tenant.local').and_return(account)
      allow(AccountElevator).to receive(:switch!)

      service.send(:switch_to_single_tenant!)

      expect(AccountElevator).to have_received(:switch!).with('custom.tenant.local')
    end
  end

  describe '#already_seeded?' do
    it 'is true when the completion marker exists in Fedora' do
      allow(ActiveFedora::Base).to receive(:exists?)
        .with(described_class::COMPLETION_WORK_ID).and_return(true)

      expect(service.send(:already_seeded?)).to be(true)
    end

    it 'falls back to Solr when the Fedora marker is absent' do
      allow(ActiveFedora::Base).to receive(:exists?)
        .with(described_class::COMPLETION_WORK_ID).and_return(false)
      relation = instance_double('ActiveFedora::Relation', any?: true)
      allow(GenericWork).to receive(:where)
        .with(bulkrax_identifier_tesim: described_class::COMPLETION_MARKER)
        .and_return(relation)

      expect(service.send(:already_seeded?)).to be(true)
    end

    it 'is false when neither Fedora nor Solr has the marker' do
      allow(ActiveFedora::Base).to receive(:exists?)
        .with(described_class::COMPLETION_WORK_ID).and_return(false)
      relation = instance_double('ActiveFedora::Relation', any?: false)
      allow(GenericWork).to receive(:where)
        .with(bulkrax_identifier_tesim: described_class::COMPLETION_MARKER)
        .and_return(relation)

      expect(service.send(:already_seeded?)).to be(false)
    end
  end

  describe '#fold_uc_metadata' do
    it 'returns the base description when no fields are given' do
      expect(service.send(:fold_uc_metadata, 'Base text')).to eq('Base text')
    end

    it 'omits nil fields and joins the rest' do
      result = service.send(
        :fold_uc_metadata,
        'Base text',
        college: 'Arts',
        department: nil,
        note: 'Hello'
      )

      expect(result).to eq('Base text [UC seed fields: college: Arts | note: Hello]')
    end
  end

  describe '#grant_admin!' do
    let(:site) { instance_double(Site) }
    let(:user) { instance_double(User) }

    before { allow(Site).to receive(:instance).and_return(site) }

    it 'adds both global and site admin roles when missing' do
      allow(user).to receive(:has_role?).with(:admin).and_return(false)
      allow(user).to receive(:has_role?).with(:admin, site).and_return(false)
      allow(user).to receive(:add_role)

      service.send(:grant_admin!, user)

      expect(user).to have_received(:add_role).with(:admin)
      expect(user).to have_received(:add_role).with(:admin, site)
    end

    it 'does not re-add roles the user already has' do
      allow(user).to receive(:has_role?).with(:admin).and_return(true)
      allow(user).to receive(:has_role?).with(:admin, site).and_return(true)
      allow(user).to receive(:add_role)

      service.send(:grant_admin!, user)

      expect(user).not_to have_received(:add_role)
    end
  end

  describe '#upsert_user' do
    let(:user) { instance_double(User) }

    before do
      allow(User).to receive(:find_or_initialize_by).with(email: 'sample@example.com').and_return(user)
      allow(user).to receive(:password=)
      allow(user).to receive(:password_confirmation=)
      allow(user).to receive(:display_name=)
      allow(user).to receive(:department=)
      allow(user).to receive(:save!)
    end

    it 'sets password and profile fields then saves' do
      service.send(
        :upsert_user,
        email: 'sample@example.com',
        display_name: 'Sample User',
        department: 'Library'
      )

      expect(user).to have_received(:password=).with('testing123')
      expect(user).to have_received(:password_confirmation=).with('testing123')
      expect(user).to have_received(:display_name=).with('Sample User')
      expect(user).to have_received(:department=).with('Library')
      expect(user).to have_received(:save!)
    end

    it 'skips department when nil and grants admin when requested' do
      allow(service).to receive(:grant_admin!)

      service.send(
        :upsert_user,
        email: 'sample@example.com',
        display_name: 'Admin User',
        department: nil,
        admin: true
      )

      expect(user).not_to have_received(:department=)
      expect(service).to have_received(:grant_admin!).with(user)
    end
  end

  describe '#uc_seed_solr_docs' do
    it 'keeps only documents whose bulkrax id uses the uc-seed prefix' do
      allow(Hyrax::SolrService).to receive(:query) do |query, **|
        if query.include?('GenericWork')
          [
            {
              'id' => 'keep',
              'has_model_ssim' => ['GenericWork'],
              'bulkrax_identifier_tesim' => ['uc-seed-bulk-1']
            },
            {
              'id' => 'drop',
              'has_model_ssim' => ['GenericWork'],
              'bulkrax_identifier_tesim' => ['bulkrax-other']
            }
          ]
        else
          []
        end
      end

      docs = service.send(:uc_seed_solr_docs)

      expect(docs.map { |doc| doc['id'] }).to eq(['keep'])
    end
  end

  describe '#remove_uc_seed_objects!' do
    it 'continues when one destroy fails' do
      keep = instance_double(GenericWork)
      allow(service).to receive(:destroy_completion_marker_in_fedora!)
      allow(service).to receive(:uc_seed_solr_docs).and_return(
        [
          { 'id' => 'bad', 'has_model_ssim' => ['GenericWork'] },
          { 'id' => 'good', 'has_model_ssim' => ['GenericWork'] }
        ]
      )
      allow(GenericWork).to receive(:find).with('bad').and_raise(StandardError, 'missing')
      allow(GenericWork).to receive(:find).with('good').and_return(keep)
      allow(keep).to receive(:destroy)

      expect { service.send(:remove_uc_seed_objects!) }.not_to raise_error
      expect(keep).to have_received(:destroy)
    end

    it 'skips docs that have no model name' do
      allow(service).to receive(:destroy_completion_marker_in_fedora!)
      allow(service).to receive(:uc_seed_solr_docs).and_return(
        [{ 'id' => 'orphan', 'has_model_ssim' => [] }]
      )

      expect(GenericWork).not_to receive(:find)
      service.send(:remove_uc_seed_objects!)
    end
  end

  describe '#write_completion_marker!' do
    let(:user) do
      instance_double(User, display_name: 'Many Deposits', email: 'manydeposits@example.com')
    end
    let(:work) { instance_double(GenericWork) }
    let(:admin_set) { instance_double(AdminSet) }

    before do
      service.instance_variable_set(:@admin_set, admin_set)
      allow(GenericWork).to receive(:new).and_return(work)
      allow(service).to receive(:save_work!).with(work, user).and_return(work)
      allow(work).to receive(:update_index)
    end

    it 'persists a fixed-id marker and indexes it immediately' do
      service.send(:write_completion_marker!, user)

      expect(GenericWork).to have_received(:new).with(
        hash_including(
          id: described_class::COMPLETION_WORK_ID,
          bulkrax_identifier: described_class::COMPLETION_MARKER,
          admin_set: admin_set
        )
      )
      expect(work).to have_received(:update_index)
      expect(service.instance_variable_get(:@created)).to eq([work])
    end
  end
end
