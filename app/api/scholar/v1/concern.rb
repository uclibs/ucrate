module Scholar
  module V1
    class Concern < Grape::API
      version 'v1', using: :accept_version_header
      format :json
      prefix :api
      helpers SharedParams

      # Check the given key
      before do
        error!('401 Unauthorized', 401) unless APIHelper.authenticate!(headers['Api-Key'])
      end

      resource :concern do
        # api/concern/:work_type
        route_param :work_type do
          # api/concern/:work_type/:id
          route_param :id do
            desc 'Return a work.'
            params do
              requires :work_type, type: String, values: ["etds", "articles", "documents", "datasets", "images", "media", "student_works", "generic_works"]
              requires :id, type: String
            end
            get do
              filtered_params = filter_params(params[:work_type])
              begin
                case filtered_params["work_type"]
                when "etds"
                  w = Etd.find(filtered_params["id"])
                when "articles"
                  w = Article.find(filtered_params["id"])
                when "documents"
                  w = Document.find(filtered_params["id"])
                when "datasets"
                  w = Dataset.find(filtered_params["id"])
                when "images"
                  w = Image.find(filtered_params["id"])
                when "media"
                  w = Medium.find(filtered_params["id"])
                when "student_works"
                  w = StudentWork.find(filtered_params["id"])
                when "generic_works"
                  w = GenericWork.find(filtered_params["id"])
                end
              rescue
                error!("Unable to find the ID for that specified work type", 400)
              end
              present w
            end

            desc 'Update a work.'
            params do
              requires :work_type, type: String, values: ["etds", "articles", "documents", "datasets", "images", "media", "student_works", "generic_works"]
              requires :id, type: String
              use :update_work, :optional_work
            end
            patch do
              # Validation
              filtered_params = filter_params(params[:work_type])
              e = ""
              if filtered_params["college"]
                e << "college " unless APIHelper.validate_college?(filtered_params["college"])
              end
              if filtered_params["license"]
                e << "license " unless APIHelper.validate_license?(filtered_params["license"])
              end
              if filtered_params["genre"]
                e << "genre " unless APIHelper.validate_genre?(filtered_params["genre"], params[:work_type])
              end
              if filtered_params["access"]
                e << "access " unless APIHelper.validate_access?(filtered_params["access"])
              end
              error!("Invalid parameter(s): #{e}", 400) unless e == ""

              # DB Call
              begin
                case filtered_params["work_type"]
                when "etds"
                  w = Etd.find(filtered_params["id"])
                when "articles"
                  w = Article.find(filtered_params["id"])
                when "documents"
                  w = Document.find(filtered_params["id"])
                when "datasets"
                  w = Dataset.find(filtered_params["id"])
                when "images"
                  w = Image.find(filtered_params["id"])
                when "media"
                  w = Medium.find(filtered_params["id"])
                when "student_works"
                  w = StudentWork.find(filtered_params["id"])
                when "generic_works"
                  w = GenericWork.find(filtered_params["id"])
                end
              rescue
                error!("Unable to find the ID for that specified work type", 400)
              end
              w.title = APIHelper.handle_multi(filtered_params["title"]) if filtered_params["title"]
              w.creator = APIHelper.handle_multi(filtered_params["creator"]) if filtered_params["creator"]
              w.college = filtered_params["college"] if filtered_params["college"]
              w.department = filtered_params["department"] if filtered_params["department"]
              w.description = APIHelper.handle_multi(filtered_params["description"]) if filtered_params["description"]
              w.license = APIHelper.handle_multi(filtered_params["license"]) if filtered_params["license"]
              w.publisher = APIHelper.handle_multi(filtered_params["publisher"]) if filtered_params["publisher"]
              w.date_created = APIHelper.handle_multi(filtered_params["date_created"]) if filtered_params["date_created"]
              w.alternate_title = APIHelper.handle_multi(filtered_params["alternate_title"]) if filtered_params["alternate_title"]
              w.subject = APIHelper.handle_multi(filtered_params["subject"]) if filtered_params["subject"]
              w.geo_subject = APIHelper.handle_multi(filtered_params["geo_subject"]) if filtered_params["geo_subject"]
              w.time_period = APIHelper.handle_multi(filtered_params["time_period"]) if filtered_params["time_period"]
              w.language = APIHelper.handle_multi(filtered_params["language"]) if filtered_params["language"]
              w.required_software = filtered_params["required_software"] if filtered_params["required_software"]
              w.note = filtered_params["note"] if filtered_params["note"]
              w.related_url = APIHelper.handle_multi(filtered_params["related_url"]) if filtered_params["related_url"]
              w.genre = filtered_params["genre"] if filtered_params["genre"]
              w.degree = filtered_params["degree"] if filtered_params["degree"]
              w.journal_title = APIHelper.handle_multi(filtered_params["journal_title"]) if filtered_params["journal_title"]
              w.issn = APIHelper.handle_multi(filtered_params["issn"]) if filtered_params["issn"]
              w.committee_member = APIHelper.handle_multi(filtered_params["committee_member"]) if filtered_params["committee_member"]
              w.advisor = APIHelper.handle_multi(filtered_params["advisor"]) if filtered_params["advisor"]
              w.etd_publisher = filtered_params["etd_publisher"] if filtered_params["etd_publisher"]
              w.read_groups = [filtered_params['access']] if filtered_params["access"]
              w.date_modified = DateTime.now.iso8601.to_datetime
              begin
                w.save
              rescue StandardError => e
                error!("Error: #{e}", 400)
              end
              present w
            end
          end

          desc 'Create a work.'
          params do
            requires :work_type, type: String, values: ["etds", "articles", "documents", "datasets", "images", "media", "student_works", "generic_works"]
            use :create_work, :optional_work
            optional :attachments, type: Array do
              requires :file, type: Rack::Multipart::UploadedFile, desc: "Attached files."
            end
          end
          post do
            create_user = false
            filtered_params = filter_params(params[:work_type])
            e = ""
            if filtered_params["college"]
              e << "college " unless APIHelper.validate_college?(filtered_params["college"])
            end
            if filtered_params["license"]
              e << "license " unless APIHelper.validate_license?(filtered_params["license"])
            end
            if filtered_params["genre"]
              e << "genre " unless APIHelper.validate_genre?(filtered_params["genre"], params[:work_type])
            end
            if filtered_params["access"]
              e << "access " unless APIHelper.validate_access?(filtered_params["access"])
            else filtered_params["access"] = "restricted"
            end
            if !APIHelper.find_user(filtered_params["email"]) && filtered_params["create_user"]
              APIHelper.create_user(filtered_params["email"], filtered_params["first_name"], filtered_params["last_name"])
              create_user = true
            end
            # Check if email was created or exists
            e << "email " unless APIHelper.find_user(filtered_params["email"])
            error!("Invalid parameter(s): #{e}", 400) unless e == ""
            actor = Hyrax::CurationConcern.actor

            case filtered_params["work_type"]
            when "etds"
              w = Etd.new
            when "articles"
              w = Article.new
            when "documents"
              w = Document.new
            when "datasets"
              w = Dataset.new
            when "images"
              w = Image.new
            when "media"
              w = Medium.new
            when "student_works"
              w = StudentWork.new
            when "generic_works"
              w = GenericWork.new
            else
              error!("Unable to create for this work type", 400)
            end
            user = User.find_by_email(filtered_params["email"])
            attributes_for_actor = {}
            # Required fields
            attributes_for_actor["title"] = APIHelper.handle_multi(filtered_params["title"])
            attributes_for_actor["creator"] = APIHelper.handle_multi(filtered_params["creator"])
            attributes_for_actor["description"] = APIHelper.handle_multi(filtered_params["description"])
            attributes_for_actor["license"] = filtered_params["license"]
            attributes_for_actor["visibility"] = filtered_params["access"]

            # Optional Values
            # Note: Look into the state field
            attributes_for_actor["department"] = if filtered_params["department"]
                                                   filtered_params["department"]
                                                 else user["department"]
                                                 end
            attributes_for_actor["publisher"] = APIHelper.handle_multi(filtered_params["publisher"]) if filtered_params["publisher"]
            attributes_for_actor["college"] = if filtered_params["college"]
                                                filtered_params["college"]
                                              else user.college
                                              end
            attributes_for_actor["creator"] = APIHelper.handle_multi(filtered_params["creator"]) if filtered_params["creator"]
            attributes_for_actor["date_created"] = APIHelper.handle_multi(filtered_params["date_created"]) if filtered_params["date_created"]
            attributes_for_actor["alternate_title"] = APIHelper.handle_multi(filtered_params["alternate_title"]) if filtered_params["alternate_title"]
            attributes_for_actor["subject"] = APIHelper.handle_multi(filtered_params["subject"]) if filtered_params["subject"]
            attributes_for_actor["geo_subject"] = APIHelper.handle_multi(filtered_params["geo_subject"]) if filtered_params["geo_subject"]
            attributes_for_actor["time_period"] = APIHelper.handle_multi(filtered_params["time_period"]) if filtered_params["time_period"]
            attributes_for_actor["language"] = APIHelper.handle_multi(filtered_params["language"]) if filtered_params["language"]
            attributes_for_actor["required_software"] = filtered_params["required_software"] if filtered_params["required_software"]
            attributes_for_actor["note"] = filtered_params["note"] if filtered_params["note"]
            attributes_for_actor["related_url"] = APIHelper.handle_multi(filtered_params["related_url"]) if filtered_params["related_url"]
            attributes_for_actor["genre"] = filtered_params["genre"] if filtered_params["genre"]
            attributes_for_actor["degree"] = filtered_params["degree"] if filtered_params["degree"]
            attributes_for_actor["journal_title"] = APIHelper.handle_multi(filtered_params["journal_title"]) if filtered_params["journal_title"]
            attributes_for_actor["issn"] = APIHelper.handle_multi(filtered_params["issn"]) if filtered_params["issn"]
            attributes_for_actor["committee_member"] = APIHelper.handle_multi(filtered_params["committee_member"]) if filtered_params["committee_member"]
            attributes_for_actor["advisor"] = APIHelper.handle_multi(filtered_params["advisor"]) if filtered_params["advisor"]
            attributes_for_actor["etd_publisher"] = filtered_params["etd_publisher"] if filtered_params["etd_publisher"]
            attributes_for_actor['uploaded_files'] = APIHelper.handle_files(user, params["attachments"]) if params["attachments"]
            actor_environment = Hyrax::Actors::Environment.new(w, Ability.new(user), attributes_for_actor)
            actor.create(actor_environment)
            if create_user
              present JSON.parse "{ \"created_user\": #{user.serializable_hash.to_json}, \"concern\": #{w.to_json} }"
            else present w
            end
          end
        end
      end
    end
  end
end
