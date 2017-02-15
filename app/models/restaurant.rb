# == Schema Information
#
# Table name: restaurants
#
#  id                     :string         	not null, primary key
#  restaurant_name        :string						not null, default("")
#  address                :string           not null, default("")
#  lat							      :float            not null, default(0)
#  lng								    :float						not null, default(0)
#  active							    :boolean					not null, default(0)
#  timestamp		          :timestamp
#	 user_id								References the users table.
#	 image
#
# Has many meals, created by one user.

class Restaurant < ActiveRecord::Base
	self.primary_key = 'id'
	
	# For geolocational capabilities, validate the address before proceeding.
	acts_as_mappable :auto_geocode=>{:field=>:address, :error_message=>'This is not a valid address.'}

	# Define the relationships to other models.
	before_create :generate_id
	belongs_to :user
	has_many :meals, :dependent => :destroy
	before_validation :geocode_address, :on => [:create, :update]
	
	# Validate the model properties.
	validates :user_id, presence: true
  validates :restaurant_name, presence: true, length: { maximum: 120 }
	validates :address, presence: true
	
	# For image uploading capabilities.
	mount_uploader :image, ImageUploader
	validates_processing_of :image
	validate :image_size_validation
	
	def self.search(search)
		if search
			where('restaurant_name ILIKE ?', "%#{search}%")
		else
			none
		end
	end
	
	def self.main_search(keywords, location)
		if keywords.size == 1 && keywords[0].downcase["restaurant"]
			restaurants = Restaurant.within(50, :origin => location).where(["restaurants.active = ?", true])
			restaurants.sort do |a,b|
				case
				when a.restaurant_composite_score < b.restaurant_composite_score
					-1
				when a.restaurant_composite_score > b.restaurant_composite_score
					1
				else
					0
				end
			end
			return restaurants
		elsif keywords.size > 0
			# Create the condition array to be used for the WHERE clause.
			condition_array = Array.new
			condition_array.push((['restaurant_name ILIKE ?'] * keywords.size).join(' OR '))
			keywords.each {|keyword| condition_array.push("%#{keyword}%")}
			
			restaurants = Restaurant.within(50, :origin => location)
			.where(condition_array)
			.where(["restaurants.active = ?", true])
			
			restaurants.sort do |a,b|
				case
				when a.restaurant_composite_score < b.restaurant_composite_score
					-1
				when a.restaurant_composite_score > b.restaurant_composite_score
					1
				else
					0
				end
			end
			
			return restaurants
		else
			none
		end
	end
	
	def restaurant_composite_score
		total_rated_meal_scores = 0
		restaurant_rated_meals.each do |m|
				total_rated_meal_scores += m.meal_score
		end
		
		if restaurant_rated_meals.size > 0
			return (total_rated_meal_scores.to_f/restaurant_rated_meals.size.to_f).to_i
		else
			return 0
		end
	end
	
	def restaurant_rated_meals
		rated_meals = Array.new
		meals.each do |m|
			if m.meal_recommendations.size > 0
				rated_meals.push(m)
			end
		end
		return rated_meals
	end
	
	private
		def image_size_validation
			errors[:image] << "should be less than 5MB" if image.size > 5.0.megabytes
		end
		
		def geocode_address
			geo=Geokit::Geocoders::MultiGeocoder.geocode (address)
			errors.add(:address, "Could not Geocode address") if !geo.success
			self.lat, self.lng = geo.lat,geo.lng if geo.success
		end
	
	# Generate a unique identifier for the restaurant's id property.
	private
		def generate_id
			self.id = SecureRandom.hex(32)
		end
end
