require 'spec_helper'

describe "income_statements/show" do
  before(:each) do
    @income_statement = assign(:income_statement, stub_model(IncomeStatement))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
