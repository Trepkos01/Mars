class IssuesController < ApplicationController
	include SessionHelper
	before_action :authenticate_user!
	before_action :is_user_moderator, :only => [:edit, :destroy]
	
	def new
		@issue = current_user.issues.new
	end
	
	def create
		@issue = current_user.issues.build(params.require(:issue).permit(:issue))
		if @issue.save
			flash[:success] = "Thanks!"
			redirect_to root_url
		else
			flash[:failure] = "We had an issue reporting your issue!"
			render "new"
		end
	end
	
	def show
		@issue = Issue.find(params[:id])
	end
	
	def resolve
		if @issue = Issue.find(params[:id]).update_attributes(:resolved => true)
			flash[:success] = "Issue marked as resolved!"
			redirect_to moderator_path
		else
			flash[:danger] = "Unable to save changes."
			render "show"
		end
	end
end