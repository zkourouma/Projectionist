class Metric < ActiveRecord::Base
  attr_accessible :name, :period, :value
end
