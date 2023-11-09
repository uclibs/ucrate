# frozen_string_literal: true

module Hyrax
  module CollectionTypes
    class PermissionsService
      # Pieces of this class was overwritten from the hyrax gem version 2.9.6 because some
      # of the sql queries being performed were giving a deprecation warning about a potentially
      # unsafe SQL query. The queries in this gem have been rewritten to use syntax compatible
      # with Rails 6.
      def self.collection_type_ids_for_user(roles:, user: nil, ability: nil)
        return false unless user.present? || ability.present?
        return Hyrax::CollectionType.distinct.pluck(:id) if user_admin?(user, ability)
        Hyrax::CollectionTypeParticipant.where(agent_type: Hyrax::CollectionTypeParticipant::USER_TYPE,
                                               agent_id: user_id(user, ability),
                                               access: roles)
                                        .or(
                                          Hyrax::CollectionTypeParticipant.where(agent_type: Hyrax::CollectionTypeParticipant::GROUP_TYPE,
                                                                                 agent_id: user_groups(user, ability),
                                                                                 access: roles)
                                        )
                                        .select(:hyrax_collection_type_id)
                                        .distinct
                                        .pluck(:hyrax_collection_type_id)
      end

      # There were no changes to this method, but the Hyrax tests are intertwined and require it here.
      def self.collection_types_for_user(roles:, user: nil, ability: nil)
        return false unless user.present? || ability.present?
        return Hyrax::CollectionType.all if user_admin?(user, ability)
        Hyrax::CollectionType.where(id: collection_type_ids_for_user(user: user, roles: roles, ability: ability))
      end

      def self.agent_ids_for(collection_type:, agent_type:, access:)
        Hyrax::CollectionTypeParticipant.where(hyrax_collection_type_id: collection_type.id,
                                               agent_type: agent_type,
                                               access: access)
                                        .select(:agent_id)
                                        .distinct
                                        .pluck(:agent_id)
      end
      private_class_method :agent_ids_for

      def self.user_edit_grants_for_collection_of_type(collection_type: nil)
        return [] unless collection_type
        Hyrax::CollectionTypeParticipant.joins(:hyrax_collection_type)
                                        .where(hyrax_collection_type_id: collection_type.id,
                                               agent_type: Hyrax::CollectionTypeParticipant::USER_TYPE,
                                               access: Hyrax::CollectionTypeParticipant::MANAGE_ACCESS)
                                        .select(:agent_id)
                                        .distinct
                                        .pluck(:agent_id)
      end

      def self.group_edit_grants_for_collection_of_type(collection_type: nil)
        return [] unless collection_type
        groups = Hyrax::CollectionTypeParticipant.joins(:hyrax_collection_type)
                                                 .where(hyrax_collection_type_id: collection_type.id,
                                                        agent_type: Hyrax::CollectionTypeParticipant::GROUP_TYPE,
                                                        access: Hyrax::CollectionTypeParticipant::MANAGE_ACCESS)
                                                 .select(:agent_id)
                                                 .distinct
                                                 .pluck(:agent_id)
        groups | ['admin']
      end

      # The self.user_admin? method in the gem is followed by a mistake.  It has
      # `private_class_method :user_groups` beneath both self.user_groups and
      # beneath self.user_admin?  We're not making a change to the function here
      # but are correcting the private_class_method line.
      def self.user_admin?(user, ability)
        # if called from abilities class, use ability instead of user; otherwise, you end up in an infinite loop
        return ability.admin? if ability.present?
        user.ability.admin?
      end
      private_class_method :user_admin?
    end
  end
end
