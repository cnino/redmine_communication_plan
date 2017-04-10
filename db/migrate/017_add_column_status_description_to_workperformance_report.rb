class AddColumnStatusDescriptionToWorkperformanceReport < ActiveRecord::Migration
  def change
    add_column :workperformance_reports, :status_description, :string
  end
end
