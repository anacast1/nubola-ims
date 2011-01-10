class RemoveColumnAppManyInstances < ActiveRecord::Migration
  def self.up
    remove_column :apps, :many_instances
  end

  def self.down
	add_column :apps, :many_instances, :boolean, :default => false, :null => false
  end
end
