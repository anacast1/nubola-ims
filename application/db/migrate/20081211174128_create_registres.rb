class CreateRegistres < ActiveRecord::Migration
  def self.up
    create_table :registres do |t|
      t.integer  "user_id"
      t.integer  "group_id"
      t.integer  "app_id"
      t.string   "action"
      t.text     "text"
      t.timestamps
    end
  end

  def self.down
    drop_table :registres
  end
end
