require 'spec_helper'

describe "balance_sheets/show" do
  before(:each) do
    @balance_sheet = assign(:balance_sheet, stub_model(BalanceSheet))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
