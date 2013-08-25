require 'launchy'
require 'spec_helper'
include Warden::Test::Helpers
# save_and_open_page

describe IncomeStatement do
  before(:each) do
    @income = IncomeStatement.new
    @metric_tree = build_tree
    @yr = Date.today.strftime("%Y").to_i
  end

  describe "Meta Stats" do
# Specs assume that each metric value is 100 (see spec_helper)
    it "has gross profit" do
      @income.gross_profit(@metric_tree, 1, @yr).should eq(0)
    end

    it "has operating profit" do
      @income.operating_profit(@metric_tree, 1, @yr).should eq(-400)
    end

    it "has ebitda" do
      @income.ebitda(@metric_tree, 1, @yr).should eq(-200)
    end

    it "has net income" do
      @income.net_income(@metric_tree, 1, @yr).should eq(-600)
    end

    it "has eps" do
      @income.eps(@metric_tree, 1, @yr).should eq(-2)
    end

    it "has operating expenses" do
      @income.opex(@metric_tree, 1, @yr).should eq(200)
    end

    it "has gross margin" do
      @income.gross_margin(@metric_tree, 1, @yr).should eq(0)
    end

    it "has operating margin" do
      @income.operating_margin(@metric_tree, 1, @yr).should eq(-4)
    end

    it "has ebitda margin" do
      @income.ebitda_margin(@metric_tree, 1, @yr).should eq(-2)
    end
  end
end
