class DestroyGroupDates < ActiveRecord::Migration
  def self.up
    drop_table :group_dates
  end

  def self.down
    create_table :group_dates do |t|
      t.column :group_id, :string, :null => false
      t.column :app_id, :string, :null => false
      t.column :created_on, :datetime, :null => false
      t.column :active, :boolean, :null => false, :default => true
    end
  end
end
