# frozen_string_literal: true

require 'iiif_manifest'
require Hyrax::Engine.root.join('app/controllers/concerns/hyrax/works_controller_behavior.rb')

module Hyrax
  module WorksControllerBehavior
    def create
      fix_field_that_ends_with_double_quote('description')
      fix_field_that_ends_with_double_quote('note')
      if actor.create(actor_environment)
        after_create_response
      else
        respond_to do |wants|
          wants.html do
            build_form
            render 'new', status: :unprocessable_entity
          end
          wants.json { render_json_response(response_type: :unprocessable_entity, options: { errors: curation_concern.errors }) }
        end
      end
    end

    private

      # add a space to the end of the field when the field ends in a double quote
      # fileds that end in a double quote throw an error
      def fix_field_that_ends_with_double_quote(field_name)
        params[work_type][field_name] = params[work_type][field_name].gsub(/"$/, '" ')
      end

      def work_type
        curation_concern.class.to_s.underscore
      end
  end
end
