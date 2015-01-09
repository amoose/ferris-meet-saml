Rails.application.routes.draw do

  get '/saml/auth' => 'saml_idp#new'
  get '/saml/metadata' => 'saml_idp#show'
  post '/saml/auth' => 'saml_idp#create'
  match '/saml/sso' => 'saml_idp#sso', via: [:get, :post]
end
