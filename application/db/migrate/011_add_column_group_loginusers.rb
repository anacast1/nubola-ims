class AddColumnGroupLoginusers < ActiveRecord::Migration
  def self.up
      add_column :groups, :loginusers, :integer, :null => false, :default => 0
    end

    def self.down
      remove_column :groups, :loginusers
  end
end
