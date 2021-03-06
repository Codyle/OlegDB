OlegDB
============

[![Build Status](https://travis-ci.org/infoforcefeed/OlegDB.svg?branch=master)](https://travis-ci.org/infoforcefeed/OlegDB)
![OlegDB MAYO](http://b.repl.ca/v1/OlegDB-MAYO-brightgreen.png)
[![Scan Status](https://scan.coverity.com/projects/1414/badge.svg)](https://scan.coverity.com/projects/1414)

Alternate title: "How far can we push a mayonnaise metaphor?"

````
$ pgrep olegdb | xargs kill
olegdb: No.
````

OlegDB is a ~~single-threaded, non-concurrent~~, transactionless NoSQL database
written by bitter SQL-lovers in a futile attempt to hop on the schemaless trend
before everyone realizes it was a bad move. It is primarily a C library with an
Erlang frontend for communication.

Dependencies
============

* A healthy fear of the end
* Erlang

Installation
============

OlegDB consists of a server written in Erlang and a C library for all of the
heavy lifting. Binaries are in `build/bin/` and the library is in `build/lib/`.
Beam files are also thrown in `build/bin/`.

Currently builds are tested against gcc and clang.

```bash
# Building everything:
make
# Just the erlang beam files:
make server
# Just the C library:
make liboleg
# Install
sudo make install
```

To run tests:

```bash
./run_tests.sh
```

To run the erlang server:

```bash
olegdb <db_location>
```

You can optionally specify a port, host or both. But not just a host.

```bash
olegdb <db_location> [[host] port]
```

curl2sudo® install script coming soon.

Documentation
=============

Documentation exists primarily on the [the website](https://olegdb.org/documentation.html).

Roadmap
=======

0.1
---

* Persistence
* Speaks HTTP with a heavy accent
* 250 byte hard keysize limit
* Working database
* Non-guaranteed record expiry

0.2
---
* Splay Trees for key iteration and introspection
* pub/sub or general evented framework
* Lists/Queues
* Speak Redis/Memcached protocol subsets

0.3
---
* SPDY Protocol

1.0
---

* Distributed fault-tolerant store

2.0
---
* BSP Export
