AdminData::Engine.routes.draw do

  controller "crud" do
    match '/klass/*klass/new',      :to => :new,           :via => :get,    :as => :new
    match '/klass/*klass/:id/del',  :to => :del,           :via => :delete, :as => :delete
    match '/klass/*klass/:id/edit', :to => :edit,          :via => :get,    :as => :edit
    match '/klass/*klass/:id',      :to => :show,          :via => :get,    :as => :show
    match '/klass/*klass/:id',      :to => :update,        :via => :put,    :as => :update
    match '/klass/*klass/:id',      :to => :destroy,       :via => :delete, :as => :destroy
    match '/klass/(*klass)',        :to => :index,         :via => :get,    :as => :index
    match '/klass/(*klass)',        :to => :create,        :via => :post,   :as => :create
  end

  controller "migration" do
    match '/migration', :to => :index,  :as => :migration_information
    match '/jstest',    :to => :jstest, :as => :jstest
  end

  match '/table_structure/*klass' => "table_structure#index",  :as => :table_structure

  match '/quick_search/*klass'    => "search#quick_search",    :as => :search
  match '/quick_search'           => "search#quick_search"

  match '/advance_search/*klass'  => "search#advance_search",  :as => :advance_search
  match '/advance_search'         => "search#advance_search"

  match '/feed/*klasss'           => "feed#index", :defaults => { :format =>'rss' }, :as => :feed

  match '/public/*file'           => "public#serve", :as => :public

  root :to => "home#index"
end
