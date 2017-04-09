class AddColumnProjectIdToCommunicationPlan < ActiveRecord::Migration
  def change
    add_column :communication_plans, :project_id, :integer
  end
end
