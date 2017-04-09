class CreateScheduleActivities < ActiveRecord::Migration
  def change
    create_table :schedule_activities do |t|
      t.integer :order
      t.string :activity
      t.string :planned
      t.string :accomplished
      t.integer :workperformance_report_id
    end

  end
end
