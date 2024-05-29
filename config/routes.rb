Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  root "home#index"
  get 'signup/create'
  controller :refresh do
    post 'refresh' => 'refresh#create'
  end

  controller :signin do
    post 'signin' => 'signin#create'
    delete 'signout' => 'signin#destroy'
  end

  controller :signup do
    post 'signup' => 'signup#create'
  end

  controller :conversation do
    get '/conversation' => 'conversation#conversations'
    get '/conversation/search' => 'conversation#find_conversation'
  end
  controller :conversation_message do
    get '/conversation_messages' => 'conversation_message#messages'
    post '/conversation_messages/send' => 'conversation_message#send_message'
  end

  controller :profile do
    get '/profile' => 'profile#profiles'
    post '/profile/new' => 'profile#create'
    put '/profile/update' => 'profile#edit_profile'
    delete '/profile/delete' => 'profile#delete_profile'
    get '/profile/search' => 'profile#search'
    get '/profile/filter' => 'profile#filter'
  end

  controller :note do
    get '/notes' => 'note#notes'
    post '/new_note' => 'note#create'
  end

  controller :analytic do
    get '/analytics' => 'analytic#index'
  end

end
