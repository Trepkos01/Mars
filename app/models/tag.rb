# == Schema Information
#
# Table name: tag
#
#  id                     :integer         	not null, primary key
#  name						        :string						not null
#  taggings_count         :integer
#
# Belongs to a meal, created by a user.
class Tag < ActiveRecord::Base
	has_and_belongs_to_many :meals
end
