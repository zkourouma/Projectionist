require 'spec_helper'

describe "cash_flows/index" do
  before(:each) do
    assign(:cash_flows, [
      stub_model(CashFlow),
      stub_model(CashFlow)
    ])
  end

  it "renders a list of cash_flows" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
