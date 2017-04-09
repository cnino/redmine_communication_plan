class CreateTargetAudiences < ActiveRecord::Migration
  def change
    create_table :target_audiences do |t|
      t.boolean :external_user
      t.string :user_email
      t.string :user_name
      t.integer :communication_plan_id
    end

  end
end
