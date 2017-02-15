class CreateIssueTable < ActiveRecord::Migration
  def change
    create_table :issues do |t|
			
			t.text :issue,				null: false
			t.belongs_to :user,		index: true
			
			t.timestamps null: false
    end
  end
end
