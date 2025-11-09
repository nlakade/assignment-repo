class CreatePhoneCalls < ActiveRecord::Migration[7.0]
  def change
    create_table :phone_calls do |t|
      t.string :phone_number, null: false
      t.string :status, default: 'pending'
      t.integer :attempts, default: 0
      t.integer :duration
      t.datetime :called_at
      t.datetime :completed_at
      
      t.timestamps
    end
  end
end