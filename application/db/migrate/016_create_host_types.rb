class CreateHostTypes < ActiveRecord::Migration
  def self.up
    create_table :host_types do |t|

      t.column :name, :string
      t.column :cpu, :string
      t.column :ram, :string
      t.column :disk, :string
      t.column :price, :string

      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :host_types
  rescue
    drop_table :vhost_types
  end
end
