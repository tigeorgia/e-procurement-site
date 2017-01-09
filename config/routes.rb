BootstrapStarter::Application.routes.draw do

	#--------------------------------
	# all resources should be within the scope block below
	#--------------------------------
	scope ":locale", locale: /#{I18n.available_locales.join("|")}/ do

		match '/admin', :to => 'admin#index', :as => :admin, :via => [:get]
    match '/user', :to => 'user#index', :as => :user, :via => [:get]
  
		devise_for :users, :controllers => { :sessions => "users/sessions", :registrations => "users/registrations" }, :path_names => { :sign_up => "register" }

    namespace :admin do
      resources :users
    end

    resources :tenders
    resources :organizations
    #resources :simplified_procurement

    match '/simplified_procurement' => 'simplified_procurement#index', :via => [:get]
    match '/simplified_procurement/index' => 'simplified_procurement#index', :via => [:get]
    match '/simplified_procurement/search' => 'simplified_procurement#search', :via => [:get]
    match '/simplified_procurement/:id', :to => 'simplified_procurement#show', :as => :simplified_tender, :via => [:get]

    match '/organization/search_procurer' => 'organizations#search_procurer', :via => [:get]
    match '/organization/search' => 'organizations#search', :via => [:get]
    match '/organization/getProcurers' => 'organizations#getProcurers', :via => [:get]
    match '/organization/getSuppliers' => 'organizations#getSuppliers', :via => [:get]
    match '/root/organization/search_procurer' => 'organizations#search_procurer', :via => [:get]
    match '/root/organization/search' => 'organizations#search', :via => [:get]
    match '/tender/search' => 'tenders#search', :via => [:get]
    match '/tender/search_via_saved' => 'tenders#search_via_saved', :via => [:get]
    match '/tender/download' => 'tenders#download', :via => [:get]
    match '/tender/download_all' => 'tenders#download_all', :via => [:get]
    match '/organization/download_proc_tenders' => 'organizations#download_proc_tenders', :via => [:get]
    match '/organization/download_org_tenders' => 'organizations#download_org_tenders', :via => [:get]
    match '/tenders/index' => 'tenders#index', :via => [:get]
    match '/procurer' => 'organizations#show_procurer', :via => [:get]
    match '/watch_tender/subscribe' => 'watch_tender#subscribe', :via => [:get]
    match '/watch_tender/unsubscribe' => 'watch_tender#unsubscribe', :via => [:get]
    match '/cpv_tree/showCPVtree' => 'cpv_tree#showCPVTree', :via => [:get]
    match ':controller/:action', :via => [:get]
    match '/build_user_data', :to => 'root#build_user_data', :as => :build_user_data, :via => [:get]
    match '/generate_cpv_codes', :to => 'root#generate_cpv_codes', :as => :generate_cpv_codes, :via => [:get]
    match '/:locale' => 'root#index', :via => [:get]
    #match '/maintenance', :to => redirect('/maintenance.html')
    root :to => 'root#index', :via => [:get]
	  
	end

	match '', :to => redirect("/ka"), :via => [:get]
	
end
