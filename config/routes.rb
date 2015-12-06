Rails.application.routes.draw do
  get 'page/dashboard'

  get '/search/program' => 'api#search_program'
  get '/get_recommendation/:upucode' => 'api#topsis'
  
  
  root 'page#dashboard'

end
