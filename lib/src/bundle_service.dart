part of micro_dart;

class _BundleService {

  final Logger _log = new Logger("BundleService");

  Future<Map<String, Bundle>> discoverBundles(Directory bundleDirectory) async {
    if (bundleDirectory == null) {
      throw new ArgumentError.notNull("bundleDirectory");
    }
    if (!bundleDirectory.existsSync()) {
      throw new ArgumentError("Directory does not exist: $bundleDirectory");
    }

    Map<String, Bundle> bundles = new Map();
    await for (FileSystemEntity fileSystemEntity in bundleDirectory.list()) {
      if (fileSystemEntity is Directory) {
        String rootPath = fileSystemEntity.absolute.path;
        String entryPointPath = join(rootPath, "main.dart");
        File entryPoint = new File.fromUri(new Uri.file(entryPointPath));
        if (entryPoint.existsSync()) {
          Bundle bundle = new Bundle();
          bundle.name = basename(fileSystemEntity.path);
          bundle.rootPath = rootPath;
          bundle.entryPointPath = entryPointPath;
          bundle.packageRootPath = join(rootPath, "packages");
          bundles[bundle.name] = bundle;
        }
      }
    }
    return bundles;
  }

  Future startBundles(Map<String, Bundle> bundles) {
    List<Future> bundleFutures = new List();
    bundles.forEach((name, bundle) {
      bundleFutures.add(startBundle(bundle));
    });

    return Future.wait(bundleFutures);
  }

  Future<Bundle> startBundle(bundle) async {
    _log.info("Starting bundle: ${bundle.name}");
    int port = await _getFreePort();
    _log.info("Assigning port $port to ${bundle.name}");
    Isolate isolate = await Isolate.spawnUri(new Uri.file(bundle.entryPointPath), [port], null, paused: true, packageRoot: new Uri.file(bundle.packageRootPath));
    bundle.port = port;
    ReceivePort exitReceivePort = new ReceivePort();
    ReceivePort errorReceivePort = new ReceivePort();

    exitReceivePort.listen((message){
      if (message == null) {
        _log.info("Bundle exited: ${bundle.name}");
        bundle.status = BundleStatus.STOPPED;
        errorReceivePort.close();
        exitReceivePort.close();
      }
    });
    isolate.addOnExitListener(exitReceivePort.sendPort);

    errorReceivePort.listen((message){
      if (message == null) {
        _log.info("Bundle errored: ${bundle.name}");
        bundle.status = BundleStatus.STOPPED;
      }
    });
    isolate.addErrorListener(errorReceivePort.sendPort);

    bundle.status = BundleStatus.RUNNING;
    isolate.resume(isolate.pauseCapability);
    bundle.isolate = isolate;
    return bundle;
  }

  Future<int> _getFreePort() async {
    int port = null;
    HttpServer server = await HttpServer.bind(InternetAddress.ANY_IP_V4, 0);
    port = server.port;
    await server.close(force: true);
    return port;
  }

  stopBundle(Bundle bundle) {
    if (bundle.status == BundleStatus.RUNNING) {
      _log.info("Stopping bundle: ${bundle.name}");
      bundle.isolate.kill(Isolate.IMMEDIATE);
      bundle.status = BundleStatus.STOPPED;
    } else if (bundle.status == BundleStatus.STOPPED) {
      _log.info("Bundle not running: ${bundle.name}");
    }
    bundle.isolate = null;
  }

  void stopBundles(Map<String, Bundle> bundles) {
    bundles.forEach((name, bundle) {
      stopBundle(bundle);
    });
  }
}

class Bundle {
  String name, rootPath, entryPointPath, packageRootPath;
  BundleStatus status = BundleStatus.STOPPED;
  Isolate isolate;
  int port;
}

enum BundleStatus {
  STOPPED, RUNNING
}