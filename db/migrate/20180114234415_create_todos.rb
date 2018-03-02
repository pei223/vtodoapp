class CreateTodos < ActiveRecord::Migration[5.1]
  def change
    create_table :todos do |t|
      t.string :title
      t.text :todo
      t.datetime :deadline
      t.boolean :finish

      t.timestamps
    end
  end
end
