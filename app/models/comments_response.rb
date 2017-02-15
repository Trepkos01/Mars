# == Schema Information
#
# Table name: comments_responses
#
#  id                     :integer         	not null, primary key
#  helpful					      :boolean					not null
#  timestamp		          :timestamp
#	 user_id
#	 meal_recommendation_id
#
# Belongs to a meal recommendation, created by a user.

class CommentsResponse < ActiveRecord::Base
	belongs_to :meal_recommendation
	belongs_to :user
end
