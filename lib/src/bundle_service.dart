part of micro_dart;

class BundleService {

  Uri bundleRoot;

  BundleService(Uri this.bundleRoot);

  Map<String, Bundle> discoverBundles() {
    Map<String, Bundle> bundles = new Map();
    Directory directory = new Directory.fromUri(bundleRoot);
    directory.listSync().forEach((FileSystemEntity fileSystemEntity) {
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
    });
    return bundles;
  }

  void startBundles(List<Bundle> bundles) {
    bundles.forEach((bundle) async {
      print("Starting bundle: ${bundle.name}");
      Isolate isolate = await Isolate.spawnUri(new Uri.file(bundle.entryPointPath), null, null, paused: true, packageRoot: new Uri.file(bundle.packageRootPath));
      bundle.status = "paused";
      ReceivePort receivePort = new ReceivePort();
      receivePort.listen((message){
        if (message == null) {
          print("Bundle exited: ${bundle.name}");
          bundle.status = "stopped";
        }
      });
      isolate.addOnExitListener(receivePort.sendPort);
      isolate.resume(isolate.pauseCapability);
      bundle.isolate = isolate;
    });
  }

  void stopBundles(List<Bundle> bundles) {
    bundles.forEach((bundle) {
      if (bundle.status == "running") {
        print("Stopping bundle: ${bundle.name}");
        bundle.isolate.kill();
      } else if (bundle.status == "stopped") {
        print("Bundle not running: ${bundle.name}");
      }
    });
  }
}

class Bundle {
  String name, rootPath, entryPointPath, packageRootPath, status = "stopped";
  Isolate isolate;
}