require 'datomic/client/version'
require 'rest-client'
require 'edn'

module Datomic
  class Client
    READ_EDN = lambda do |body, request, response|
      res = EDN.read(body) rescue body
      res = RestClient::Response.create(res, response, request.args)
      res.return!(request, response)
    end

    def initialize(url, storage = nil)
      @url = url
      @storage = storage
    end

    def create_database(dbname)
      RestClient.put db_url(dbname), {}
    end

    def database_info(dbname)
      RestClient.get(db_url(dbname), &READ_EDN)
    end

    def transact(dbname, data)
      data = transmute_data(data)
      RestClient.post(db_url(dbname), data, :content_type => 'application/x-edn', &READ_EDN)
    end

    def datoms(dbname, index, params = {})
      RestClient.get(db_url(dbname, "datoms/#{index}"), {:params => params}, &READ_EDN)
    end

    def range(dbname, params = {})
      RestClient.get(db_url(dbname, 'range'), {:params => params}, &READ_EDN)
    end

    def entity(dbname, id, params = {})
      RestClient.get(db_url(dbname, 'entity', id), :params => params, &READ_EDN)
    end

    def query(dbname, query, params = {})
      query = transmute_data(query)
      args = [{:"db/alias" => [@storage, dbname].join('/')}].to_edn
      RestClient.get(root_url("api/query"), :params => params.merge(:q => query, :args => args), &READ_EDN)
    end

    def monitor(dbname)
      RestClient.get root_url('monitor', @storage, dbname)
    end

    # Given block is called with Net::HTTPOK response from event
    def events(dbname, &block)
      RestClient::Request.execute(:method => :get,
        :url => root_url('events', @storage, dbname),
        :headers => {:accept => "text/event-stream"},
        :block_response => block)
    end

    private

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
