class ChangeUserColumnInCommentsResponses < ActiveRecord::Migration
  def change
		change_column(:comments_responses, :user_id, :string)
  end
end
