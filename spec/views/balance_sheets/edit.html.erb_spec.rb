require 'spec_helper'

describe "balance_sheets/edit" do
  before(:each) do
    @balance_sheet = assign(:balance_sheet, stub_model(BalanceSheet))
  end

  it "renders the edit balance_sheet form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", balance_sheet_path(@balance_sheet), "post" do
    end
  end
end
