class AddColumnUserIdToTargetAudience < ActiveRecord::Migration
  def change
    add_column :target_audiences, :user_id, :integer
  end
end
