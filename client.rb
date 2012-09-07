require 'pp'
require 'rest-client'

module Datomic
  class Client
    def initialize(url, storage)
      @url = url
      @storage = storage
    end

    def create_database(dbname)
      RestClient.put db(dbname), {}
    end

    def database_info(dbname)
      RestClient.get db(dbname)
    end

    def datoms(dbname, index)
      raise ArgumentError if !%w{eavt aevt avet vaet}.include?(index)
      RestClient.get "#{db(dbname)}/datoms/#{index}"
    end

    private

    def db(dbname)
      full_storage_url + "/#{dbname}"
    end

    def full_storage_url
      "#{@url}/db/#{@storage}"
    end
  end

end
