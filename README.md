heimdallr_testing
=================

Testing how [heimdallr](https://github.com/roundlake/heimdallr) gem performs on scope fetches

# Installation

    sqlite3 development.sqlite3

    CREATE TABLE users(id INTEGER PRIMARY KEY, admin BOOLEAN DEFAULT false);
    CREATE TABLE articles(id INTEGER PRIMARY KEY, owner_id INTEGER, secrecy_level INTEGER, content VARCHAR(255));

    ruby test.rb

# Output

```
$ ruby test.rb
Nothing happens
Hello World
Heimdallr::PermissionError is raised
Heimdallr::PermissionError is raised

#<Heimdallr::Proxy::Record:0x007fdb7533cb58>
#<Heimdallr::Proxy::Record:0x007fdb7534b1a8>
#<Heimdallr::Proxy::Record:0x007fdb753572a0>
ActiveRecord::RecordNotFound is raised
```
