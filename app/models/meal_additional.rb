# == Schema Information
#
# Table name: meal_additional
#
#  id                     :integer         	not null, primary key
#  cost						        :float						not null
#  portion				        :float						not null
#  user_agent	            :string           not null
#  timestamp		          :timestamp
#	 user_id
#
# Belongs to a meal, created by a user.
class MealAdditional < ActiveRecord::Base
	belongs_to :meal
	belongs_to :user
end
