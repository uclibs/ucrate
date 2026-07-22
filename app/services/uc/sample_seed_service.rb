# frozen_string_literal: true

# Adapts Scholar@UC develop db/seeds.rb sample users/works onto Hyku OOB models.
# Removable UC-local path — does not replace stock Hyku db/seeds.rb.
#
# Mapping onto models Hyku already ships (no UC custom work types):
#   develop Article / Document / Dataset / Medium / StudentWork / GenericWork → GenericWork
#     (develop-only fields recorded in description; resource_type notes the develop type)
#   Image → Image; Etd → Etd
#   User first_name/last_name/ucdepartment → display_name / department
#
module Uc
  class SampleSeedService # rubocop:disable Metrics/ClassLength
    # Written only after a full successful run. Presence = safe no-op on re-run.
    COMPLETION_MARKER = 'uc-seed-v1-complete'
    SEED_ID_PREFIX = 'uc-seed-'
    PUBLIC = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    RIGHTS = ['http://rightsstatements.org/vocab/InC/1.0/'].freeze

    Result = Struct.new(:status, :password, :created_count, keyword_init: true)

    def self.call(works_per_user: ENV.fetch('UC_SEED_WORKS_PER_USER', '10').to_i)
      new(works_per_user: works_per_user).call
    end

    def initialize(works_per_user:)
      @works_per_user = works_per_user
      @password = Devise.friendly_token.first(8)
      @created = []
      @logger = Logger.new($stdout)
    end

    def call
      switch_to_single_tenant!

      if already_seeded? && !force?
        @logger.info('UC sample seeds already complete; skipping work creation.')
        return Result.new(status: :skipped)
      end

      setup_active_fedora_mode!
      begin
        remove_uc_seed_objects! if force? || uc_seed_solr_docs.any?

        @logger.info('Creating UC sample seeds (adapted from develop onto Hyku OOB models)...')
        @logger.info("Password for UC sample accounts: #{@password}")

        users = create_users
        @admin_set = find_or_create_active_fedora_admin_set!(users[:admin])
        create_bulk_generic_works(users[:depositors])
        create_complete_works_collection(users[:many_deposits])
        write_completion_marker!(users[:many_deposits])

        index_created!
        @logger.info("Indexed #{@created.size} UC sample objects.")
        Result.new(status: :created, password: @password, created_count: @created.size)
      ensure
        restore_active_fedora_mode!
      end
    end

    private

    def force?
      ActiveModel::Type::Boolean.new.cast(ENV.fetch('UC_SEED_FORCE', 'false'))
    end

    def switch_to_single_tenant!
      cname = ENV.fetch('HYKU_SINGLE_TENANT_CNAME', 'single.tenant.default')
      account = Account.find_by(cname: cname)
      raise "Single-tenant account not found (cname=#{cname}). Run rails db:seed first." if account.blank?

      AccountElevator.switch!(account.cname)
    end

    # Hyku's default admin set is often AdminSetResource (Valkyrie). AF works need
    # an ActiveFedora::AdminSet — same approach as Sample::ActiveFedoraService.
    def find_or_create_active_fedora_admin_set!(user)
      admin_set = AdminSet.where(id: AdminSet::DEFAULT_ID).first
      return admin_set if admin_set.present?

      admin_set = AdminSet.new(id: AdminSet::DEFAULT_ID, title: ['UC Sample Admin Set'])
      admin_set.creator = [user.user_key]
      raise "Failed to save ActiveFedora AdminSet: #{admin_set.errors.full_messages}" unless admin_set.save

      ActiveRecord::Base.transaction do
        permission_template = Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set.id)
        permission_template.access_grants.find_or_create_by!(
          agent_type: 'user',
          agent_id: user.user_key,
          access: Hyrax::PermissionTemplateAccess::MANAGE
        )
        permission_template.reset_access_controls_for(collection: admin_set, interpret_visibility: true)
      end

      admin_set
    end

    def setup_active_fedora_mode!
      @original_use_valkyrie = Hyrax.config.use_valkyrie?
      ENV['HYRAX_VALKYRIE'] = 'false'
      Hyrax.config.use_valkyrie = false
    end

    def restore_active_fedora_mode!
      Hyrax.config.use_valkyrie = @original_use_valkyrie unless @original_use_valkyrie.nil?
    end

    def already_seeded?
      solr_id_exists?(COMPLETION_MARKER)
    end

    def solr_id_exists?(bulkrax_id)
      GenericWork.where(bulkrax_identifier_tesim: bulkrax_id).any?
    end

    # Wipe prior UC seed objects (failed run leftovers, or UC_SEED_FORCE=true).
    # Solr text fields don't reliably match uc-seed-* wildcards, so filter in Ruby.
    def remove_uc_seed_objects!
      docs = uc_seed_solr_docs
      return if docs.blank?

      @logger.info("Removing #{docs.size} prior UC seed object(s)...")
      docs.each do |doc|
        model = Array(doc['has_model_ssim']).first
        next if model.blank?

        model.constantize.find(doc['id']).destroy
      rescue StandardError => e
        @logger.warn("Could not destroy #{doc['id']}: #{e.message}")
      end
    end

    def uc_seed_solr_docs
      %w[GenericWork Image Etd Collection].flat_map do |model|
        Hyrax::SolrService.query(
          "has_model_ssim:#{model}",
          rows: 10_000,
          fl: 'id,has_model_ssim,bulkrax_identifier_tesim'
        ).select do |doc|
          Array(doc['bulkrax_identifier_tesim']).any? { |value| value.start_with?(SEED_ID_PREFIX) }
        end
      end
    end

    def write_completion_marker!(user)
      work = save_work!(
        GenericWork.new(
          title: ['UC seed completion marker'],
          description: ['Internal marker — UC sample seed completed successfully.'],
          creator: [user.display_name.presence || user.email],
          rights_statement: RIGHTS,
          bulkrax_identifier: COMPLETION_MARKER,
          visibility: PUBLIC,
          admin_set: @admin_set,
          resource_type: ['Generic Work']
        ),
        user
      )
      @created << work
    end

    def create_users
      many = upsert_user(
        email: 'manydeposits@example.com',
        display_name: 'Many Deposits',
        department: 'CCM Music'
      )
      no_deposits = upsert_user(
        email: 'nodeposits@example.com',
        display_name: 'No Deposits',
        department: 'UCL Research'
      )
      delegate = upsert_user(
        email: 'delegate@example.com',
        display_name: 'Student Delegate',
        department: 'CEAS Computer Science'
      )
      admin = upsert_user(
        email: 'admin@example.com',
        display_name: 'Admin User',
        department: nil,
        admin: true
      )

      { many_deposits: many, no_deposits: no_deposits, delegate: delegate, admin: admin,
        depositors: [many, delegate, admin] }
    end

    def upsert_user(email:, display_name:, department:, admin: false)
      user = User.find_or_initialize_by(email: email)
      user.password = @password
      user.password_confirmation = @password
      user.display_name = display_name
      user.department = department if department
      user.save!
      grant_admin!(user) if admin
      @logger.info("Account ready: #{email}")
      user
    end

    def grant_admin!(user)
      user.add_role(:admin) unless user.has_role?(:admin)
      return if user.has_role?(:admin, Site.instance)

      user.add_role(:admin, Site.instance)
    end

    def create_bulk_generic_works(users)
      users.each do |user|
        @works_per_user.times do |i|
          work = save_work!(
            GenericWork.new(
              title: ['This is the title'],
              description: ['This is the description'],
              creator: [user.display_name.presence || user.email],
              subject: %w[geography history chemistry],
              rights_statement: RIGHTS,
              publisher: ['Penguin Publishing'],
              language: ['English'],
              date_created: [Time.zone.at(rand * Time.now.to_i).to_date.to_s],
              bulkrax_identifier: "uc-seed-bulk-#{user.id}-#{i}",
              visibility: PUBLIC,
              admin_set: @admin_set,
              resource_type: ['Generic Work']
            ),
            user
          )
          @created << work
        end
        @logger.info("#{@works_per_user} Generic Works created for #{user.email}")
      end
    end

    def create_complete_works_collection(user)
      collection_type = Hyrax::CollectionType.find_or_create_default_collection_type
      collection = Collection.new(
        title: ['Complete Works'],
        description: ['This is a collection of works with all their metadata filled in.'],
        creator: [user.display_name],
        visibility: PUBLIC,
        collection_type_gid: collection_type.to_global_id.to_s,
        bulkrax_identifier: 'uc-seed-complete-collection'
      )
      collection.apply_depositor_metadata(user.user_key)
      collection.save!
      Sample::PermissionTemplateService.create_for_collection(collection, user)
      @created << collection

      members = complete_member_works(user)
      members.each do |work|
        work.member_of_collections << collection
        work.save!
      end
      collection.update_index
      @logger.info("Complete Works collection created for #{user.email} (#{members.size} members)")
    end

    def complete_member_works(user)
      [
        complete_generic_work(user),
        complete_as_generic_work(user, type: 'Article', title: 'Article Title',
                                       extras: { journal_title: 'Article Journal', issn: '0001' }),
        complete_as_generic_work(user, type: 'Document', title: 'Document Title',
                                       extras: { genre: 'Document Genre' }),
        complete_as_generic_work(user, type: 'Dataset', title: 'Dataset Title'),
        complete_image(user),
        complete_as_generic_work(user, type: 'Medium', title: 'Medium Title'),
        complete_etd(user),
        complete_as_generic_work(
          user,
          type: 'Student Work',
          title: 'Student Work Title',
          extras: { advisor: 'Student Work Advisor', degree: 'Student Work Degree' }
        )
      ]
    end

    def complete_generic_work(user)
      save_work!(
        GenericWork.new(
          title: ['Generic Work Title'],
          creator: ['Generic Work Creator', 'Secondary Generic Work Creator'],
          description: [fold_uc_metadata(
            'This is the description of a Generic Work',
            college: 'Generic Work College',
            department: 'Generic Work Department',
            alternate_title: 'Generic Work Alternate Title',
            geo_subject: 'Generic Work Geo Subject',
            time_period: 'Generic Work Time Period',
            required_software: 'Generic Work Required Software',
            note: 'Generic Work Note'
          )],
          publisher: ['Generic Work Publisher', 'Secondary Generic Work Publisher'],
          date_created: ['2001-01-01'],
          subject: ['Generic Work Subject', 'Secondary Generic Work Subject'],
          language: ['Generic Work Language', 'Secondary Generic Work Language'],
          related_url: ['http://example.com/generic_work', 'http://example.com/secondary_generic_work'],
          rights_statement: RIGHTS,
          bulkrax_identifier: 'uc-seed-complete-generic',
          visibility: PUBLIC,
          admin_set: @admin_set,
          resource_type: ['Generic Work']
        ),
        user
      ).tap { |w| @created << w }
    end

    def complete_as_generic_work(user, type:, title:, extras: {})
      desc_fields = {
        college: "#{type} College",
        department: "#{type} Department",
        alternate_title: "#{type} Alternate Title",
        geo_subject: "#{type} Geo Subject",
        time_period: "#{type} Time Period",
        required_software: "#{type} Required Software",
        note: "#{type} Note"
      }.merge(extras)

      save_work!(
        GenericWork.new(
          title: [title],
          creator: ["#{type} Creator", "Secondary #{type} Creator"],
          description: [fold_uc_metadata("This is the description of a #{type}", **desc_fields)],
          publisher: ["#{type} Publisher", "Secondary #{type} Publisher"],
          date_created: ['2001-01-01'],
          subject: ["#{type} Subject", "Secondary #{type} Subject"],
          language: ["#{type} Language", "Secondary #{type} Language"],
          related_url: ["http://example.com/#{type.parameterize}", "http://example.com/secondary_#{type.parameterize}"],
          rights_statement: RIGHTS,
          bulkrax_identifier: "uc-seed-complete-#{type.parameterize}",
          visibility: PUBLIC,
          admin_set: @admin_set,
          resource_type: [type]
        ),
        user
      ).tap { |w| @created << w }
    end

    def complete_image(user)
      save_work!(
        Image.new(
          title: ['Image Title'],
          creator: ['Image Work Creator', 'Secondary Image Work Creator'],
          description: [fold_uc_metadata(
            'This is the description of an Image',
            college: 'Image College',
            department: 'Image Department',
            genre: 'Image Genre',
            alternate_title: 'Image Alternate Title',
            geo_subject: 'Image Geo Subject',
            time_period: 'Image Work Time Period',
            required_software: 'Image Work Required Software',
            note: 'Image Work Note'
          )],
          publisher: ['Image Publisher', 'Secondary Image Publisher'],
          date_created: ['2001-01-01'],
          subject: ['Image Subject', 'Secondary Image Subject'],
          language: ['Image Work Language', 'Secondary Image Work Language'],
          related_url: ['http://example.com/image', 'http://example.com/secondary_image'],
          rights_statement: RIGHTS,
          bulkrax_identifier: 'uc-seed-complete-image',
          visibility: PUBLIC,
          admin_set: @admin_set,
          resource_type: ['Image']
        ),
        user
      ).tap { |w| @created << w }
    end

    def complete_etd(user)
      save_work!(
        Etd.new(
          title: ['Etd Work Title'],
          creator: ['Etd Creator', 'Secondary Etd Creator'],
          description: [fold_uc_metadata(
            'This is the description of an Etd work.',
            college: 'Etd Work College',
            alternate_title: 'Etd Alternate Title',
            genre: 'Etd Genre',
            geo_subject: 'Etd Work Geo Subject',
            time_period: 'Etd Work Time Period',
            required_software: 'Etd Work Required Software',
            note: 'etd Work Note',
            etd_publisher: 'Generic Work Publisher'
          )],
          advisor: ['Etd Advisor', 'Secondary Etd Advisor'],
          committee_member: ['Committee Member', 'Secondary Committee Member'],
          degree_name: ['Etd Degree'],
          department: ['Etd Department'],
          date_created: ['2001-01-01'],
          subject: ['Etd Subject', 'Secondary Etd Subject'],
          language: ['Etd Work Language', 'Secondary Etd Work Language'],
          related_url: ['http://example.com/etd', 'http://example.com/secondary_etd'],
          rights_statement: RIGHTS,
          bulkrax_identifier: 'uc-seed-complete-etd',
          visibility: PUBLIC,
          admin_set: @admin_set,
          resource_type: ['Masters Thesis']
        ),
        user
      ).tap { |w| @created << w }
    end

    def fold_uc_metadata(base, **fields)
      extras = fields.compact.map { |k, v| "#{k}: #{v}" }.join(' | ')
      extras.empty? ? base : "#{base} [UC seed fields: #{extras}]"
    end

    def save_work!(work, user)
      work.apply_depositor_metadata(user.user_key)
      work.edit_users += [user.email] unless work.edit_users.include?(user.email)
      work.save!
      work
    end

    def index_created!
      @logger.info('Indexing UC sample objects in Solr...')
      @created.each(&:update_index)
    end
  end
end
