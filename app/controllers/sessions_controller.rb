class SessionsController < Devise::SessionsController

	def new
		super
	end

	def create
		super do |resource|
      resource.provider = "default"
			resource.save!
    end
	end

end