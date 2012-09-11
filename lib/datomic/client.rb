$:.push(File.expand_path('../..', __FILE__))
require 'datomic/client/version'
require 'rest-client'

module Datomic
  class Client
    def initialize(url, storage = nil)
      @url = url
      @storage = storage
    end

    def create_database(dbname)
      RestClient.put db_url(dbname), {}
    end

    def database_info(dbname)
      RestClient.get db_url(dbname)
    end

    def transact(dbname, data)
      RestClient.post db_url(dbname), data
    end

    def datoms(dbname, index, params = {})
      RestClient.get db_url(dbname, "datoms/#{index}"), :params => params
    end

    def range(dbname, params = {})
      RestClient.get db_url(dbname, 'range'), :params => params
    end

    def entity(dbname, id, params = {})
      RestClient.get db_url(dbname, 'entity', id), :params => params
    end

    def query(query, params = {})
      RestClient.get root_url("api/query"), :params => params.merge(:q => query)
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
  end
end
