module ApplicationHelper
	def header(text)
		content_for(:header) { text.to_s }
	end
	
	def image_valid(image_file_name)
		if image_file_name
			return image_file_name
		else
			return "placeholder_image.jpg"
		end
	end
	
	def return_score_image(meal_score)
		if meal_score >= 95
			return "ext_rec.png"
		elsif meal_score <= 94 && meal_score >= 85
			return "high_rec.png"
		elsif meal_score <= 84 && meal_score >= 60
			return "rec.png"
		elsif meal_score <= 59 && meal_score >= 50
			return "ind_rec.png"
		elsif meal_score <= 49 && meal_score >= 35
			return "not_rec.png"
		elsif meal_score <= 34 && meal_score >= 25
			return "high_not_rec.png"
		elsif meal_score <= 24 && meal_score >= 0
			return "ext_not_rec.png"
		end
	end
	
	def return_meal_cost_image(meal_cost)
		if meal_cost >= 85
			return "high_cheap.png"
		elsif meal_cost <= 84 && meal_cost >= 75
			return "cheap.png"
		elsif meal_cost <= 25 && meal_cost >= 16
			return "expensive.png"
		elsif meal_cost <= 15 && meal_cost >= 0
			return "high_expensive.png"
		end
	end
	
	def return_meal_portion_image(meal_portion)
		if meal_portion >= 85
			return "high_large.png"
		elsif meal_portion <= 84 && meal_portion >= 75
			return "large.png"
		elsif meal_portion <= 25 && meal_portion >= 16
			return "small.png"
		elsif meal_portion <= 15 && meal_portion >= 0
			return "high_small.png"
		end
	end
end
