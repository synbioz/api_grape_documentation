Rails.application.routes.draw do
  mount CarWorldTrader::Base => '/'
  mount GrapeSwaggerRails::Engine => '/apidoc'
end
