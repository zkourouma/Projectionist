require 'spec_helper'

describe "balance_sheets/new" do
  before(:each) do
    assign(:balance_sheet, stub_model(BalanceSheet).as_new_record)
  end

  it "renders new balance_sheet form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", balance_sheets_path, "post" do
    end
  end
end
