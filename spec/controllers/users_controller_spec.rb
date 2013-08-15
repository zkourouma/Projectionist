require 'spec_helper'

describe RegistrationsController do

  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to User, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { email: 'test@google.com', password: 'password' } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "Sign up" do
    xit "creates a new user" do
        visit "/user/sign_up"
        fill_in "Email", with: "new_user@email.com"
        fill_in "Password", with: 'password'
        click 'Sign Up'
        page.should have_content 'New Company'
    end

    xit "redirects back after creating a user" do
      sign_up("test@google.com")
      click 'Logout'
      sign_in("test@google.com")
      page.should have_content 'New Company'
    end
  end
end
