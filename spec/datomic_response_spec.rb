require 'datomic/client'

describe Datomic::Client::Response do
  let(:datomic_uri) { ENV['DATOMIC_URI'] || 'http://localhost:9000' }
  let(:client) do
    Datomic::Client.new datomic_uri, ENV['DATOMIC_STORAGE'] || 'socrates'
  end

  describe '.new' do
    let(:resp) { client.create_database("test-#{Time.now.to_i}") }

    it "returns a valid code" do
      resp.code.should be_a Integer
    end

    it "returns a valid string" do
      resp.body.should be_a String
    end

    it "returns valid headers" do
      resp.headers.should be_a Hash
    end

    it "returns valid cookies" do
      resp.cookies.should be_a Hash
    end

    it "returns valid raw headers" do
      resp.raw_headers.should be_a Hash
    end
  end
end
