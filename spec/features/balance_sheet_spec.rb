require 'launchy'
require 'spec_helper'
include Warden::Test::Helpers
# save_and_open_page

describe BalanceSheet do
  before(:each) do
    @balance = BalanceSheet.new
    @metric_tree = build_tree
    @yr = Date.today.strftime("%Y").to_i
  end

  describe "Meta Stats" do
# Specs assume that each metric value is 100 (see spec_helper)
    it "has debt to equity" do
      @balance.debt_to_equity(@metric_tree, 1, @yr).should eq(200.0/30000.0)
    end

    it "has cash per share" do
      @balance.cash_per_share(@metric_tree, 1, @yr).should eq(100.0/300.0)
    end

    it "has current ratio" do
      @balance.current_ratio(@metric_tree, 1, @yr).should eq(1.5)
    end

    it "has book value" do
      @balance.book_value(@metric_tree, 1, @yr).should eq(100)
    end

    it "has capital expenditure" do
      @balance.capex(@metric_tree, 1, @yr).should eq(100)
    end

    it "has working capital" do
      @balance.working_capital(@metric_tree, 1, @yr).should eq(100)
    end
  end
end
