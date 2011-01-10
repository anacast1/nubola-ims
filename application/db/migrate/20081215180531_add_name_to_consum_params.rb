class AddNameToConsumParams < ActiveRecord::Migration
  def self.up
    add_column :consum_params, :name, :string
  end

  def self.down
    remove_column :consum_params, :name
  end
end
