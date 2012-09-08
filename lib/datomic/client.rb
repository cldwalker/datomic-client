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
      RestClient.get "#{db_url(dbname)}/datoms/#{index}", :params => params
    end

    private

    def db_url(dbname)
      full_storage_url + "/#{dbname}"
    end

    def full_storage_url
      "#{@url}/db/#{@storage}"
    end
  end
end
