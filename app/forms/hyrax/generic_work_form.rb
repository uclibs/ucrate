# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work GenericWork`
module Hyrax
  class GenericWorkForm < Hyrax::Forms::WorkForm
    self.model_class = ::GenericWork

    ## Adding custom descriptive metadata terms
    self.terms += %i[alternate_title time_period required_software
                     note geo_subject]

    ## Adding terms needed for the special DOI form tab
    self.terms += %i[doi doi_assignment_strategy existing_identifier]

    ## Adding terms college and department
    self.terms += %i[college department]

    ## Removing terms that we don't use
    self.terms -= %i[rights_statement keyword source contributor based_near identifier resource_type]

    ## Setting custom required fields
    self.required_fields = %i[title creator college department description license]

    ## Adding above the fold on the form without making this required
    def primary_terms
      required_fields + %i[publisher date_created alternate_title subject geo_subject time_period
                           language required_software note related_url]
    end

    ## Gymnastics to allow repeatble fields to behave as non-repeatable

#    def self.model_attributes(_)
#      attrs = super
#      attrs[:title] = Array(attrs[:title]) if attrs[:title]
#      attrs[:description] = Array(attrs[:description]) if attrs[:description]
#      attrs[:date_created] = Array(attrs[:date_created]) if attrs[:date_created]
#      attrs[:alternative_title] = Array(attrs[:alternative_title]) if attrs[:alternative_title]
#      attrs[:rights_notes] = Array(attrs[:rights_notes]) if attrs[:rights_notes]
#      attrs[:access_rights] = Array(attrs[:access_rights]) if attrs[:access_rights]
#      attrs[:creator] = Array(attrs[:access_rights]) if attrs[:creator]


#      attrs
#    end

    def self.model_attributes(attributes)
        attrs = super
        return attrs unless attributes[:title]

          attrs[:title] = Array(attributes[:title])
            return attrs if attributes[:alternate_title].nil?
          Array(attributes[:alternate_title]).each do |value|
            attrs["title"] << value if value != ""
        end
        attrs
     end





    def title
      super.first || ""
    end

#    def description
#      super.first || ""
#    end

#    def creator
#      super.first || ""
#    end

#    def date_created
#      super.first || ""
#    end

#    def altervative_title
#       super.first || ""
#    end

#    def rights_notes
#       super.first || ""
#    end

#    def access_rights
#       super.first || ""
#    end


  end
end
