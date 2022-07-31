class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.integer :from_account_id, null: false
      t.integer :to_account_id, null: false
      t.integer :status, null: false, default: 0
      t.monetize :amount

      t.timestamps
    end

    add_index :transactions, :from_account_id
    add_index :transactions, :to_account_id
  end
end
