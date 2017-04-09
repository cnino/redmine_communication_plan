class CreateWorkperformanceReportStatuses < ActiveRecord::Migration
  def change
    create_table :workperformance_report_statuses do |t|
        t.integer :tracker_id
    end

  end
end
