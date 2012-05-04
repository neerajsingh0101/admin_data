AdminData::Engine.routes.draw do

  controller "crud" do
    match '/klass/(:klass)',                :to => :index,            :as => :crud_index,   :via => :get
    match '/klass/(:klass)',                :to => :create,           :as => :crud_index,   :via => :post
    match '/klass/:klass/new',              :to => :new,              :as => :crud_new,     :via => :get
    match '/klass/:klass/:id/del',          :to => :del,              :as => :crud_del,     :via => :delete
    match '/klass/:klass/:id/edit',         :to => :edit,             :as => :crud_edit,    :via => :get
    match '/klass/:klass/:id',              :to => :show,             :as => :crud_show,    :via => :get
    match '/klass/:klass/:id',              :to => :update,           :via => :put
    match '/klass/:klass/:id',              :to => :destroy,          :via => :delete
  end

  controller "migration" do
    match '/migration', :to => :index,  :as => :migration_information
    match '/jstest',    :to => :jstest, :as => :jstest
  end

  match '/table_structure/:klass' => "table_structure#index",  :as => :table_structure

  match '/quick_search/:klass'    => "search#quick_search",    :as => :search
  match '/quick_search'           => "search#quick_search"

  match '/advance_search/:klass'  => "search#advance_search",  :as => :advance_search
  match '/advance_search'         => "search#advance_search"

  match '/analytics/daily/:klass'       => "analytics#daily",        :as => :daily_analytics
  match '/analytics/monthly/:klass'     => "analytics#monthly",      :as => :monthly_analytics

  match '/feed/:klasss'           => "feed#index", :defaults => { :format =>'rss' }, :as => :feed

  match '/public/*file'           => "public#serve", :as => :public

  root :to => "home#index"

end
