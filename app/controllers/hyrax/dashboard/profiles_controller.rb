# frozen_string_literal: true

require Hyrax::Engine.root.join('app/controllers/hyrax/dashboard/profiles_controller.rb')
module Hyrax
  module Dashboard
    class ProfilesController < Hyrax::UsersController
      def show
        user = ::User.from_url_component(params[:id])
        return redirect_to root_path, alert: "User '#{params[:id]}' does not exist" if user.nil?

        # prefer user profile view to dashboard profile
        redirect_to hyrax.user_path(user)
      end

      private

        def user_params
          params.require(:user).permit(:avatar, :facebook_handle, :twitter_handle,
                                       :googleplus_handle, :linkedin_handle, :remove_avatar,
                                       :orcid, :first_name, :last_name, :title, :ucdepartment, :uc_affiliation,
                                       :alternate_email, :telephone, :alternate_phone_number, :website, :blog, :rd_page)
        end
    end
  end
end
