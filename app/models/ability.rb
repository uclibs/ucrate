# frozen_string_literal: true

class Ability
  include Hydra::Ability
  include Hyrax::Ability
  self.ability_logic += [:everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions # rubocop:disable Metrics/MethodLength
    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end

    cannot [:edit, :update, :delete], Etd
    can [:manage], Etd if user_is_etd_manager

    can [:create], ClassifyConcern unless current_user.new_record?
    can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role if current_user.admin?
    can [:manage], Etd if current_user.admin?
  end

  private

  def curation_concerns_models
    default_curation_concerns = Hyrax.config.curation_concerns
    default_curation_concerns.delete(Etd)
    [::FileSet, ::Collection] + default_curation_concerns
  end

  def user_is_etd_manager
    user_groups.include? 'etd_manager'
  end
end
