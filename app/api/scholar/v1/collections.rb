# frozen_string_literal: true
module Scholar
  module V1
    class Collections < Grape::API
      version 'v1', using: :accept_version_header
      format :json
      prefix :api
      helpers SharedParams

      # Check the given key
      before do
        error!('401 Unauthorized', 401) unless APIHelper.authenticate!(headers['Api-Key'])
      end

      resource :collections do
        params do
          requires :id, type: String
        end
        # api/collections/:id
        route_param :id do
          desc 'Return a collection.'
          get do
            filtered_params = filter_params(:collections)
            begin
              c = Collection.find(filtered_params["id"])
            rescue
              error!("ID not found", 400)
            end
            present c
          end

          desc 'Update a collection.'
          params do
            use :update_collection
            at_least_one_of :title, :creator, :description, :license, :access
          end
          patch do
            # Validation
            filtered_params = filter_params(:collections)
            e = ""
            if filtered_params["license"]
              e << "license " unless APIHelper.validate_license?(filtered_params["license"])
            end
            if filtered_params["access"]
              e << "access " unless APIHelper.validate_access?(filtered_params["access"])
            end
            error!("Invalid parameter(s): #{e}", 400) unless e == ""

            # DB Call
            begin
              c = Collection.find(filtered_params["id"])
            rescue
              error!("ID not found", 400)
            end
            c.title = Array(filtered_params["title"]) if filtered_params["title"]
            c.creator = Array(filtered_params["creator"]) if filtered_params["creator"]
            c.description = Array(filtered_params["description"]) if filtered_params["description"]
            c.license = filtered_params["license"] if filtered_params["license"]
            c.visibility = filtered_params["access"] if filtered_params["access"]
            c.date_modified = DateTime.now.iso8601.to_datetime
            begin
              c.save
            rescue StandardError => e
              error!("Error: #{e}", 400)
            end
            present c
          end
        end

        # api/collections
        desc 'Create a collection.'
        params do
          use :create_collection
        end
        post do
          # Validation
          filtered_params = filter_params(:collections)
          e = ""
          if filtered_params["license"]
            e << "license " unless APIHelper.validate_license?(filtered_params["license"])
          end
          if filtered_params["access"]
            e << "access " unless APIHelper.validate_access?(filtered_params["access"])
          end
          APIHelper.create_user(filtered_params["email"], filtered_params["first_name"], filtered_params["last_name"]) unless APIHelper.find_user(filtered_params["email"])
          error!("Invalid parameter(s): #{e}", 400) unless e == ""

          hash_params = eval("{ title: ['#{filtered_params['title']}'], depositor: '#{filtered_params['email']}', creator: ['#{filtered_params['creator']}'], edit_users: ['#{filtered_params['email']}'], description: ['#{filtered_params['description']}'], collection_type_gid: '#{Hyrax::CollectionType.find_or_create_default_collection_type.gid}', license: '#{filtered_params['license']}', visibility: '#{filtered_params['access']}'}")

          c = Collection.create(hash_params)
          c.date_uploaded = DateTime.now.iso8601.to_datetime
          c.date_modified = DateTime.now.iso8601.to_datetime
          c.save
          present c
        end
      end
    end
  end
end
