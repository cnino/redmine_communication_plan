class CreateCommunicationPlans < ActiveRecord::Migration
  def change
    create_table :communication_plans do |t|
      t.boolean :active, :default => true
      t.integer :periodicity
      t.datetime :start_date
      t.boolean :automatic_creation, :default => true
    end

  end
end
