# frozen_string_literal: true

shared_examples 'concern calls' do |work_class|
  let!(:user) { create(:user) }
  let(:work) { FactoryBot.build(work_class.classify.constantize, user: user, college: "ceas", department: "Test", creator: ["Test"], description: ["Test"], license: ["http://www.opendatacommons.org/licenses/by/1.0/"]) }
  let(:parameters) do
    {
      "access": "open",
      "title": "Title",
      "email": "test@mail.com",
      "first_name": "FName",
      "last_name": "LName",
      "college": "Libraries",
      "department": "Program or Department",
      "creator": "Creator",
      "description": "Description",
      "license": "http://rightsstatements.org/vocab/InC/1.0/",
      "date_created": "1/1/2019",
      "alternate_title": "Test",
      "subject": "subject",
      "geo_subject": "geo_subject",
      "time_period": "time_period",
      "language": "language",
      "required_software": "required_software",
      "note": "note",
      "related_url": "related_url",
      "publisher": "publisher",
      "create_user": "yes"
    }
  end

  let(:genre) do
    if work_class == "documents" || work_class == "student_works"
      { "genre": "Book" }
    else
      { "genre": "Poster" }
    end
  end

  let(:etd_sw_fields) do
    {
      "advisor": "advisor",
      "degree": "degree"
    }
  end

  let(:etd_only) do
    {
      "committee_member": "committee_member",
      "etd_publisher": "etd_publisher"
    }
  end

  let(:articles) do
    {
      "journal_title": "journal_title",
      "issn": "issn"
    }
  end

  describe "create concern" do
    context "with new user" do
      before do
        case work_class
        when "documents"
          genre.each { |key, value| parameters[key] = value }
        when "images"
          genre.each { |key, value| parameters[key] = value }
        when "etds"
          etd_sw_fields.each { |key, value| parameters[key] = value }
          etd_only.each { |key, value| parameters[key] = value }
        when "student_works"
          etd_sw_fields.each { |key, value| parameters[key] = value }
          genre.each { |key, value| parameters[key] = value }
        when "articles"
          articles.each { |key, value| parameters[key] = value }
        end
        post "/api/concern/#{work_class}", params: parameters, headers: { 'API-KEY' => 'testKey' }
      end

      it "responds with correct values" do
        # These must be in the it block
        hash = JSON.parse response.body
        concern = ActiveFedora::Base.find(hash['concern']['id'])
        expect(User.count).to eq(2)
        expect(response.status).to eq(201)
        # All work types
        expect(concern.title).to eq([parameters[:title]])
        expect(concern.depositor).to eq(parameters[:email])
        expect(concern.college).to eq(parameters[:college])
        expect(concern.department).to eq(parameters[:department])
        expect(concern.creator).to eq([parameters[:creator]])
        expect(concern.description).to eq([parameters[:description]])
        expect(concern.license).to eq([parameters[:license]])
        expect(concern.date_created).to eq([parameters[:date_created]])
        expect(concern.alternate_title).to eq([parameters[:alternate_title]])
        expect(concern.subject).to eq([parameters[:subject]])
        expect(concern.geo_subject).to eq([parameters[:geo_subject]])
        expect(concern.time_period).to eq([parameters[:time_period]])
        expect(concern.language).to eq([parameters[:language]])
        expect(concern.required_software).to eq(parameters[:required_software])
        expect(concern.note).to eq(parameters[:note])
        expect(concern.related_url).to eq([parameters[:related_url]])
        # Special cases
        expect(concern.publisher).to eq([parameters[:publisher]]) if work_class != "etds"
        case work_class
        when "documents"
          expect(concern.genre).to eq(parameters[:genre])
        when "images"
          expect(concern.genre).to eq(parameters[:genre])
        when "etds"
          expect(concern.advisor).to eq([parameters[:advisor]])
          expect(concern.degree).to eq(parameters[:degree])
          expect(concern.committee_member).to eq([parameters[:committee_member]])
          expect(concern.etd_publisher).to eq(parameters[:etd_publisher])
        when "student_works"
          expect(concern.genre).to eq(parameters[:genre])
          expect(concern.advisor).to eq([parameters[:advisor]])
          expect(concern.degree).to eq(parameters[:degree])
        when "articles"
          expect(concern.journal_title).to eq([parameters[:journal_title]])
          expect(concern.issn).to eq([parameters[:issn]])
        end
      end
    end

    context "with existing user" do
      before do
        case work_class
        when "documents"
          genre.each { |key, value| parameters[key] = value }
        when "images"
          genre.each { |key, value| parameters[key] = value }
        when "etds"
          etd_sw_fields.each { |key, value| parameters[key] = value }
          etd_only.each { |key, value| parameters[key] = value }
        when "student_works"
          etd_sw_fields.each { |key, value| parameters[key] = value }
          genre.each { |key, value| parameters[key] = value }
        when "articles"
          articles.each { |key, value| parameters[key] = value }
        end
        parameters[:email] = user.email
        post "/api/concern/#{work_class}", params: parameters, headers: { 'API-KEY' => 'testKey' }
      end

      it "responds with correct values" do
        # These must be in the it block
        hash = JSON.parse response.body
        concern = ActiveFedora::Base.find(hash['id'])
        expect(User.count).to eq(1)
        expect(response.status).to eq(201)
        # All work types
        expect(concern.title).to eq([parameters[:title]])
        expect(concern.depositor).to eq(parameters[:email])
        expect(concern.college).to eq(parameters[:college])
        expect(concern.department).to eq(parameters[:department])
        expect(concern.creator).to eq([parameters[:creator]])
        expect(concern.description).to eq([parameters[:description]])
        expect(concern.license).to eq([parameters[:license]])
        expect(concern.date_created).to eq([parameters[:date_created]])
        expect(concern.alternate_title).to eq([parameters[:alternate_title]])
        expect(concern.subject).to eq([parameters[:subject]])
        expect(concern.geo_subject).to eq([parameters[:geo_subject]])
        expect(concern.time_period).to eq([parameters[:time_period]])
        expect(concern.language).to eq([parameters[:language]])
        expect(concern.required_software).to eq(parameters[:required_software])
        expect(concern.note).to eq(parameters[:note])
        expect(concern.related_url).to eq([parameters[:related_url]])
        # Special cases
        case work_class
        when "documents"
          expect(concern.genre).to eq(parameters[:genre])
        when "images"
          expect(concern.genre).to eq(parameters[:genre])
        when "etds"
          expect(concern.advisor).to eq([parameters[:advisor]])
          expect(concern.degree).to eq(parameters[:degree])
          expect(concern.committee_member).to eq([parameters[:committee_member]])
          expect(concern.etd_publisher).to eq(parameters[:etd_publisher])
        when "student_works"
          expect(concern.genre).to eq(parameters[:genre])
          expect(concern.advisor).to eq([parameters[:advisor]])
          expect(concern.degree).to eq(parameters[:degree])
        when "articles"
          expect(concern.journal_title).to eq([parameters[:journal_title]])
          expect(concern.issn).to eq([parameters[:issn]])
        end
      end
    end

    context "with invalid JSON" do
      before do
        parameters.delete :title
        post '/api/collections', params: parameters, headers: { 'API-KEY' => 'testKey' }
      end

      it "responds with the correct error message" do
        expect(response.status).to eq(400)
        expect(response.body).to eq("{\"error\":\"title is missing\"}")
      end
    end
  end

  describe "update collection" do
    context "with valid JSON" do
      before do
        work.save
        parameters.delete :first_name
        parameters.delete :last_name
        parameters.delete :email
        parameters.delete :create_user
        patch "/api/concern/#{work_class}/#{work.id}", params: parameters, headers: { 'API-KEY' => 'testKey' }
      end

      it "returns correct response" do
        concern = ActiveFedora::Base.find(work.id)
        expect(response.status).to eq(200)
        # All work types
        expect(concern.title).to eq([parameters[:title]])
        expect(concern.college).to eq(parameters[:college])
        expect(concern.department).to eq(parameters[:department])
        expect(concern.creator).to eq([parameters[:creator]])
        expect(concern.description).to eq([parameters[:description]])
        expect(concern.license).to eq([parameters[:license]])
        expect(concern.date_created).to eq([parameters[:date_created]])
        expect(concern.alternate_title).to eq([parameters[:alternate_title]])
        expect(concern.subject).to eq([parameters[:subject]])
        expect(concern.geo_subject).to eq([parameters[:geo_subject]])
        expect(concern.time_period).to eq([parameters[:time_period]])
        expect(concern.language).to eq([parameters[:language]])
        expect(concern.required_software).to eq(parameters[:required_software])
        expect(concern.note).to eq(parameters[:note])
        expect(concern.related_url).to eq([parameters[:related_url]])
        # Special cases
        case work_class
        when "documents"
          expect(concern.genre).to eq(parameters[:genre])
        when "images"
          expect(concern.genre).to eq(parameters[:genre])
        when "etds"
          expect(concern.advisor).to eq([parameters[:advisor]])
          expect(concern.degree).to eq(parameters[:degree])
          expect(concern.committee_member).to eq([parameters[:committee_member]])
          expect(concern.etd_publisher).to eq(parameters[:etd_publisher])
        when "student_works"
          expect(concern.genre).to eq(parameters[:genre])
          expect(concern.advisor).to eq([parameters[:advisor]])
          expect(concern.degree).to eq(parameters[:degree])
        when "articles"
          expect(concern.journal_title).to eq([parameters[:journal_title]])
          expect(concern.issn).to eq([parameters[:issn]])
        end
      end
    end
  end

  describe "get concern" do
    context "with valid JSON" do
      before do
        work.save
        get "/api/concern/#{work_class}/#{work.id}", headers: { 'API-KEY' => 'testKey' }
      end

      it "returns correct response" do
        expect(response.status).to eq(200)
        expect(response.body).to eq(work.to_json)
      end
    end
  end
end
