require 'datomic/client'

# datomic's `rest` needs to run for these tests to pass i.e.
#   bin/rest 9000 socrates datomic:mem://
describe Datomic::Client do
  let(:datomic_uri) { ENV['DATOMIC_URI'] || 'http://localhost:9000' }
  let(:storage) { ENV['DATOMIC_STORAGE'] || 'socrates' }
  let(:client) do
    Datomic::Client.new datomic_uri, storage
  end
  let(:schema) { File.read(File.expand_path('../fixtures/seattle-schema.dtm', __FILE__)) }

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
      resp = client.database_info('test-database_info')
      resp.code.should == 200
    end

    it "returns database info for existing database" do
      resp = client.database_info('test-database_info')
      resp.data.should have_key(:"basis-t")
      resp.data.should have_key(:"db/alias")
    end

    it "returns 200 for different version" do
      resp = client.database_info('test-database_info', :t => 1)
      resp.code.should == 200
      resp.args[:url].should match(%r{/1/$})
    end

    it "returns 404 for nonexistent database" do
      resp = client.database_info('zxvf')
      resp.code.should == 404
    end
  end

  describe "#transact" do
    before { client.create_database('test-transact') }

    it "returns correct response with string of data" do
      resp = client.transact('test-transact', schema)
      resp.code.should == 201
      resp.data.should be_a(Hash)
      resp.data.keys.sort.should == [:"db-after", :"db-before", :tempids, :"tx-data"]
    end

    it "returns correct response with array of data" do
      resp = client.transact('test-transact', [[:"db/add", 1, :"community/name", "Some Community"]])
      resp.code.should == 201
      resp.data.should be_a(Hash)
      resp.data.keys.sort.should == [:"db-after", :"db-before", :tempids, :"tx-data"]
    end
  end

  describe "#datoms" do
    before { client.create_database('test-datoms') }

    %w{eavt aevt avet vaet}.each do |index|
      it "returns correct response for index '#{index}'" do
        resp = client.datoms('test-datoms', :index => index)
        resp.code.should == 200
        resp.data.should be_a(Array)
      end
    end

    it "returns 500 for invalid index" do
       resp = client.datoms('test-datoms', :index => 'blarg')
       resp.code.should == 500
    end

    it "returns correct response with limit param" do
      resp = client.datoms('test-datoms', :index => "eavt", :limit => 0)
      resp.code.should == 200
      resp.data.should == []
    end

    it "returns correct response for range usage" do
      resp = client.datoms('test-datoms', :index => 'avet', :a => 'db/ident')
      resp.code.should == 200
      resp.data.should be_a(Array)
    end

    it "returns correct response for different version" do
      resp = client.datoms('test-datoms', :t => 2)
      resp.code.should == 200
      resp.args[:url].should match(%r{2/datoms$})
    end
  end

  describe "#entity" do
    before { client.create_database('test-entity') }

    it "returns correct response" do
      resp = client.entity('test-entity', 1)
      resp.code.should == 200
      resp.data.should be_a(Hash)
    end

    it "returns correct response with valid param" do
      resp = client.entity('test-entity', 1, :since => 0)
      resp.code.should == 200
      resp.data.should be_a(Hash)
    end

    it "returns correct response for different version" do
      resp = client.entity('test-entity', 1, :t => 2)
      resp.code.should == 200
      resp.args[:url].should match(%r{2/entity$})
    end
  end

  describe "#query" do
    let(:db_id) { 1 }

    before {
      client.create_database('test-query')
      client.transact('test-query', schema)
      client.transact('test-query', [{:"db/id" => db_id, :"community/name" => "Some Community"}])
    }

    context "with a dbname passed in for args" do
      it "returns a correct response with a string query" do
        resp = client.query('[:find ?e :where [?e :community/name "Some Community"]]', 'test-query')
        resp.code.should == 200
        resp.data.should be_a(Array)
      end

      it "returns a correct response with limit param" do
        resp = client.query('[:find ?c :where [?c :community/name]]', 'test-query', :limit => 0)
        resp.code.should == 200
        resp.data.should be_a(Array)
        resp.data.should == []
      end

      it "returns a correct response with a data query" do
        resp = client.query([:find, EDN::Type::Symbol.new('?c'), :where,
                              [EDN::Type::Symbol.new('?c'), :"community/name"]],
                      'test-query')
        resp.code.should == 200
        resp.data.should be_a(Array)
      end
    end

    context "with an array passed in for args" do
      it "returns a correct response" do
        client.transact('test-query', [{
                            :"db/id" => db_id,
                            :"community/name" => "Some Community Again"}])
        query = [:find, ~'?e', ~'?v', :where, [~'?e', :"community/name", ~'?v']]

        resp_without_history = client.query(query, 'test-query')
        resp_with_history = client.query(query, [{
                                             :"db/alias" => "#{storage}/test-query",
                                             :history => true}])
        resp_with_history.code.should == 200
        resp_with_history.data.should be_a(Array)
        resp_with_history.data.count.should > resp_without_history.data.count
      end
    end
  end

  describe "#events" do
    before { client.create_database('test-events') }

    it "returns correct response" do
      begin
        client.events('test-events') do |resp|
          resp.code.should == "200"
          # Don't see a cleaner way to quit after testing one event
          raise Timeout::Error
        end
      rescue RestClient::RequestTimeout
      end
    end

    it "returns a 503 for nonexistent db" do
      resp = client.events('zzzz')
      resp.code.should == 503
    end
  end

  describe "#db_alias" do
    it "returns an object that can be used as a database alias input to #query" do
      client.db_alias('test').should == {:"db/alias" => "#{storage}/test"}
    end
  end
end
