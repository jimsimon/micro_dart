part of micro_dart;

class BundleService {

  BundleService() {}

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
        String entryPointPath = join(fileSystemEntity.path, "main.dart");
        File entryPoint = new File.fromUri(new Uri.file(entryPointPath));
        if (entryPoint.existsSync()) {
          Bundle bundle = new Bundle();
          bundle.name = basename(fileSystemEntity.path);
          bundle.rootPath = fileSystemEntity.path;
          bundle.entryPointPath = entryPointPath;
          bundle.packageRootPath = join(fileSystemEntity.path, "packages");
          bundles[bundle.name] = bundle;
        }
      }
    }
    return bundles;
  }

  Future startBundles(List<Bundle> bundles) {
    List<Future> bundleFutures = new List();
    bundles.forEach((bundle) {
      bundleFutures.add(_startBundle(bundle));
    });

    return Future.wait(bundleFutures);
  }

  Future<Bundle> _startBundle(bundle) async {
    print("Starting bundle: ${bundle.name}");
    Isolate isolate = await Isolate.spawnUri(new Uri.file(bundle.entryPointPath), null, null, paused: true, packageRoot: new Uri.file(bundle.packageRootPath));
    ReceivePort exitReceivePort = new ReceivePort();
    ReceivePort errorReceivePort = new ReceivePort();

    exitReceivePort.listen((message){
      if (message == null) {
        print("Bundle exited: ${bundle.name}");
        bundle.status = BundleStatus.STOPPED;
        errorReceivePort.close();
        exitReceivePort.close();
      }
    });
    isolate.addOnExitListener(exitReceivePort.sendPort);

    errorReceivePort.listen((message){
      if (message == null) {
        print("Bundle errored: ${bundle.name}");
        bundle.status = BundleStatus.STOPPED;
      }
    });
    isolate.addErrorListener(errorReceivePort.sendPort);

    bundle.status = BundleStatus.STARTED;
    isolate.resume(isolate.pauseCapability);
    bundle.isolate = isolate;
    return bundle;
  }

  void stopBundles(List<Bundle> bundles) {
    bundles.forEach((bundle) {
      if (bundle.status == BundleStatus.STARTED) {
        print("Stopping bundle: ${bundle.name}");
        bundle.isolate.kill(Isolate.IMMEDIATE);
        bundle.isolate = null;
        bundle.status = BundleStatus.STOPPED;
      } else if (bundle.status == BundleStatus.STOPPED) {
        print("Bundle not running: ${bundle.name}");
      }
    });
  }
}

class Bundle {
  String name, rootPath, entryPointPath, packageRootPath;
  BundleStatus status = BundleStatus.STOPPED;
  Isolate isolate;
}

enum BundleStatus {
  STOPPED, STARTED
}