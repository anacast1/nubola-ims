class CreateRelationships < ActiveRecord::Migration
  def self.up
    create_table :relationships, :id => false do |t|
      t.column :dependencia_id, :integer
      t.column :dependiente_id, :integer
    end
  end

  def self.down
    drop_table :relationships
  end
end
