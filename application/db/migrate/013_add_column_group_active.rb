class AddColumnGroupActive < ActiveRecord::Migration
  def self.up
      add_column :groups, :active, :boolean, :null => false, :default => true
    end

    def self.down
      remove_column :groups, :active
  end
end
