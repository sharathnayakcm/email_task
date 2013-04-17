Beehive::Application.routes.draw do

  devise_for :users, :path_names => { :sign_up => "register", :sessions => "sessions" }, :controllers => {:registrations => "registrations"}

  resources :cugs do
    collection do
      get  :get_cug_view
      get  :cugs_names_with_aliases
      get  :search_members
      post :get_cug_view
      get  :advance_search
      get  :buzz_properties
    end
    member do
      get :more_buzzes
      get  :search_cug_members
    end
  end

  resources :favourites
  resources :channels do
    collection do
      get  :get_channels
      post :get_channels
    end
  end

  namespace :admin do
    resources :users do
      collection do
        get   :upload_csv
        post  :save_csv
      end
      member do
        put   :deactivate
        put   :activate
      end
    end
  end

  resources :home do
    collection do
      get   :help
      get   :add_to_watch
      get   :download_attachment
      post  :beehive_search
      get   :beehive_search_more
      get   :icons_help
    end
  end

  resources :rezzs do
    collection do
      get :members
    end
  end

  resources :buzz_tags do
    collection do
      post  :create_tag
      get   :buzz_tag_list
    end
  end

  resources :buzz_flags

  resources :buzz_tasks do
    collection do
      get :buzz_tasks_completed
      get :cug_channel_tasks
      put :buzz_task_mark_as_complete
    end
    member do
      get :view_buzz
    end
  end
  resources :buzz_names

  resources :buzzs do
    collection do
      get   :insync_buzz_in_channel
      post  :limit_user
      get   :channel_search
      get   :user_has_priority_response_expected
      get   :filter_buzzs
    end
    member do
      get   :more_buzzs
      get   :limit_buzz
      get   :get_channel
    end
  end

  resources :subscriptions
  resources :response_expected_buzzs
  resources :priority_buzzs

  resources :tags do
    collection do
      post :channel_tag
    end
  end


  # Below are the routes used for the mobile API
  namespace :api do
    devise_scope :user do
      resource  :sessions do
        collection do
          post  :create
          post  :forgot_password
          post  :change_password
          get   :preference
          post  :save_preference
        end
      end
      resource :channel do
        collection do
          get   :get_detail
          get   :get_channel_detail
          get   :get_moderator_list
          get   :get_moderator_channel_detail
          get   :subs_unsubscribe_channel
          get   :close_channel
          post  :update_channel
          get   :channel_buzzers
          get   :delete_buzz
          get   :swap_cug_type
          get   :get_cug_contribution
          post  :buzz_here
          get   :channel_members
        end
      end
      resource  :command do
        collection do
          post  :process_command
        end
      end
      resource  :buzzes do
        collection do
          get   :insync_buzz
          get   :buzz_flags
          get   :get_cug_tags
          post  :add_new_tag
          post  :save_buzz_tags
        end
        member do
          post  :limit_user
          post  :save_buzz_flags
          get   :members
          get   :buzz_detail
          get   :dozz_detail
          get   :task_detail
          post  :save_task
          get   :complete_or_delete_dozz_task
        end
      end
      resource :rezz do
        member do
          get :view
        end
      end
    end
  end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  #root :to => "cugs#index"
  root :to => "channels#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
