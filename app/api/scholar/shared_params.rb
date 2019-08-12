module Scholar
  module SharedParams
    extend Grape::API::Helpers

    def filter_params(type) # Work type or collection
      declared_params = declared(params).to_a
      # Add special cases to allow for different types
      if type == 'etds' || type == 'student_works'
        declared_params << ["advisor", params[:advisor]] if params.key?("advisor")
        declared_params << ["degree", params[:degree]] if params.key?("degree")
        declared_params << ["committee_member", params[:committee_member]] if params.key?("committee_member")
        declared_params << ["etd_publisher", params[:etd_publisher]] if params.key?("etd_publisher")
      elsif type == 'articles'
        declared_params << ["journal_title", params[:journal_title]] if params.key?("journal_title")
        declared_params << ["issn", params[:issn]] if params.key?("issn")
      end
      if type == 'images' || type == 'student_works' || type == 'documents'
        declared_params << ["genre", params[:genre]] if params.key?("genre")
      end
      # Note: You must do it in this order to not fail optional fields
      diff = params.to_a - declared_params.to_a
      if diff.any?
        e_message = ""
        diff.each { |x| e_message << "#{x[0]} " }
        error!("Invalid parameter(s): #{e_message}", 400)
      end
      declared_params.to_h
    end

    # Required fields for all work types
    params :create_work do
      requires :email, regexp: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
      requires :first_name, type: String
      requires :last_name, type: String
      requires :title, type: String
      requires :creator, type: String
      requires :description, type: String
      requires :license, type: String
      optional :create_user, type: Boolean
    end

    # Optional fields for updating a work
    params :update_work do
      optional :title, type: String
      optional :creator, type: String
      optional :description, type: String
      optional :license, type: String
    end

    params :optional_work do
      optional :access, type: String
      optional :college, type: String
      optional :department, type: String
      optional :date_created, type: String
      optional :alternate_title, type: String
      optional :subject, type: String
      optional :geo_subject, type: String
      optional :time_period, type: String
      optional :language, type: String
      optional :required_software, type: String
      optional :note, type: String
      optional :related_url, type: String
      optional :publisher, type: String
    end

    params :create_user do
      requires :email, regexp: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
      requires :first_name, type: String
      requires :last_name, type: String
      requires :password, type: String
    end

    params :update_user do
      # Use -dot-
      requires :email, type: String
      optional :first_name, type: String
      optional :last_name, type: String
    end

    params :optional_user do
      optional :facebook_handle, type: String
      optional :twitter_handle, type: String
      optional :googleplus_handle, type: String
      optional :department, type: String
      optional :title, type: String
      optional :website, type: String
      optional :telephone, type: String
      optional :alternate_phone_number, type: String
      optional :blog, type: String
      optional :alternate_email, type: String
      optional :linkedin_handle, type: String
      optional :ucdepartment, type: String
    end

    params :create_collection do
      requires :title, type: String
      requires :email, regexp: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
      requires :first_name, type: String
      requires :last_name, type: String
      requires :creator, type: String
      requires :description, type: String
      requires :license, type: String
      requires :access, type: String
    end

    params :update_collection do
      optional :title, type: String
      optional :creator, type: String
      optional :description, type: String
      optional :license, type: String
      optional :access, type: String
    end
  end
end
