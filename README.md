heimdallr_testing
=================

testing how [heimdallr](https://github.com/roundlake/heimdallr) performs on scope fetches

    sqlite3 development.sqlite3

    CREATE TABLE users(id INTEGER PRIMARY KEY, admin BOOLEAN DEFAULT false);
    CREATE TABLE articles(id INTEGER PRIMARY KEY, owner_id INTEGER, secrecy_level INTEGER, content VARCHAR(255));
