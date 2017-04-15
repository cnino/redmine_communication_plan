class TargetAudience < ActiveRecord::Base
  unloadable

  belongs_to :communication_plan
  belongs_to :user

end
