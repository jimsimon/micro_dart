part of micro_dart;

class BundleProxy {
  HttpServer server;
  BundleManager bundleManager;

  BundleProxy(BundleManager this.bundleManager);

  start() async {
    var pipeline = const shelf.Pipeline().addMiddleware(shelf.logRequests());
    var myRouter = router();

    bundleManager._bundles.forEach((name, bundle) {
      int port = bundle.port;
      var proxy = proxyHandler("http://localhost:$port");
      myRouter.add("/$name", ["POST", "GET", "PUT", "DELETE", "OPTIONS", "PATCH"], proxy, exactMatch: false);
    });
    var handler = pipeline.addHandler(myRouter.handler);
    server = await io.serve(handler, InternetAddress.LOOPBACK_IP_V4.address, 8080);
    print("Listening on port 80");
  }

  stop() async {
    await server.close(force: true);
  }
}