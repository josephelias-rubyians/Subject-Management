class CreateSubAndClasses < ActiveRecord::Migration[6.1]
  def change
    create_table :sub_and_classes do |t|
      t.references :subject, null: false, foreign_key: true
      t.references :teaching_class, null: false, foreign_key: true

      t.timestamps
    end
  end
end
