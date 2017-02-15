Rails.application.routes.draw do
  devise_for :users, :controllers => { registrations: 'users/registrations', omniauth_callbacks: 'omniauth_callbacks', sessions: "sessions" }
	
	match '/users/:id/verified_email_not_found' => 'users#verified_email_not_found', via: [:get, :patch], :as => :verified_email_not_found
	match '/privacy' => 'static#privacy', via: [:get]
	match '/terms' => 'static#terms', via: [:get]
  
  ## Direct the root route to the main controller's index action.
  get 'main/index'
  root 'main#index'
	
	
	## Define the restaurant-meal relationship routes.
	resources :restaurants, :except => [:index] do 
		member do
			post 'change_status' 
    end
		resources :meals, :except => [:index] do
			member do
				post 'assess'
				post 'change_status'
				post 'share'
				post 'rate_comment'
			end
		end
  end
	
	resources :tags, :only => [:show]
	
	get 'user_profile/index', to: 'user_profile#index', as: 'user_profile'
	get 'moderator/index', to: 'moderator#index', as: 'moderator'
	
	# jQuery action for the main search.
	post 'main/search', to: 'main#search', as: 'main_search'
	get 'main/search', to: 'main#search'
	
	resources :issues, :only => [:new, :create, :show] do
		member do
			post 'resolve'
		end
	end
	
	# Return unknown routes to root.
	get '*path' => redirect('/')
end
