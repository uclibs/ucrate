# frozen_string_literal: true
class WorksReport < Report
  def self.report_objects
    works = []
    work_type_classes.each do |type_class|
      type_class.all.each { |work| works << work }
    end
    works
  end

  def self.fields(work = GenericWork.new)
    [
      { id: work.id },
      { owner: work.owner },
      { depositor: work.depositor },
      { editors: work.edit_users.join(" ") }
    ] + attributes(work)
  end

  def self.attributes(work)
    all_attributes_list.map do |attribute|
      if work.class.method_defined? attribute
        { attribute => work.send(attribute) }
      else
        { attribute => nil }
      end
    end
  end

  def self.all_attributes_list
    %i[
      abstract
      admin_set_id
      advisor
      alt_date_created
      alt_description
      alternate_title
      bibliographic_citation
      college
      committee_member
      contributor
      creator
      cultural_context
      date_created
      date_digitized
      degree
      department
      description
      embargo_release_date
      etd_publisher
      existing_identifier
      genre
      geo_subject
      identifier
      inscription
      issn
      journal_title
      language
      license
      location
      material
      measurement
      note
      publisher
      related_url
      required_software
      source
      subject
      time_period
      title
      type
      visibility
      visibility_after_embargo
      visibility_during_embargo
    ]
  end

  def self.work_type_classes
    Hyrax.config.registered_curation_concern_types.collect(&:constantize)
  end
end
