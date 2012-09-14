require 'datomic/client/version'
require 'datomic/client/response'
require 'rest-client'
require 'edn'

module Datomic
  class Client
    HANDLE_RESPONSE = lambda do |body, request, response|
      Response.new body, response, request
    end

    def initialize(url, storage = nil)
      @url = url
      @storage = storage
    end

    def create_database(dbname)
      RestClient.put db_url(dbname), {}, &HANDLE_RESPONSE
    end

    def database_info(dbname)
      get db_url(dbname)
    end

    # Data can be a ruby data structure or a string representing clojure data
    def transact(dbname, data)
      data = transmute_data(data)
      RestClient.post(db_url(dbname), data, :content_type => 'application/x-edn', &HANDLE_RESPONSE)
    end

    # Index only has certain valid types. See datomic's docs for details.
    def datoms(dbname, index, params = {})
      get db_url(dbname, "datoms/#{index}"), :params => params
    end

    def range(dbname, params = {})
      get db_url(dbname, 'range'), :params => params
    end

    def entity(dbname, id, params = {})
      get db_url(dbname, 'entity', id), :params => params
    end

    # Query can be a ruby data structure or a string representing clojure data
    def query(dbname, query, params = {})
      query = transmute_data(query)
      args = [{:"db/alias" => [@storage, dbname].join('/')}].to_edn
      get root_url("api/query"), :params => params.merge(:q => query, :args => args)
    end

    def monitor(dbname)
      get root_url('monitor', @storage, dbname)
    end

    # Given block is called with Net::HTTPOK response from event
    def events(dbname, &block)
      # can't use RestClient.get b/c of :block_response
      RestClient::Request.execute(:method => :get,
        :url => root_url('events', @storage, dbname),
        :headers => {:accept => "text/event-stream"},
        :block_response => block, &HANDLE_RESPONSE)
    end

    private

    def get(*args)
      RestClient.get(*args, &HANDLE_RESPONSE)
    end

    def root_url(*parts)
      [@url].concat(parts).join('/')
    end

    def db_url(dbname, *parts)
      root_url 'db', @storage, dbname, *parts
    end

    def transmute_data(data)
      data.is_a?(String) ? data : data.to_edn
    end
  end
end
