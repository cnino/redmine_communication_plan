class CreateStandardMacroActivities < ActiveRecord::Migration
  def change
    create_table :standard_macro_activities do |t|
      t.integer :order
      t.string :title
    end

  end
end
