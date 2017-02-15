class ChangeMealDescriptionToText < ActiveRecord::Migration
  def change
		change_column(:meals, :description, :text)
  end
end
