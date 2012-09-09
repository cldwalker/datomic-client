## Usage

```sh
# In another shell in datomic's directory
$ bin/rest 9000 socrates datomic:mem://

# In project's directory
$ irb -Ilib -rdatomic/client
>> dbname = 'cosas'
>> datomic = Datomic::Client.new 'http://localhost:9000', 'socrates'
>> datomic.create_database(dbname)
>> datomic.database_info(dbname)
>> datomic.datoms(dbname, 'aevt')
>> datomic.range(dbname, :a => "db/ident")
>> datomic.entity(1)
>> datomic.query("[:find ?e :where [?e :id 1]]")
>> datomic.monitor(dbname)
>> datomic.events(dbname) {|r| puts "Received: #{r.inspect}" }
```

## Credits

* @flyingmachine for starting this

## Links

* [API documentation](http://docs.datomic.com/rest.html)
* [Initial announcement](http://blog.datomic.com/2012/09/rest-api.html)
