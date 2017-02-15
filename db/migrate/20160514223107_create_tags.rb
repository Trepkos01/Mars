## The tag table stores the single word tag information.
class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
			## The tag information.
			t.string :tag,	null: false

			t.timestamps 	null: false
    end
  end
end
