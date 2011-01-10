class AddHasUsersColumnToAppTable < ActiveRecord::Migration
  def self.up
    add_column :apps, :has_users, :boolean
  end

  def self.down
    remove_column :apps, :has_users
  end
end
