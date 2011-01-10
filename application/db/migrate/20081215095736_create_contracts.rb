class CreateContracts < ActiveRecord::Migration
  def self.up
    create_table :contracts do |t|
      t.string :code, :limit => 100, :default => "", :null => false # xml id
      t.string :name
      t.integer :group_id
      t.string :num
      t.date   :date
      t.string :contract_type
      t.string :contact_name
      t.string :department
      t.string :mail
      t.string :telf
      t.integer :concurrentusers
      t.boolean :concurrentuserslimit
      t.timestamp :created_at
      t.timestamp :updated_at
      t.integer :state, :default => 0
      t.string :co_street
      t.string :co_cp
      t.string :co_town
      t.string :co_province
      t.string :co_country
      t.string :co_nif

      t.timestamps
    end

    add_column :groups, :contract_id, :integer
  end

  def self.down
    drop_table :contracts
    remove_column :groups, :contract_id
  end
end
