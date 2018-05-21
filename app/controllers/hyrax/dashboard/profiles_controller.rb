require Hyrax::Engine.root.join('app/controllers/hyrax/dashboard/profiles_controller.rb')
module Hyrax
  module Dashboard
    class ProfilesController < Hyrax::UsersController
      def show
        user = ::User.from_url_component(params[:id])
        return redirect_to root_path, alert: "User '#{params[:id]}' does not exist" if user.nil?
        @presenter = Hyrax::UserProfilePresenter.new(user, current_ability)
        @permalinks_presenter = PermalinksPresenter.new(hyrax.dashboard_profile_path(locale: nil))
      end

      private

        def user_params
          params.require(:user).permit(:avatar, :facebook_handle, :twitter_handle,
                                       :googleplus_handle, :linkedin_handle, :remove_avatar,
                                       :orcid, :first_name, :last_name, :title, :ucdepartment, :uc_affiliation,
                                       :alternate_email, :telephone, :alternate_phone_number, :website, :blog)
        end
    end
  end
end
