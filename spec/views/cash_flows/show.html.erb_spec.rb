require 'spec_helper'

describe "cash_flows/show" do
  before(:each) do
    @cash_flow = assign(:cash_flow, stub_model(CashFlow))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
