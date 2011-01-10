class CreateConsumParams < ActiveRecord::Migration
  def self.up
    create_table :consum_params do |t|
      t.column :app_id, :integer, :default => 0, :null => false
      t.column :code, :string, :null => false
      t.column :value, :string, :null => false
    end
  end

  def self.down
    drop_table :consum_params
  end
end
