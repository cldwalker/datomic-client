module Datomic
  class Client
    class Response
      # Response body as a string
      attr_reader :body
      # Underlying Net:HTTP response
      attr_reader :net_http

      def initialize(body, response, request)
        @body = body
        @args = request.args
        @net_http = response
        # used to parse response cookies and headers
        @rest_client_response = RestClient::Response.create(body, response, @args)
      end

      # converts an EDN body to a data structure i.e. array, hash
      def data
        @data ||= EDN.read @body
      end

      [:code, :headers, :cookies, :raw_headers].each do |meth|
        define_method(meth) do
          @rest_client_response.public_send(meth)
        end
      end
    end
  end
end
