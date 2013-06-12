BootstrapStarter::Application.routes.draw do

	#--------------------------------
	# all resources should be within the scope block below
	#--------------------------------
	scope ":locale", locale: /#{I18n.available_locales.join("|")}/ do

		match '/admin', :to => 'admin#index', :as => :admin, :via => :get
    match '/user', :to => 'user#index', :as => :user, :via => :get
  
		devise_for :users, :path_names => { :sign_up => "register" }

    namespace :admin do
      resources :users
    end

    resources :tenders
    resources :organizations

    match '/organization/search_procurer' => 'organizations#search_procurer'
    match '/organization/search' => 'organizations#search'
    match '/organization/getProcurers' => 'organizations#getProcurers'
    match '/organization/getSuppliers' => 'organizations#getSuppliers'
    match '/root/organization/search_procurer' => 'organizations#search_procurer'
    match '/root/organization/search' => 'organizations#search'

    match '/tender/search' => 'tenders#search'
    match '/tender/search_via_saved' => 'tenders#search_via_saved'
    match '/tender/download' => 'tenders#download'
    match '/organization/download_proc_tenders' => 'organizations#download_proc_tenders'
    match '/organization/download_org_tenders' => 'organizations#download_org_tenders'
    match '/tenders/index' => 'tenders#index'
    match '/procurer' => 'organizations#show_procurer'
    match '/watch_tender/subscribe' => 'watch_tender#subscribe'
    match '/watch_tender/unsubscribe' => 'watch_tender#unsubscribe'
    match '/cpv_tree/showCPVtree' => 'cpv_tree#showCPVTree'
    match ':controller/:action'
    match '/build_user_data', :to => 'root#build_user_data', :as => :build_user_data, :via => :get
    match '/generate_cpv_codes', :to => 'root#generate_cpv_codes', :as => :generate_cpv_codes, :via => :get
    match '/:locale' => 'root#index'		
    root :to => 'root#index'
	  
	end

	match '', :to => redirect("/#{I18n.default_locale}") # handles /
	
end
