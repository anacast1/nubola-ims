class CreateBinds < ActiveRecord::Migration
  def self.up
    create_table :binds do |t|
      t.column :app_id,   :integer
      t.column :user_id, :integer
      t.column :status,   :string

      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
    end

    drop_table :apps_users
  end

  def self.down
    drop_table :binds
  end
end
