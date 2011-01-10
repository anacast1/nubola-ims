class RemoveColumnContractNum < ActiveRecord::Migration
  def self.up
    remove_column :contracts, :num
  end

  def self.down
    add_column :contracts, :num, :string
  end
end
