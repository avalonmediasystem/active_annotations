class CreateAnnotations < ActiveRecord::Migration
  def change
    create_table :annotations do |t|
      t.string :uuid
      t.string :source_uri
      t.text   :annotation
    end
  end
end
