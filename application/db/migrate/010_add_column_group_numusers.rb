class AddColumnGroupNumusers < ActiveRecord::Migration
  def self.up
      add_column :groups, :numusers, :integer, :null => false, :default => 0
    end

    def self.down
      remove_column :groups, :numusers
  end
end
