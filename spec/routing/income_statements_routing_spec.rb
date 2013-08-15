require "spec_helper"

describe IncomeStatementsController do
  describe "routing" do

    it "routes to #index" do
      get("/income_statements").should route_to("income_statements#index")
    end

    it "routes to #new" do
      get("/income_statements/new").should route_to("income_statements#new")
    end

    it "routes to #show" do
      get("/income_statements/1").should route_to("income_statements#show", :id => "1")
    end

    it "routes to #edit" do
      get("/income_statements/1/edit").should route_to("income_statements#edit", :id => "1")
    end

    it "routes to #create" do
      post("/income_statements").should route_to("income_statements#create")
    end

    it "routes to #update" do
      put("/income_statements/1").should route_to("income_statements#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/income_statements/1").should route_to("income_statements#destroy", :id => "1")
    end

  end
end
