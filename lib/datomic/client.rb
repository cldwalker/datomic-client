require 'rest-client'

module Datomic
  class Client
    VERSION = '0.1.0'

    def initialize(url, storage)
      @url = url
      @storage = storage
    end

    def create_database(dbname)
      RestClient.put db_url(dbname), {}
    end

    def database_info(dbname)
      RestClient.get db_url(dbname)
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

    private

    def db_url(dbname, *parts)
      [@url, 'db', @storage, dbname].concat(parts).join('/')
    end
  end
end
