class AddColumnSentTargetAudienceToWorkperformanceReport < ActiveRecord::Migration
  def change
    add_column :workperformance_reports, :sent_target_audience, :string
  end
end
