module SpreeAtlassianTax
  module Utilities
    class PingService < SpreeAtlassianTax::Base
      def call
        request_result(client.ping)
      end
    end
  end
end
