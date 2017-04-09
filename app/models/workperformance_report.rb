class WorkperformanceReport < ActiveRecord::Base
  unloadable

  belongs_to :communication_plan
  has_many :change_requests
  has_many :schedule_activities
  belongs_to :flag
  has_one :workperformance_report_status
  belongs_to :user
  
end
