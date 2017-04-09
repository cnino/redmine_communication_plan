class WorkperformanceReportStatus < ActiveRecord::Base
  unloadable

  has_many :workperformance_reports
  has_one :issue_status
end
