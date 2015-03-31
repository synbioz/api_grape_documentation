module CarWorldTrader
  class Base < Grape::API
    format :json
    prefix :api

    mount CarWorldTrader::V1::Cars

    add_swagger_documentation(
      base_path: "",
      api_version: "1.0",
      format: :json,
      hide_documentation_path: true,
      info: {
        title: "CarWorldTrader API",
        description: 'API to expose Cars informations form AutoTrader',
        contact: "jfrancois@synbioz.com",
        license: "All Rights Reserved"
        }
    )
  end
end
