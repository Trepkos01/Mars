require 'rqrcode_png'

class RestaurantsController < ApplicationController
	include SessionHelper
	
	around_filter :catch_not_found

	# Allow un-registered users only the ability to view existing restaurants.
	before_action :authenticate_user!, :except => [:show]
	before_action :is_user_moderator, :only => [:edit, :destroy]
  
	# Define the empty restaurant model on the new form.
	def new
		@restaurant = current_user.restaurants.build
	end
	
	# Attempt to create the new restaurant.
	def create
		@restaurant = current_user.restaurants.build(restaurant_params)
     if @restaurant.save
      flash[:success] = "Restaurant created!"
      redirect_to root_url
     else
		  render "new"
     end
	end
	
	# Show the restaurant details.
	def show
		@restaurant = Restaurant.find(params[:id])
		@meals = @restaurant.meals
		@entree_meals = @restaurant.meals.where("category = ?", "entree").paginate(page: params[:entrees_page], :per_page => 5)
		@appetizer_meals = @restaurant.meals.where("category = ?", "appetizer").paginate(page: params[:appetizers_page], :per_page => 5)
		@soup_meals = @restaurant.meals.where("category = ?", "soup").paginate(page: params[:soups_page], :per_page => 5)
		@salad_meals = @restaurant.meals.where("category = ?", "salad").paginate(page: params[:salads_page], :per_page => 5)
		@drink_meals = @restaurant.meals.where("category = ?", "drink").paginate(page: params[:drinks_page], :per_page => 5)
		@side_meals = @restaurant.meals.where("category = ?", "side").paginate(page: params[:sides_page], :per_page => 5)
		@dessert_meals = @restaurant.meals.where("category = ?", "dessert").paginate(page: params[:dessert_page], :per_page => 5)
		@qr_url = RQRCode::QRCode.new(request.original_url).to_img.resize(120, 120).to_data_url
	end
	
	# Show the edit restaurant page.
	def edit
		@restaurant = Restaurant.find(params[:id])
		@meals = @restaurant.meals
		@entree_meals = @restaurant.meals.where("category = ?", "entree").paginate(page: params[:entrees_page], :per_page => 5)
		@appetizer_meals = @restaurant.meals.where("category = ?", "appetizer").paginate(page: params[:appetizers_page], :per_page => 5)
		@soup_meals = @restaurant.meals.where("category = ?", "soup").paginate(page: params[:soups_page], :per_page => 5)
		@salad_meals = @restaurant.meals.where("category = ?", "salad").paginate(page: params[:salads_page], :per_page => 5)
		@drink_meals = @restaurant.meals.where("category = ?", "drink").paginate(page: params[:drinks_page], :per_page => 5)
		@side_meals = @restaurant.meals.where("category = ?", "side").paginate(page: params[:sides_page], :per_page => 5)
		@dessert_meals = @restaurant.meals.where("category = ?", "dessert").paginate(page: params[:dessert_page], :per_page => 5)
	end
	
	# Update the existing restaurant.
	def update
		@restaurant = Restaurant.find(params[:id])
		if @restaurant.update_attributes(edit_restaurant_params)
			flash[:success] = "Saved changed to restaurant!"
			redirect_to edit_restaurant_path(params[:id])
		else
			flash[:danger] = "Unable to save changes."
			redirect_to edit_restaurant_path(params[:id])
		end
	end
	
	# Delete the restaurant and all meals related to this restaurant.
	def destroy
		Restaurant.find(params[:id]).destroy
    flash[:success] = "Restaurant and related meals removed."
    redirect_to moderator_path
	end
	
	# Change the status of the restaurant.
	def change_status
		@restaurant = Restaurant.find(params[:id])
		
		if params[:activate]
			active = true
		elsif params[:deactivate]
			active = false
		end
		
		if @restaurant.update_attributes(active: active)
			flash[:success] = "Restaurant status has been changed!"
			redirect_to edit_restaurant_path(params[:id])
		else
			flash[:danger] = "Unable to save changes."
			redirect_to edit_restaurant_path(params[:id])
		end
	end
	
	# Validate the form data and also add the current user's moderator value to determine if the restaurant should be
	# active or inactive unpon creation.
	private
		def restaurant_params
			params.require(:restaurant).permit(:restaurant_name, :address, :user_id, :image).merge(active: current_user.moderator)
		end
		
		def edit_restaurant_params
			if params[:restaurant].has_key?("image")
				params.require(:restaurant).permit(:restaurant_name, :address, :image)
			else
				params.require(:restaurant).permit(:restaurant_name, :address)
			end
		end
		
		def catch_not_found
			yield
		rescue ActiveRecord::RecordNotFound
			redirect_to root_url, :flash => { :error => "Record not found." }
		end
end
