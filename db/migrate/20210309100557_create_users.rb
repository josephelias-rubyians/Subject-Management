class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, default: ""
      t.string :password
      t.boolean :admin

      t.timestamps
    end
  end
end
