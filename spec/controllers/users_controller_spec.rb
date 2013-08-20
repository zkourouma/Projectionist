require 'launchy'
require 'spec_helper'
include Warden::Test::Helpers
# save_and_open_page

describe RegistrationsController do
  describe "Sign up" do
    it "creates a new user" do
        visit '/user/sign_up'
        fill_in 'user_email', with: 'new_user@email.com'
        fill_in 'user_password', with: 'password'
        fill_in 'user_password_confirmation', with: 'password'
        click_on 'Sign up'
        page.should have_content 'New Company Profile'
    end

    it "redirects back after creating a user" do
      sign_up('test@google.com')
      click_on 'Logout'
      fill_in "user_email", with: "test@google.com"
      fill_in "user_password", with: 'password'
      click_on 'Sign in'
      
      page.should have_content 'New Company Profile'
    end

    it 'creates shell companies' do
      sign_in_charles
      fill_in 'Name', with: 'Nonsense'
      click_on 'Next'
      visit '/'
      page.should have_content 'Nonsense'
    end

    it 'redirects to income statement after creating a company' do
      sign_in_charles
      fill_in 'Name', with: 'Nonsense'
      click_on 'Next'
      page.should have_content 'New Income Statement'
    end

    it 'redirects to balance sheet after creating an income statement' do
      sign_in_charles
      fill_in 'Name', with: 'Nonsense'
      click_on 'Next'
      fill_in 'income[metrics_attributes][0][value]', with: 1
      click_on 'Next'
      page.should have_content 'New Balance Sheet'
    end

    it 'redirects to cash flow after creating a balance sheet' do
      sign_in_charles
      fill_in 'Name', with: 'Nonsense'
      click_on 'Next'
      fill_in 'income[metrics_attributes][0][value]', with: 1
      click_on 'Next'
      fill_in 'balance[metrics_attributes][0][value]', with: 1
      click_on 'Next'
      page.should have_content 'New Cash Flow'
    end

    it 'redirects to company show page on completion' do
      sign_in_charles
      fill_in 'Name', with: 'Nonsense'
      click_on 'Next'
      fill_in 'income[metrics_attributes][0][value]', with: 1
      click_on 'Next'
      fill_in 'balance[metrics_attributes][0][value]', with: 1
      click_on 'Next'
      fill_in 'cashflow[metrics_attributes][0][value]', with: 1
      click_on 'Complete'
      page.should have_content 'Nonsense'
    end

    it "can't access other user's pages" do
      sign_in_charles
      fill_in 'Name', with: 'Nonsense'
      click_on 'Next'
      click_on 'Logout'
      sign_up('test@google.com')
      visit '/'
      page.should_not have_content 'Nonsense'
    end
  end
end
