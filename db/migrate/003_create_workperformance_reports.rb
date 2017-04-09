class CreateWorkperformanceReports < ActiveRecord::Migration
  def change
    create_table :workperformance_reports do |t|
      t.datetime :start_period
      t.datetime :end_period
      t.text :overall_objective
      t.text :next_steps
      t.text :risks
      t.datetime :send_date
      t.integer :communication_plan_id
      t.integer :flag_id
      t.integer :workperformance_report_status_id
    end

  end
end
