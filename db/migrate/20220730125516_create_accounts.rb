class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.string :currency
      t.references :user, null: false, foreign_key: true
      t.string :number, null: false
      t.monetize :balance

      t.timestamps
    end
  end
end
