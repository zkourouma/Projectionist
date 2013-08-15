require 'spec_helper'

describe "IncomeStatements" do
  describe "GET /income_statements" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get income_statements_path
      response.status.should be(200)
    end
  end
end
