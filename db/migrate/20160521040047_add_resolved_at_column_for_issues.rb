class AddResolvedAtColumnForIssues < ActiveRecord::Migration
  def change
		add_column(:issues, :resolved, :boolean, :default => false)
	end
end
