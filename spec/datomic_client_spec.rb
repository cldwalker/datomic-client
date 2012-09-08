require 'datomic/client'

describe Datomic::Client do
  # datomic's `rest` needs to run for these tests to pass i.e.
  #   bin/rest 9000 socrates datomic:mem://
  let(:client) do
    Datomic::Client.new ENV['DATOMIC_URI'] || 'http://localhost:9000',
      ENV['DATOMIC_STORAGE'] || 'socrates'
  end

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
    before { client.create_database('test123') }

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
end
