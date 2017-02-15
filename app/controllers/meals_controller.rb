class MealsController < ApplicationController
	include SessionHelper
	
	around_filter :catch_not_found
	# Allow un-registered users only the ability to view existing restaurants.
	before_action :authenticate_user!, :except => [:show]
	before_action :is_user_moderator, :only => [:edit, :destroy]
	
	# Create the new meal form.
  def new
		@restaurant = Restaurant.find(params[:restaurant_id])
    @meal = @restaurant.meals.build
		
		# Default empty array for public tag list.
		@public_tag_list = ""
	end
	
	# Actually create the new meal, redirect to the meal page.
	def create
	 	@restaurant = Restaurant.find(params[:restaurant_id])
    @meal = @restaurant.meals.build(meal_params)
		
		# Add the "private" tags, which are the restaurant, meal names, and the meal category.
		@meal.tag_list.add(@restaurant.restaurant_name, @meal.meal_name, @meal.category)
		
     if @meal.save
      flash[:success] = "Meal created!"
      redirect_to restaurant_path(@restaurant)
     else
			flash[:danger] = "Could not create the meal!"
	 	  render "new"
     end
	 end
	
	# Show the meal details.
	def show
		@meal = Meal.find(params[:id])
		@commented_meal_recommendations = @meal.meal_recommendations.where("comments != ''")
		if(current_user)
			@meal_recommendation = @meal.meal_recommendations.where("user_id = ?", current_user.id).first
			@meal_additional = @meal.meal_additionals.where("user_id = ?", current_user.id).first
		end
	end
	
	# Show the edit meal details page.
	def edit
		@meal = Meal.find(params[:id])
		
		# Remove the "private" tags from the input text field. 
		@public_tag_list = (@meal.tag_list - [@meal.meal_name, @meal.restaurant.restaurant_name, @meal.category]).join(",")
		
		if(current_user)
			@meal_recommendation = @meal.meal_recommendations.where("user_id = ?", current_user.id).first
			@meal_additional = @meal.meal_additionals.where("user_id = ?", current_user.id).first
		end
	end
	
	# Update the existing restaurant.
	def update
		@meal = Meal.find(params[:id])
		
		# Add the new "private" tags to the tag list.
		params[:meal][:tag_list] = params[:meal][:tag_list]+","+[@meal.restaurant.restaurant_name, params[:meal][:meal_name], params[:meal][:category], "food"].join(",")
		if @meal.update_attributes(edit_meal_params)
			flash[:success] = "Saved changed to meal!"
			redirect_to edit_restaurant_meal_path(@meal.restaurant.id,params[:id])
		else
			flash[:danger] = "Unable to save changes."
			redirect_to edit_restaurant_meal_path(@meal.restaurant.id,params[:id])
		end
	end
	
	# Delete the restaurant and all meals related to this restaurant.
	def destroy
		Meal.find(params[:id]).destroy
    flash[:success] = "Meal and related information removed."
    redirect_to moderator_path
	end
	
	# Change the status of the meal.
	def change_status
		@meal = Meal.find(params[:id])
		
		if params[:activate]
			active = true
		elsif params[:deactivate]
			active = false
		end
		
		if @meal.update_attributes(active: active)
			flash[:success] = "Meal status has been changed!"
			redirect_to edit_restaurant_meal_path(@meal.restaurant.id,params[:id])
		else
			flash[:danger] = "Unable to save changes."
			redirect_to edit_restaurant_meal_path(@meal.restaurant.id,params[:id])
		end
	end
	
	
	# Action for assessing the meal.
	def assess
		# Remove any pre-existing recommendations from this user for this meal.
		meal = Meal.find(params[:id])
		meal_recommendation = meal.meal_recommendations.where("user_id = ?", current_user.id).first
		if meal_recommendation
			MealRecommendation.delete(meal_recommendation.id)
		end
		
		# Determine if the user recommended or didnt'recommend the meal.
		if params[:recommend]
			rating = true
		elsif params[:dont_recommend]
			rating = false
		end
		
		# Build the new meal recommendation object.
		new_meal_recommendation = meal.meal_recommendations.build(:rating => rating, :meal_id => meal.id, :user_id => current_user.id, :user_agent => request.env['HTTP_USER_AGENT'], :comments => params[:comments])
		
		# Remove any pre-existing meal additional info for this user and meal.
			meal_additional = meal.meal_additionals.where("user_id = ?", current_user.id).first
			if meal_additional
				MealAdditional.delete(meal_additional.id)
			end
		
		# Check to see if the 'cost' or 'portion' radiobutton groups have been selected.
		if params[:cost] || params[:portion]
			# Default values for cost and portion.
			cost = 0.5
			portion = 0.5
			# Get the cost(if it exists)
			if params[:cost]
				cost = params[:cost]
			end
			# Get the portion(if it exists)
			if params[:portion]
				portion = params[:portion]
			end
			
			# Build the new meal additional object.
			new_meal_additional = meal.meal_additionals.build(:cost => cost, :portion => portion, :meal_id => meal.id, :user_id => current_user.id, :user_agent => request.env['HTTP_USER_AGENT'])
			
			# Attempt to save the new meal additional object to the database.
			if new_meal_additional.save
				flash[:success] = "Optional Details added!"
			else
				flash[:failure] = "Optional Details could not be added."
			end
		end
		
		# Attempt to save the meal recommendation object to the database.
		if new_meal_recommendation.save
			flash[:success] = "Meal Recommendation added!"
			redirect_to restaurant_meal_path(params[:restaurant_id],meal.id)
		else
			flash[:failure] = "Meal Recommendation could not be added."
			redirect_to restaurant_meal_path(params[:restaurant_id],meal.id)
		end	
	end
	
	# For sharing recommendations on social media.
	def share
		meal = Meal.find(params[:id])
		restaurant_name = meal.restaurant.restaurant_name
		restaurant_location = meal.restaurant.address
		meal_recommendation = meal.meal_recommendations.where("user_id = ?", current_user.id).first
		
		if meal_recommendation.rating
			recommend_string = "recommends"
		else
			recommend_string = "does not recommend"
		end
			
		
		if params[:share_facebook]
			# Set up the Koala Facebook graph API.
			access_token = Identity.where(" user_id = ? AND provider = ? ", current_user.id, "facebook").first.access_token
			graph = Koala::Facebook::API.new(access_token, ENV["FACEBOOK_SECRET"])
			
			# Content information 
			title = current_user.user_name + " " + recommend_string + " this meal on Mars"
			message = meal.meal_name + " at " + restaurant_name + "(" + restaurant_location + "), " + meal.total_recommendations.to_s + " " + "person".pluralize(meal.total_recommendations) + " recommend" + (meal.total_recommendations == 1 ? "s" : "") + " this meal."
			link = "https://www.mars-score.com/restaurants/" + params[:restaurant_id] + "/meals/" + meal.id
			
			# If the meal image is available, use it, otherwise use the restaurant image. If neither are available, then use the logo image.
			if meal.image_url
				share_image_url = view_context.image_path(meal.image_url)
			elsif meal.restaurant.image_url
				share_image_url = view_context.image_path(meal.restaurant.image_url)
			else
				share_image_url = "https://www.mars-score.com" + view_context.image_path("mars_logo_large.png")
			end
			
			# Attempt to post to the user's wall.
			callback = graph.put_object("me", "feed", {
				:site_name => "Mars",
				:name => title,
				:link => link,
				:description => message,
				:picture => share_image_url
			})
		else
			twitter_identity = Identity.where(" user_id = ? AND provider = ? ", current_user.id, "twitter").first
			access_token = twitter_identity.access_token
			access_secret = twitter_identity.access_secret
			logger.info access_token
			logger.info access_secret
			
			client = Twitter::REST::Client.new do |config|
				config.consumer_key        = ENV["TWITTER_ID"]
				config.consumer_secret     = ENV["TWITTER_SECRET"]
				config.access_token        = access_token
				config.access_token_secret = access_secret
			end
			
			Bitly.use_api_version_3
			bitly = Bitly.new(ENV["BITLY_USERNAME"],ENV["BITLY_KEY"])
			bitly_url = bitly.shorten("https://www.mars-score.com/restaurants/" + params[:restaurant_id] + "/meals/" + meal.id)
			
			begin
				callback = client.update(recommend_string.capitalize +  " " + meal.meal_name + " at " + restaurant_name + "(" + restaurant_location + ") " + bitly_url.short_url)
			rescue Twitter::Error
				callback = false
			end
		end
		
		if callback
			flash[:success] = "Your recommendation has been shared."
			meal_recommendation.shared = true
			meal_recommendation.save!
		else
			flash[:failure] = "We were unable to share your recommendation."
		end
		
		
		redirect_to restaurant_meal_path(params[:restaurant_id],meal.id)
	end
	
	def rate_comment
		if params[:report]
			meal = Meal.find(params[:id])
			
			issue = "Issue with comment " + params[:comment_id] + " for meal " + meal.meal_name + " at " + meal.restaurant.restaurant_name 
			report_issue = current_user.issues.build(:issue => issue)
			if report_issue.save
				flash[:success] = "Your issue has been reported."
			else
				flash[:failure] = "Your issue could not be reported."
			end
		else
			meal_recommendation = MealRecommendation.find(params[:comment_id])
			
			# Remove any previous rating for this comment belonging to you.
			previous_rating = meal_recommendation.comments_responses.where("user_id = ?", current_user.id).first
			if previous_rating
				CommentsResponse.delete(previous_rating.id)
			end
			
			# Was the comment helpful?
			if params[:yes]
				helpful = true
			elsif params[:no]
				helpful = false
			end
			
			# Build the new meal recommendation object.
			new_comments_response = meal_recommendation.comments_responses.build(:helpful => helpful, :meal_recommendation_id => params[:comment_id], :user_id => current_user.id)
			if new_comments_response.save
				flash[:success] = "Your response to the comment has been recorded."
			else
				flash[:failure] = "Your response to the comment was not recorded."
			end
		end
		
		# Update the comments listing.
			@meal = Meal.find(params[:id])
			@commented_meal_recommendations = @meal.meal_recommendations.where("comments != ''")
	end
	
	
	# Parameters for a new meal.
	private
	 def meal_params
		params.require(:meal).permit(:meal_name, :description, :category, :restaurant_id, :image, :tag_list).merge(active: current_user.moderator, user_id: current_user.id)
	end
	
	def edit_meal_params
			if params[:meal].has_key?("image")
				params.require(:meal).permit(:meal_name, :description, :category, :restaurant_id, :image, :tag_list)
			else
				params.require(:meal).permit(:meal_name, :description, :category, :restaurant_id, :tag_list)
			end
		end
		
	# If any of these actions were navigated to without the correct ID information, redirect.
	def catch_not_found
		yield
	rescue ActiveRecord::RecordNotFound
		redirect_to root_url, :flash => { :error => "Record not found." }
	end
end
