class FixActivityColumnName < ActiveRecord::Migration
  rename_column :schedule_activities, :activity, :title
end
