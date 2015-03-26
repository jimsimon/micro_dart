# micro_dart

A microservices runtime for Dart.

IDEAS
=======
*Allow bundles to use each other OSGI style (not high priority)
*Determine a free port for each bundle to use for IO purposes and pass it to the bundle on startup.  Maybe proxy traffic to the correct bundle automatically?
Example:
BundleA gets port 8080 and starts a web server
micro_dart listens to port 80 and redirects any http calls from /BundleA to BundleA's root url on port 8080
*Provide logging mechanism to standardize log file location?  (maybe not useful, not sure)
*Watch for changes to the bundles folder and automatically load new bundles.  If a zip/tar/tgz is dropped into the bundles folder, it should be extracted/expanded before starting.
