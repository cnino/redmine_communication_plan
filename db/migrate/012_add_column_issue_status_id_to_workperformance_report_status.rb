class AddColumnIssueStatusIdToWorkperformanceReportStatus < ActiveRecord::Migration
  def change
      add_column :workperformance_report_statuses, :issue_status_id, :integer
  end
end
