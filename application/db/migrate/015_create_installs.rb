class CreateInstalls < ActiveRecord::Migration
  def self.up
    create_table :installs do |t|
      t.column :app_id,   :integer
      t.column :group_id, :integer
      t.column :host_id, :integer
      t.column :status,   :string

      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
    end

    drop_table :apps_groups
  end

  def self.down
    #TODO: comprovar si hi ha installs que no son a apps_groups
    drop_table :installs
  end
end
