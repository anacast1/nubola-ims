class ModifyHostTypePriceToFloat < ActiveRecord::Migration
  def self.up
    change_column :host_types, :price, :decimal, :precision => 10, :scale => 2
  end

  def self.down
    change_column :host_types, :price, :integer
  end
end
