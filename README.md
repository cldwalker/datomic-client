## Description

This gem provides a simple way to use datomic's [http API](http://docs.datomic.com/rest.html).

## Install

Install as a gem:

    $ gem install datomic-client

If your application is using a Gemfile, add this to it:

    gem 'datomic-client', :require => 'datomic/client'

and then `bundle`.

## Usage

```sh
# In another shell in datomic's directory
$ bin/rest 9000 socrates datomic:mem://

# In project's directory
$ irb -rdatomic/client
>> dbname = 'cosas'
>> datomic = Datomic::Client.new 'http://localhost:9000', 'socrates'
>> datomic.create_database(dbname)
>> datomic.database_info(dbname)
>> datomic.transact(dbname, "TODO")
>> datomic.datoms(dbname, 'aevt')
>> datomic.range(dbname, :a => "db/ident")
>> datomic.entity(dbname, 1)
>> datomic.query(dbname, "TODO")
>> datomic.monitor(dbname)
>> datomic.events(dbname) {|r| puts "Received: #{r.inspect}" }
```

## Issues
Please report them [on github](http://github.com/cldwalker/datomic-client/issues).

## Contributing
[See here](http://tagaholic.me/contributing.html) for contribution policies.

## Credits

* @flyingmachine for starting this with me

##Todo

* Fix pending specs

## Links

* [API documentation](http://docs.datomic.com/rest.html)
* [Initial announcement](http://blog.datomic.com/2012/09/rest-api.html)
