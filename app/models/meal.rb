# == Schema Information
#
# Table name: meals
#
#  id                     :string         	not null, primary key
#  meal_name			        :string						not null, default("")
#  description            :string           not null, default("")
#  timestamp		          :timestamp
#	 user_id								:string
#	 restaurant_id					:string
#	 category								:string
#	 image									:string
#  lat										:float
#	 lng										:float
#
# Belongs to a single restaurant, created by one user.
# Has many meal recommendations and meal additionals.
# Belongs to many tags and has many tags.
class Meal < ActiveRecord::Base
	self.primary_key = 'id'
	
	# Define the virtual attribute, tags.
	acts_as_taggable
  validate :tag_list_count
	
	before_create :generate_id
	belongs_to :restaurant
	belongs_to :user
	has_many :meal_recommendations, :dependent => :destroy
	has_many :meal_additionals, :dependent => :destroy
	
	acts_as_mappable :through => :restaurant
	
	# Validate the model properties.
	validates :user_id, presence: true
	validates :restaurant_id, presence: true
  validates :description, presence: true, length: { maximum: 240 }
	validates :category, presence: true
	
	# For image uploading capabilities.
	mount_uploader :image, ImageUploader
	validates_processing_of :image
	validate :image_size_validation
	
	# For basic moderator searching by name.
	def self.search(search)
		if search
			where('meal_name LIKE ?', "%#{search}%")
		else
			none
		end
	end
	
	# For the primary search page.
	def self.main_search(keywords, location)
		if keywords.size > 0
			# Get all nearby meals.
			meals = Meal.joins(:restaurant).within(50, :origin => location) # Get meals by location.
			.tagged_with(keywords, :any => true, :wild => true)	# AND filter by tags
			.where(["meals.active = ?", true])	# AND return only active meals
			# Sort the result list based on their meal score.
			meals.sort do |a,b|
				case
				when a.meal_score < b.meal_score
					-1
				when a.meal_score > b.meal_score
					1
				else
					0
				end
			end
			return meals
		else
			none
		end
	end
		
	def meal_score
		if meal_recommendations.size > 0 
			return ((total_recommendations.to_f/meal_recommendations.size.to_f)*100).to_i 
		else 
			return 0 
		end
	end
	
	# Get the cost score.
	def cost_score
		if meal_additionals.size > 0 
			return ((sum_cost.to_f/meal_additionals.size.to_f)*100).to_i 
		else 
			return 0 
		end
	end
	
	# Get the portion score.
	def portion_score
		if meal_additionals.size > 0 
			return ((sum_portion.to_f/meal_additionals.size.to_f)*100).to_i 
		else 
			return 0 
		end
	end
	
	def achievements
		qualified_achievements = Array.new
		
		# The meal has enough responses to qualify for the "fork" achievements.
		if meal_recommendations.size >= 1000
			if meal_score >= 95
				qualified_achievements.push("diamond_fork.png")
			elsif meal_score >= 85 && meal_score < 95
				qualified_achievements.push("gold_fork.png")
			elsif meal_score >= 75 && meal_score < 85
				 qualified_achievements.push("silver_fork.png")
			end
		elsif meal_recommendations.size >= 100 && meal_recommendations.size < 1000	#The meal has only enough responses to qualify for the "star" achievements.
			if meal_score >= 95
				qualified_achievements.push("diamond_star.png")
			elsif meal_score >= 85 && meal_score < 95
				qualified_achievements.push("gold_star.png")
			elsif meal_score >= 75 && meal_score < 85
				qualified_achievements.push("silver_star.png")
		  end
		end
		
		# If the meal has enough additional and recommended responses to qualify for cost and taste, portion and taste achievements.
		if meal_recommendations.size >= 50 && meal_additionals.size >= 50
			if meal_score >= 85 && cost_score >= 85
				qualified_achievements.push("gold_dollar.png")
			end
			if meal_score >= 85 && portion_score >= 85	
				qualified_achievements.push("gold_portion.png")
			end
		end
		
		# If the meal has enough responses to qualify for the meal achievements.
		if meal_recommendations.size >= 100 && meal_additionals.size >= 100
			if meal_score >= 85 && cost_score >= 85 && portion_score >= 85
				qualified_achievements.push("diamond_meal.png")
			end
			if meal_score >= 75 && meal_score < 85 && cost_score >= 75 && cost_score < 85 && portion_score >= 75 && portion_score < 85 
				qualified_achievements.push("gold_meal.png")
			end
		end
		
		return qualified_achievements
	end
	
	# Get the total number of recommendations.
		def total_recommendations
			recommendations = 0
			meal_recommendations.each do |r|
				if r.rating?
					recommendations += 1
				end
			end
			return recommendations
		end
	
	private
		def image_size_validation
			errors[:image] << "should be less than 5MB" if image.size > 5.0.megabytes
		end
		
		# Determine if the user has added more than 10 tags(excluding the 3 "private" tags)
		def tag_list_count
			errors[:tag_list] << "10 tags maximum" if tag_list.count > 13
		end
	
		# Generate a unique identifier for the meal's id property.
		def generate_id
			self.id = SecureRandom.hex(32)
		end
		
		# Get the total portion value.
		def sum_cost
			total_cost = 0
			meal_additionals.each do |c|
					total_cost += c.cost
			end
			return total_cost
		end
		
		# Get the total cost value
		def sum_portion
			total_portion = 0
			meal_additionals.each do |p|
					total_portion += p.portion
			end
			return total_portion
		end
end
