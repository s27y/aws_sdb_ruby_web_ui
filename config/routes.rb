Rails.application.routes.draw do
  get 'attribute/get'
  post 'attribute/get'

  get 'attribute/put'
  post 'attribute/put'

  get 'attribute/delete'

  get 'attribute/select'

  get 'attribute/list'

  get 'get/put'

  get 'get/delete'

  get 'get/select'

  get 'get/list'

  get 'domain/add'
  post 'domain/add'

  get 'domain/delete'
  post 'domain/delete'

  get 'domain/list'
  post 'domain/list'

  get 'domain/metadata'
  post 'domain/metadata'

  get 'credential/add'
  post 'credential/add'

  get 'credential/remove'

  get 'home/index'

  get 'home/bye'

  get 'attribute/test_hash'



  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
   root 'home#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  get 'attribute/select/:domain_name', to: 'attribute#select'
  get 'attribute/list/:domain_name', to: 'attribute#list'
  get 'attribute/put/:domain_name', to: 'attribute#put'
  get 'attribute/get/:domain_name', to: 'attribute#get'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  resources :item
  resources :new_item

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
