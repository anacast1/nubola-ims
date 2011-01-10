class AddDemoEndsToGroup < ActiveRecord::Migration
  def self.up
    add_column :groups, :demo_ends, :datetime
  end

  def self.down
    remove_column :groups, :demo_ends
  end
end
