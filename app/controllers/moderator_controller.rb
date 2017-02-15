class ModeratorController < ApplicationController
	include SessionHelper
	
	before_action :authenticate_user!, :is_user_moderator
	def index
		@inactive_restaurants = Restaurant.where("active = ? ", false).paginate(page: params[:restaurants_page], :per_page => 10)
		@inactive_meals = Meal.where("active = ?", false).paginate(page: params[:meals_page], :per_page => 10)
		@search = params[:search]
		@restaurants = Restaurant.search(params[:search]).paginate(page: params[:search_restaurants_page], :per_page => 5)
		@meals = Meal.search(params[:search]).paginate(page: params[:search_meals_page], :per_page => 5)
		@issues = Issue.where("resolved = ?", false)
	end
end