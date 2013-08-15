require 'spec_helper'

describe "balance_sheets/index" do
  before(:each) do
    assign(:balance_sheets, [
      stub_model(BalanceSheet),
      stub_model(BalanceSheet)
    ])
  end

  it "renders a list of balance_sheets" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
