class CreateStatementItems < ActiveRecord::Migration[7.1]
  def change
    create_table :statement_items do |t|
      t.references :statement, null: false, foreign_key: true
      t.string :item_type
      t.string :name
      t.decimal :amount, precision: 10, scale: 2

      t.timestamps
    end
  end
end
