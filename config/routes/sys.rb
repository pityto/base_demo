PreReport::Application.routes.draw do

  namespace :admin do
    #人事管理
    namespace :hr do
      root to: 'admin/hr/employees#desboart'
      #员工管理
      resources :employees, except: [:show, :destroy] do
        collection do
          get  :forget_password
          post :forget_password
          get  :reset_mail
          get  :error_mail
          get  :add_roles
          post :save_roles
          get  :desboart
        end
      end
      #角色管理
      resources :roles do
        member do
          get :permission
          post :update_permission
        end
      end
      #部门管理
      resources :departments do
        member do
          get :get_sub_departments
        end
      end
      #小组管理
      resources :teams, except: :show
    end
    
  end
end
