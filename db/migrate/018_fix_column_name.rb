class FixColumnName < ActiveRecord::Migration
  rename_column :workperformance_reports, :workperformance_report_status_id, :issue_status_id
end
