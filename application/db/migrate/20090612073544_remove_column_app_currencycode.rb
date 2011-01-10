class RemoveColumnAppCurrencycode < ActiveRecord::Migration
  def self.up
    remove_column :apps, :currencycode
  end

  def self.down
    add_column :apps, :currencycode, :string
  end
end
