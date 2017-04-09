class AddColumnUserIdToCommunicationPlan < ActiveRecord::Migration
  def change
    add_column :communication_plans, :user_id, :integer
  end
end
