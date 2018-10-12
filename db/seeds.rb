# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
class AddSeedObjects < ActiveRecord::Migration[5.1]

  password = Devise.friendly_token.first(8)
  puts "Password for all accounts: #{password}\n\n"

  User.find_by_email('manydeposits@example.com').try(:destroy)
  many_deposits = User.create(
    email: 'manydeposits@example.com',
    first_name: 'Many',
    last_name: 'Deposits',
    password: password,
    password_confirmation: password)
  puts "Account created: #{many_deposits.email}"

  User.find_by_email('nodeposits@example.com').try(:destroy)
  no_deposits = User.create(
    email: 'nodeposits@example.com',
    first_name: 'No',
    last_name: 'Deposits',
    password: password,
    password_confirmation: password)
  puts "Account created: #{no_deposits.email}"

  User.find_by_email('delegate@example.com').try(:destroy)
  student_delegate = User.create(
    email: 'delegate@example.com',
    first_name: 'Student',
    last_name: 'Delegate',
    password: password,
    password_confirmation: password)
  puts "Account created: #{student_delegate.email}"

  User.find_by_email('admin@example.com').try(:destroy)
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
        date_created: [Time.zone.at(rand * Time.now.to_i).to_s.sub(/\s(.*)/, '')],
        admin_set: AdminSet.first
      )
      work.read_groups = [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC]
      work.edit_users = [user.email]
      work.save
      work.to_solr
    end
    puts "#{works_per_user} Generic Works created for #{user.email}"
  end

end
