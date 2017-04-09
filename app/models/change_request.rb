class ChangeRequest < ActiveRecord::Base
  unloadable

  belongs_to :workperformance_report
  
end
