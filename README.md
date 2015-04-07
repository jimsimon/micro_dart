# micro_dart

A microservices runtime for Dart.

IDEAS
=======
* Allow bundles to use each other OSGI style (not high priority -- maybe not possible?)
* Determine a free port for each bundle to use for IO purposes and pass it to the bundle on startup (DONE).  Maybe proxy traffic to the correct bundle automatically? (not done yet)
* Provide logging mechanism to standardize log file location?  (maybe not useful, not sure)
* Watch for changes to the bundles folder and automatically load new bundles.  If a zip/tar/tgz is dropped into the bundles folder, it should be extracted/expanded before starting.
* Allow for bundle install from URL (support zip, tar, tar.gz, and tgz -- see managed_mongo for how to do this)
* Allow for two different versions of the same bundle to be installed and independently proxied (ex: bundleA/1.0.0 and bundleA/1.1.0) -- pull version from pubspec.yaml?
* Add management REST API and UI