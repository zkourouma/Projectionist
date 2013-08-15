require 'spec_helper'

describe "income_statements/new" do
  before(:each) do
    assign(:income_statement, stub_model(IncomeStatement).as_new_record)
  end

  it "renders new income_statement form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", income_statements_path, "post" do
    end
  end
end
