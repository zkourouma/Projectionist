# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end

def sign_up(email)
  visit "/user/sign_up"
  fill_in "Email", with: email
  fill_in "Password", with: 'password'
  click_button 'Sign Up'
end

def sign_up_as_charles
  sign_up("charles@google.com")
end

def sign_in(email='charles@google.com', password='password')
  visit "/user/sign_in"
  fill_in "Email", with: email
  fill_in "Password", with: password
  click_button 'Sign In'
end

def make_company(name="Google", hq="New York, NY")
  sign_up_as_charles
  visit "/user/company/new"
  fill_in "Name", with: name
  fill_in "Headquarters", with: hq
  fill_in "# of Employees", with: 39
  select 'Software', from: "Industries"
  click_button ''
end

def set_income_statement(company)
  
end

def set_balance_sheet(company)
  
end

def set_cash_flow(company)
  
end