Wf4EverDropboxConnector::Application.routes.draw do

  match 'ros_help' => 'home#ros_help'

  match 'dashboard' => 'dashboard#show'
  match 'dashboard/ros' => 'dashboard#ros'
  match 'dashboard/dropbox' => 'dashboard#dropbox'

  resources :dropbox_accounts do
    resources :ro_containers, :controller => "DropboxResearchObjectContainer"
  end
  
  match 'connect' => 'dropbox_accounts#connect'

  root :to => 'home#index'

  match 'admin' => 'admin/dashboard#index'

  devise_for :users
  
  namespace "admin" do
    resources :users
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
#== Route Map
# Generated on 05 Apr 2011 16:37
#
#     dropbox_account_ro_containers GET    /dropbox_accounts/:dropbox_account_id/ro_containers(.:format)          {:action=>"index", :controller=>"DropboxResearchObjectContainer"}
#                                   POST   /dropbox_accounts/:dropbox_account_id/ro_containers(.:format)          {:action=>"create", :controller=>"DropboxResearchObjectContainer"}
#  new_dropbox_account_ro_container GET    /dropbox_accounts/:dropbox_account_id/ro_containers/new(.:format)      {:action=>"new", :controller=>"DropboxResearchObjectContainer"}
# edit_dropbox_account_ro_container GET    /dropbox_accounts/:dropbox_account_id/ro_containers/:id/edit(.:format) {:action=>"edit", :controller=>"DropboxResearchObjectContainer"}
#      dropbox_account_ro_container GET    /dropbox_accounts/:dropbox_account_id/ro_containers/:id(.:format)      {:action=>"show", :controller=>"DropboxResearchObjectContainer"}
#                                   PUT    /dropbox_accounts/:dropbox_account_id/ro_containers/:id(.:format)      {:action=>"update", :controller=>"DropboxResearchObjectContainer"}
#                                   DELETE /dropbox_accounts/:dropbox_account_id/ro_containers/:id(.:format)      {:action=>"destroy", :controller=>"DropboxResearchObjectContainer"}
#                  dropbox_accounts GET    /dropbox_accounts(.:format)                                            {:action=>"index", :controller=>"dropbox_accounts"}
#                                   POST   /dropbox_accounts(.:format)                                            {:action=>"create", :controller=>"dropbox_accounts"}
#               new_dropbox_account GET    /dropbox_accounts/new(.:format)                                        {:action=>"new", :controller=>"dropbox_accounts"}
#              edit_dropbox_account GET    /dropbox_accounts/:id/edit(.:format)                                   {:action=>"edit", :controller=>"dropbox_accounts"}
#                   dropbox_account GET    /dropbox_accounts/:id(.:format)                                        {:action=>"show", :controller=>"dropbox_accounts"}
#                                   PUT    /dropbox_accounts/:id(.:format)                                        {:action=>"update", :controller=>"dropbox_accounts"}
#                                   DELETE /dropbox_accounts/:id(.:format)                                        {:action=>"destroy", :controller=>"dropbox_accounts"}
#                           connect        /connect(.:format)                                                     {:action=>"connect", :controller=>"dropbox_accounts"}
#                              root        /(.:format)                                                            {:controller=>"home", :action=>"index"}
#                             admin        /admin(.:format)                                                       {:action=>"index", :controller=>"admin/dashboard"}
#                  new_user_session GET    /users/sign_in(.:format)                                               {:action=>"new", :controller=>"devise/sessions"}
#                      user_session POST   /users/sign_in(.:format)                                               {:action=>"create", :controller=>"devise/sessions"}
#              destroy_user_session GET    /users/sign_out(.:format)                                              {:action=>"destroy", :controller=>"devise/sessions"}
#                     user_password POST   /users/password(.:format)                                              {:action=>"create", :controller=>"devise/passwords"}
#                 new_user_password GET    /users/password/new(.:format)                                          {:action=>"new", :controller=>"devise/passwords"}
#                edit_user_password GET    /users/password/edit(.:format)                                         {:action=>"edit", :controller=>"devise/passwords"}
#                                   PUT    /users/password(.:format)                                              {:action=>"update", :controller=>"devise/passwords"}
#                 user_confirmation POST   /users/confirmation(.:format)                                          {:action=>"create", :controller=>"devise/confirmations"}
#             new_user_confirmation GET    /users/confirmation/new(.:format)                                      {:action=>"new", :controller=>"devise/confirmations"}
#                                   GET    /users/confirmation(.:format)                                          {:action=>"show", :controller=>"devise/confirmations"}
#                       admin_users GET    /admin/users(.:format)                                                 {:action=>"index", :controller=>"admin/users"}
#                                   POST   /admin/users(.:format)                                                 {:action=>"create", :controller=>"admin/users"}
#                    new_admin_user GET    /admin/users/new(.:format)                                             {:action=>"new", :controller=>"admin/users"}
#                   edit_admin_user GET    /admin/users/:id/edit(.:format)                                        {:action=>"edit", :controller=>"admin/users"}
#                        admin_user GET    /admin/users/:id(.:format)                                             {:action=>"show", :controller=>"admin/users"}
#                                   PUT    /admin/users/:id(.:format)                                             {:action=>"update", :controller=>"admin/users"}
#                                   DELETE /admin/users/:id(.:format)                                             {:action=>"destroy", :controller=>"admin/users"}
#                         evergreen        /evergreen                                                             {:to=>#<Rack::Builder:0xb177ab8 @ins=[{"/jasmine"=>#<Rack::Static:0xb1776f8 @app=#<Proc:0xb177770@/home/jits/.rvm/gems/ruby-1.9.2-p180@global/gems/evergreen-0.4.0/lib/evergreen/application.rb:6 (lambda)>, @urls=["/"], @file_server=#<Rack::File:0xb1776e4 @root="/home/jits/.rvm/gems/ruby-1.9.2-p180@global/gems/evergreen-0.4.0/lib/jasmine/lib">>, "/resources"=>#<Rack::Static:0xb177374 @app=#<Proc:0xb177450@/home/jits/.rvm/gems/ruby-1.9.2-p180@global/gems/evergreen-0.4.0/lib/evergreen/application.rb:11 (lambda)>, @urls=["/"], @file_server=#<Rack::File:0xb177360 @root="/home/jits/.rvm/gems/ruby-1.9.2-p180@global/gems/evergreen-0.4.0/lib/evergreen/resources">>, "/"=>#<Class:0xb177284>}]>}
#                        styleguide GET    /styleguides(.:format)                                                 {:action=>"show", :controller=>"flutie/styleguides"}
#                 delayed_job_admin        /delayed_job_admin(.:format)                                           {:action=>"index", :controller=>"delayed_job_admin"}
#                            jammit        /assets/:package.:extension(.:format)                                  {:extension=>/.+/, :controller=>"jammit", :action=>"package"}
