require 'spec_helper'

describe "income_statements/edit" do
  before(:each) do
    @income_statement = assign(:income_statement, stub_model(IncomeStatement))
  end

  it "renders the edit income_statement form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", income_statement_path(@income_statement), "post" do
    end
  end
end
