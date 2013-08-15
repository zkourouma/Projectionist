require 'spec_helper'

describe "income_statements/index" do
  before(:each) do
    assign(:income_statements, [
      stub_model(IncomeStatement),
      stub_model(IncomeStatement)
    ])
  end

  it "renders a list of income_statements" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
