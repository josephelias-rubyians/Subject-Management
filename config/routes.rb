Rails.application.routes.draw do

	devise_for :users, path: '', path_names: {
	  sign_in: 'login',
	  sign_out: 'logout',
	  registration: 'signup'
	},
	controllers: {
	  sessions: 'users/sessions',
	  registrations: 'users/registrations'
	}

	resources :users, only: [:index, :show, :update, :destroy] do
		member do
  		post :update_password
  	end
	end

	resources :subjects
end
