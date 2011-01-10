class RemoveUsersNotesAndGroupActive < ActiveRecord::Migration
  def self.up
    remove_column :users, :notes
    remove_column :groups, :active
  end

  def self.down
    add_column :users, :notes, :text
    add_column :groups, :active, :boolean, :null => false, :default => true
  end
end
