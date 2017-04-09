class TargetAudience < ActiveRecord::Base
  unloadable

  belongs_to :communication_plan
  has_one :user
  
end
