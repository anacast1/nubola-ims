class UpdateAppsSetHasUsersDefaultTrue < ActiveRecord::Migration
  def self.up
	change_column :apps, :has_users, :boolean, :default => true
  end

  def self.down
	change_column :apps, :has_users, :boolean, :default => nil
  end
end
