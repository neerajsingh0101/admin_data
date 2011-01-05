Rails.application.routes.draw do

  namespace(:admin_data) do
    scope :admin_data do
      controller "crud" do
        match '/klass/(:klass)',                :to => :index,            :as => :index,   :via => :get
        match '/klass/(:klass)',                :to => :create,           :as => :index,   :via => :post
        match '/klass/:klass/new',              :to => :new,              :as => :new,     :via => :get
        match '/klass/:klass/:id/del',          :to => :del,              :as => :del,     :via => :delete
        match '/klass/:klass/:id/edit',         :to => :edit,             :as => :edit,    :via => :get
        match '/klass/:klass/:id',              :to => :show,             :via => :get
        match '/klass/:klass/:id',              :to => :update,           :via => :put
        match '/klass/:klass/:id',              :to => :destroy,          :via => :delete
      end

      controller "migration" do
        match '/migration', :to => :index,  :as => :migration_information
        match '/jstest',    :to => :jstest, :as => :jstest
      end

      match '/table_structure/:klass' => "table_structure#index", :as => :table_structure

      match '/quick_search/:klass' => "search#quick_search",      :as => :search

      match '/advance_search/:klass' => "search#advance_search",  :as => :advance_search

      match '/feed/:klasss' => "feed#index", :defaults => { :format =>'rss' }, :as => :feed

      match '/public/*file' => "public#serve", :as => :public

      root :to => "home#index"
    end
  end

end
