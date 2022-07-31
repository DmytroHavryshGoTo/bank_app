class AddIndexOnAccountNumber < ActiveRecord::Migration[6.0]
  def change
    add_index :accounts, :number
  end
end
