module CarWorldTrader
  class Base < Grape::API
    mount CarWorldTrader::V1::Cars
    mount CarWorldTrader::V2::Cars
  end
end
