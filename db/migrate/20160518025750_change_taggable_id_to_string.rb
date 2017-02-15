class ChangeTaggableIdToString < ActiveRecord::Migration
  def change
		change_column(:taggings, :taggable_id, :string)
  end
end
