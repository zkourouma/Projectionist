require "spec_helper"

describe CashFlowsController do
  describe "routing" do

    it "routes to #index" do
      get("/cash_flows").should route_to("cash_flows#index")
    end

    it "routes to #new" do
      get("/cash_flows/new").should route_to("cash_flows#new")
    end

    it "routes to #show" do
      get("/cash_flows/1").should route_to("cash_flows#show", :id => "1")
    end

    it "routes to #edit" do
      get("/cash_flows/1/edit").should route_to("cash_flows#edit", :id => "1")
    end

    it "routes to #create" do
      post("/cash_flows").should route_to("cash_flows#create")
    end

    it "routes to #update" do
      put("/cash_flows/1").should route_to("cash_flows#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/cash_flows/1").should route_to("cash_flows#destroy", :id => "1")
    end

  end
end
