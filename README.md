## Usage

```sh
$ irb -Ilib -rdatomic/client
>> dbname = 'daniel'
>> datomic = Datomic::Client.new 'http://localhost:9000', 'socrates'
>> datomic.create_database(dbname)
>> datomic.database_info(dbname)
```

## Credits

* @flyingmachine for starting this
