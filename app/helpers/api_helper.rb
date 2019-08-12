# frozen_string_literal: true

module APIHelper
  def self.authenticate!(token)
    # Check token against our api_keys
    #  Can set a value for what is being checked to the key of the token used
    eval(ENV['API_KEY']).value?(token) ? true : false
  end

  def self.validate_college?(input)
    college_yaml = YAML.load_file(Rails.root.join('config', 'college_and_department.yml'))
    college_yaml.each_key do |outer_key|
      # if you are at the end of the list
      return false if outer_key == "legacy_colleges"
      # Check the list for the input
      college_yaml[outer_key].each_key do |inner_key|
        return true if college_yaml[outer_key][inner_key]["label"] == input
      end
    end
  end

  def self.validate_license?(input)
    license_yaml = YAML.load_file(Rails.root.join('config', 'authorities', 'licenses.yml'))
    # Loop licenses
    license_yaml["terms"].each do |license|
      return true if license["id"] == input
    end
    false
  end

  def self.validate_genre?(input, work_type)
    # Loop genres
    if work_type == "etds" || work_type == "student_works"
      student_yaml = YAML.load_file(Rails.root.join('config', 'authorities', 'genre_types_student_work.yml'))
      student_yaml["terms"].each do |genre|
        return true if genre[0] == input
      end
    elsif work_type == "images"
      image_yaml = YAML.load_file(Rails.root.join('config', 'authorities', 'genre_types_image.yml'))
      image_yaml["terms"].each do |genre|
        return true if genre[0] == input
      end
    else
      document_yaml = YAML.load_file(Rails.root.join('config', 'authorities', 'genre_types_document.yml'))
      document_yaml["terms"].each do |genre|
        return true if genre[0] == input
      end
    end
    false
  end

  def self.validate_access?(input)
    return true if input == "open" || input == "authenticated" || input == "restricted"
    false
  end

  def self.handle_multi(input)
    input.split("|")
  end

  def self.find_user(input)
    input = input.downcase
    return true if User.find_by_email(input)
    false
  end

  def self.create_user(email, first_name, last_name)
    password = Devise.friendly_token.first(8)
    User.create(eval("{ email: '#{email}', first_name: '#{first_name}', last_name: '#{last_name}', password: '#{password}', password_confirmation: '#{password}'}"))
  end

  def self.uc?(email)
    return true if email.include? "uc.edu"
    false
  end

  def self.handle_files(user, file_array)
    ids = []
    file_array.each do |file|
      send_file = ActionDispatch::Http::UploadedFile.new(tempfile: file["file"]["tempfile"])
      send_file.original_filename = file["file"]["filename"]
      send_file.content_type = file["file"]["type"]
      send_file.headers = file["file"]["head"]
      ApiUploadsController.create(user, send_file)
      ids << Hyrax::UploadedFile.last.id.to_s
    end
    ids
  end
end
