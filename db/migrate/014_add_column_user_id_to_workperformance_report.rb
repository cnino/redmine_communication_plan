class AddColumnUserIdToWorkperformanceReport < ActiveRecord::Migration
  def change
    add_column :workperformance_reports, :user_id, :integer
  end
end
