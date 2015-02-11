module CarWorldTrader
  module V2
    class Cars < Grape::API
      version 'v2', using: :path
      format :json
      prefix :api

      resource :cars do
        desc "Create a car"
        params do
          requires :car, type: Hash do
            requires :manufacturer, type: String, regexp: /^[A-Z][a-z]+$/
            requires :design, type: String, values: ["tourer", "racing"]
            requires :style, type: String
          end
        end
        post do
          Car.create!(params[:car].merge(doors: 5))
        end
      end
    end
  end
end
