## Description

This gem provides a simple way to use datomic's [http API](http://docs.datomic.com/rest.html).

## Install

Install as a gem:

    $ gem install datomic-client

If your application is using a Gemfile, add this to it:

    gem 'datomic-client', :require => 'datomic/client'

and then `bundle`.

## Usage

```ruby
# In another shell in datomic's directory
$ bin/rest 9000 socrates datomic:mem://

# Assuming you have a schema with a :"community/name" attribute
# In project's directory
$ irb -rdatomic/client
>> dbname = 'cosas'
>> datomic = Datomic::Client.new 'http://localhost:9000', 'socrates'
>> resp = datomic.create_database(dbname)
=> #<Datomic::Client::Response:0x0000010157bc58 @body="", @args={:method=>:put,
:url=>"http://localhost:9000/db/socrates/test-1347638297", :payload=>{}, :headers=>{}},
@net_http=#<Net::HTTPCreated 201 Created readbody=true>, @rest_client_response="">
>> resp.code
=> 201
>> resp.body
=> ''

# Most responses are in edn and thus can be accessed natively
>> resp = datomic.query(dbname, '[:find ?c :where [?c :community/name]]')
>> resp.data
=> [[1]]

# additional endpoints
>> datomic.database_info(dbname)
>> datomic.transact(dbname, [[:"db/add", 1, :"community/name", "Some Community"]])
>> datomic.datoms(dbname, 'aevt')
>> datomic.range(dbname, :a => "db/ident")
>> datomic.entity(dbname, 1)
>> datomic.events(dbname) {|r| puts "Received: #{r.inspect}" }
```

## Issues
Please report them [on github](http://github.com/cldwalker/datomic-client/issues).

## Contributing
[See here](http://tagaholic.me/contributing.html) for contribution policies.

## Credits

* @crnixon for adding edn support
* @flyingmachine for starting this with me

## Links

* [API documentation](http://docs.datomic.com/rest.html) - Actual documentation now resides on root
  url of datomic endpoint
* [Initial announcement](http://blog.datomic.com/2012/09/rest-api.html)
