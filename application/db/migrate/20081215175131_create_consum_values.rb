class CreateConsumValues < ActiveRecord::Migration
  def self.up
    create_table :consum_values do |t|
      t.integer :consum_param_id
      t.integer :contract_id
      t.boolean :limit, :default => true
      t.integer :maxconsumitem

      t.timestamps
    end
  end

  def self.down
    drop_table :consum_values
  end
end
