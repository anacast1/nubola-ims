class AddSourceToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :source, :string, :limit => 100, :default => "", :null => false
  end

  def self.down
    remove_column :groups, :source
  end
end
