require "spec_helper"

describe BalanceSheetsController do
  describe "routing" do

    it "routes to #index" do
      get("/balance_sheets").should route_to("balance_sheets#index")
    end

    it "routes to #new" do
      get("/balance_sheets/new").should route_to("balance_sheets#new")
    end

    it "routes to #show" do
      get("/balance_sheets/1").should route_to("balance_sheets#show", :id => "1")
    end

    it "routes to #edit" do
      get("/balance_sheets/1/edit").should route_to("balance_sheets#edit", :id => "1")
    end

    it "routes to #create" do
      post("/balance_sheets").should route_to("balance_sheets#create")
    end

    it "routes to #update" do
      put("/balance_sheets/1").should route_to("balance_sheets#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/balance_sheets/1").should route_to("balance_sheets#destroy", :id => "1")
    end

  end
end
