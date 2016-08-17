require "rails_helper"

RSpec.describe WorkgroupsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/workgroups").to route_to("workgroups#index")
    end

    it "routes to #new" do
      expect(:get => "/workgroups/new").to route_to("workgroups#new")
    end

    it "routes to #show" do
      expect(:get => "/workgroups/1").to route_to("workgroups#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/workgroups/1/edit").to route_to("workgroups#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/workgroups").to route_to("workgroups#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/workgroups/1").to route_to("workgroups#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/workgroups/1").to route_to("workgroups#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/workgroups/1").to route_to("workgroups#destroy", :id => "1")
    end

  end
end
