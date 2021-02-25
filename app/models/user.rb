# frozen_string_literal: true

class User < ApplicationRecord
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles

  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats

  attr_accessible :email, :password, :password_confirmation if Blacklight::Utils.needs_attr_accessible?
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, omniauth_providers: [:orcid, :shibboleth]

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  def name
    return "#{first_name} #{last_name}" unless first_name.blank? || last_name.blank?
    user_key
  end

  def name_for_works
    last_name + ", " + first_name unless first_name.blank? || last_name.blank?
  end

  def waive_welcome_page!
    update_column(:waived_welcome_page, true)
  end

  def student?
    uc_affiliation == 'student'
  end

  def college
    return "Other" if ucdepartment.blank?
    user_colleges.each_key do |key|
      return user_colleges[key]["label"] if ucdepartment.downcase.start_with?(key + " ")
    end
    "Other"
  end

  def department
    return "Unknown" if ucdepartment.blank?
    user_colleges.each_key do |key|
      return ucdepartment[/(?<=\s).*/] if ucdepartment.downcase.start_with?(key + " ")
    end
    ucdepartment
  end

  def full_department
    return college if department == "Unknown"
    "#{college}: #{department}"
  end

  def name_for_people_page
    if first_name.blank? || last_name.blank?
      email
    else
      last_name + ", " + first_name
    end
  end

  private

  def user_colleges
    COLLEGE_AND_DEPARTMENT["current_colleges_for_degrees"].merge(COLLEGE_AND_DEPARTMENT["additional_current_colleges_library"])
  end
end
