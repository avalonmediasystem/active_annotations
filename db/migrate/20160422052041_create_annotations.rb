class CreateAnnotations < ActiveRecord::Migration[4.2]
  def change
    create_table :annotations do |t|
      t.string :uuid
      t.string :source_uri
      t.text   :annotation
    end
  end
end
