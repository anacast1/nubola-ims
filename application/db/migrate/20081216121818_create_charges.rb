class CreateCharges < ActiveRecord::Migration
  def self.up
    create_table :charges do |t|
      t.column :group_id, :integer
      t.column :concept_type, :string, :limit => 20
      t.column :period_from, :date
      t.column :period_to, :date
      # TODO: Ull amb els arrondoniments. Utilitzar clase Money o similar
      t.column :quantity, :decimal, :precision => 10, :scale => 2
      t.column :price, :decimal, :precision => 10, :scale => 2
      t.timestamps
    end
  end

  def self.down
    drop_table :charges
  end
end
