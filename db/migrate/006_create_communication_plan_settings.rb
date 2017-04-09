class CreateCommunicationPlanSettings < ActiveRecord::Migration
  def change
    create_table :communication_plan_settings do |t|
      t.string :parameter
      t.string :value
    end

  end
end
