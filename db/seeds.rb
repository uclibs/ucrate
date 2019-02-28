# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
class AddSeedObjects < ActiveRecord::Migration[5.1]

  password = Devise.friendly_token.first(8)
  puts "Password for all accounts: #{password}\n\n"


  if many_deposits = User.find_by_email('manydeposits@example.com')
    many_deposits.update(
      password: password, 
      password_confirmation: password)
    puts "Account updated: #{many_deposits.email}"
    many_deposits.save
  else
    many_deposits = User.create(
      email: 'manydeposits@example.com',
      first_name: 'Many',
      last_name: 'Deposits',
      password: password,
      password_confirmation: password,
      ucdepartment: 'CCM Music')
    puts "Account created: #{many_deposits.email}"
  end

  if no_deposits = User.find_by_email('nodeposits@example.com')
    no_deposits.update(
      password: password,
      password_confirmation: password)
    puts "Account updated: #{no_deposits.email}"
    no_deposits.save
  else
    no_deposits = User.create(
      email: 'nodeposits@example.com',
      first_name: 'No',
      last_name: 'Deposits',
      password: password,
      password_confirmation: password,
      ucdepartment: 'UCL Rsearch')
    puts "Account created: #{no_deposits.email}"
  end

  if student_delegate = User.find_by_email('delegate@example.com')
    student_delegate.update(
      password: password,
      password_confirmation: password)
    student_delegate.save
    puts "Account updated: #{student_delegate.email}"
  else
    student_delegate = User.create(
      email: 'delegate@example.com',
      first_name: 'Student',
      last_name: 'Delegate',
      password: password,
      password_confirmation: password,
      ucdepartment: 'CEAS Computer Science')
    puts "Account created: #{student_delegate.email}"
  end

  if admin_user = User.find_by_email('admin@example.com')
    admin_user.update(
      password: password,
      password_confirmation: password)
    admin = Role.find_or_create_by(name: 'admin')
    admin.users << admin_user
    admin.save
    puts "Account updated: #{admin_user.email}"
  else
    admin_user = User.create(
      email: 'admin@example.com',
      first_name: 'Admin',
      last_name: 'User',
      password: password,
      password_confirmation: password)
    admin = Role.find_or_create_by(name: 'admin')
    admin.users << admin_user
    admin.save
    puts "Account created: #{admin_user.email}\n\n"
  end

  users_with_works = [many_deposits, student_delegate, admin_user]
  works_per_user = 10

  users_with_works.each do |user|
    works_per_user.times do
      work = GenericWork.create(
        title: ['This is the title'],
        description: ['This is the description'],
        depositor: user.email,
        owner: user.email,
        creator: ["#{user.last_name}, #{user.first_name}"],
        subject: ['geography', 'history', 'chemistry'],
        rights_statement: ["http://rightsstatements.org/vocab/InC/1.0/"],
        publisher: ['Penguin Publishing'],
        language: ['English'],
        based_near: ['The world'],
        date_created: [Time.zone.at(rand * Time.now.to_i).to_s.sub(/\s(.*)/, '')]
      )
      work.read_groups = [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC]
      work.edit_users = [user.email]
      work.save
      work.to_solr
    end
    puts "#{works_per_user} Generic Works created for #{user.email}"
  end

  # Generate complete works

  complete_collection = Collection.create(
    title: ["Complete Works"],
    depositor: many_deposits.email,
    creator: ["Deposits, Many"],
    edit_users: [many_deposits.email],
    description: ["This is a collection of works with all their metadata filled in."],
    collection_type_gid: "gid://scholar-uc/hyrax-collectiontype/1",
    visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    )

  complete_generic_work = GenericWork.create(
    title: ['Generic Work Title'],
    creator: ["Generic Work Creator", "Secondary Generic Work Creator"],
    depositor: many_deposits.email,
    owner: many_deposits.email,
    description: ["This is the description of a Generic Work"],
    college: "Generic Work College",
    department: "Generic Work Department",
    license: ["http://rightsstatements.org/vocab/InC/1.0/"],
    publisher: ["Generic Work Publisher", "Secondary Generic Work Publisher"],
    date_created: ["2001-01-01"],
    alternate_title: ["Generic Work Alternate Title", "Generic Work Secondary Alternate Title"],
    subject: ["Generic Work Subject", "Secondary Generic Work Subject"],
    geo_subject: ["Generic Work Geo Subject", "Secondary Generic Work Geo Subject"],
    time_period: ["Generic Work Time Period", "Secondary Generic Work Time Period"],
    language: ["Generic Work Language", "Secondary Generic Work Language"],
    required_software: "Generic Work Required Software",
    note: "Generic Work Note",
    related_url: ["example.com/generic_work", "example.com/secondary_generic_work"]
  )
  complete_generic_work.read_groups = [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC]
  complete_generic_work.edit_users = [many_deposits.email]
  complete_generic_work.save
  complete_generic_work.to_solr
  complete_collection.add_member_objects [complete_generic_work.id]

  complete_article = Article.create(
    title: ['Article Title'],
    creator: ["Article Creator", "Secondary Article Creator"],
    depositor: many_deposits.email,
    owner: many_deposits.email,
    description: ["This is the description of an Article"],
    college: "Article College",
    department: "Article Department",
    license: ["http://rightsstatements.org/vocab/InC/1.0/"],
    publisher: ["Article Publisher", "Secondary Article Publisher"],
    date_created: ["2001-01-01"],
    alternate_title: ["Article Alternate Title", "Secondary Article Alternate Title"],
    journal_title: ["Article Journal", "Secondary Article Journal"],
    issn: ["0001", "0002"],
    subject: ["Article Subject", "Secondary Article Subject"],
    geo_subject: ["Article Geo Subject", "Secondary Article Geo Subject"],
    time_period: ["Article Time Period", "Secondary Article Time Period"],
    language: ["Article Language", "Secondary Article Language"],
    required_software: "Article Required Software",
    note: "Article Note",
    related_url: ["example.com/article", "example.com/secondary_article"]
  )
  complete_article.read_groups = [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC]
  complete_article.edit_users = [many_deposits.email]
  complete_article.save
  complete_article.to_solr
  complete_collection.add_member_objects [complete_article.id]

  complete_document = Document.create(
    title: ['Document Title'],
    creator: ["Document Creator", "Secondary Document Creator"],
    depositor: many_deposits.email,
    owner: many_deposits.email,
    description: ["This is the description of a Document"],
    college: "Document College",
    department: "Document Department",
    license: ["http://rightsstatements.org/vocab/InC/1.0/"],
    publisher: ["Document Publisher", "Secondary Document Publisher"],
    date_created: ["2001-01-01"],
    alternate_title: ["Document Alternate Title", "Secondary Document Title"],
    genre: "Document Genre",
    subject: ["Document Subject", "Secondary Document Subject"],
    geo_subject: ["Document Geo Subject", "Secondary Document Geo Subject"],
    time_period: ["Document Work Time Period", "Secondary Doeument Work Time Period"],
    language: ["Document Work Language", "Secondary Document Work Language"],
    required_software: "Document Work Required Software",
    note: "Document Work Note",
    related_url: ["example.com/document", "example.com/secondary_document"]
  )
  complete_document.read_groups = [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC]
  complete_document.edit_users = [many_deposits.email]
  complete_document.save
  complete_document.to_solr

  complete_collection.add_member_objects [complete_document.id]

  complete_dataset = Dataset.create(
    title: ['Dataset Title'],
    creator: ["Dataset Creator", "Secondary Dataset Creator"],
    depositor: many_deposits.email,
    owner: many_deposits.email,
    description: ["This is the description of a Dataset"],
    college: "Dataset College",
    department: "Dataset Department",
    license: ["http://rightsstatements.org/vocab/InC/1.0/"],
    publisher: ["Dataset Publisher", "Secondary Dataset Publisher"],
    date_created: ["2001-01-01"],
    alternate_title: ["Dataset Alternate Title", "Secondary Dataset Alternate Title"],
    subject: ["Dataset Subject", "Secondary Dataset Subject"],
    geo_subject: ["Dataset Geo Subject", "Secondary Dataset Geo Subject"],
    time_period: ["Dataset Time Period", "Secondary Dataset Time Period"],
    language: ["Dataset Language", "Secondary Dataset Language"],
    required_software: "Dataset Required Software",
    note: "Dataset Note",
    related_url: ["example.com/dataset", "example.com/secondary_dataset"]
  )
  complete_dataset.read_groups = [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC]
  complete_dataset.edit_users = [many_deposits.email]
  complete_dataset.save
  complete_dataset.to_solr
  complete_collection.add_member_objects [complete_dataset.id]

  complete_image = Image.create(
    title: ['Image Title'],
    creator: ["Image Work Creator", "Secondary Image Work Creator"],
    depositor: many_deposits.email,
    owner: many_deposits.email,
    description: ["This is the description of an Image"],
    college: "Image College",
    department: "Image Department",
    license: ["http://rightsstatements.org/vocab/InC/1.0/"],
    publisher: ["Image Publisher", "Secondary Image Publisher"],
    date_created: ["2001-01-01"],
    alternate_title: ["Image Alternate Title", "Secondary Image Alternate Title"],
    genre: "Image Genre",
    subject: ["Image Subject", "Secondary Image Subject"],
    geo_subject: ["Image Geo Subject", "Secondary Image Geo Subject"],
    time_period: ["Image Work Time Period", "Secondary Image Work Time Period"],
    language: ["Image Work Language", "Secondary Image Work Language"],
    required_software: "Image Work Required Software",
    note: "Image Work Note",
    related_url: ["example.com/image", "example.com/secondary_image"]
  )
  complete_image.read_groups = [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC]
  complete_image.edit_users = [many_deposits.email]
  complete_image.save
  complete_image.to_solr
  complete_collection.add_member_objects [complete_image.id]

  complete_medium = Medium.create(
    title: ['Medium Title'],
    creator: ["Medium Creator", "Secondary Medium Creator"],
    depositor: many_deposits.email,
    owner: many_deposits.email,
    description: ["This is the description of a Medium"],
    college: "Medium College",
    department: "Medium Department",
    license: ["http://rightsstatements.org/vocab/InC/1.0/"],
    publisher: ["Medium Publisher", "Secondary Medium Publisher"],
    date_created: ["2001-01-01"],
    alternate_title: ["Medium Alternate Title", "Secondary Medium Alternate Title"],
    subject: ["Medium Subject", "Secondary Medium Subject"],
    geo_subject: ["Medium Geo Subject", "Secondary Medium Geo Subject"],
    time_period: ["Medium Time Period", "Secondary Medium Time Period"],
    language: ["Medium Language", "Secondary Medium Language"],
    required_software: "Medium Required Software",
    note: "Medium Note",
    related_url: ["example.com/medium", "example.com/secondary_medium"]
  )
  complete_medium.read_groups = [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC]
  complete_medium.edit_users = [many_deposits.email]
  complete_medium.save
  complete_medium.to_solr
  complete_collection.add_member_objects [complete_medium.id]

  complete_etd = Etd.create(
    title: ['Etd Work Title'],
    creator: ["Etd Creator", "Secondary Etd Creator"],
    depositor: many_deposits.email,
    owner: many_deposits.email,
    description: ["This is the description of an Etd work."],
    college: "Etd Work College",
    department: "Etd Department",
    advisor: ["Etd Advisor", "Secondary Etd Advisor"],
    license: ["http://rightsstatements.org/vocab/InC/1.0/"],
    committee_member: ["Committee Member", "Secondary Committee Member"],
    degree: "Etd Degree",
    etd_publisher: "Generic Work Publisher",
    date_created: ["2001-01-01"],
    alternate_title: ["Etd Alternate Title", "Secondary Etd Alternate Title"],
    genre: "Etd Genre",
    subject: ["Etd Subject", "Secondary Etd Subject"],
    geo_subject: ["Etd Work Geo Subject", "Secondary Etd Work Geo Subject"],
    time_period: ["Etd Work Time Period", "Secondary Etd Work Time Period"],
    language: ["Etd Work Language", "Secondary Etd Work Language"],
    required_software: "Etd Work Required Software",
    note: "etd Work Note",
    related_url: ["example.com/etd", "example.com/secondary_etd"]
  )
  complete_etd.read_groups = [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC]
  complete_etd.edit_users = [many_deposits.email]
  complete_etd.save
  complete_etd.to_solr
  complete_collection.add_member_objects [complete_etd.id]

  complete_student_work = StudentWork.create(
    title: ['Student Work Title'],
    creator: ["Student Work Creator", "Secondary Student Work Creator"],
    depositor: many_deposits.email,
    owner: many_deposits.email,
    description: ["This is the description of a Student Work"],
    college: "Student Work College",
    department: "Generic Work Department",
    advisor: ["Student Work Advisor", "Secondary Student Work Advisor"],
    license: ["http://rightsstatements.org/vocab/InC/1.0/"],
    degree: "Student Work Degree",
    publisher: ["Student Work Publisher", "Secondary Student Work Publisher"],
    date_created: ["2001-01-01"],
    alternate_title: ["Student Work Alternate Title", "Secondary Student Work Alternate Title"],
    genre: "Student Work Genre",
    subject: ["Student Work Subject", "Secondary Student Work Subject"],
    geo_subject: ["Student Work Geo Subject", "Secondary Student Work Geo Subject"],
    time_period: ["Student Work Time Period", "Secondary Student Work Time Period"],
    language: ["Student Work Language", "Secondary Student Work Language"],
    required_software: "Student Work Required Software",
    note: "Student Work Note",
    related_url: ["example.com/student_work", "example.com/secondary_student_work"]
  )
  complete_student_work.read_groups = [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC]
  complete_student_work.edit_users = [many_deposits.email]
  complete_student_work.save
  complete_student_work.to_solr
  complete_collection.add_member_objects [complete_student_work.id]

  puts "Complete Works created for #{many_deposits.email} and added them to the collection #{complete_collection.title.first}"
end
