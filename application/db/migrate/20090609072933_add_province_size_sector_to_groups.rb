class AddProvinceSizeSectorToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :province, :string
    add_column :groups, :size, :string
    add_column :groups, :sector, :string
  end

  def self.down
    remove_column :groups, :province
    remove_column :groups, :size
    remove_column :groups, :sector
  end
end
