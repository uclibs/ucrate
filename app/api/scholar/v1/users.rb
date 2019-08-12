# frozen_string_literal: true
module Scholar
  module V1
    class Users < Grape::API
      version 'v1', using: :accept_version_header
      format :json
      prefix :api
      helpers SharedParams

      # Check the given key
      before do
        error!('401 Unauthorized', 401) unless APIHelper.authenticate!(headers['Api-Key'])
      end

      resource :users do
        params do
          requires :email, type: String
        end

        route_param :email do
          # api/users/:email
          desc 'Return user.'
          get do
            # Validation
            filtered_params = filter_params(:users)
            u = User.from_url_component(filtered_params["email"].downcase)
            error!("User doesn't exist") if u.nil?
            present u.serializable_hash
          end

          desc 'Update user.'
          params do
            use :update_user, :optional_user
          end
          patch do
            # Validation
            params[:department] = params["ucdepartment"].split(' ', 2)[1] if params.key?("ucdepartment")
            filtered_params = filter_params(:users)
            error!("User doesn't exist") if User.from_url_component(filtered_params["email"]).nil?
            u = User.from_url_component(filtered_params["email"])
            u.first_name = filtered_params["first_name"] if filtered_params["first_name"]
            u.last_name = filtered_params["last_name"] if filtered_params["last_name"]
            u.facebook_handle = filtered_params["facebook_handle"] if filtered_params["facebook_handle"]
            u.twitter_handle = filtered_params["twitter_handle"] if filtered_params["twitter_handle"]
            u.googleplus_handle = filtered_params["googleplus_handle"] if filtered_params["googleplus_handle"]
            u.department = filtered_params["department"] if filtered_params["department"]
            u.title = filtered_params["title"] if filtered_params["title"]
            u.website = filtered_params["website"] if filtered_params["website"]
            u.telephone = filtered_params["telephone"] if filtered_params["telephone"]
            u.alternate_phone_number = filtered_params["alternate_phone_number"] if filtered_params["alternate_phone_number"]
            u.blog = filtered_params["blog"] if filtered_params["blog"]
            u.alternate_email = filtered_params["alternate_email"] if filtered_params["alternate_email"]
            u.linkedin_handle = filtered_params["linkedin_handle"] if filtered_params["linkedin_handle"]
            u.ucdepartment = filtered_params["ucdepartment"] if filtered_params["ucdepartment"]
            if APIHelper.uc?(filtered_params["email"])
              u.uid = filtered_params["email"].split('@')[0] + "@uc.edu"
              u.provider = "shibboleth"
            end
            u.updated_at = DateTime.now.iso8601.to_datetime
            begin
              u.save
            rescue StandardError => e
              error!("Error: #{e}", 400)
            end
            present u.serializable_hash
          end
        end

        # api/users
        desc 'Create user.'
        params do
          use :create_user, :optional_user
        end
        post do
          # Validation
          params[:department] = params["ucdepartment"].split(' ', 2)[1] if params.key?("ucdepartment")
          filtered_params = filter_params(:users)
          error!("Email already in use") if APIHelper.find_user(filtered_params["email"])

          u = User.create(eval("{ email: '#{filtered_params['email']}', first_name: '#{filtered_params['first_name']}', last_name: '#{filtered_params['last_name']}', password: '#{filtered_params['password']}', password_confirmation: '#{filtered_params['password']}'}"))

          u.facebook_handle = filtered_params["facebook_handle"] if filtered_params["facebook_handle"]
          u.twitter_handle = filtered_params["twitter_handle"] if filtered_params["twitter_handle"]
          u.googleplus_handle = filtered_params["googleplus_handle"] if filtered_params["googleplus_handle"]
          u.department = filtered_params["department"] if filtered_params["department"]
          u.title = filtered_params["title"] if filtered_params["title"]
          u.website = filtered_params["website"] if filtered_params["website"]
          u.telephone = filtered_params["telephone"] if filtered_params["telephone"]
          u.alternate_phone_number = filtered_params["alternate_phone_number"] if filtered_params["alternate_phone_number"]
          u.blog = filtered_params["blog"] if filtered_params["blog"]
          u.alternate_email = filtered_params["alternate_email"] if filtered_params["alternate_email"]
          u.linkedin_handle = filtered_params["linkedin_handle"] if filtered_params["linkedin_handle"]
          u.ucdepartment = filtered_params["ucdepartment"] if filtered_params["ucdepartment"]
          if APIHelper.uc?(filtered_params["email"])
            u.uid = filtered_params["email"].split('@')[0] + "@uc.edu"
            u.provider = "shibboleth"
          end
          u.created_at = DateTime.now.iso8601.to_datetime
          u.updated_at = DateTime.now.iso8601.to_datetime
          begin
            u.save
          rescue StandardError => e
            error!("Error: #{e}", 400)
          end
          present u.serializable_hash
        end
      end
    end
  end
end
