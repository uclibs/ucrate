require 'rails_helper'

RSpec.feature "End to end", type: :feature do
  scenario "workflow" do
    ## Create an account
    visit "/"
    click_link "Log in"
    click_link "Sign up"
    fill_in "Email", with: "test1@example.com"
    fill_in "Password", with: "password"
    fill_in "Password confirmation", with: "password"
    click_button "Sign up"
    save_and_open_page
    expect(page).to have_content("Welcome! You have signed up successfully.")
    expect(page).to have_content("Logged in as test1@example.com")

    ## Log out
    click_link "Log out"
    expect(page).to have_content("Signed out successfully")

    ## Log back in
    click_link "Log in"
    fill_in "Email", with: "test1@example.com"
    fill_in "Password", with: "password"
    click_button "Log in"
    expect(page).to have_content("Signed in successfully.")
    expect(page).to have_content("Logged in as test1@example.com")

    ## Set first name and last name
    visit edit_user_registration_path
    within '#edit_user' do
      fill_in 'First name', with: 'John'
      fill_in 'Last name', with: 'Doe'
      fill_in 'Current password', with: 'password'
      click_button 'Update'
    end
    expect(page).to have_content("Your account has been updated successfully.")
    
    ## Create a Workgroup
    visit "/workgroups"
    click_link "New Workgroup"
    expect(page).to have_content("New Workgroup")
    fill_in "Title", with: "end to end workgroup"
    fill_in "Description", with: "workgroup created by the end to end spec"
    click_button "Create Workgroup"
    expect(page).to have_content("Workgroup was successfully created.")

    ## Edit Workgroup
    click_link "Edit"
    expect(page).to have_content("Editing Workgroup")
    fill_in "Title", with: "end to end workgroup edited"
    fill_in "Description", with: "workgroup edited by the end to end spec"
    click_button "Update Workgroup"
    expect(page).to have_content("Workgroup was successfully updated.")
  end
end
