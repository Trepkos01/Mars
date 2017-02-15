class TagsController < ApplicationController
	def show
			@tag =  ActsAsTaggableOn::Tag.find(params[:id])
			@meals = Meal.tagged_with(@tag.name).paginate(page: params[:page], :per_page => 10)
	end
end