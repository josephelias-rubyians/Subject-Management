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
	resources :teaching_classes
	resources :subject_and_classes, only: [:create]
	delete '/subject_and_classes', to: 'subject_and_classes#remove_subject_and_classes'
	resources :user_and_subjects, only: [:create]
	delete '/user_and_subjects', to: 'user_and_subjects#remove_user_and_subjects'
end
