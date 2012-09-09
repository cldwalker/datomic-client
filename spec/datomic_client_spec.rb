require 'datomic/client'

describe Datomic::Client do
  # datomic's `rest` needs to run for these tests to pass i.e.
  #   bin/rest 9000 socrates datomic:mem://
  let(:client) do
    Datomic::Client.new ENV['DATOMIC_URI'] || 'http://localhost:9000',
      ENV['DATOMIC_STORAGE'] || 'socrates'
  end

  VEC = /^\[.*\]$/
  MAP = /^\{.*\}$/

  describe "#create_database" do
    it "returns 201 when creating a new database" do
      resp = client.create_database("test-#{Time.now.to_i}")
      resp.code.should == 201
    end

    it "returns 200 when database already exists" do
      db = "test-#{Time.now.to_i}"
      client.create_database(db)
      resp = client.create_database(db)
      resp.code.should == 200
    end
  end

  describe "#database_info" do
    before { client.create_database('test-database_info') }

    it "returns 200 for existing database" do
      resp = client.database_info('test123')
      resp.code.should == 200
      resp.body.should include(':basis-t')
      resp.body.should include(':db/alias')
    end

    it "returns database info for existing database" do
      resp = client.database_info('test123')
      resp.body.should include(':basis-t')
      resp.body.should include(':db/alias')
    end

    # returning 500 which rest-client throws as an error, awesome
    pending "returns 404 for nonexistent database" do
      resp = client.database_info('zxvf')
      resp.code.should == 404
    end
  end

  describe "#datoms" do
    before { client.create_database('test-datoms') }

    %w{eavt aevt avet vaet}.each do |index|
      it "returns correct response for index '#{index}'" do
        pending if index == 'vaet'
        resp = client.datoms('test-datoms', index)
        resp.code.should == 200
        resp.body.should match VEC
      end
    end

    it "raises 500 error for invalid index" do
       expect { client.datoms('test-datoms', 'blarg') }.
         to raise_error(RestClient::InternalServerError, /500 Internal Server Error/)
    end

    it "returns correct response with limit param" do
      resp = client.datoms('test-datoms', "eavt", :limit => 0)
      resp.code.should == 200
      resp.body.should == "[]"
    end
  end

  describe "#range" do
    before { client.create_database('test-range') }

    it "returns correct response with required attribute" do
      resp = client.range('test-range', :a => "db/ident")
      resp.code.should == 200
      resp.body.should match VEC
    end

    it "raises 400 without required attribute" do
      expect { client.range('test-range') }.
        to raise_error(RestClient::BadRequest, /400 Bad Request/)
    end
  end

  describe "#entity" do
    before { client.create_database('test-entity') }

    it "returns correct response" do
      resp = client.entity('test-entity', 1)
      resp.code.should == 200
      resp.body.should match MAP
    end

    it "returns correct response with valid param" do
      resp = client.entity('test-entity', 1, :since => 0)
      resp.code.should == 200
      resp.body.should match MAP
    end
  end

  describe "#query" do
    before { client.create_database('test-query') }

    it "returns a correct response" do
      pending "til valid query given"
      resp = client.query("[:find ?e :where [?e :id 1]]")
      resp.code.should == 200
      resp.body.should match VEC
    end
  end

  describe "#monitor" do
    before { client.create_database('test-monitor') }

    it "returns a correct response" do
      resp = client.monitor('test-monitor')
      resp.code.should == 200
      resp.body.should match(/\<script\>/)
    end
  end
end
