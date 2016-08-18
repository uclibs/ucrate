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

    ## Create a Workgroup
    visit "/workgroups"
    click_link "New Workgroup"
    expect(page).to have_content("New Workgroup")
    click_button "Create Workgroup"
    expect(page).to have_content("Workgroup was successfully created.")

    ## Edit Workgroup
    click_link "Edit"
    expect(page).to have_content("Editing Workgroup")
    click_button "Update Workgroup"
    expect(page).to have_content("Workgroup was successfully updated.")
  end
end
