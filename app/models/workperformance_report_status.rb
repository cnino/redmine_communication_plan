class WorkperformanceReportStatus < ActiveRecord::Base
  unloadable

  has_many :workperformance_reports
  belongs_to :issue_status
end
