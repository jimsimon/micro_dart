part of micro_dart;

class BundleProxy {
  HttpServer server;
  Router proxyRouter;
  Map<String, shelf.Handler> proxyHandlers = new Map();

  static Future<BundleProxy> getInstance({int port: 8080}) async {
    BundleProxy proxy = new BundleProxy._internal();
    await proxy.start(port: port);
    return proxy;
  }

  BundleProxy._internal();

  Future start({int port: 8080}) async {
    proxyRouter = router();
    var handler = const shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(_bundleHandler);
    server = await io.serve(handler, InternetAddress.LOOPBACK_IP_V4.address, port);
  }

  addProxies(Map<String, Bundle> bundles) {
    bundles.forEach((name, bundle){
      var proxy = proxyHandler("http://localhost:${bundle.port}");
      proxyHandlers[bundle.name] = proxy;
    });
  }

  removeProxies(Map<String, Bundle> bundles) {
    bundles.forEach((name, bundle){
      proxyHandlers.remove(name);
    });
  }

  Future stop() async {
    proxyHandlers.clear();
    await server.close(force: true);
  }

  _bundleHandler(shelf.Request request) {
    List<String> segments = request.url.pathSegments;
    if (segments == null || segments.isEmpty) {
      return new shelf.Response.notFound(null);
    }

    String proxyRoot = segments.first;
    shelf.Handler proxyHandler = proxyHandlers[proxyRoot];
    if (proxyHandler == null) {
      return new shelf.Response.notFound(null);
    }

    return proxyHandler(request);
  }
}