class MainController < ApplicationController
  # Landing page initial action.
	def index
		@current_restaurant_count = Restaurant.all.size
		@current_meal_count = Meal.all.size
		
		locations = ActiveRecord::Base.connection.execute("SELECT DISTINCT substring(address from '[A-Za-z\s]+,\s[A-Z]{2}') AS location FROM restaurants WHERE random() < 0.01 LIMIT 10")
		locations_result = locations.values
		@locations_string = locations_result.map{|l| l[0].tr(',','') }.join(",")
		
		results = ActiveRecord::Base.connection.execute("SELECT COUNT(DISTINCT substring(address from '[A-Za-z\s]+,\s[A-Z]{2}')) AS num_cities FROM restaurants")
		@cities_count = results[0]['num_cities']
		
		results = ActiveRecord::Base.connection.execute("SELECT COUNT(DISTINCT substring(address from ',\s[A-Z]{2}')) AS num_states FROM restaurants")
		@states_count = results[0]['num_states']
		
  end
	
	# The search action.
	def search
	
		# Get the keyword string.
		# Set the defaults whose values will be determined later.
		keyword_string = params[:search]
		preposition_location = nil
		remove_token_count = 1
		use_current_location = false
		no_location_available = false
		
		# Check for first occurence of prepositions - "near", "close to", "in", "at"
		# If the first preoposition is "close to", we shift the location array two elements
		# To remove the prepositional phrase, otherwise we shift only once.
		if keyword_string.index(" near ")
			preposition_location = keyword_string.index(" near ")
		elsif keyword_string.index(" close to ")
			preposition_location = keyword_string.index(" close to ")
			remove_token_count = 2
		elsif keyword_string.index(" in ")
			preposition_location = keyword_string.index(" in ")
		elsif keyword_string.index(" at ")
			preposition_location = keyword_string.index(" at ")
		end
		
		# If a preposition is found, get the location information supplied after the preposition
		# while removing the actual prepositional phrase. Next, re-form the keyword array to exclude
		# the preposition and location information. Also check if the "location" info is actually "me"
		# which commonly means current location.
		#
		# If no preposition is supplied, check to see if the current location lat/lng details are available,
		# if they are. Then use the current location, if not, then we have no location information to go by.
		if preposition_location
			location_array = keyword_string[preposition_location..-1].split(" ")
			location_array.shift(remove_token_count)
			location_substr = location_array.join(" ")
			keyword_array = keyword_string[0..preposition_location].split
			if location_substr == "me"
				if !params[:lat].blank? && !params[:lon].blank?
					use_current_location = true
				else
					no_location_available = true
				end
			else
				@location = location_substr
				use_current_location = false
			end
		else
			if !params[:lat].blank? && !params[:lon].blank?
				keyword_array = keyword_string.split
				use_current_location = true
			else
				no_location_available = true
			end
		end
		
		# We have determined which location-based search approach that we're taking.
		# Either we have locaton information available or we are using the current location
		# information available from the browser(obtained by Javascript and stored in the template)
		# If we're not using the current location and yet we do have location information, try to
		# geocode this location information, if successful, proceed with the search, otherwise inform
		# the user that the information could not be geocode'd.
		if no_location_available
			@message = "We could not find your current location. Please provide one in your search."
			@meals = Meal.none
			@restaurants = Restaurant.none
		elsif use_current_location
			@message = "Showing results near current location."
			coordinate_array = Array.new
			coordinate_array.push(params[:lat])
			coordinate_array.push(params[:lon])
			@meals = Meal.main_search(keyword_array, coordinate_array).paginate(page: params[:search_meals_page], :per_page => 10)
			@restaurants = Restaurant.main_search(keyword_array, coordinate_array).paginate(page: params[:search_restaurants_page], :per_page => 10)
		else
			geocode_failure = Geokit::Geocoders::MultiGeocoder.geocode(location_substr).full_address.blank?
			if geocode_failure
				@message = "Could not process the location #{location_substr}"
				@meals = Meal.none
				@restaurants = Restaurant.none
			else
				@message = "Showing results near #{location_substr}."
				@meals = Meal.main_search(keyword_array, location_substr).paginate(page: params[:search_meals_page], :per_page => 10)
				@restaurants = Restaurant.main_search(keyword_array, location_substr).paginate(page: params[:search_restaurants_page], :per_page => 10)
			end
		end
	end
end
