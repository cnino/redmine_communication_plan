class CreateChangeRequests < ActiveRecord::Migration
  def change
    create_table :change_requests do |t|
      t.string :requester
      t.text :description
      t.string :opening_date
      t.string :situation
      t.integer :workperformance_report_id
    end

  end
end
