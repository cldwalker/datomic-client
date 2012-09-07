require 'httparty'
require 'pp'
require 'rest-client'
class Client
  include HTTParty

  base_uri 'localhost:9000'


end

pp RestClient.put('http://localhost:9000/db/socrates/daniel', {})
