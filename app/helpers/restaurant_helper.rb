module RestaurantHelper
	def return_meal_section(meals, label)
		if !meals.any?
			 	render partial: "no_meal", locals: { label: label }
		else
			meals.each do |meal|
				render partial: "meal", locals: { meal: meal }
			end
		end
	end
end