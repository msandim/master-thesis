ELKI Data Mining Toolkit
========================

You can find additional information on ELKI at:
[http://elki.dbs.ifi.lmu.de/](http://elki.dbs.ifi.lmu.de/)

Citing ELKI
-----------

ELKI is an academic project. We appreciate citations using the latest
ELKI publication. This is release 0.7.1, which should be cited as

```
@article{DBLP:journals/pvldb/SchubertKEZSZ15,
  author    = {Erich Schubert and
               Alexander Koos and
               Tobias Emrich and
               Andreas Z{\"{u}}fle and
               Klaus Arthur Schmid and
               Arthur Zimek},
  title     = {A Framework for Clustering Uncertain Data},
  journal   = {{PVLDB}},
  volume    = {8},
  number    = {12},
  pages     = {1976--1979},
  year      = {2015},
  url       = {http://www.vldb.org/pvldb/vol8/p1976-schubert.pdf}
}
```

Launching ELKI
--------------

To launch ELKI, make sure you have at least Java 7 installed.

* On Windows, run `elki.bat`
* On Linux, run `elki.sh`
* On OSX, run `elki.sh`

If these scripts do not work for you (it is hard to predict how your
computer is configured), please set up your class path manually.
It may be necessary to launch from command line to see error messages.

You need to have the `.jar` files in both the `elki` and the `dependency`
folder on your class path, or you can try the `elki-bundle` single-jar
downloadable on the home page.

Developing ELKI
---------------

ELKI is an open-source project, which welcomes contributions and add-ons.

The folders `javadoc` and `sources` can be used with IDEs such as Eclipse
to have easy access to the documentation and source code. Because the
`pom.xml` files are not included in these jars, they cannot be automatically
recompiled (please get the source package instead).

You can find more information on the homepage:
[http://elki.dbs.ifi.lmu.de/](http://elki.dbs.ifi.lmu.de/)

You can also find the project on GitHub:
[http://github.com/elki-project/elki](http://github.com/elki-project/elki)


Add-ons for ELKI
----------------

Add-ons for ELKI such as the ph-tree add-on can (usually) be installed by
putting the `.jar` files in the `elki` or `dependency` folders.

ELKI will find new implementations if the `.jar` contains a file named
`META-INF/elki/<interfacename>` for the implemented interfaces, listing
the new classes and aliases. Additionally, folders (but not `.jar`s) on
the class path will be scanned for new implementations.
