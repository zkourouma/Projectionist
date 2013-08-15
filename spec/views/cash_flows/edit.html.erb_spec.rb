require 'spec_helper'

describe "cash_flows/edit" do
  before(:each) do
    @cash_flow = assign(:cash_flow, stub_model(CashFlow))
  end

  it "renders the edit cash_flow form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", cash_flow_path(@cash_flow), "post" do
    end
  end
end
