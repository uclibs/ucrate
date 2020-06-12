# frozen_string_literal: true
module Hyrax
  module Actors
    class MintDoiActor < Hyrax::Actors::AbstractActor
      def create(env)
        next_actor.create(env)
        apply_doi_assignment_strategy(env.curation_concern)
      end

      def update(env)
        next_actor.update(env.attributes)
        apply_doi_assignment_strategy(env.curation_concern)
      end

      private

      def apply_doi_assignment_strategy(work)
        work.extend(RemotelyIdentifiedByDoi::MintingBehavior)
        work.apply_doi_assignment_strategy { work.save }
      end
    end
  end
end
