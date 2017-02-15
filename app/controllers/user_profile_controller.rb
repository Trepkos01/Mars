class UserProfileController < ApplicationController
	def index
		@restaurants = current_user.restaurants.paginate(page: params[:restaurants_page], :per_page => 10)
		@meals = current_user.meals.paginate(page: params[:meals_page], :per_page => 10)
	end
end
