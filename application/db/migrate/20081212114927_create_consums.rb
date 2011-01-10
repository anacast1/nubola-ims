class CreateConsums < ActiveRecord::Migration
  # Consum inherits from Registre
  def self.up
    add_column :registres, :type,   :string
    add_column :registres, :amount, :integer
  end

  def self.down
    remove_column :registres, :type
    remove_column :registres, :amount
  end
end
