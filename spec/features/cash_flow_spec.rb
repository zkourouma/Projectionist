require 'launchy'
require 'spec_helper'
include Warden::Test::Helpers
# save_and_open_page

describe CashFlow do
  before(:each) do
    @cashflow = CashFlow.new
    @metric_tree = build_tree
    @yr = Date.today.strftime("%Y").to_i
    @cashflow.stub(:company).and_return(@company = Company.new)
    @company.stub(:income).and_return(@income = IncomeStatement.new)
    @company.stub(:balance).and_return(@balance = BalanceSheet.new)
  end

  describe "Meta Stats" do
# Specs assume that each metric value is 100 (see spec_helper)
    it "has operating cash flow" do

      @cashflow.operating_cash_flow(@metric_tree, 1, @yr).should eq(-300)
    end

    it "has free cash flow" do
      @cashflow.free_cash_flow(@metric_tree, 1, @yr).should eq(-400)
    end

    it "has change in accounts receivable" do
      @cashflow.delta_receivables(@metric_tree, 1, @yr).should eq(100)
    end

    it "has change in inventory" do
      @cashflow.delta_inventory(@metric_tree, 1, @yr).should eq(100)
    end

    it "has change in liabilities" do
      @cashflow.delta_liabilities(@metric_tree, 1, @yr).should eq(300)
    end

    it "has capital expenditure" do
      @cashflow.capex(@metric_tree, 1, @yr).should eq(100)
    end
  end
end
