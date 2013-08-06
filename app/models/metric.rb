class Metric < ActiveRecord::Base
  attr_accessible :name, :quarter, :year, :value, :statementable_id, :statementable_type

  belongs_to :statementable, polymorphic: true
end
