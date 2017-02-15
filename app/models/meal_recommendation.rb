# == Schema Information
#
# Table name: meal_recommendation
#
#  id                     :integer         	not null, primary key
#  rating					        :boolean					not null
#  user_agent	            :string           not null
#	 shared									:boolean					false
#	 comments								:text							null
#  timestamp		          :timestamp
#	 user_id
#
# Belongs to a meal, created by a user.

class MealRecommendation < ActiveRecord::Base
	belongs_to :meal
	belongs_to :user
	
	has_many :comments_responses, :dependent => :destroy
	
	def total_helpfuls
		helpfuls = 0
			comments_responses.each do |r|
				if r.helpful?
					helpfuls += 1
				end
			end
			return helpfuls
	end
	
	def total_not_helpfuls
		return comments_responses.size-total_helpfuls
	end
end
