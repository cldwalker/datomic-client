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
```

## Credits

* @flyingmachine for starting this
