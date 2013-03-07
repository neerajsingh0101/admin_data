AdminDataDemo::Application.routes.draw do

  #root :to => "/admin_data"
  match "/" => redirect("/admin_data")

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
