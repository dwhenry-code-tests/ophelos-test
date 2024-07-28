class CreateStatements < ActiveRecord::Migration[7.1]
  def change
    create_table :statements do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :year
      t.decimal :disposable_income, precision: 10, scale: 2
      t.string :ie_rating

      t.timestamps
    end
  end
end
