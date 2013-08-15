require 'spec_helper'

describe "cash_flows/new" do
  before(:each) do
    assign(:cash_flow, stub_model(CashFlow).as_new_record)
  end

  it "renders new cash_flow form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", cash_flows_path, "post" do
    end
  end
end
